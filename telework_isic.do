clear all
set more off
if "`c(username)'" == "rafse" {
    global root "C:/Users/`c(username)'/Documents/RESEARCH/DingelNeiman-workathome/national_measures/"
}
if "`c(username)'" == "Rafael"  {
    global root "D:/RESEARCH/DingelNeiman-workathome/national_measures/"
}
cd "$root\"

foreach package in listtex {
    capture which `package'
    if _rc==111 ssc install `package'
}


//BN-JD coding of teleworkability
//LOAD NAICS-SOC data
import excel using "$root/input/natsector_M2018_dl.xlsx", clear firstrow
keep if OCC_GROUP=="broad"
//Merge with BN-JD coding of teleworkability
clonevar BroadGroupCode = OCC_CODE
merge m:1 BroadGroupCode using "$root/input/Teleworkable_BNJDopinion.dta", assert(using match) keep(match) nogen
rename Teleworkable teleworkable

//NAICS to ISIC Classification
gen isic_match = 0
replace isic_match = 1 if NAICS == "11"
replace isic_match = 2 if NAICS == "21"
replace isic_match = 3 if NAICS == "31-33"
replace isic_match = 4 if NAICS == "22"
replace isic_match = 5 if NAICS == "56"
replace isic_match = 6 if NAICS == "23"
replace isic_match = 7 if NAICS == "42" | NAICS == "44-45"
replace isic_match = 8 if NAICS == "48-49"
replace isic_match = 9 if NAICS == "72"
replace isic_match = 10 if NAICS == "51"
replace isic_match = 11 if NAICS == "52" | NAICS == "55"
replace isic_match = 12 if NAICS == "53"
replace isic_match = 13 if NAICS == "54"
replace isic_match = 14 if NAICS == "56"
replace isic_match = 15 if NAICS == "92" | NAICS == "99"
replace isic_match = 16 if NAICS == "61"
replace isic_match = 17 if NAICS == "62"
replace isic_match = 18 if NAICS == "71"
replace isic_match = 19 if NAICS == "81"
replace isic_match = 20 if NAICS == "0"
replace isic_match = 21 if NAICS == "0"

* Generate sector labels
label define isic_label 1 `"A"'
label define isic_label 2 `"B"', add
label define isic_label 3 `"C"', add
label define isic_label 4 `"D"', add
label define isic_label 5 `"E"', add
label define isic_label 6 `"F"', add
label define isic_label 7 `"G"', add
label define isic_label 8 `"H"', add
label define isic_label 9 `"I"', add
label define isic_label 10 `"J"', add
label define isic_label 11 `"K"', add
label define isic_label 12 `"L"', add
label define isic_label 13 `"M"', add
label define isic_label 14 `"N"', add
label define isic_label 15 `"O"', add
label define isic_label 16 `"P"', add
label define isic_label 17 `"Q"', add
label define isic_label 18 `"R"', add
label define isic_label 19 `"S"', add
label define isic_label 20 `"T"', add
label define isic_label 21 `"U"', add
label values isic_match isic_label

* Euro Sectors
gen eursec = 0
replace eursec = 1  if isic_match == 1
replace eursec = 2  if isic_match == 2 | isic_match == 3 | isic_match == 4 | isic_match == 5 
replace eursec = 3  if isic_match == 6
replace eursec = 4  if isic_match == 7 | isic_match == 8 | isic_match == 9
replace eursec = 5  if isic_match == 10
replace eursec = 6  if isic_match == 11
replace eursec = 7  if isic_match == 12
replace eursec = 8  if isic_match == 13 | isic_match == 14
replace eursec = 9  if isic_match == 15 | isic_match == 16 | isic_match == 17
replace eursec = 10 if isic_match == 18 | isic_match == 19 | isic_match == 20 | isic_match == 21


label define eurlabel 1 `"A"'
label define eurlabel 2 `"B-E"', add
label define eurlabel 3 `"F"', add
label define eurlabel 4 `"G-I"', add
label define eurlabel 5 `"J"', add
label define eurlabel 6 `"K"', add
label define eurlabel 7 `"L"', add
label define eurlabel 8 `"M_N"', add
label define eurlabel 9 `"O-Q"', add
label define eurlabel 10 `"R-U"', add
label values eursec eurlabel


gen eur_descript = "Agriculture, forestry and fishing"
replace eur_descript = "Industry (except construction)" if eursec == 2
replace eur_descript = "Construction" if eursec == 3
replace eur_descript = "Wholesale and retail trade, transport, accommodation and food service activities" if eursec == 4
replace eur_descript = "Information and communication" if eursec == 5
replace eur_descript = "Financial and insurance activities" if eursec == 6
replace eur_descript = "Real estate activities" if eursec == 7
replace eur_descript = "Professional, scientific and technical activities; administrative and support service activities" if eursec == 8
replace eur_descript = "Public administration, defence, education, human health and social work activities" if eursec == 9
replace eur_descript = "Arts, entertainment and recreation; other service activities; activities of household and extra-territorial organizations and bodies" if eursec == 10


//Generate employment-weighted and wage-weighted means
destring TOT_EMP, replace ig(*)
bys eursec: egen emp_denom  = total(TOT_EMP)
bys eursec: egen emp_numer  = total(teleworkable*TOT_EMP)
replace H_MEAN = "100" if H_MEAN=="#"
destring H_MEAN, replace ig(*)
bys eursec: egen wage_denom = total(H_MEAN*TOT_EMP*(missing(H_MEAN)==0))
bys eursec: egen wage_numer = total(teleworkable*H_MEAN*TOT_EMP*(missing(H_MEAN)==0))
gen teleworkable_emp = emp_numer / emp_denom
gen teleworkable_wage = wage_numer / wage_denom
//Industry-level results
keep eur_descript eursec teleworkable_emp teleworkable_wage
duplicates drop

//Report results in TEX 
tempvar tv1 tv2
egen `tv1' = rank(teleworkable_emp), field
egen `tv2' = rank(teleworkable_emp), track

keep if inrange(`tv1',1,5) | inrange(`tv2',1,5)
gen row = (`tv1')*inrange(`tv1',1,5) + (11-`tv2')*inrange(`tv2',1,5)
list eur_descript teleworkable_emp teleworkable_wage row
gen str tele_emp_str = string(teleworkable_emp,"%3.2f")
gen str tele_wage_str = string(teleworkable_wage,"%3.2f")

listtex eur_descript tele_emp_str tele_wage_str using "D:/RESEARCH/covid-project/data/workfromhome.tex", replace ///
rstyle(tabular) head("\begin{tabular}{lcc} \toprule" "& Unweighted & Weighted by wage\\" "\midrule") foot("\bottomrule \end{tabular}")

// Export to CSV
export delimited eursec eur_descript teleworkable_emp teleworkable_wage using "D:\RESEARCH\covid-project\data\ISIC_workfromhome.csv", replace
