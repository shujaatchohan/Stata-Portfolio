clear


// Importing relevant dataset
use "D:\EVALUATION BOOTCAMP\Intro to Stata- Data cleaning wokring on PSLM\PSLM\stata_data_pslm_2019_20\stata data\plist.dta" 
merge 1:1 hhcode idc using "D:\EVALUATION BOOTCAMP\Intro to Stata- Data cleaning wokring on PSLM\PSLM\stata_data_pslm_2019_20\stata data\secc1.dta", nogenerate
merge 1:1 hhcode idc using "D:\EVALUATION BOOTCAMP\Intro to Stata- Data cleaning wokring on PSLM\PSLM\stata_data_pslm_2019_20\stata data\sece.dta", nogenerate

// Defining Strata since it is stratified by province then region
egen strata = group( province region )

 label define strata_lbl ///
	1 "khyber pakhtunkhwa - rural" ///
	2 "khyber pakhtunkhwa - urban" ///
	3 "punjab - rural" ///
	4 "punjab - urban" ///
	5 "sindh - rural" ///
	6 "sindh - urban" ///
	7 "balochistan - rural" ///
	8 "balochistan - urban"
 
label values strata strata_lbl


codebook strata

// Setting up the survey design criteria for future analysis
svyset psu [pw=weights], strata(strata)
svydescribe
codebook sb1q2
tab sb1q2

// Generating dummy variable for hh head from categorical variable
gen hh_head = 1 if sb1q2 == 1
replace hh_head =0 if sb1q2 !=1
codebook sc1q05
tab sc1q05

// Properly codified the education variable according to the PSLM questionairre
label define edu_lbl ///
0 "No education" ///
1 "Class 1" ///
2 "Class 2" ///
3 "Class 3" ///
4 "Class 4" ///
5 "Class 5" ///
6 "Class 6" ///
7 "Class 7" ///
8 "Class 8" ///
9 "Class 9" ///
10 "Class 10 / O-Level" ///
11 "Polytechnic diploma" ///
12 "FA/FSc/I.Com/ICS/A-Level" ///
13 "BA/BSc/BCom (2 yrs)" ///
14 "B.Ed/M.Ed" ///
15 "BS/BE/BSc (4 yrs)" ///
16 "MA/MSc (2 yrs)" ///
17 "Degree in Medicine" ///
18 "Degree in Agriculture" ///
19 "Degree in Law" ///
20 "Degree in Engineering" ///
21 "Degree in Accountancy" ///
22 "M.Phil" ///
23 "PhD" ///
24 "MS" ///
25 "Play Group" ///
26 "Nursery" ///
27 "Prep" ///
28 "Other"

label values sc1q05 edu_lbl

// Generating a dummy variable for hh head education level
gen hhh_edu=.
replace hhh_edu = sc1q05 if hh_head == 1
tab hh_head
codebook hh_head

// spreading the hh education level for all family members 
bysort hhcode (sb1q2): replace hhh_edu = hhh_edu[1] if missing(hhh_edu)
tab sc1q05 if hh_head == 1, mi
count if hh_head ==1 & hhh_edu==.
su hhcode if hh_head ==1 & hhh_edu==.
replace hhh_edu = 0 if hhh_edu ==.

// Our for our research the hh head education level = above primary
// generating a new binary variable for hh head educated or no
// Criteria = primary(class 5 or above) 
gen haboveprimary = 1 if hhh_edu >= 5
replace haboveprimary = 0 if hhh_edu < 5

br hhcode sb1q2 hh_head hhh_edu haboveprimary if hhh_edu >5

// generating age brackets for ease in analysis
gen agebr = "5-10" if age>=5 & age<=10
replace agebr = "10-15" if age>10 & age<=15
replace agebr = "15-20" if age>15 & age<=20
replace agebr = "20-25" if age>20 & age<=25
replace agebr = "above 25" if age>25
replace agebr = "below 5" if age<5

//enrollment child2                    // see it later
//gen attendedschool = 1 if sc1q01 ==3
//replace attendedschool = 0 if sc1q01 !=3  

// Binary Variable for the School Enrollment from age 5-16
gen enrollment5_16 = 1 if sc1q01==3 & age>=5 & age <=16
replace enrollment5_16 = 0 if inlist(sc1q01, 1, 2) & age>=5 & age <=16


// Generating Confounding variables needed 


// 1: household head female 
gen female = 1 if hh_head ==1 & sb1q4 == 2
replace female = 0 if hh_head ==1 & sb1q4 ==1

preserve                                // Save original data state

keep if hh_head == 1                    // Keep only head of household
keep hhcode female                 // Keep only vars we want to merge
duplicates drop hhcode, force           // Ensure only 1 row per hhcode
rename female female_head_hh       // Rename for clarity

tempfile headinfo
save `headinfo'                         // Save head-only file temporarily

restore 

merge m:1 hhcode using `headinfo'

// 2. Head Employement variable (not including it)
//gen head_employed = 0
 
//replace head_employed = 1 if sb1q2==1 & seaq01==1
//replace head_employed = . if sb1q2==1 & missing(seaq01)
//replace head_employed = . if sb1q2==1 & !inlist(seaq01, 0, 1, 2)
//tab head_employed

*if i run logit with the following variable,, the model gives an error (keeping it here for reference)
	//gen head_employed = .
	//replace head_employed = 1 if sb1q2==1 & seaq01==1  // Head worked
	//replace head_employed = 0 if sb1q2==1 & seaq01==2  // Head didn't work


// Starting with basic Logit Models

svy: logit enrollment5_16 i.haboveprimary, or   //basic model 
svy: logit enrollment5_16 i.haboveprimary c.age i.region i.sb1q4 i.female_head_hh , or // adjusted model
svy: logit enrollment5_16 i.haboveprimary c.age##c.age i.region i.sb1q4 i.female_head_hh , or // adjusted model


// Testing Interactions

* A) head educated x region
svy: logit enrollment5_16 i.haboveprimary##i.region c.age i.sb1q4 i.female_head_hh, or

margins i.haboveprimary#i.region, predict(pr)
marginsplot, title("Predicted Enrollment Probability by Education and Region")

* B) head educated x head gender
svy: logit enrollment5_16 i.haboveprimary##i.female_head_hh c.age i.region i.sb1q4, or

margins i.haboveprimary#i.female_head_hh, predict(pr)
marginsplot, title("Predicted Enrollment Probability by Education and Household Head Gender")

* B) head educated x child gender
svy: logit enrollment5_16 i.haboveprimary##i.sb1q4 c.age i.region i.female_head_hh, or

margins i.haboveprimary#i.sb1q4, predict(pr)
marginsplot

// Runnning Tests on our model

estat gof, group(10) // Goodness of fit test

svy, subpop(if region==1): logit enrollment5_16 i.haboveprimary c.age i.sb1q4 i.female_head_hh, // Subpop Test

pwcorr haboveprimary female_head_hh age region sb1q4, sig // Vif not applicable with svy

// Predicted Probability
margins i.haboveprimary#i.female_head_hh, by age( predict(pr)
marginsplot, title("Enrollment Probability by Education and Household Head Gender") ///
    ytitle("Predicted Probability") xtitle("Education > Primary")

