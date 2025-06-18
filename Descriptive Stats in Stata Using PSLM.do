// ASSIGNMENT - 2 - Shujaat: Use of Merge, Creating New Variable, and Basic Descriptive Stats 


use "D:\STATA\stata_data_pslm_2019_20\stata data\plist.dta" 

* merging two files
merge 1:1 hhcode idc using "D:\STATA\stata_data_pslm_2019_20\stata data\secc2.dta"


// Q1: Districts in Each Province with highest use of SmartPhones?

codebook sc2q06
tab district sc2q06 if province==1,row nof
tab district sc2q06 if province==2,row nof
tab district sc2q06 if province==3,row nof
tab district sc2q06 if province==4,row nof

* In Punjab, Rawalpindi with 35.8%, 
* In KPK, Abbotabad with 31.4% 
* In Sindh, Karachi East with 42.4%
* In Balochistan, Kohlu with 42.2%


// Q2: Which Age Group has highest smartphone usage?

* Generating a new variable for Age Group

gen age_group = " 5-20" if age>=5 & age<=20
replace age_group = "20-40"  if age>20 & age<=40
replace age_group = "Above 40" if age>40
replace age_group ="Below 5" if age<5
codebook age age_group
tab age_group sc2q06,col nof

* The age group of 20-40 has the highest usage of Smartphones at 46%


// Q3: District in each province with highest Unemployement? 

clear

* merging two files
use "D:\STATA\stata_data_pslm_2019_20\stata data\plist.dta" 
merge 1:1 hhcode idc using "D:\STATA\stata_data_pslm_2019_20\stata data\sece.dta"

*finding unemployement variables
br age  seaq01 seaq06
count if seaq01==2 & seaq06 != .
count if seaq01==2 & seaq06 == .
drop if age<10
count if seaq01==2 & seaq06 == .
count if seaq01==. & seaq06 == .
count if seaq06==.

*generating a new variable for employment status
gen Employement_Status= " Employed" if seaq06 != .
replace Employement_Status = "Unemployed" if seaq06==.
tab Employement_Status

*tabulating unemployment by district
tab district Employement_Status if province==1, col nof
tab district Employement_Status if province==1, row nof
tab district Employement_Status if province==2, row nof
tab district Employement_Status if province==3, row nof
tab district Employement_Status if province==4, row nof

* In Punjab, Narowal has the highest unemployment rate of 73%, 
* In KPK, Hangu has the highest unemployment rate of 80% 
* In Sindh, Karachi East has the highest unemployment rate of 65%
* In Balochistan, Killah Abdullah has the highest unemployment rate of 73.5%


// Q4: Age Group with Highest unemployment?


gen age_group = " 10-20" if age>=10 & age<=20
replace age_group = "20-30"  if age>20 & age<=30
replace age_group = "30-40"  if age>30 & age<=40
replace age_group = "Above 40" if age>40
tab age_group
tab age_group Employement_Status, row nof

* the highest unemployment rate lies btw the age group of 10-20 years at 86%


// Q5: Age group with highest Female unemployment? 

tab age_group sb1q4 if Employement_Status=="Unemployed", row nof

* Females between the age of 30-40 have high unemployment rate of 95%


// Q6: Plot a bar chart of Average expenditure on education by gender and province 


clear 
use "D:\STATA\stata_data_pslm_2019_20\stata data\plist.dta" 
merge 1:1 hhcode idc using "D:\STATA\stata_data_pslm_2019_20\stata data\secc1.dta"

graph bar (mean) sc1q19i, over(sb1q4) over(province) title("Average Expenditure on Education"),
>  size(medlarge) color(black))
  