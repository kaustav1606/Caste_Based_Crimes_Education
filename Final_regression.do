***** Caste Based crimes paper ******
*** 12 th  June 2024 ***
*** Final Regression ***
**** data preparation ******

import excel "C:\Users\user\Documents\development_project\Final_Data_new.xlsx", sheet("stata") firstrow clear
drop in 1384
set matsize 4000

egen statenum = group(state)

egen stateyear=group(statenum year)
egen disnum = group(district)
xtset disnum year


tab state, g(state)

sum state*
***gen state_year = statenum * year



sort disnum year
sum disnum year
codebook disnum
egen distyear=group(disnum year)
sum distyear 

qui tab district, g(distt)
qui tab year, g(yeard)


**** margin variables ******


forval i = 1/15 {
    gen dum`i' = m`i' != .
}



local varlist "m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 m13 m14 m15"

**** polynomials for RDD ******

foreach var of local varlist{
replace `var'=0 if `var'==.
gen `var's2=`var'^2
gen `var's3=`var'^3
gen `var's4=`var'^4
gen `var's5=`var'^5
gen `var's6=`var'^6
}


**** polynomials for RDD ******
global margin1 dum1-dum15 m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 m13 m14 m15
global margin2 dum1-dum15 m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 m13 m14 m15 m1s2 m2s2 m3s2 m4s2 m5s2 m6s2 m7s2 m8s2 m9s2 m10s2 m11s2 m12s2 m13s2 m14s2 m15s2
global margin3 dum1-dum15 m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 m13 m14 m15 m1s2 m2s2 m3s2 m4s2 m5s2 m6s2 m7s2 m8s2 m9s2 m10s2 m11s2 m12s2 m13s2 m14s2 m15s2 m1s3 m2s3 m3s3 m4s3 m5s3 m6s3 m7s3 m8s3 m9s3 m10s3 m11s3 m12s3 m13s3 m14s3 m15s3


****dummies for various robustness ******
gen bimarou=( statenum ==2|statenum ==3|statenum ==5|statenum ==8|statenum ==10|statenum ==11|statenum==13)
gen highHDI=( statenum ==15|statenum ==12|statenum ==9|statenum ==7)
gen electionyr = (( statenum == 14 | statenum == 7 | statenum == 12 )& year == 2011)
replace electionyr = (( statenum == 4 |statenum == 13 )& year == 2012)
replace electionyr = (( statenum == 3 |statenum == 6 | statenum == 8 |statenum == 11 )& year == 2013)
gen mediumHDI = ( statenum==1|statenum==4|statenum==6|statenum==11|statenum==14)
gen propSCSTpopl2 = propSCSTpopl^2


sum SCcrime_rate SC_Act_crime murder_SC_rate rape_SC_rate SCcrime SC_Act_crime if highHDI ==1
sum SCcrime_rate SC_Act_crime murder_SC_rate rape_SC_rate SCcrime SC_Act_crime if mediumHDI ==1
sum SCcrime_rate SC_Act_crime murder_SC_rate rape_SC_rate SCcrime SC_Act_crime if mediumHDI ==0 & highHDI ==0


sum propSCSTseat ruralprop illiterateprop nonworkerprop nonworkermaleprop propSCSTpopl propSCSTpopl2 electionyr proptotalclose propgrad propclosegrad 
 

macro define demog1 "propSCSTseat ruralprop illiterateprop nonworkerprop nonworkermaleprop propSCSTpopl propSCSTpopl2 electionyr"

**** regression vary by BIMAROU, fixed effects, controls, margin, dependent variable

***** all states with total crime *****

****xtivreg2 SCcrime_rate (women=close) totalclose $margin3 $demog1 i.bord i.mult i.yearc i.state*yearc if `var'_exp==1 , fe  i(seqid) robust cluster(distcode) first nonworkerprop

xtivreg SCcrime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum i.disnum (propgrad = propclosegrad), re vce(cluster disnum)

xtivreg SCcrime proptotalclose $margin3 $demog1 i.stateyear i.year (propgrad = propclosegrad), re  vce(cluster disnum)


xtivreg ln_SCcrime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad), fe  vce(cluster disnum)
outreg2 using crime.doc, replace ctitle(All states IPC crime)

xtivreg ln_SCcrime_rate proptotalclose $margin2 $demog1 i.stateyear i.year (propgrad = propclosegrad), fe  vce(cluster disnum)
outreg2 using crime.doc, append ctitle(All states IPC crime)

xtivreg ln_SCcrime_rate proptotalclose $margin2 $demog1 (propgrad = propclosegrad), fe  vce(cluster disnum)
outreg2 using crime.doc, append ctitle(All states IPC crime wihout all)



xtivreg ln_SCcrime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad), re  vce(cluster disnum)


***** all states with act crime *****

xtivreg ln_SC_Act_crime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum i.disnum (propgrad = propclosegrad), fe  vce(cluster disnum)


xtivreg SC_Act_crime proptotalclose $margin3 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad), re  vce(cluster disnum)



xtivreg ln_SC_Act_crime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad), fe  vce(cluster disnum)
outreg2 using crime.doc, append ctitle(All states SLL crime)

xtivreg ln_SC_Act_crime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum i.disnum (propgrad = propclosegrad), re  vce(cluster disnum)


xtivreg ln_SC_Act_crime_rate proptotalclose $margin2 $demog1 i.stateyear i.year (propgrad = propclosegrad), fe  vce(cluster disnum)
outreg2 using crime.doc, append ctitle(All states SLL crime without state)

xtivreg ln_SC_Act_crime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad), re  vce(cluster disnum)



***** BIMAROU/NON states with act crime *****


xtivreg ln_SC_Act_crime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) if bimarou ==1, fe  vce(cluster disnum)
outreg2 using crime_bimarou.doc, replace ctitle(All states SLL crime bimarou state)


xtivreg ln_SC_Act_crime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) if bimarou ==0, fe  vce(cluster disnum)
outreg2 using crime_bimarou.doc, append ctitle(All states SLL crime nonbimarou state)



***** BIMAROU/NON states with total crime *****


xtivreg ln_SCcrime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) if bimarou ==1, fe  vce(cluster disnum)
outreg2 using crime_bimarou.doc, append ctitle(All states IPC crime bimarou state)

xtivreg ln_SCcrime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) if bimarou ==0, fe  vce(cluster disnum)
outreg2 using crime_bimarou.doc, append ctitle(All states IPC crime nonbimarou state)


***** high HDI/NON states with total crime *****

xtivreg ln_SC_Act_crime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum i.disnum (propgrad = propclosegrad) if highHDI ==1, re  vce(cluster disnum) first



xtivreg SC_Act_crime proptotalclose $margin3 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) if bimarou ==0, re  vce(cluster disnum)






outreg2 using crime_hdi.doc, replace ctitle(highhdi SLL crime)


xtivreg ln_SCcrime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) if highHDI ==1, fe  vce(cluster disnum)
outreg2 using crime_hdi.doc, append ctitle(highhdi IPC crime used)





xtivreg ln_SC_Act_crime_rate proptotalclose $margin3 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) if mediumHDI ==1, fe  vce(cluster disnum)
outreg2 using crime_hdi.doc, append ctitle(mediumhdi SLL crime used)




xtivreg ln_SCcrime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) if mediumHDI ==1, fe  vce(cluster disnum)
outreg2 using crime_hdi.doc, append ctitle(mediumhdi IPC crime used)



xtivreg ln_SC_Act_crime_rate proptotalclose $margin3 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) if mediumHDI ==0 & highHDI ==0, fe  vce(cluster disnum)
outreg2 using crime_hdi.doc, append ctitle(lowhdi SLL crime used)




xtivreg ln_SCcrime_rate proptotalclose $margin2 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) if mediumHDI ==0 & highHDI ==0, fe  vce(cluster disnum)
outreg2 using crime_hdi.doc, append ctitle(lowhdi IPC crime used)





xtivreg ln_SC_Act_crime_rate proptotalclose $margin3 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) if mediumHDI ==1, re  vce(cluster disnum)



***** Specific Crimes *****


xtivreg ln_murder_SC_rate proptotalclose $margin3 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) , re  vce(cluster disnum) first small


xtivreg ln_rape_SC_rate proptotalclose $margin3 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) , re  vce(cluster disnum) first small



xtivreg murder proptotalclose $margin3 $demog1 i.stateyear i.year i.statenum (propgrad = propclosegrad) , re  vce(cluster disnum) first small





















