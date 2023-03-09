*THESIS CODE - WRANGLING - MICHELE GIUNTI

*Part 1: drop all 2016 observations
clear
use "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Thesis Workshop V2\Thesis_code\Data\Source\01_ANES_GSS_merge.dta" 

drop wtssall_1a wtssnr_1a vstrat_1a vpsu_1a year_1a id_1a age_1a attend_1a fair_1a happy_1a health_1a marcohab_1a marital_1a occ10_1a realrinc_1a region_1a rincome_1a socbar_1a socfrend_1a socommun_1a socrel_1a trust_1a uscitzn_1a wwwhr_1a conf2f_1a conwkday_1a intcntct_1a lonely1_1a lonely2_1a lonely3_1a partlsc_1a partpart_1a partvol_1a partlsc_1b partlsc_2 race_1a V160001_orig V200002 V200003 V200004 V200005 V200006 V200007 V200008 V200009

*Part 2: Standardize missing variable codes for ANES and GSS

foreach var of varlist V202013 V202014 V202022 V202023 V202024 V202025 V202026 V202027 V202028 V202029 V202031 V202032 V202033 V202352 V202470 V202504 V202541a V202541b V202541c V202541d V202541e V202541f V202541g V202541h V202541i V202542 V202543 V202544 V202545 V202546 V202547 V202629 V202630 V202631 V202632 V202633{
	replace `var' = .d if `var' == -8
	replace `var' = .i if `var' == -1
	replace `var' = .n if `var' == -9 | `var' == -5
}
replace rincome_2 = .n if rincome_2 == 13

replace race_2 = 1 if race_1b == 1
replace race_2 = 2 if race_1b == 2
replace race_2 = 3 if race_1b == 3
label define RACE 1 "White" 2 "Black" 3 "Other", replace

*Part 2b: ANES variables that we did not need in the end:

drop V202023 V202504 V202025 V202631 V202632 V202633          
*Note: These variables can be useful for other types of analysis for this data, especially political aspects of it.

*Part 3: Make social cohesion outcome variables into binaries

label define FAIR2 0 "People take advantage" 1 "People are fair"
recode fair_2 (1 3 = 0) (2 = 1)
label values fair_2 FAIR2

label define HELPFUL2 0 "Not Helpful" 1 "Helpful"
recode helpful_2 (2 3 = 0) (1 = 1)
label values helpful_2 HELPFUL2

label define TRUST2 0 "Can't be too careful" 1 "People can be trusted"
recode trust_2 (2 3 = 0) (1 = 1)
label values trust_2 TRUST2

recode fair_1b (1 3 = 0) (2 = 1)
label values fair_1b FAIR2

recode helpful_1b (2 3 = 0) (1 = 1)
label values helpful_1b HELPFUL2

recode trust_1b (2 3 = 0) (1 = 1)
label values trust_1b TRUST2

*Part 4: Create factor alternatives to key variables

*HEALTH
label define HEALTH2 1 "Excellent" 2 "Acceptable" 3 "Poor"
recode health_1b (1 = 1) (2 = 2) (3 4 = 3)
label values health_1b HEALTH2
label variable health_1b "Perceived Health"

recode health_2 (1 = 1) (2 = 2) (3 4 = 3)
label values health_2 HEALTH2
label variable health_2 "Perceived Health"

**AGE
gen agecat_1b = age_1b
recode agecat_1b (min/25 = 1) (26/45 = 2) (46/64 = 3) (65/max = 4)
label define AGECAT 1 "18-25" 2 "26-45" 3 "46-64" 4 "65+"
label values agecat_1b AGECAT
label variable agecat_1b "Age in Categories"

gen agecat_2 = age_2
recode agecat_2 (min/25 = 1) (26/45 = 2) (46/64 = 3) (65/max = 4)
label values agecat_2 AGECAT
label variable agecat_2 "Age in Categories"

**REGION
label define REGION2 1 "North-East" 2 "Midwest" 3 "South" 4 "West"
gen region4_1b = region_1b
recode region4_1b (1 2 = 1) (3 4 = 2) (5 6 7 = 3) (8 9 = 4)
label values region4_1b REGION2
label variable region4_1b "Region of Interview (4 regions)"

gen region4_2 = region_2
recode region4_2 (1 2 = 1) (3 4 = 2) (5 6 7 = 3) (8 9 = 4)
label values region4_2 REGION2
label variable region4_2 "Region of Interview (4 regions)"

**ATTEND
label define ATTEND2 1 "Never" 2 "Less than 3 times a year" 3 "3 to 12 times a year" 4 "More than once a month"
gen attend4_1b = attend_1b
recode attend4_1b (0 = 1) (1 2 = 2) (3 4 5 = 3) (6 7 8 = 4)
label values attend4_1b ATTEND2
label variable attend4_1b "frequency of Religious Attendance"

gen attend4_2 = attend_2
recode attend4_2 (0 = 1) (1 2 = 2) (3 4 5 = 3) (6 7 8 = 4)
label values attend4_2 ATTEND2
label variable attend4_2 "Frequency of Religious Attendance"

**OCCUPATION
label define OCC10F2 1 "Management" 2 "Business and Financial Operations" 3 "Computer and Mathematical" 4 "Architecture and Engineering" 5 "Life, Physical, and Social Science" 6 "Community and Social Service" 7 "Legal" 8 "Education, Training, and Library" 9 "Arts, Design, Entertainment, Sports, and Media" 10 "Healthcare Practitioners and Technical" 11 "Healthcare Support" 12 "Protective Service" 13 "Food Preparation and Serving Related" 14 "Building and Grounds Cleaning and Maintenance" 15 "Personal Care and Service" 16 "Sales and Related" 17 "Office and Administrative Support" 18 "Farming, Fishing, and Forestry" 19 "Construction and Extraction" 20 "Installation, Maintenance, and Repair" 21 "Production" 22 "Transportation and Material Moving" 23 "Military Specific"

label define OCC10F3 1 "STEM Occupation" 0 "Non-STEM Occupation"

gen occ23cat_1b = occ10_1b
recode occ23cat_1b (10 20 30 40 50 60 100 110 120 135 136 137 140 150 160 205 220 230 300 310 325 330 340 350 360 400 410 420 425 430 = 1) (500 510 520 530 540 565 600 630 640 650 700 710 725 726 735 740 800 810 820 830 840 850 860 900 910 930 940 950 = 2) (1005 1006 1007 1010 1020 1030 1050 1060 1105 1106 1107 1200 1210 1220 1230 1240  = 3) (1300 1310 1320 1330 1340 1350 1360 1400 1410 1420 1430 1440 1450 1460 1500 1510 1520 1530 1540 1550 1560 = 4) (1600 1610 1640 1650 1660 1700 1710 1720 1740 1760 1800 1815 1820 1830 1840 1860 1900 1910 1920 1930 1940 1950 1965 = 5) (2000 2010 2015 2016 2025 2040 2050 2060 = 6) (2100 2105 2110 2145 2160 = 7) (2200 2300 2310 2320 2330 2340 2400 2430 2440 2540 2550 = 8) (2600 2630 2700 2710 2720 2740 2750 2760 2800 2810 2825 2830 2840 2850 2860 2900 2910 2920 2960 = 9) (3000 3010 3030 3040 3050 3060 3110 3120 3140 3150 3160 3200 3210 3220 3230 3235 3245 3250 3255 3256 3257 3258 3260 3300 3310 3320 3400 3420 3500 3510 3520 3535 3540 = 10) (3600 3610 3620 3630 3640 3645 3646 3647 3648 3649 3655 = 11) (3700 3710 3720 3730 3740 3750 3800 3820 3830 3840 3850 3860 3900 3910 3930 3940 3945 3955 = 12) (4000 4010 4020 4030 4040 4050 4060 4110 4120 4130 4140 4150 4160 = 13) (4200 4210 4220 4230 4240 4250 = 14) (4300 4320 4340 4350 4400 4410 4420 4430 4460 4465 4500 4510 4520 4530 4540 4600 4610 4620 4640 4650 = 15) (4700 4710 4720 4740 4750 4760 4800 4810 4820 4830 4840 4850 4900 4920 4930 4940 4950 4965 = 16) (5000 5010 5020 5030 5100 5110 5120 5130 5140 5150 5160 5165 5200 5210 5220 5230 5240 5250 5260 5300 5310 5320 5330 5340 5350 5360 5400 5410 5420 5500 5510 5520 5530 5540 5550 5560 5600 5610 5620 5630 5700 5800 5810 5820 5830 5840 5850 5860 5900 5910 5920 5940 = 17) (6005 6010 6020 6040 6050 6100 6110 6120 6130 = 18) (6200 6210 6220 6230 6240 6250 6260 6300 6310 6320 6330 6355 6360 6400 6420 6430 6440 6460 6500 6515 6520 6530 6540 6600 6660 6700 6710 6720 6730 6740 6750 6765 6800 6820 6820 6840 6910 6920 6930 6940 = 19) (7000 7010 7020 7030 7040 7050 7100 7110 7120 7130 7140 7150 7160 7200 7210 7220 7240 7260 7300 7315 7320 7330 7340 7350 7360 7410 7420 7430 7440 7510 7520 7540 7550 7560 7600 7610 7630 = 20) (7700 7710 7720 7730 7740 7750 7800 7810 7830 7840 7850 7855 7900 7920 7930 7940 7950 7960 8000 8010 8020 8030 8040 8060 8100 8120 8130 8140 8150 8160 8200 8210 8220 8250 8255 8256 8300 8310 8320 8330 8340 8350 8360 8400 8410 8420 8430 8440 8450 8460 8500 8510 8520 8530 8540 8550 8600 8610 8620 8630 8640 8650 8710 8720 8730 8740 8750 8760 8800 8810 8830 8840 8850 8860 8900 8910 8920 8930 8940 8950 8965 = 21) (9000 9030 9040 9050 9110 9120 9130 9140 9150 9200 9230 9240 9260 9300 9640 9330 9340 9350 9360 9410 9415 9420 9500 9510 9520 9560 9600 9610 9620 9630 9640 9650 9720 9730 9740 9750 = 22) (9800 9810 9820 9830 = 23)
label values occ23cat_1b OCC10F2
label variable occ23cat_1b "Respondent Census Occupation Code (23 categories)"
replace occ23cat_1b = .i if occ23cat_1b == 9997 | occ23cat_1b == 3890 | occ23cat_1b == 6990 | occ23cat_1b == 7270 | occ23cat_1b == 7490 | occ23cat_1b ==7570 | occ23cat_1b == 7870 | occ23cat_1b == 8270 | occ23cat_1b == 8690 | occ23cat_1b == 9170


gen occ23cat_2 = occ10_2
recode occ23cat_2 (10 20 30 40 50 60 100 110 120 135 136 137 140 150 160 205 220 230 300 310 325 330 340 350 360 400 410 420 425 430 = 1) (500 510 520 530 540 565 600 630 640 650 700 710 725 726 735 740 800 810 820 830 840 850 860 900 910 930 940 950 = 2) (1005 1006 1007 1010 1020 1030 1050 1060 1105 1106 1107 1200 1210 1220 1230 1240  = 3) (1300 1310 1320 1330 1340 1350 1360 1400 1410 1420 1430 1440 1450 1460 1500 1510 1520 1530 1540 1550 1560 = 4) (1600 1610 1640 1650 1660 1700 1710 1720 1740 1760 1800 1815 1820 1830 1840 1860 1900 1910 1920 1930 1940 1950 1965 = 5) (2000 2010 2015 2016 2025 2040 2050 2060 = 6) (2100 2105 2110 2145 2160 = 7) (2200 2300 2310 2320 2330 2340 2400 2430 2440 2540 2550 = 8) (2600 2630 2700 2710 2720 2740 2750 2760 2800 2810 2825 2830 2840 2850 2860 2900 2910 2920 2960 = 9) (3000 3010 3030 3040 3050 3060 3110 3120 3140 3150 3160 3200 3210 3220 3230 3235 3245 3250 3255 3256 3257 3258 3260 3300 3310 3320 3400 3420 3500 3510 3520 3535 3540 = 10) (3600 3610 3620 3630 3640 3645 3646 3647 3648 3649 3655 = 11) (3700 3710 3720 3730 3740 3750 3800 3820 3830 3840 3850 3860 3900 3910 3930 3940 3945 3955 = 12) (4000 4010 4020 4030 4040 4050 4060 4110 4120 4130 4140 4150 4160 = 13) (4200 4210 4220 4230 4240 4250 = 14) (4300 4320 4340 4350 4400 4410 4420 4430 4460 4465 4500 4510 4520 4530 4540 4600 4610 4620 4640 4650 = 15) (4700 4710 4720 4740 4750 4760 4800 4810 4820 4830 4840 4850 4900 4920 4930 4940 4950 4965 = 16) (5000 5010 5020 5030 5100 5110 5120 5130 5140 5150 5160 5165 5200 5210 5220 5230 5240 5250 5260 5300 5310 5320 5330 5340 5350 5360 5400 5410 5420 5500 5510 5520 5530 5540 5550 5560 5600 5610 5620 5630 5700 5800 5810 5820 5830 5840 5850 5860 5900 5910 5920 5940 = 17) (6005 6010 6020 6040 6050 6100 6110 6120 6130 = 18) (6200 6210 6220 6230 6240 6250 6260 6300 6310 6320 6330 6355 6360 6400 6420 6430 6440 6460 6500 6515 6520 6530 6540 6600 6660 6700 6710 6720 6730 6740 6750 6765 6800 6820 6820 6840 6910 6920 6930 6940 = 19) (7000 7010 7020 7030 7040 7050 7100 7110 7120 7130 7140 7150 7160 7200 7210 7220 7240 7260 7300 7315 7320 7330 7340 7350 7360 7410 7420 7430 7440 7510 7520 7540 7550 7560 7600 7610 7630 = 20) (7700 7710 7720 7730 7740 7750 7800 7810 7830 7840 7850 7855 7900 7920 7930 7940 7950 7960 8000 8010 8020 8030 8040 8060 8100 8120 8130 8140 8150 8160 8200 8210 8220 8250 8255 8256 8300 8310 8320 8330 8340 8350 8360 8400 8410 8420 8430 8440 8450 8460 8500 8510 8520 8530 8540 8550 8600 8610 8620 8630 8640 8650 8710 8720 8730 8740 8750 8760 8800 8810 8830 8840 8850 8860 8900 8910 8920 8930 8940 8950 8965 = 21) (9000 9030 9040 9050 9110 9120 9130 9140 9150 9200 9230 9240 9260 9300 9640 9330 9340 9350 9360 9410 9415 9420 9500 9510 9520 9560 9600 9610 9620 9630 9640 9650 9720 9730 9740 9750 = 22) (9800 9810 9820 9830 = 23)
label values occ23cat_2 OCC10F2
label variable occ23cat_2 "Respondent Census Occupation Code (23 categories)"
replace occ23cat_2 = .i if occ23cat_2 == 9997 | occ23cat_2 == 3890 | occ23cat_2 == 6990 | occ23cat_2 == 7270 | occ23cat_2 == 7490 | occ23cat_2 == 7570 | occ23cat_2 == 7870 | occ23cat_2 == 8270 | occ23cat_2 == 8690 | occ23cat_2 == 9170 | occ23cat_2 == 9840

***NEW OCCUPATION VARiABLE BINARY BASED ON TECHNOLOGICAL USE
gen occ10STEM_1b = occ10_1b
recode occ10STEM_1b (10 20 30 40 50 60 100 120 135 136 137 140 150 160 205 220 230 310 325 330 340 400 410 420 425 430 500 510 520 530 540 565 600 630 640 650 700 710 725 726 735 740 800 810 820 830 840 850 860 900 910 930 940 950 2000 2010 2015 2016 2025 2040 2050 2060 2100 2105 2110 2145 2160 2200 2300 2310 2320 2330 2340 2400 2430 2440 2540 2550 2600 2630 2700 2710 2720 2740 2750 2760 2800 2810 2825 2830 2840 2850 2860 2900 2910 2920 2960 3600 3610 3620 3630 3640 3645 3646 3647 3648 3649 3655 3700 3710 3720 3730 3740 3750 3800 3820 3830 3840 3850 3860 3900 3910 3930 3940 3945 3955 4000 4010 4020 4030 4040 4050 4060 4110 4120 4130 4140 4150 4160 4200 4210 4220 4230 4240 4250 4300 4320 4340 4350 4400 4410 4420 4430 4460 4465 4500 4510 4520 4530 4540 4600 4610 4620 4640 4650 4700 4710 4720 4740 4750 4760 4800 4810 4820 4830 4840 4850 4900 4920 4930 4940 4950 4965 5000 5010 5020 5030 5100 5110 5120 5130 5140 5150 5160 5165 5200 5210 5220 5230 5240 5250 5260 5300 5310 5320 5330 5340 5350 5360 5400 5410 5420 5500 5510 5520 5530 5540 5550 5560 5600 5610 5620 5630 5700 5800 5810 5820 5830 5840 5850 5860 5900 5910 5920 5940 6005 6010 6020 6040 6050 6100 6110 6120 6130 6200 6210 6220 6230 6240 6250 6260 6300 6310 6320 6330 6355 6360 6400 6420 6430 6440 6460 6500 6515 6520 6530 6540 6600 6660 6700 6710 6720 6730 6740 6750 6765 6800 6820 6820 6840 6910 6920 6930 6940 7000 7010 7020 7030 7040 7050 7100 7110 7120 7130 7140 7150 7160 7200 7210 7220 7240 7260 7300 7315 7320 7330 7340 7350 7360 7410 7420 7430 7440 7510 7520 7540 7550 7560 7600 7610 7630 7700 7710 7720 7730 7740 7750 7800 7810 7830 7840 7850 7855 7900 7920 7930 7940 7950 7960 8000 8010 8020 8030 8040 8060 8100 8120 8130 8140 8150 8160 8200 8210 8220 8250 8255 8256 8300 8310 8320 8330 8340 8350 8360 8400 8410 8420 8430 8440 8450 8460 8500 8510 8520 8530 8540 8550 8600 8610 8620 8630 8640 8650 8710 8720 8730 8740 8750 8760 8800 8810 8830 8840 8850 8860 8900 8910 8920 8930 8940 8950 8965 9000 9030 9040 9050 9110 9120 9130 9140 9150 9200 9230 9240 9260 9300 9640 9330 9340 9350 9360 9410 9415 9420 9500 9510 9520 9560 9600 9610 9620 9630 9640 9650 9720 9730 9740 9750 9800 9810 9820 9830 = 0) (110 300 350 360 1005 1006 1007 1010 1020 1030 1050 1060 1105 1106 1107 1200 1210 1220 1230 1240 1300 1310 1320 1330 1340 1350 1360 1400 1410 1420 1430 1440 1450 1460 1500 1510 1520 1530 1540 1550 1560 1600 1610 1640 1650 1660 1700 1710 1720 1740 1760 1800 1815 1820 1830 1840 1860 1900 1910 1920 1930 1940 1950 1965 2200 3000 3010 3030 3040 3050 3060 3110 3120 3140 3150 3160 3200 3210 3220 3230 3235 3245 3250 3255 3256 3257 3258 3260 3300 3310 3320 3400 3420 3500 3510 3520 3535 3540 = 1)
label values occ10STEM_1b OCC10F3
label variable occ10STEM_1b "Respondent Census Occupation Code (STEM or Non-STEM)"
replace occ10STEM_1b = .i if occ10STEM_1b == 3890 | occ10STEM_1b == 6990 | occ10STEM_1b == 7270 | occ10STEM_1b == 7490 | occ10STEM_1b == 7570 | occ10STEM_1b == 7870 | occ10STEM_1b == 8270 | occ10STEM_1b == 8690 | occ10STEM_1b == 9170

gen occ10STEM_2 = occ10_2
recode occ10STEM_2 (10 20 30 40 50 60 100 120 135 136 137 140 150 160 205 220 230 310 325 330 340 400 410 420 425 430 500 510 520 530 540 565 600 630 640 650 700 710 725 726 735 740 800 810 820 830 840 850 860 900 910 930 940 950 2000 2010 2015 2016 2025 2040 2050 2060 2100 2105 2110 2145 2160 2200 2300 2310 2320 2330 2340 2400 2430 2440 2540 2550 2600 2630 2700 2710 2720 2740 2750 2760 2800 2810 2825 2830 2840 2850 2860 2900 2910 2920 2960 3600 3610 3620 3630 3640 3645 3646 3647 3648 3649 3655 3700 3710 3720 3730 3740 3750 3800 3820 3830 3840 3850 3860 3900 3910 3930 3940 3945 3955 4000 4010 4020 4030 4040 4050 4060 4110 4120 4130 4140 4150 4160 4200 4210 4220 4230 4240 4250 4300 4320 4340 4350 4400 4410 4420 4430 4460 4465 4500 4510 4520 4530 4540 4600 4610 4620 4640 4650 4700 4710 4720 4740 4750 4760 4800 4810 4820 4830 4840 4850 4900 4920 4930 4940 4950 4965 5000 5010 5020 5030 5100 5110 5120 5130 5140 5150 5160 5165 5200 5210 5220 5230 5240 5250 5260 5300 5310 5320 5330 5340 5350 5360 5400 5410 5420 5500 5510 5520 5530 5540 5550 5560 5600 5610 5620 5630 5700 5800 5810 5820 5830 5840 5850 5860 5900 5910 5920 5940 6005 6010 6020 6040 6050 6100 6110 6120 6130 6200 6210 6220 6230 6240 6250 6260 6300 6310 6320 6330 6355 6360 6400 6420 6430 6440 6460 6500 6515 6520 6530 6540 6600 6660 6700 6710 6720 6730 6740 6750 6765 6800 6820 6820 6840 6910 6920 6930 6940 7000 7010 7020 7030 7040 7050 7100 7110 7120 7130 7140 7150 7160 7200 7210 7220 7240 7260 7300 7315 7320 7330 7340 7350 7360 7410 7420 7430 7440 7510 7520 7540 7550 7560 7600 7610 7630 7700 7710 7720 7730 7740 7750 7800 7810 7830 7840 7850 7855 7900 7920 7930 7940 7950 7960 8000 8010 8020 8030 8040 8060 8100 8120 8130 8140 8150 8160 8200 8210 8220 8250 8255 8256 8300 8310 8320 8330 8340 8350 8360 8400 8410 8420 8430 8440 8450 8460 8500 8510 8520 8530 8540 8550 8600 8610 8620 8630 8640 8650 8710 8720 8730 8740 8750 8760 8800 8810 8830 8840 8850 8860 8900 8910 8920 8930 8940 8950 8965 9000 9030 9040 9050 9110 9120 9130 9140 9150 9200 9230 9240 9260 9300 9640 9330 9340 9350 9360 9410 9415 9420 9500 9510 9520 9560 9600 9610 9620 9630 9640 9650 9720 9730 9740 9750 9800 9810 9820 9830 = 0) (110 300 350 360 1005 1006 1007 1010 1020 1030 1050 1060 1105 1106 1107 1200 1210 1220 1230 1240 1300 1310 1320 1330 1340 1350 1360 1400 1410 1420 1430 1440 1450 1460 1500 1510 1520 1530 1540 1550 1560 1600 1610 1640 1650 1660 1700 1710 1720 1740 1760 1800 1815 1820 1830 1840 1860 1900 1910 1920 1930 1940 1950 1965 2200 3000 3010 3030 3040 3050 3060 3110 3120 3140 3150 3160 3200 3210 3220 3230 3235 3245 3250 3255 3256 3257 3258 3260 3300 3310 3320 3400 3420 3500 3510 3520 3535 3540 = 1)
label values occ10STEM_2 OCC10F3
label variable occ10STEM_2 "Respondent Census Occupation Code (STEM or Non-STEM)"
replace occ10STEM_2 = .i if occ10STEM_2 == 9840

*Part 5: Dealing with empty or nearly empty categories by collapsing them into the next category

**SOCIAL INTERACTION VARIABLES
label define LABBN2 1 "Once a week or more" 2 "Once a week to once a month" 3 "Less than once a month" 4 "Never"
recode socbar_1b (1 2 = 1) (3 4 = 2) (5 6 = 3) (7 = 4)
recode socfrend_1b (1 2 = 1) (3 4 = 2) (5 6 = 3) (7 = 4)
recode socommun_1b (1 2 = 1) (3 4 = 2) (5 6 = 3) (7 = 4)
recode socrel_1b (1 2 = 1) (3 4 = 2) (5 6 = 3) (7 = 4)
label values socbar_1b LABBN2
label values socfrend_1b LABBN2
label values socommun_1b LABBN2
label values socrel_1b LABBN2

recode socbar_2 (1 2 = 1) (3 4 = 2) (5 6 = 3) (7 = 4)
recode socfrend_2 (1 2 = 1) (3 4 = 2) (5 6 = 3) (7 = 4)
recode socommun_2 (1 2 = 1) (3 4 = 2) (5 6 = 3) (7 = 4)
recode socrel_2 (1 2 = 1) (3 4 = 2) (5 6 = 3) (7 = 4)
label values socbar_2 LABBN2
label values socfrend_2 LABBN2
label values socommun_2 LABBN2
label values socrel_2 LABBN2

**COHABITATION
replace marcohab_1b = .i if marcohab_1b == 4
replace marcohab_2 = .i if marcohab_2 == 4

*ONLINE HOURS
label define ONLNHR2 0 "0 Hours" 1 "1 to 21 Hours" 2 "22 to 42 Hours" 3 "43 or more Hours"
recode wwwhr_1b (1/21 = 1) (22/42 = 2) (43/168 = 3)
label values wwwhr_1b ONLNHR2

recode wwwhr_2 (1/21 = 1) (22/42 = 2) (43/168 = 3)
label values wwwhr_2 ONLNHR2

*INCOME
label define INCOME2 1 "Under $7,000" 2 "$7,000 to $24,999" 3 "Over $25,000"
recode rincome_1b (1/6 = 1) (7/11 = 2) (12 = 3)
label values rincome_1b INCOME2

recode rincome_2 (1/6 = 1) (7/11 = 2) (12 = 3)
label values rincome_2 INCOME2

*Part 5: Dealing with the Lonely variable and standardizing a single code for both years

**LONELY

label define LONELY 1 "Never" 2 "Very Rarely" 3 "Rarely" 4 "Occasionally" 5 "Sometimes" 6 "Frequently" 7 "Often" 8 "Very Often" 9 "Usually"


recode conwkday_1b (5 6 = 5)
label define CONWKDAY 5 "50 or more people", modify

egen lonely_1b = group(lonely3_1b conwkday_1b), label missing
replace lonely_1b = .i if lonely_1b == 28
replace lonely_1b = .n if lonely_1b == 30 | lonely_1b == 29
replace lonely_1b = .d if lonely_1b == 27 | lonely_1b == 17 | lonely_1b == 6
recode lonely_1b (1 = 1) (2 7 = 2) (3 8 12 = 3) (4 9 13 18 = 4) (5 10 14 19 23 = 5) (11 15 20 24 = 6) (16 21 25 = 7) (22 = 8) (26 = 9)
label values lonely_1b LONELY
label variable lonely_1b "Loneliness Scale (Physical and Emotional)"


egen lonely_2 = group(lonely1_2 lonely2_2), label missing
replace lonely_2 = .i if lonely_2 == 27
replace lonely_2 = .n if lonely_2 == 28
replace lonely_2 = .s if lonely_2 == 29 | lonely_2 == 30 | lonely_2 == 31
replace lonely_2 = .d if lonely_2 == 26
recode lonely_2 (1 = 1) (2 6 = 2) (3 7 11 = 3) (4 8 12 16 = 4) (5 9 13 17 21 = 5) (10 14 18 22 = 6) (15 19 23 = 7) (20 24 = 8) (25 = 9)
label values lonely_2 LONELY
label variable lonely_2 "Loneliness Scale (Physical and Emotional)"

*subPart 5.5: Changing loneliness scale labels to address small factors

label define LONELY2 1 "Rarely" 2 "Sometimes" 3 "Often"
foreach var of varlist lonely_1b lonely_2{
	recode `var' (1 2 3 = 1) (4 5 6 = 2) (7 8 9 = 3)
	label values `var' LONELY2
}


*Part 6: Creating a social cohesion index out of the three dummies

label define COHESION 1 "Not Fair, Not Helpful, Not Trustworthy" 2 "At least two No" 3 "At least two Yes" 4 "Fair, Helpful, and Trustworthy"
egen cohesion_1b = group(fair_1b helpful_1b trust_1b), label missing
replace cohesion_1b = .i if cohesion_1b == 19
replace cohesion_1b = .d if cohesion_1b == 3 | cohesion_1b == 6 | cohesion_1b == 12 | cohesion_1b == 13 | cohesion_1b == 15 | cohesion_1b == 16 | cohesion_1b == 17 | cohesion_1b == 18
replace cohesion_1b = .n if cohesion_1b == 9 | cohesion_1b == 14 | cohesion_1b == 20
recode cohesion_1b (1 = 1) (2 4 7 = 2) (5 8 10 = 3) (11 = 4)
label values cohesion_1b COHESION
label variable cohesion_1b "Social Cohesion Index based on Fair, Helpful, and Trust"

egen cohesion_2 = group(fair_2 helpful_2 trust_2), label missing
replace cohesion_2 = .i if cohesion_2 == 22 | cohesion_2 == 3 | cohesion_2 == 21
replace cohesion_2 = .d if cohesion_2 == 7 | cohesion_2 == 13 | cohesion_2 == 16 | cohesion_2 == 17 | cohesion_2 == 18 | cohesion_2 == 19 | cohesion_2 == 20
replace cohesion_2 = .s if cohesion_2 == 4 | cohesion_2 == 8 | cohesion_2 == 14 | cohesion_2 == 15 | cohesion_2 == 23 | cohesion_2 == 24 | cohesion_2 == 25
recode cohesion_2 (1 = 1) (2 5 9 = 2) (6 10 11 = 3) (12 = 4)
label values cohesion_2 COHESION
label variable cohesion_2 "Social Cohesion Index based on Fair, Helpful, and Trust"

*Part 7: Creating a social participation variable out of the ANES POST survey questions

*POLITICAL (2018)
label define LABEH2 0 "Not Participated" 1 "Participated"
gen partpartoffline_1b = partpart_1b
recode partpartoffline_1b (1 2 3 4 = 1) (5 = 0)
label values partpartoffline_1b LABEH2
label variable partpartoffline_1b "past 12 months, r has participated in orgs for politics or political assoc."

rename partpart_1b partpartonline_1b
recode partpartonline_1b (1 2 3 4 = 1) (5 = 0)
label values partpartonline_1b LABEH2

*POLITICAL (NON-ONLINE)
egen partpartoffline_2 = group(V202014 V202024 V202028 V202031 V202032), label missing
replace partpartoffline_2 = . if partpartoffline_2 == 30
recode partpartoffline_2 (1 2 3 4 5 6 8 9 10 12 14 15 16 18 22 = 1) (29 28 27 26 25 24 23 21 20 19 17 13 11 7 = 0)
label values partpartoffline_2 LABEH2
label variable partpartoffline_2 "past 12 months, r has participated in political activities or orgs offline"

*POLITICAL (ONLINE)
egen partpartonline_2 = group(V202013 V202024 V202028 V202029 V202026), label missing
replace partpartonline_2 = . if partpartonline_2 == 33
recode partpartonline_2 (1 2 3 4 5 6 7 9 10 11 13 17 18 19 21 25 = 1) (32 31 30 29 28 27 26 24 23 22 20 16 15 14 12 8  = 0)
label values partpartonline_2 LABEH2
label variable partpartonline_2 "past 12 months, r has participated in political activities or orgs online"

drop V202014 V202024 V202028 V202031 V202032 V202013 V202029 V202026 partpart_2

*RELIGIOUS
drop partvol_2

recode partvol_1b (1 2 3 4 = 1) (5 = 0)
label values partvol_1b LABEH2
egen partvol_2 = group(V202027 V202033), label missing
replace partvol_2 = . if partvol_2 == 5
recode partvol_2 (1 2 3 = 1) (4 = 0)
label values partvol_2 LABEH2
label variable partvol_2 "in past 12 months, r has participated in charitable or religious volunteer orgs"

drop V202027 V202033

*Part 8: Deduce online interaction patterns from website use

label define ONLINE 0 "Low or Mid-Level Online Presence" 1 "High Online Presence"
recode intcntct_1b (1 2 = 1) (3 4 5 6 = 0)
label values intcntct_1b ONLINE

drop intcntct_2
egen intcntct_2 = group(V202541a V202541b V202541c V202541d V202541e V202541f V202541g V202541h V202541i), label missing
replace intcntct_2 = . if intcntct_2 == 79
replace intcntct_2 = .n if intcntct_2 == 80
recode intcntct_2 (1 2 3 4 5 6 7 8 9 10 11 12 13 14 17 18 19 20 21 23 24 28 29 30 31 32 33 34 35 37 39 42 43 44 46 51 56 57 58 65 = 0) (15 16 22 25 26 27 36 38 40 41 45 47 48 49 50 52 53 54 55 59 60 61 62 63 64 66 67 68 69 70 71 72 73 74 75 76 77 78 = 1)
label values intcntct_2 ONLINE
label variable intcntct_2 "how much of r's communication is via text, mobile phone, or internet"


drop V202541a V202541b V202541c V202541d V202541e V202541f V202541g V202541h V202541i

*Part 9: SAVE

save "C:\Users\miche\OneDrive\Documenti\USA\School\SPRING 2023\Thesis Workshop V2\Thesis_code\Data\Wrangling\02_ANES_GSS_merge_2018_2020.dta", replace