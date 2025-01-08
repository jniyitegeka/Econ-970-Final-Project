version 18

clear all

capture log close

cd "/Users/jules/Downloads/econ970fp "
log using "Output/score.log", replace

*************************************************************************** Section 1: Cleaning the datasets *********************************************************************************

*** importing datasets from collegeScore Card using forvalues
forvalues i = 2011/2022 {
    clear
    import delimited "rawdata/MERGED`i'.csv"
    gen year = `i'
    save "rawdata/score`i'.dta", replace
}

** interested in variable default rates after 3 years that started being collected in which is 2011
***: adding observations in my in 1 dataset using append option
forvalues i = 2011/2022 {
    append using "rawdata/score`i'.dta", force
	save "rawdata/score_2011_2022.dta", replace 
}

***: cleaning the final datasets

use "rawdata/score_2011_2022.dta", replace 



keep year instnm city stabbr zip control iclevel adm_rate st_fips sat_avg ugds ugds_white ugds_black ugds_hisp ugds_asian ugds_aian ugds_nhpi ugds_2mor ugds_nra ugds_unkn c150_4 cdr3 num41_pub num42_pub num43_pub num44_pub num45_pub num41_priv num42_priv num43_priv num44_priv num45_priv grad_debt_mdn wdraw_debt_mdn pctfloan pctpell 

** Adding labels
label variable year "Year"
label variable instnm "Institution Name"
label variable city "City"
label variable stabbr "State Abbreviation"
label variable zip "ZIP Code"
label variable control "Control Type (Public/Private)"
label variable iclevel "Level of Institution"
label variable adm_rate "Admission Rate"
label variable st_fips "State FIPS Code"
label variable sat_avg "Admitted Students Average SAT "
label variable ugds "Enrollment of Undergraduates"
label variable ugds_white " White Undergraduates %"
label variable ugds_black "Black Undergraduates %"
label variable ugds_hisp " Hispanic Undergraduates %"
label variable ugds_asian "Asian Undergraduates %"
label variable ugds_aian "American Indian/Alaska Native Undergraduates %"
label variable ugds_nhpi "Native Hawaiian/Pacific Islander %"
label variable ugds_2mor "Share of Undergraduate Degree-Seeking Students Who Are Two or More Races"
label variable ugds_nra "Share of Undergraduate Degree-Seeking Students Who Are Non-Resident Aliens"
label variable ugds_unkn "Share of Undergraduate Degree-Seeking Students Whose Race Is Unknown"
label variable pctpell "Students Receiving Pell Grants %"
label variable c150_4 "150% Normal Time Completion Rate for Four-Year Institutions"
label variable pctfloan "Students Receiving a Federal Student Loan %"
label variable cdr3 "3-Year Cohort Default Rate"
label variable num41_pub "Number of Title IV students, $0-$30,000 family income (public institutions)"
label variable num42_pub "Number of Title IV students, $30,001-$48,000 family income (public institutions)"
label variable num43_pub "Number of Title IV students, $48,001-$75,000 family income (public institutions)"
label variable num44_pub "Number of Title IV students, $75,001-$110,000 family income (public institutions)"
label variable num45_pub "Number of Title IV students, $110,000+ family income (public institutions)"
label variable num41_priv "Number of Title IV students, $0-$30,000 family income (private for-profit and nonprofit institutions)"
label variable num42_priv "Number of Title IV students, $30,001-$48,000 family income (private for-profit and nonprofit institutions)"
label variable num43_priv "Number of Title IV students, $48,001-$75,000 family income (private for-profit and nonprofit institutions)"
label variable num44_priv "Number of Title IV students, $75,001-$110,000 family income (private for-profit and nonprofit institutions)"
label variable num45_priv "Number of Title IV students, $110,000+ family income (private for-profit and nonprofit institutions)"

order year instnm city stabbr st_fips zip control iclevel cdr3


*** Clean the variables of interest
// Define the list of variables
local vars  adm_rate sat_avg ugds ugds_white ugds_black ugds_hisp ugds_asian ugds_aian ugds_nhpi ugds_2mor ugds_nra ugds_unkn c150_4 cdr3 num41_pub num42_pub num43_pub num44_pub num45_pub num41_priv num42_priv num43_priv num44_priv num45_priv grad_debt_mdn wdraw_debt_mdn pctfloan pctpell 

// Loop through variables to clean non-numeric values
foreach var of local vars {
    replace `var' = "." if inlist(`var', "NA", "PS", "") // Replace "NA", "PS", and blanks with missing
}
// Convert all variables to numeric
destring `vars', replace


** Creating average family income and average student debt variables from the available data

* Step 1: Define Midpoints for Income Brackets
gen midpoint_0_30000 = 15000
gen midpoint_30001_48000 = 39000
gen midpoint_48001_75000 = 61500
gen midpoint_75001_110000 = 92500
gen midpoint_110001_plus = 120000

* Step 3: Calculate Weighted Income for Public Institutions, Ignoring Missing Values
gen weighted_income_0_30000 = cond(missing(num41_pub), 0, num41_pub * midpoint_0_30000)
gen weighted_income_30001_48000 = cond(missing(num42_pub), 0, num42_pub * midpoint_30001_48000)
gen weighted_income_48001_75000 = cond(missing(num43_pub), 0, num43_pub * midpoint_48001_75000)
gen weighted_income_75001_110000 = cond(missing(num44_pub), 0, num44_pub * midpoint_75001_110000)
gen weighted_income_110001_plus = cond(missing(num45_pub), 0, num45_pub * midpoint_110001_plus)

* Step 4: Calculate Total Weighted Income and Total Students for Public Institutions
gen total_weighted_income_pub = weighted_income_0_30000 + weighted_income_30001_48000 + weighted_income_48001_75000 + weighted_income_75001_110000 + weighted_income_110001_plus

gen total_students_pub = cond(missing(num41_pub), 0, num41_pub) + ///
                         cond(missing(num42_pub), 0, num42_pub) + ///
                         cond(missing(num43_pub), 0, num43_pub) + ///
                         cond(missing(num44_pub), 0, num44_pub) + ///
                         cond(missing(num45_pub), 0, num45_pub)
* Step 5: Calculate Average Family Income for Public Institutions
gen average_income_pub = cond(total_students_pub == 0, ., total_weighted_income_pub / total_students_pub)

* Step 6: Calculate Weighted Income for Private (Including For-Profit) Institutions, Ignoring Missing Values
gen weighted_income_priv = cond(missing(num41_priv), 0, num41_priv * midpoint_0_30000) + ///
                           cond(missing(num42_priv), 0, num42_priv * midpoint_30001_48000) + ///
                           cond(missing(num43_priv), 0, num43_priv * midpoint_48001_75000) + ///
                           cond(missing(num44_priv), 0, num44_priv * midpoint_75001_110000) + ///
                           cond(missing(num45_priv), 0, num45_priv * midpoint_110001_plus)

* Step 7: Calculate Total Students for Private Institutions
gen total_students_priv = cond(missing(num41_priv), 0, num41_priv) + cond(missing(num42_priv), 0, num42_priv) + ///
                          cond(missing(num43_priv), 0, num43_priv) + cond(missing(num44_priv), 0, num44_priv) + ///
                          cond(missing(num45_priv), 0, num45_priv)

* Step 8: Calculate Average Family Income for Private Institutions
gen average_income_priv = cond(total_students_priv == 0, ., weighted_income_priv / total_students_priv)

* Step 9: Drop All Generated Variables Except average_income_pub and average_income_priv
drop midpoint_0_30000 midpoint_30001_48000 midpoint_48001_75000 midpoint_75001_110000 midpoint_110001_plus
drop weighted_income_0_30000 weighted_income_30001_48000 weighted_income_48001_75000 weighted_income_75001_110000 weighted_income_110001_plus
drop total_weighted_income_pub total_students_pub
drop weighted_income_priv total_students_priv
drop num41_pub num42_pub num43_pub num44_pub num45_pub num41_priv num42_priv num43_priv num44_priv num45_priv

* Step 10: Add Labels to Remaining Variables
label variable average_income_pub "Average Public inst Student Family Income($)"
label variable average_income_priv "Average Private inst Student Family Income ($)"



*** Average debt calculation
* Step 1: Replace Missing Values with Zero
gen grad_debt_mdn_clean = cond(missing(grad_debt_mdn), 0, grad_debt_mdn)
gen wdraw_debt_mdn_clean = cond(missing(wdraw_debt_mdn), 0, wdraw_debt_mdn)

* Step 2: Calculate Total Debt
gen total_avg_debt = grad_debt_mdn_clean + wdraw_debt_mdn_clean

* Step 3: Replace Total Debt with the Average if Both Variables Are Non-Zero
replace total_avg_debt = (grad_debt_mdn_clean + wdraw_debt_mdn_clean) / 2 if grad_debt_mdn_clean > 0 & wdraw_debt_mdn_clean > 0

drop grad_debt_mdn_clean wdraw_debt_mdn_clean

label variable total_avg_debt "Student Average Debt (Completed+Withdrawn)"


******************************************************************************************Section 2: EDA **************************************************************************************
***** Visualization of the variable of interest across different institution to see if the trends are same with the existing literature paper

// Replace values of institution type with the desired strings
tostring iclevel, replace
replace iclevel = "4-year" if iclevel == "1"
replace iclevel = "2-year" if iclevel == "2"
replace iclevel = "Less-than-2-year" if iclevel == "3"

tostring control, replace
replace control = "public" if control == "1"
replace control = "private nonprofit" if control == "2"
replace control = "private for-profit" if control == "3"
replace control = "foreign" if control == "4"



* Create separate variables for each category
gen cdr3_public = cdr3 if control == "public"
gen cdr3_private_forprofit = cdr3 if control == "private for-profit"
gen cdr3_private_nonprofit = cdr3 if control == "private nonprofit"
gen cdr3_4year = cdr3 if iclevel == "4-year"
gen cdr3_2year = cdr3 if iclevel == "2-year"
gen cdr3_1year = cdr3 if iclevel == "Less-than-2-year"

* Label the new variables
label variable cdr3_public "Public Institutions"
label variable cdr3_private_forprofit "Private For-Profit Institutions"
label variable cdr3_private_nonprofit "Private Nonprofit Institutions"
label variable cdr3_4year "4-Year Institutions"
label variable cdr3_2year "2-Year Institutions"
label variable cdr3_1year "Less-than-2-Year Institutions"


* Create side-by-side histograms using facet wrapping
graph bar cdr3_public cdr3_private_forprofit cdr3_private_nonprofit ///
    cdr3_4year cdr3_2year cdr3_1year, ///
    over(year, label(angle(45))) ///
    bar(1, color(blue)) ///
    bar(2, color(red)) ///
    bar(3, color(green)) ///
    bar(4, color(purple)) ///
    bar(5, color(orange)) ///
    bar(6, color(gray)) ///
    ytitle("3-Year Default Rate") ///
    title("Default Rate by Institution Type Over Time") label
 

*********** summary table for the dataset
* Create a new variable for 2-year intervals
gen year_group = year if mod(year, 2) == 0

* Summarize variables by 2-year intervals
bysort year_group: eststo: estpost sum cdr3 adm_rate sat_avg ugds ugds_white ugds_black ugds_hisp ugds_asian ugds_aian ugds_nhpi c150_4 ///
average_income_pub average_income_priv total_avg_debt pctfloan pctpell 

* Generate the table with reduced column space
esttab using "Output/summary.doc", main(mean) aux(sd) rtf replace label varwidth(30) ///
    title("Table 2: Summary Statics for Variables of Interest Over the Years") mtitle("2011" "2013" "2015" "2017" "2019" "2021") nonotes ///
    addnotes("NOTE: Table reports weighted averages with standard deviations in parentheses from 2011-2022 jumping in 2-year intervals") ///
    b(%9.2f) compress


************************************************************************************Section 3: Analysis *********************************************************************************
** Aggregating data on state level to be able to do the difference in difference
** for categorical variable picked the majority institutions
encode stabbr, gen(state_code)

bysort state_code year: egen mode_control = mode(control)
bysort state_code year: egen mode_iclevel = mode(iclevel)

gen priv_forprofit = (mode_control == "private for-profit")
gen priv_nonprofit = (mode_control == "private nonprofit")
gen public = (mode_control == "public")
gen foreign = (mode_control == "foreign")

gen yrs_coll_4 = (mode_iclevel == "4-year")
gen yrs_coll_2 = (mode_iclevel == "2-year")
gen yrs_coll_less_2 = (mode_iclevel == "Less-than-2-year")

collapse (mean) adm_rate sat_avg pctfloan ugds ugds_white ugds_black ugds_hisp ugds_asian ugds_aian ugds_nhpi ugds_2mor ugds_nra ugds_unkn c150_4 cdr3 pctpell total_avg_debt average_income_pub average_income_priv (first) priv_forprofit priv_nonprofit public foreign yrs_coll_4 yrs_coll_2 yrs_coll_less_2 , by(state_code year)

**Declaring the dataset as panel dataset
xtset state_code year



*** DIfference In Difference
ssc install drdid, all replace
ssc install csdid, all replace

* Initialize the group treatment variable
gen groupvar = 0

* Assign event years for each state
* group the bills together
replace groupvar = 2016 if state_code == 29 // Missouri
replace groupvar = 2017 if state_code == 6 // California
replace groupvar = 2018 if state_code == 18  |  state_code == 24 | state_code == 44  // Illinois, Maryland, Pennsylvania
replace groupvar = 2019 if state_code == 23 // Massachusetts
replace groupvar = 2020 if state_code == 50 |  state_code == 53   // Tennessee, Virginia
replace groupvar = 2021 if state_code == 37  // New Jersey
replace groupvar = 2022 if state_code == 10  // Delaware


* generate treated variable or not
gen treated = 0
replace treated = 1 if groupvar != 0

**** Difference in difference across different categories

***DiD no controls
csdid cdr3, cluster(state_code) time(year) gvar(groupvar) method(reg)
estat simple,estore(model1)
estat event, estore(model5)

csdid_plot, title("Event Study with No Controls")
graph export "Output/no_controls.png", replace

**DiD all controls
csdid cdr3 adm_rate sat_avg ugds ugds_white ugds_black ugds_hisp ugds_asia priv_forprofit priv_nonprofit yrs_coll_4 yrs_coll_2, cluster(state_code) time(year) gvar(groupvar) method(reg)
estat simple,estore(model2)
estat event, estore(model6)

csdid_plot, title("Event Study with All Controls")
graph export "Output/all_controls.png",replace

*** time varying
csdid cdr3 adm_rate sat_avg pctpell total_avg_debt average_income_pub average_income_priv, cluster(state_code) time(year) gvar(groupvar) method(reg)
estat simple, estore(model3)
estat event, estore(model7)

csdid_plot, title("Event Study with Time Varying Controls")
graph export "Output/varying_controls.png", replace


*** non-time varying
csdid cdr3 ugds ugds_white ugds_black ugds_hisp ugds_asian priv_forprofit priv_nonprofit yrs_coll_4 yrs_coll_2, cluster(state_code) time(year) gvar(groupvar) method(reg)
estat simple, estore(model4)

estat event, estore(model8)
csdid_plot, title("Event Study with Non-varying Time Controls")
graph export "Output/nonvarying_controls.png", replace

etable, estimates(model5 model6 model7 model8) ///
    keep(Pre_avg Post_avg) ///
    title("Average Treatment Effect on the Treated States") ///
    mstat(N) mstat(F) mstat(r2) name(TableCollection1) ///
    column(index) ///
    export("Output/mycsdid4.docx"), replace

etable, estimates(model1 model2 model3 model4) ///
    title("Average Treatment Effect on the Treated States (Additional Models)") ///
    mstat(N) mstat(F) mstat(r2) ///
    column(index) ///
   export("Output/myatt4.docx"),replace ///
   


   




