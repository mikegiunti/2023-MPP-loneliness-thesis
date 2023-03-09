*THESIS CODE - DATA PREP - MICHELE GIUNTI

*Part 1: selecting ANES variables and changing the ANES YEARID variable into lowercase for merging

use version V200001 YEARID V160001_orig V200002 V200003 V200004 V200005 V200006 V200007 V200008 V200009 V200017b V200017c V200017d V202013 V202014 V202541a V202542 V202543 V202541c V202541b V202541d V202541e V202541f V202541g V202541h V202541i V202544 V202545 V202546 V202547 V202022 V202023 V202024 V202025 V202026 V202027 V202028 V202029 V202031 V202032 V202033 V202352 V202470 V202504 V202629 V202630 V202631 V202632 V202633 using "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Thesis Workshop V2\Thesis_code\Data\Source\anes_timeseries_2020_gss_stata_20220408.dta", clear

rename YEARID, lower

save "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Thesis Workshop V2\Thesis_code\Data\Source\01_ANES_subset_2020.dta", replace

*Part 2: selecting GSS variables and merging with ANES

use samptype yearid fileversion panstat wtssall_1a wtssall_1b wtssall_2 wtssnr_1a wtssnr_1b wtssnr_2 vstrat_1a vstrat_1b vstrat_2 vpsu_1a vpsu_1b vpsu_2 year_1a year_1b year_2 id_1a id_1b id_2 age_1a age_1b age_2 attend_1a attend_1b attend_2 fair_1a fair_1b fair_2 happy_1a happy_1b happy_2 health_1a health_1b health_2 helpful_1b helpful_2 marcohab_1a marcohab_1b marcohab_2 marital_1a marital_1b marital_2 occ10_1a occ10_1b occ10_2 realrinc_1a realrinc_1b realrinc_2 region_1a region_1b region_2 rincome_1a rincome_1b rincome_2 socbar_1a socbar_1b socbar_2 socfrend_1a socfrend_1b socfrend_2 socommun_1a socommun_1b socommun_2 socrel_1a socrel_1b socrel_2 trust_1a trust_1b trust_2 uscitzn_1a uscitzn_1b uscitzn_2 wwwhr_1a wwwhr_1b wwwhr_2 conf2f_1a conf2f_1b conf2f_2 conwkday_1a conwkday_1b conwkday_2 intcntct_1a intcntct_1b intcntct_2 lonely1_1a lonely2_1a lonely3_1a lonely1_1b lonely2_1b lonely3_1b lonely1_2 lonely2_2 lonely3_2 partlsc_1a partlsc_1b partlsc_2 partpart_1a partpart_1b partpart_2 partvol_1a partvol_1b partvol_2 race_1a race_1b race_2 anesid using "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Thesis Workshop V2\Thesis_code\Data\Source\gss2020panel_r1a.dta"

save "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Thesis Workshop V2\Thesis_code\Data\Source\01_GSS_subset_allyears.dta", replace

merge 1:1 yearid using "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Thesis Workshop V2\Thesis_code\Data\Source\01_ANES_subset_2020.dta"

save "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Thesis Workshop V2\Thesis_code\Data\Source\01_ANES_GSS_merge.dta", replace

*note: no merge version
drop _merge

save "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Thesis Workshop V2\Thesis_code\Data\Source\01_ANES_GSS_nomerge.dta", replace

