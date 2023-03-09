*THESIS CODE - ANALYSIS - MICHELE GIUNTI
clear
cd "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Thesis Workshop V2\Thesis_code\Data\Analysis"
use "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Thesis Workshop V2\Thesis_code\Data\Analysis\03_GSS_ANES_merge.dta" 

*Note: This code uses tabout v3. To install, visit https://tabout.net.au/docs/home.php

*PART 1: Relabel Variables

label variable happy "General Happiness"
label variable marcohab "Cohabitation Status"
label variable marital "Marital Status"
label variable rincome "Respondent's Income"
label variable socbar "How Frequently Spend Evening at Bar"
label variable socfrend "How Frequently Spend Evening with Friends"
label variable socommun "How Frequently Spend Evening with Neighbors"
label variable socrel "How Frequently Spend Evening with Relatives"
label variable wwwhr "Internet Access Hours per Week"
label variable intcntct "How Frequently Use Online Communication"
label variable partpartonline "Online Political Participation (12 Months)"
label variable partpartoffline "Offline Political Participation (12 Months)"
label variable partvol "Volunteering Participation (12 Months)"
label variable region4 "Region of Interview"
label variable attend4 "Frequency of Religious Attendance"
label variable cohesion "Cohesion Index"
label variable race "Race of Respondent"
label variable occ10STEM "Census Occupation (STEM or Non-STEM)"

label define anes_satisfaction 1 "Very Happy" 2 "Pretty Happy" 3 "Not Too Happy", replace
label define happy 1 "Very Happy" 2 "Pretty Happy" 3 "Not Too Happy", replace

*PART 2: Set the survey set and panel data, and inspect data
svyset [pweight=anes_pweight], strata(anes_strata) psu(anes_vpsu) singleunit(scaled)
xtset anesid year
sum health happy cohesion lonely

*PART 3: Standardize missing
foreach var of varlist * {
	replace `var' = . if missing(`var')
}

*PART 4: Visualize if effects vary
foreach var of varlist happy health cohesion lonely wwwhr intcntct partpartonline partpartoffline partvol marcohab occ23cat {
	display "`var'"
	qui bysort anesid (`var') : gen changed = `var'[_N] != `var'[1]
	qui bysort anesid (year) : gen profile = 10 * `var'[1] + `var'[2]
	qui egen tag = tag(anesid)
	tab changed if tag
	tab profile if tag, sort
	drop changed profile tag
}

*PART 5: Verify if time effects are needed
svy: xtmlogit happy ib2.lonely intcntct partpartonline cohesion partvol marcohab occ10STEM attend i.year, fe
testparm i.year
scalar F_time_FE = r(F)
scalar p_time_FE = r(p)

svy: xtmlogit happy ib2.lonely intcntct partpartonline cohesion partvol marcohab occ10STEM attend i.year
testparm i.year
scalar F_time_RE = r(F)
scalar p_time_RE = r(p)


*PART 6: Hausman Test
xtmlogit happy ib2.lonely intcntct partpartonline cohesion partvol marcohab occ10STEM attend i.year, fe
estimates store fixed

xtmlogit happy ib2.lonely intcntct partpartonline cohesion partvol marcohab occ10STEM attend i.year
estimates store random

hausman fixed random, alleqs
scalar chi_haus = r(chi2)
scalar p_haus = r(p)

matrix A = (chi_haus\p_haus)
matrix rownames A = Hausman_chi2 Hausman_p
matrix colnames A = Values
esttab matrix(A), nomtitles


*PART 7: Fixed Effects models
svy: xtmlogit happy ib2.lonely intcntct partpartonline cohesion partvol marcohab occ10STEM attend i.year, fe

generate fe_include = (e(sample) == 1)

qui svy: xtmlogit happy ib2.lonely if fe_include == 1, fe
estimates store base_happy_fe
estadd scalar chi_haus = chi_haus
estadd scalar p_haus = p_haus
estadd scalar F_time = F_time_FE
estadd scalar p_time = p_time_FE

qui svy: xtmlogit happy ib2.lonely i.year if fe_include == 1, fe
estimates store base_happy_dummy_fe

qui svy: xtmlogit happy ib2.lonely intcntct partpartoffline cohesion i.year if fe_include == 1, fe
estimates store offline_happy_fe

qui svy: xtmlogit happy ib2.lonely intcntct partpartoffline cohesion partvol marcohab occ10STEM attend i.year if fe_include == 1, fe
estimates store offline_happy_control_fe


qui svy: xtmlogit happy ib2.lonely intcntct partpartonline cohesion i.year if fe_include == 1, fe
estimates store online_happy_fe

qui svy: xtmlogit happy ib2.lonely intcntct partpartonline cohesion partvol marcohab occ10STEM attend i.year if fe_include == 1, fe
estimates store online_happy_control_fe


*PART 8: Random Effects Models
svy: xtmlogit happy ib2.lonely intcntct partpartonline cohesion partvol marcohab occ10STEM attend i.year

generate re_include = (e(sample) == 1)

qui svy: xtmlogit happy ib2.lonely if re_include == 1
estimates store base_happy_re
estadd scalar F_time = F_time_RE
estadd scalar p_time = p_time_RE

qui svy: xtmlogit happy ib2.lonely i.year if re_include == 1
estimates store base_happy_dummy_re

qui svy: xtmlogit happy ib2.lonely intcntct partpartoffline cohesion i.year if re_include == 1
estimates store offline_happy_re

qui svy: xtmlogit happy ib2.lonely intcntct partpartoffline cohesion partvol marcohab occ10STEM attend i.year if re_include == 1
estimates store offline_happy_control_re

qui svy: xtmlogit happy ib2.lonely intcntct partpartonline cohesion i.year if re_include == 1
estimates store online_happy_re

qui svy: xtmlogit happy ib2.lonely intcntct partpartonline cohesion partvol marcohab occ10STEM attend i.year if re_include == 1
estimates store online_happy_control_re

*PART 9: Survey Data Descriptives Fixed Effects

tabout lonely happy intcntct year using DescriptiveFE.tex if fe_include == 1, replace style(tex) font(bold) twidth(12) c(col) bt svy f(3) npos(col) dropc(4) h1(Year) h2c(2 2 1) ptotal(none) nlab(Total) title(Table 1: Descriptive Statistics of Survey Participants (Fixed Effects)) fn(\textbf{Note:} Cell numbers indicate the proportion of participants per category per year, while the \emph{total} column indicates the total number of participants within each category across both years. These variables are used as the main regressors in the model.)


tabout agecat race region4 attend4 using DemographicFE.tex if fe_include == 1, replace style(tex) font(bold) twidth(10) c(col se) f(1p 2) mult(100) h1(Stratified Sample) bt oneway svy ptotal(none) noobs title(Table 2: Demographic Statistics of Survey Participants (Fixed Effects)) fn(\textbf{Note:} These numbers reflect the participants that were used in the regression sample, and did not drop due to either missingness or lack of variance across survey years.)

tabout cohesion partpartoffline partpartonline occ10STEM year using TechFE.tex if fe_include == 1, replace style(tex) font(bold) twidth(12) c(col) bt svy f(3) npos(col) dropc(4) h1(Year) h2c(2 2 1) ptotal(none) nlab(Total) title(Table 3: Behavioral Descriptives of Survey Participants (Fixed Effects)) fn(\textbf{Note:} Cell numbers indicate the proportion of participants per category per year, while the \emph{total} column indicates the total number of participants within each category across both years. It is assumed that these variables will mediate the effect of our main regressors on happiness.)

*PART 10: Table with main effect, RE and FE

esttab base_happy_fe base_happy_dummy_fe base_happy_re base_happy_dummy_re using TimeEffectREFE.tex, replace booktabs b(3) se(2) coeflabels(1.lonely "Low Loneliness" 3.lonely "High Loneliness" 2.year "Year") varwidth(30) modelwidth(5) legend nobaselevels noomitted unstack lines compress nogaps title("\textbf{Comparison of Fixed and Random Effects Loneliness Models} \strut" \label{tab1}) mgroups("Fixed Effects" "Random Effects", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nomtitles eqlabels("Happy" "Unhappy") nonumber addnote("\textbf{Note:} the results provided here indicate the need for a time effect control to be utilized with the main model." "In addition, the Hausman test shows that the Fixed Effects model is the most appropriate design for the purpose of the provided data.") drop(var(u1) var(u3)) scalars("N_pop Individuals" "F F-Statistic" "p p-value" "à \hline \textbf{Hausman Test Results}" "chi_haus Hausman \chi^2" "p_haus Hausman p-value" "è \hline \textbf{Time Effect Test}" "F_time \texorpdfstring{F-value\textsubscript{time}}" "p_time \texorpdfstring{p-value\textsubscript{time}}") indicate("Time Effects = *.year") sfmt(%9.0fc %9.2fc %9.3fc %9.2fc %9.3fc) label

*PART 11: Offline vs. Online Fixed Effects

esttab offline_happy_fe online_happy_fe offline_happy_control_fe online_happy_control_fe using Online&OfflineFE.tex, replace booktabs b(3) se(2) refcat(1.lonely "\emph{Main Effects:}" intcntct "\emph{Engagement Effects:}" partvol "\emph{Controls:}", nolabel) coeflabels(1.lonely "\hspace{0.25cm} Low Loneliness" 3.lonely "\hspace{0.25cm} High Loneliness" intcntct "\hspace{0.25cm} Online Communication" partpartonline "\hspace{0.25cm} Online Engagement" cohesion "\hspace{0.25cm} Civic Identification" partpartoffline "\hspace{0.25cm} Offline Engagement" partvol "\hspace{0.25cm} Volunteering" marcohab "\hspace{0.25cm} Marriage Status" occ10STEM "\hspace{0.25cm} Online Workspace" attend "\hspace{0.25cm} Religious Activity" 2.year "Year") order(1.lonely 3.lonely intcntct cohesion partpartonline partpartoffline partvol marcohab occ10STEM attend 2.year) varwidth(30) modelwidth(5) legend nobaselevels noomitted unstack lines compress nogaps title("\textbf{Multinomial Logistic Model with Online and Offline Political Participation (Fixed Effects)} \strut"\label{tab2}) mgroups("Base" "Control", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("Offline" "Online" "Offline" "Online") eqlabels("Happy" "Unhappy") nonumber addnote("\textbf{Note:} the controls used in the table were included to offset their effect on Loneliness and Happiness" "Volunteering and working with online tools were included to eliminate bias in online communication and political engagement." "Religious Attendance was included to control for civic identification with the residential community.") scalars("N_pop Individuals" "F F-Statistic" "p p-value") indicate("Time Effects = *.year") sfmt(%9.0fc %9.2fc %9.4fc) label

*PART 12: Survey Data Descriptives Random Effects

tabout lonely happy intcntct year using DescriptiveRE.tex if re_include == 1, replace style(tex) font(bold) twidth(12) c(col) bt svy f(3) npos(col) dropc(4) h1(Year) h2c(2 2 1) ptotal(none) nlab(Total) title(Table A1: Descriptive Statistics of Survey Participants (Random Effects)) fn(\textbf{Note:} Cell numbers indicate the proportion of participants per category per year, while the \emph{total} column indicates the total number of participants within each category across both years. These variables are used as the main regressors in the model.)

tabout agecat race region4 attend4 using DemographicRE.tex if re_include == 1, replace style(tex) font(bold) twidth(10) c(col se) f(1p 2) mult(100) h1(Stratified Sample) bt oneway svy ptotal(none) noobs title(Table A2: Demographic Statistics of Survey Participants (Random Effects)) fn(\textbf{Note:} These numbers reflect the participants that were used in the regression sample, and did not drop due to either missingness or lack of variance across survey years.)

tabout cohesion partpartoffline partpartonline occ10STEM year using TechRE.tex if re_include == 1, replace style(tex) font(bold) twidth(12) c(col) bt svy f(3) npos(col) dropc(4) h1(Year) h2c(2 2 1) ptotal(none) nlab(Total) title(Table A3: Behavioral Descriptives of Survey Participants (Random Effects)) fn(\textbf{Note:} Cell numbers indicate the proportion of participants per category per year, while the \emph{total} column indicates the total number of participants within each category across both years. It is assumed that these variables will mediate the effect of our main regressors on happiness.)

*PART 13: Offline vs. Online Random Effects

esttab offline_happy_re online_happy_re offline_happy_control_re online_happy_control_re using Online&OfflineRE.tex, replace booktabs b(3) se(2) refcat(1.lonely "\emph{Main Effects:}" intcntct "\emph{Engagement Effects:}" partvol "\emph{Controls:}", nolabel) coeflabels(1.lonely "\hspace{0.25cm} Low Loneliness" 3.lonely "\hspace{0.25cm} High Loneliness" intcntct "\hspace{0.25cm} Online Communication" partpartonline "\hspace{0.25cm} Online Engagement" cohesion "\hspace{0.25cm} Civic Identification" partpartoffline "\hspace{0.25cm} Offline Engagement" partvol "\hspace{0.25cm} Volunteering" marcohab "\hspace{0.25cm} Marriage Status" occ10STEM "\hspace{0.25cm} Online Workspace" attend "\hspace{0.25cm} Religious Activity" 2.year "Year") order(1.lonely 3.lonely intcntct cohesion partpartonline partpartoffline partvol marcohab occ10STEM attend 2.year) varwidth(30) modelwidth(5) legend nobaselevels noomitted unstack lines compress nogaps title("\textbf{Multinomial Logistic Model with Online and Offline Political Participation (Random Effects)} \strut"\label{tab3}) mgroups("Base" "Control", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("Offline" "Online" "Offline" "Online") eqlabels("Happy" "Unhappy") nonumber addnote("\textbf{Note:} the controls used in the table were included to offset their effect on Loneliness and Happiness" "Volunteering and working with online tools were included to eliminate bias in online communication and political engagement." "Religious Attendance was included to control for civic identification with the residential community.") scalars("N_pop Individuals" "F F-Statistic" "p p-value") indicate("Time Effects = *.year") drop(var(u1) var(u3)) sfmt(%9.0fc %9.2fc %9.4fc) label

*PART 14: Relative Risk Ratio Analysis

**FE
svy: xtmlogit happy ib2.lonely i.intcntct i.partpartoffline ib3.cohesion partvol marcohab occ10STEM attend i.year if fe_include == 1, fe rrr
estimates store rrr_offline_fe

svy: xtmlogit happy ib2.lonely i.intcntct i.partpartonline ib3.cohesion partvol marcohab occ10STEM attend i.year if fe_include == 1, fe rrr
estimates store rrr_online_fe

esttab rrr_offline_fe rrr_online_fe using RRRFE.tex, replace style(tex) eform booktabs varwidth(30) modelwidth(10) legend nobaselevels noomitted unstack lines compress nogaps b(3) se(2) noomitted drop(partvol marcohab occ10STEM attend 2.year) order(1.lonely 3.lonely 1.intcntct 1.partpartoffline 1.partpartonline 1.cohesion 2.cohesion 4.cohesion) refcat(1.lonely "\textbf{Loneliness}" 1.intcntct "\textbf{Online Communication}" 1.partpartoffline "\textbf{Offline Engagement}" 1.partpartonline "\textbf{Online Engagement}" 1.cohesion "\textbf{Civic Identification}", nolabel) coeflabels(1.lonely "\hspace{0.25cm} Low Loneliness" 3.lonely "\hspace{0.25cm} High Loneliness" 1.intcntct "\hspace{0.25cm} High Online Presence" 1.partpartoffline "\hspace{0.25cm} Participated" 1.partpartonline "\hspace{0.25cm} Participated" 1.cohesion "\hspace{0.25cm} Low Identification" 2.cohesion "\hspace{0.25cm} Low-Medium Identification" 4.cohesion "\hspace{0.25cm} High Identification") mtitles("Offline" "Online" "Offline" "Online") eqlabels("Happy" "Unhappy") title("\textbf{Relative Risk Ratios for Fixed Effects (Main Regressors)} \strut"\label{tab4}) nonumber addnote("\textbf{Note:} only statistically significant variables were included in this table." "Significance levels reflect the results of the non-transformed regression.") label


**RE
svy: xtmlogit happy ib2.lonely i.intcntct i.partpartoffline ib3.cohesion partvol i.marcohab occ10STEM attend i.year if re_include == 1, rrr
estimates store rrr_offline_re

svy: xtmlogit happy ib2.lonely i.intcntct i.partpartonline ib3.cohesion partvol i.marcohab occ10STEM attend i.year if re_include == 1, rrr
estimates store rrr_online_re

esttab rrr_offline_re rrr_online_re using RRRRE.tex, replace style(tex) eform booktabs varwidth(30) modelwidth(10) legend nobaselevels noomitted unstack lines compress nogaps b(3) se(2) noomitted drop(partvol occ10STEM attend 2.year var(u1) var(u3) _cons) order(1.lonely 3.lonely 1.intcntct 1.partpartoffline 1.partpartonline 1.cohesion 2.cohesion 4.cohesion 2.marcohab 3.marcohab) refcat(1.lonely "\textbf{Loneliness}" 1.intcntct "\textbf{Online Communication}" 1.partpartoffline "\textbf{Offline Engagement}" 1.partpartonline "\textbf{Online Engagement}" 1.cohesion "\textbf{Civic Identification}" 2.marcohab "\textbf{Marriage and Cohabitation}", nolabel) coeflabels(1.lonely "\hspace{0.25cm} Low Loneliness" 3.lonely "\hspace{0.25cm} High Loneliness" 1.intcntct "\hspace{0.25cm} High Online Presence" 1.partpartoffline "\hspace{0.25cm} Participated" 1.partpartonline "\hspace{0.25cm} Participated" 1.cohesion "\hspace{0.25cm} Low Identification" 2.cohesion "\hspace{0.25cm} Low-Medium Identification" 4.cohesion "\hspace{0.25cm} High Identification" 2.marcohab "\hspace{0.25cm} Not Married, Cohabitation" 3.marcohab "\hspace{0.25cm} Not Married, No Cohabitation" ) mtitles("Offline" "Online" "Offline" "Online") eqlabels("Happy" "Unhappy") title("\textbf{Relative Risk Ratios for Random Effects (Main Regressors)} \strut"\label{tab5}) nonumber addnote("\textbf{Note:} the cohabitation variable and any other statistically significant regressor was added to the table." "Significance levels reflect the results of the non-transformed regression.") label



*PART 15: Alternative happiness
**PART 15.1: Creating and Checking the correlation

gen happy2_2018 = happy if year == 1
gen happy2_2020 = anes_satisfaction if year == 2
replace happy2_2020 = happy2_2018 if year == 1
drop happy2_2018

rename happy2_2020 happy2
label values happy2 happy
label variable happy2 "General Happiness (Post-Election)"

correlate happy happy2 lonely health, cov
matrix B = r(C)
esttab matrix(B) using corr_hap_health.tex, replace style(tex) varwidth(50) modelwidth(10) booktabs nonumber label unstack compress nonote nomtitles collabels("Happiness" "Happiness (Post-Election)" "Loneliness Scale" "Health") coeflabels(happy "Happiness" happy2 "Happiness (Post-Election)" lonely "Loneliness Scale" health "Health") title("\textbf{Covariance and Correlation Table for Happiness, Loneliness, and Health} \strut" \label{tab6})


estpost correlate happy happy2 lonely health, matrix listwise
esttab using corr_hap_health.tex, append style(tex) varwidth(50) modelwidth(10) booktabs nonumber label unstack compress nomtitles coeflabels(happy "Happiness" happy2 "Happiness (Post-Election)" lonely "Loneliness" health "Health") eqlabels("Happiness" "Happiness (Post-Election)" "Loneliness Scale" "Health") addnote("\textbf{Note:} the first table is the covariance matrix for the variables in question." "The correlation estimates (table 2) indicate that the happiness variables can be used interchageably." "The correlation significance of the variable \emph{health} also confirms the relationship described in the literature review.")

**PART 15.2: Recreating the time effect test

svy: xtmlogit happy2 ib2.lonely intcntct partpartonline cohesion partvol marcohab occ10STEM attend i.year, fe
generate fe2_include = (e(sample) == 1)

testparm i.year
scalar F2_time_FE = r(F)
scalar p2_time_FE = r(p)

**PART 15.3: Checking for differences with the first happiness variable

qui svy: xtmlogit happy ib2.lonely if fe_include == 1, fe

qui svy: xtmlogit happy2 ib2.lonely if fe2_include == 1, fe
estimates store base_happy2_fe

qui svy: xtmlogit happy ib2.lonely i.year if fe_include == 1, fe

qui svy: xtmlogit happy2 ib2.lonely i.year if fe2_include == 1, fe
estimates store base_happy2_dummy_fe

esttab base_happy_fe base_happy_dummy_fe base_happy2_fe base_happy2_dummy_fe using TimeEffectHappy.tex, replace booktabs b(3) se(2) coeflabels(1.lonely "Low Loneliness" 3.lonely "High Loneliness" 2.year "Year") varwidth(30) modelwidth(5) legend nobaselevels noomitted unstack lines compress nogaps title("\textbf{Comparison of Pre-Election to Post-Election Loneliness Models} \strut" \label{tab7}) mgroups("Before Election" "After Election", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nomtitles eqlabels("Happy" "Unhappy") nonumber addnote("\textbf{Note:} the results provided here indicate the need for a time effect control to be utilized with the main model." "No significant differences can be seen between the Happiness Variables, but certain relationships may have changed") scalars("N_pop Individuals" "F F-Statistic" "p p-value" "è \hline \textbf{Time Effect Test}" "F_time \texorpdfstring{F-value\textsubscript{time}}" "p_time \texorpdfstring{p-value\textsubscript{time}}") indicate("Time Effects = *.year") sfmt(%9.0fc %9.2fc %9.3fc %9.2fc %9.3fc) label

**PART 15.4: Full Model Comparison

qui svy: xtmlogit happy ib2.lonely intcntct partpartonline cohesion partvol marcohab occ10STEM attend i.year if fe_include == 1, fe

qui svy: xtmlogit happy2 ib2.lonely intcntct partpartonline cohesion partvol marcohab occ10STEM attend i.year if fe2_include == 1, fe
estimates store online_happy2_control_fe

qui svy: xtmlogit happy ib2.lonely intcntct partpartoffline cohesion partvol marcohab occ10STEM attend i.year if fe_include == 1, fe

qui svy: xtmlogit happy2 ib2.lonely intcntct partpartoffline cohesion partvol marcohab occ10STEM attend i.year if fe2_include==1, fe
estimates store offline_happy2_control_fe

esttab offline_happy_control_fe online_happy_control_fe offline_happy2_control_fe  online_happy2_control_fe using Online&Offline2FE.tex, replace booktabs b(3) se(2) refcat(1.lonely "\emph{Main Effects:}" intcntct "\emph{Engagement Effects:}" partvol "\emph{Controls:}", nolabel) coeflabels(1.lonely "\hspace{0.25cm} Low Loneliness" 3.lonely "\hspace{0.25cm} High Loneliness" intcntct "\hspace{0.25cm} Online Communication" partpartonline "\hspace{0.25cm} Online Engagement" cohesion "\hspace{0.25cm} Civic Identification" partpartoffline "\hspace{0.25cm} Offline Engagement" partvol "\hspace{0.25cm} Volunteering" marcohab "\hspace{0.25cm} Marriage Status" occ10STEM "\hspace{0.25cm} Online Workspace" attend "\hspace{0.25cm} Religious Activity" 2.year "Year") order(1.lonely 3.lonely intcntct cohesion partpartonline partpartoffline partvol marcohab occ10STEM attend 2.year) varwidth(30) modelwidth(5) legend nobaselevels noomitted unstack lines compress nogaps title("\textbf{Online and Offline Loneliness Fixed Effects, Before and After the 2020 Election} \strut"\label{tab8}) mgroups("Before Election" "After Election", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("Offline" "Online" "Offline" "Online") eqlabels("Happy" "Unhappy") nonumber addnote("\textbf{Note:} some very interesting facts can be read from the table, mainly the changes in significance reported within." "As demonstrated by the correlation table, the small difference in observations does not imply a difference in individuals.") scalars("N_pop Individuals" "F F-Statistic" "p p-value") indicate("Time effects = *.year") sfmt(%9.0fc %9.2fc %9.4fc) label


**PART 15.5: Relative Risk Ratios

svy: xtmlogit happy2 ib2.lonely i.intcntct i.partpartonline ib3.cohesion partvol marcohab i.occ10STEM attend i.year if fe2_include == 1, fe rrr
estimate store rrr_online2_fe

svy: xtmlogit happy2 ib2.lonely i.intcntct i.partpartoffline ib3.cohesion partvol marcohab i.occ10STEM attend i.year if fe2_include == 1, fe rrr
estimate store rrr_offline2_fe

esttab rrr_offline2_fe rrr_online2_fe using RRRFE2.tex, replace style(tex) eform booktabs varwidth(30) modelwidth(10) legend nobaselevels noomitted unstack lines compress nogaps b(5) se(5) noomitted drop(partvol marcohab attend 2.year) order(1.lonely 3.lonely 1.intcntct 1.partpartoffline 1.partpartonline 1.cohesion 2.cohesion 4.cohesion) refcat(1.lonely "\textbf{Loneliness}" 1.intcntct "\textbf{Online Communication}" 1.partpartoffline "\textbf{Offline Engagement}" 1.partpartonline "\textbf{Online Engagement}" 1.cohesion "\textbf{Civic Identification}" 1.occ10STEM "\textbf{STEM or Non-STEM Occupation}", nolabel) coeflabels(1.lonely "\hspace{0.25cm} Low Loneliness" 3.lonely "\hspace{0.25cm} High Loneliness" 1.intcntct "\hspace{0.25cm} High Online Presence" 1.partpartoffline "\hspace{0.25cm} Participated" 1.partpartonline "\hspace{0.25cm} Participated" 1.cohesion "\hspace{0.25cm} Low Identification" 2.cohesion "\hspace{0.25cm} Low-Medium Identification" 4.cohesion "\hspace{0.25cm} High Identification" 1.occ10STEM "\hspace{0.25cm} STEM Census Occupation") mtitles("Offline" "Online" "Offline" "Online") eqlabels("Happy" "Unhappy") title("\textbf{Relative Risk Ratios for Post-Election Fixed Effects} \strut"\label{tab9}) nonumber addnote("\textbf{Note:} only statistically significant variables were included in this table." "Significance levels reflect the results of the non-transformed regression." "The occupational STEM variable has a high degree of significance, requiring its own formatting.") label


