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
label define marital 1 "Married" 2 "Widowed" 3 "Divorced" 4 "Separated" 5 "Never Married", replace

*PART 2: Set the survey set and panel data, and inspect data
svyset [pweight=anes_pweight], strata(anes_strata) psu(anes_vpsu) singleunit(scaled)
xtset anesid year
sum health happy cohesion lonely

gen cohesion4 = cohesion
recode cohesion (1 2 = 0) (3 4 = 1)
label define cohesion1 0 "Low Social Cohesion" 1 "High Social Cohesion"
label values cohesion cohesion1

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

*PART 5: Create Interaction Effects
gen cohesionlonely = cohesion*lonely
gen intcntctlonely = intcntct*lonely

*PART 6: Standardize sample size
qui svy: xtmlogit happy lonely intcntct ib2.intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year, fe
gen include_intcntct = (e(sample) == 1)

svy: xtmlogit happy ib2.lonely cohesion ib2.cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year, fe
gen include_cohesion = (e(sample) == 1)

tab include_cohesion include_intcntct

gen include_sample = 0
replace include_sample = 1 if include_cohesion == 1 & include_intcntct == 1


qui svy: xtmlogit happy lonely intcntct ib2.intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year
gen REinclude_intcntct = (e(sample) == 1)

svy: xtmlogit happy ib2.lonely cohesion ib2.cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year
gen REinclude_cohesion = (e(sample) == 1)

tab REinclude_cohesion include_intcntct

gen REinclude_sample = 0
replace REinclude_sample = 1 if REinclude_cohesion == 1 & REinclude_intcntct == 1


*PART 6: Verify if time effects are needed
qui svy: xtmlogit happy lonely intcntct intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample == 1, fe
testparm i.year
scalar F_time_intcntct = r(F)
scalar p_time_intcntct = r(p)

qui svy: xtmlogit happy lonely cohesion cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample == 1, fe
testparm i.year
scalar F_time_cohesion = r(F)
scalar p_time_cohesion = r(p)


*PART 7: Hausman Test

*Connectivity
qui xtmlogit happy lonely intcntct intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample == 1, fe
estimates store fixed_intcntct

qui xtmlogit happy lonely intcntct intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if REinclude_sample == 1
estimates store random_intcntct

hausman fixed_intcntct random_intcntct, alleq
scalar chi_haus_int = r(chi2)
scalar p_haus_int = r(p)

*Cohesion
qui xtmlogit happy lonely cohesion cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample == 1, fe
estimates store fixed_cohesion

qui xtmlogit happy lonely cohesion cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if REinclude_sample == 1
estimates store random_cohesion

hausman fixed_cohesion random_cohesion, alleq
scalar chi_haus_cohesion = r(chi2)
scalar p_haus_cohesion = r(p)

*PART 8: Models
*small correction**************************************************************************************************
qui svy: xtmlogit happy lonely intcntct intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample == 1, fe
scalar F_lonely = e(F)
scalar p_lonely = e(p)

qui svy: xtmlogit happy lonely cohesion cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample == 1, fe
scalar F_cohesion = e(F)
scalar p_cohesion = e(p)

svy: xtmlogit happy ib2.lonely cohesion ib2.cohesionlonely partpartoffline partpartonline if include_sample == 1, fe
scalar F_cohesion_base = e(F)
scalar p_cohesion_base = e(p)
*******************************************************************************************************************

svy: xtmlogit happy ib2.lonely cohesion ib2.cohesionlonely partpartoffline partpartonline if include_sample == 1, fe
estimates store model_cohesion_base
estadd scalar F = F_cohesion_base, replace
estadd scalar p = p_cohesion_base, replace

svy: xtmlogit happy ib2.lonely intcntct ib2.intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample == 1, fe
estimates store model_intcntct
estadd scalar chi_haus = chi_haus_int
estadd scalar p_haus = p_haus_int
estadd scalar F_time = F_time_intcntct
estadd scalar p_time = p_time_intcntct
estadd scalar F = F_lonely, replace
estadd scalar p = p_lonely, replace

svy: xtmlogit happy ib2.lonely cohesion ib2.cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample == 1, fe
estimates store model_cohesion
estadd scalar chi_haus = chi_haus_cohesion
estadd scalar p_haus = p_haus_cohesion
estadd scalar F_time = F_time_cohesion
estadd scalar p_time = p_time_cohesion
estadd scalar F = F_cohesion, replace
estadd scalar p = p_cohesion, replace

**********************************************************************************************************
svy: xtmlogit happy ib2.lonely if include_sample == 1, fe
estimates store lonely_base

svy: xtmlogit happy ib2.lonely i.year if include_sample == 1, fe
estimates store lonely_year

svy: xtmlogit happy ib2.lonely intcntct i.year if include_sample == 1, fe
estimates store lonely_intcntct

svy: xtmlogit happy ib2.lonely cohesion i.year if include_sample == 1, fe
estimates store lonely_cohesion

**********************************************************************************************************

*PART 9: Tables

*Part 9.1: Descriptives Cohesion
tabout lonely happy intcntct cohesion partpartoffline partpartonline occ10STEM year using CohesionDescriptives.tex if include_sample == 1, replace style(tex) font(bold) twidth(12) c(col) bt svy f(3) npos(col) dropc(4) h1(Year) h2c(2 2 1) ptotal(none) nlab(Total) title(Table 3: Descriptive Statistics of Model Dependent and Indipendent Variables (Fixed Effects)) fn(\textbf{Note:} Sample values are based on the total sample size after the controlled regression (N = 276). Cell numbers indicate the proportion of participants per category per year, while the \emph{total} column indicates the total number of participants within each category across both years. It is assumed that these variables will mediate the effect of our main regressors on happiness.)

*Part 9.2: Descriptives Demographics
tabout agecat race region4 attend4 marital using DemographicDescriptives.tex if include_sample == 1, replace style(tex) font(bold) twidth(10) c(col se) f(1p 2) mult(100) h1(Stratified Sample) bt oneway svy ptotal(none) noobs title(Table 1: Demographic Statistics of Survey Participants (Fixed Effects)) fn(\textbf{Note:} Sample values are based on the total sample size after the controlled regression (N = 276). These numbers reflect the participants that were used in the regression sample, and did not drop due to either missingness or lack of variance across survey years.)

*Part 9.3: Model Comparison

*v2
esttab model_intcntct model_cohesion model_cohesion_base using Model.tex, replace style(tex) booktabs b(3) se(2) varwidth(30) modelwidth(5) legend nobaselevels noomitted unstack lines compress nogaps nonumber order(intcntct 1.intcntctlonely 3.intcntctlonely cohesion 1.cohesionlonely 3.cohesionlonely 1.lonely 3.lonely partpartonline partpartoffline partvol marcohab occ10STEM attend 2.year) indicate("Time Effects = *.year") scalars("N_pop Individuals" "F F-Statistic" "p p-value" "à \hline \textbf{Hausman Test Results}" "chi_haus Hausman \chi^2" "p_haus Hausman p-value" "è \hline \textbf{Time Effect Test}" "F_time \texorpdfstring{F-value\textsubscript{time}}" "p_time \texorpdfstring{p-value\textsubscript{time}}") title("\textbf{Multinomial Logistic Models Connectivity Vs. Social Cohesion Proxy} \strut"\label{tab3}) refcat(intcntct "\textbf{Interaction Effects:}" 1.lonely "\midrule \textbf{Main Loneliness Effect:}" partvol "\textbf{Controls:}", nolabel) coeflabels(1.lonely "\hspace{0.25cm} Low Loneliness" 3.lonely "\hspace{0.25cm} High Loneliness" cohesion "\hspace{0.25cm} High Social Cohesion" intcntct "\hspace{0.25cm} High Online Communication" partpartonline "\hspace{0.25cm} Online Engagement" partpartoffline "\hspace{0.25cm} Offline Engagement" partvol "\hspace{0.25cm} Volunteering" marcohab "\hspace{0.25cm} Marriage Status" occ10STEM "\hspace{0.25cm} Online Workspace" attend "\hspace{0.25cm} Religious Activity" 2.year "Year" 1.intcntctlonely "\hspace{0.5cm} \emph{w/Low Loneliness}" 3.intcntctlonely "\hspace{0.5cm} \emph{w/High Loneliness}" 1.cohesionlonely "\hspace{0.5cm} \emph{w/Low Loneliness}" 3.cohesionlonely "\hspace{0.5cm} \emph{w/High Loneliness}") mgroups("w/Controls" "Base", pattern(1 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("\underline{Online Communication}" "\underline{Social Cohesion}" "\underline{Social Cohesion}") eqlabels("Happy" "Unhappy") sfmt(%9.0fc %9.2fc %9.3fc %9.2fc %9.3fc) star(^+ 0.10 * 0.05 ** 0.01) label addnote("\textbf{Note:} the sample population is composed of observations that did not drop when both full models were run." "As such, the same individuals are used across years, and the full effect of the interaction terms can be compared.")

*Part 9.3.1: Base Models

esttab lonely_base lonely_year lonely_intcntct lonely_cohesion using BaseEffects.tex, replace style(tex) booktabs b(3) se(2) varwidth(30) modelwidth(5) legend nobaselevels noomitted unstack lines compress nogaps nonumber order(1.lonely 3.lonely intcntct cohesion) indicate("Time Effects = *.year") scalars("N_pop Individuals" "F F-Statistic" "p p-value") title("\textbf{Multinomial Logistic Models: Base Relationships} \strut"\label{tabA1}) refcat(1.lonely "\midrule \textbf{Main Loneliness Effect:}" intcntct "\textbf{Suggested Indicators:}", nolabel) coeflabels(1.lonely "\hspace{0.25cm} Low Loneliness" 3.lonely "\hspace{0.25cm} High Loneliness" cohesion "\hspace{0.25cm} High Social Cohesion" intcntct "\hspace{0.25cm} High Online Communication") mgroups("Base Effects" "Indicator Effects", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("\underline{Base}" "\underline{Year Effect}" "\underline{Connectivity}" "\underline{Social Cohesion}") eqlabels("Happy" "Unhappy") sfmt(%9.0fc %9.2fc %9.3fc %9.2fc %9.3fc) star(^+ 0.10 * 0.05 ** 0.01) label

*Part 9.4: Relative Risk Ratio Table
qui svy: xtmlogit happy ib2.lonely intcntct ib2.intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample == 1, fe rrr
estimates store model_intcntct_rrr

qui svy: xtmlogit happy ib2.lonely cohesion ib2.cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample == 1, fe
estimates store model_cohesion_rrr

esttab model_intcntct_rrr model_cohesion_rrr using RRR1.tex, replace style(tex) eform booktabs varwidth(30) modelwidth(10) legend nobaselevels noomitted unstack lines compress nogaps b(%9.3g) not nose noomitted order(intcntct 1.intcntctlonely 3.intcntctlonely cohesion 1.cohesionlonely 3.cohesionlonely 1.lonely 3.lonely partpartonline partpartoffline partvol marcohab occ10STEM attend 2.year) scalars("N_pop Individuals") title("\textbf{Relative Risk Ratios (Base Happiness)} \strut"\label{tab4}) refcat(intcntct "\textbf{Interaction Effects:}" 1.lonely "\midrule \textbf{Main Loneliness Effect:}" partvol "\textbf{Controls:}", nolabel) coeflabels(1.lonely "\hspace{0.25cm} Low Loneliness" 3.lonely "\hspace{0.25cm} High Loneliness" cohesion "\hspace{0.25cm} High Social Cohesion" intcntct "\hspace{0.25cm} High Online Communication" partpartonline "\hspace{0.25cm} Online Engagement" partpartoffline "\hspace{0.25cm} Offline Engagement" partvol "\hspace{0.25cm} Volunteering" marcohab "\hspace{0.25cm} Marriage Status" occ10STEM "\hspace{0.25cm} Online Workspace" attend "\hspace{0.25cm} Religious Activity" 2.year "Year" 1.intcntctlonely "\hspace{0.5cm} \emph{w/Low Loneliness}" 3.intcntctlonely "\hspace{0.5cm} \emph{w/High Loneliness}" 1.cohesionlonely "\hspace{0.5cm} \emph{w/Low Loneliness}" 3.cohesionlonely "\hspace{0.5cm} \emph{w/High Loneliness}") mtitles("\underline{Online Communication}" "\underline{Social Cohesion}" "\underline{Social Cohesion}") eqlabels("Happy" "Unhappy") sfmt(%9.0fc %9.2fc %9.3fc %9.2fc %9.3fc) star(^+ 0.10 * 0.05 ** 0.01) label drop(2.year attend occ10STEM marcohab partvol)


*PART 10: Alternative Happiness
gen happy2_2018 = happy if year == 1
gen happy2_2020 = anes_satisfaction if year == 2
replace happy2_2020 = happy2_2018 if year == 1
drop happy2_2018

rename happy2_2020 happy2
label values happy2 happy
label variable happy2 "General Happiness (Post-Election)"

correlate happy happy2 lonely health, cov
matrix B = r(C)
esttab matrix(B) using corr_hap_health.tex, replace style(tex) varwidth(50) modelwidth(10) booktabs nonumber label unstack compress nonote nomtitles collabels("Happiness" "Happiness (Post-Election)" "Loneliness Scale" "Health") coeflabels(happy "Happiness" happy2 "Happiness (Post-Election)" lonely "Loneliness Scale" health "Health") title("\textbf{Covariance and Correlation Table for Happiness, Loneliness, and Health} \strut" \label{tabA2})


estpost correlate happy happy2 lonely health, matrix listwise
esttab using corr_hap_health.tex, append style(tex) varwidth(50) modelwidth(10) booktabs nonumber label unstack compress nomtitles coeflabels(happy "Happiness" happy2 "Happiness (Post-Election)" lonely "Loneliness" health "Health") eqlabels("Happiness" "Happiness (Post-Election)" "Loneliness Scale" "Health") addnote("\textbf{Note:} the first table is the covariance matrix for the variables in question." "The correlation estimates (table 2) indicate that the happiness variables can be used interchageably." "The correlation significance of the variable \emph{health} also confirms the relationship described in the literature review.")


*Part 10.1: Replicate Time Effect Test

qui svy: xtmlogit happy2 ib2.lonely intcntct intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year, fe
gen include_intcntct2 = (e(sample) == 1)

qui svy: xtmlogit happy2 ib2.lonely cohesion ib2.cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year, fe
gen include_cohesion2 = (e(sample) == 1)

tab include_cohesion2 include_intcntct2

gen include_sample2 = 0
replace include_sample2 = 1 if include_cohesion2 == 1 & include_intcntct2 == 1


qui svy: xtmlogit happy2 lonely intcntct intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample2 == 1, fe
testparm i.year
scalar F_time_intcntct2 = r(F)
scalar p_time_intcntct2 = r(p)

qui svy: xtmlogit happy2 lonely cohesion cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample2 == 1, fe
testparm i.year
scalar F_time_cohesion2 = r(F)
scalar p_time_cohesion2 = r(p)


*Part 10.2: Models
*small correction**************************************************************************************************
qui svy: xtmlogit happy2 lonely intcntct intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample2 == 1, fe
scalar F_lonely2 = e(F)
scalar p_lonely2 = e(p)

qui svy: xtmlogit happy2 lonely cohesion cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample2 == 1, fe
scalar F_cohesion2 = e(F)
scalar p_cohesion2 = e(p)

qui svy: xtmlogit happy2 lonely cohesion cohesionlonely partpartoffline partpartonline if include_sample2 == 1, fe
scalar F_cohesion_base2 = e(F)
scalar p_cohesion_base2 = e(p)
*******************************************************************************************************************
svy: xtmlogit happy2 ib2.lonely cohesion ib2.cohesionlonely partpartoffline partpartonline if include_sample2 == 1, fe
estimates store model_cohesion_base2
estadd scalar F = F_cohesion_base2, replace
estadd scalar p = p_cohesion_base2, replace

svy: xtmlogit happy2 ib2.lonely intcntct ib2.intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample2 == 1, fe
estimates store model_intcntct2
estadd scalar F_time = F_time_intcntct2
estadd scalar p_time = p_time_intcntct2
estadd scalar F = F_lonely2, replace
estadd scalar p = p_lonely2, replace

svy: xtmlogit happy2 ib2.lonely cohesion ib2.cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample2 == 1, fe
estimates store model_cohesion2
estadd scalar F_time = F_time_cohesion2
estadd scalar p_time = p_time_cohesion2
estadd scalar F = F_cohesion2, replace
estadd scalar p = p_cohesion2, replace

**********************************************************************************************************
svy: xtmlogit happy2 ib2.lonely if include_sample2 == 1, fe
estimates store lonely_base2

svy: xtmlogit happy2 ib2.lonely i.year if include_sample2 == 1, fe
estimates store lonely_year2

svy: xtmlogit happy2 ib2.lonely intcntct i.year if include_sample2 == 1, fe
estimates store lonely_intcntct2

svy: xtmlogit happy2 ib2.lonely cohesion i.year if include_sample2 == 1, fe
estimates store lonely_cohesion2

**********************************************************************************************************





*Part 10.3: Model Comparison

*v2
esttab model_intcntct2 model_cohesion2 model_cohesion_base2 using Modelv2.tex, replace style(tex) booktabs b(3) se(2) varwidth(30) modelwidth(5) legend nobaselevels noomitted unstack lines compress nogaps nonumber order(intcntct 1.intcntctlonely 3.intcntctlonely cohesion 1.cohesionlonely 3.cohesionlonely 1.lonely 3.lonely partpartonline partpartoffline partvol marcohab occ10STEM attend 2.year) indicate("Time Effects = *.year") scalars("N_pop Individuals" "F F-Statistic" "p p-value" "è \hline \textbf{Time Effect Test}" "F_time \texorpdfstring{F-value\textsubscript{time}}" "p_time \texorpdfstring{p-value\textsubscript{time}}") title("\textbf{Multinomial Logistic Models Connectivity Vs. Social Cohesion Proxy (Alternative Happiness)} \strut"\label{tab5}) refcat(intcntct "\textbf{Interaction Effects:}" 1.lonely "\midrule \textbf{Main Loneliness Effect:}" partvol "\textbf{Controls:}", nolabel) coeflabels(1.lonely "\hspace{0.25cm} Low Loneliness" 3.lonely "\hspace{0.25cm} High Loneliness" cohesion "\hspace{0.25cm} High Social Cohesion" intcntct "\hspace{0.25cm} High Online Communication" partpartonline "\hspace{0.25cm} Online Engagement" partpartoffline "\hspace{0.25cm} Offline Engagement" partvol "\hspace{0.25cm} Volunteering" marcohab "\hspace{0.25cm} Marriage Status" occ10STEM "\hspace{0.25cm} Online Workspace" attend "\hspace{0.25cm} Religious Activity" 2.year "Year" 1.intcntctlonely "\hspace{0.5cm} \emph{w/Low Loneliness}" 3.intcntctlonely "\hspace{0.5cm} \emph{w/High Loneliness}" 1.cohesionlonely "\hspace{0.5cm} \emph{w/Low Loneliness}" 3.cohesionlonely "\hspace{0.5cm} \emph{w/High Loneliness}") mgroups("w/Controls" "Base", pattern(1 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("\underline{Online Communication}" "\underline{Social Cohesion}" "\underline{Social Cohesion}") eqlabels("Happy" "Unhappy") sfmt(%9.0fc %9.2fc %9.3fc %9.2fc %9.3fc) star(^+ 0.10 * 0.05 ** 0.01) label addnote("\textbf{Note:} the sample population is composed of observations that did not drop when both full models were run." "As such, the same individuals are used across years, and the full effect of the interaction terms can be compared.")

*Part 10.3.1: Base Models

esttab lonely_base2 lonely_year2 lonely_intcntct2 lonely_cohesion2 using BaseEffects2.tex, replace style(tex) booktabs b(3) se(2) varwidth(30) modelwidth(5) legend nobaselevels noomitted unstack lines compress nogaps nonumber order(1.lonely 3.lonely intcntct cohesion) indicate("Time Effects = *.year") scalars("N_pop Individuals" "F F-Statistic" "p p-value") title("\textbf{Multinomial Logistic Models: Alternative Relationships} \strut"\label{tabA2}) refcat(1.lonely "\midrule \textbf{Main Loneliness Effect:}" intcntct "\textbf{Suggested Indicators:}", nolabel) coeflabels(1.lonely "\hspace{0.25cm} Low Loneliness" 3.lonely "\hspace{0.25cm} High Loneliness" cohesion "\hspace{0.25cm} High Social Cohesion" intcntct "\hspace{0.25cm} High Online Communication") mgroups("Base Effects" "Indicator Effects", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("\underline{Base}" "\underline{Year Effect}" "\underline{Connectivity}" "\underline{Social Cohesion}") eqlabels("Happy" "Unhappy") sfmt(%9.0fc %9.2fc %9.3fc %9.2fc %9.3fc) star(^+ 0.10 * 0.05 ** 0.01) label

*Part 10.4: Relative Risk Ratio Table (alternate)
qui svy: xtmlogit happy2 ib2.lonely intcntct ib2.intcntctlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample2 == 1, fe rrr
estimates store model_intcntct_rrr2

qui svy: xtmlogit happy2 ib2.lonely cohesion ib2.cohesionlonely partpartoffline partpartonline partvol marcohab occ10STEM attend i.year if include_sample2 == 1, fe
estimates store model_cohesion_rrr2

esttab model_intcntct_rrr2 model_cohesion_rrr2 using RRR2.tex, replace style(tex) eform booktabs varwidth(30) modelwidth(10) legend nobaselevels noomitted unstack lines compress nogaps b(%9.3g) not nose noomitted order(intcntct 1.intcntctlonely 3.intcntctlonely cohesion 1.cohesionlonely 3.cohesionlonely 1.lonely 3.lonely partpartonline partpartoffline partvol marcohab occ10STEM attend 2.year) scalars("N_pop Individuals") title("\textbf{Relative Risk Ratios (Alternative Happiness)} \strut"\label{tab6}) refcat(intcntct "\textbf{Interaction Effects:}" 1.lonely "\midrule \textbf{Main Loneliness Effect:}" partvol "\textbf{Controls:}", nolabel) coeflabels(1.lonely "\hspace{0.25cm} Low Loneliness" 3.lonely "\hspace{0.25cm} High Loneliness" cohesion "\hspace{0.25cm} High Social Cohesion" intcntct "\hspace{0.25cm} High Online Communication" partpartonline "\hspace{0.25cm} Online Engagement" partpartoffline "\hspace{0.25cm} Offline Engagement" partvol "\hspace{0.25cm} Volunteering" marcohab "\hspace{0.25cm} Marriage Status" occ10STEM "\hspace{0.25cm} Online Workspace" attend "\hspace{0.25cm} Religious Activity" 2.year "Year" 1.intcntctlonely "\hspace{0.5cm} \emph{w/Low Loneliness}" 3.intcntctlonely "\hspace{0.5cm} \emph{w/High Loneliness}" 1.cohesionlonely "\hspace{0.5cm} \emph{w/Low Loneliness}" 3.cohesionlonely "\hspace{0.5cm} \emph{w/High Loneliness}") mtitles("\underline{Online Communication}" "\underline{Social Cohesion}" "\underline{Social Cohesion}") eqlabels("Happy" "Unhappy") sfmt(%9.0fc %9.2fc %9.3fc %9.2fc %9.3fc) star(^+ 0.10 * 0.05 ** 0.01) label drop(2.year attend occ10STEM marcohab partvol)


*PART 11: Graphs
graph bar happy lonely if include_sample == 1, over(agecat) by(year) ylab(0(.5)3) ytitle("Mean Loneliness Scale") legend(order(1 "Unhappy" 2 "Lonely"))

graph bar (percent) intcntct if include_sample == 1, over(agecat) by(year) ytitle("High Online Communication (%)")
