
***** Caste Based crimes paper ******
*** 5th June 023 **

**** data preparation ****** doing for each state *****

import excel "C:\Users\user\Documents\development_project\Data\woking data_election.xlsx", sheet("maharashtra") firstrow

     

// education gradute dummy
generate educdum = 0
replace educdum = 1 if (MyNeta_education == "Graduate Professional" | MyNeta_education == "Post Graduate"|MyNeta_education == "Graduate"|MyNeta_education == "Doctorate"|)
label variable	educdum	"graduate dummy"


// filter out the close elections and graduates vs non graduates
// create for each state winner opppo dataset in excel with filter on margin of victory and educ level
// merge based on constituency number for each state separately and filter out the 


// filter out the close elections


keep if Position == 2 | (Position == 1 & Margin_Percentage <= 10)

duplicates report Position
bysort Position: gen count = _N
drop if count == 1 | count == .
drop count

// filter out the  graduates vs non graduates
keep if Constituency_No[n] = Constituency_No[n+1]  Position == 1 & educdum == 1 | Position == 2 & educdum == 0
