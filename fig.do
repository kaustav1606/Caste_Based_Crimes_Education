
***** Caste Based crimes paper ******
*** 30 th  June 2024 ***
*** Figures used ***


**** data import ******

global root "C:/Users/user/Documents/development_project/code/stata"
set more off

cd $root

import excel "C:\Users\user\Documents\development_project\Final_Data_new.xlsx", sheet("margin_grad_sheet") firstrow clear




**rename value Margin
**label variable Margin "win margin"

/* Figure 2 */
/* Panel a */
DCdensity Margin, breakpoint(0) generate(Xj Yj r0 fhat se_fhat) 
nograph
local h=r(bandwidth)
drop Xj Yj r0 fhat se_fhat
DCdensity Margin, breakpoint(0) h(`h') generate(Xj Yj r0 fhat se_fhat) 
drop Xj Yj r0 fhat se_fhat

*/
graph export "McCary_Test.pdf", replace

/* Panel b*/

histogram Margin, normal xline(0, lw(medthick)) xtitle(Victory Margin)
graph export "Histogram.pdf", replace
********************************************************************************



///** panel 2a*** margin vs grad prop////




*gen bins:
gen bin=.
local k=0.01
forvalues i=1/100{
replace bin=`i' if Margin>=(0+(`i'-1)*(`k')) & Margin<(0+(`i')*(`k'))
replace bin=-`i' if Margin>(0-(`i')*(`k'))& Margin<=(0-(`i'-1)*(`k'))
}
gen midbin=.
forvalues i=1/100{
replace midbin=((0+(`i'-1)*(`k'))+(0+(`i')*(`k')))/2 if bin==`i'
replace midbin=((0-(`i')*(`k'))+(0-(`i'-1)*(`k')))/2 if bin==-`i'
}
*gen observations=sample
sort midbin

collapse(mean) propgrad Margin   , by(midbin)


#delimit cr
label var midbin "margin of victory grad-nongrad elections"

#delimit ;
twoway (scatter  propgrad midbin  , sort msize(small)xline(0) xlabel(-1(0.1)1)  legend(off) ) 
(lowess propgrad midbin if Margin>0  ,    sort msymbol(none) clcolor(black) clpat(solid) clwidth(thick))
(lowess propgrad midbin if Margin<0   ,  sort msymbol(none) clcolor(black) clpat(solid) clwidth(thick))


,scheme(s2mono) 

;

graph export "margin of victory grad-nongrad elections.pdf", replace


///** panel 2b*** margin vs lnSC crimerate////



*gen bins:
gen bin=.
local k=0.01
forvalues i=1/100{
replace bin=`i' if Margin>=(0+(`i'-1)*(`k')) & Margin<(0+(`i')*(`k'))
replace bin=-`i' if Margin>(0-(`i')*(`k'))& Margin<=(0-(`i'-1)*(`k'))
}
gen midbin=.
forvalues i=1/100{
replace midbin=((0+(`i'-1)*(`k'))+(0+(`i')*(`k')))/2 if bin==`i'
replace midbin=((0-(`i')*(`k'))+(0-(`i'-1)*(`k')))/2 if bin==-`i'
}
*gen observations=sample
sort midbin

collapse(mean) ln_SCcrime_rate Margin   , by(midbin)


#delimit cr
label var midbin "margin of lnSC crimerate"

#delimit ;
twoway (scatter  ln_SCcrime_rate midbin  , sort msize(small)xline(0) xlabel(-1(0.1)1)  legend(off) ) 
(lowess ln_SCcrime_rate midbin if Margin>0  ,    sort msymbol(none) clcolor(black) clpat(solid) clwidth(thick))
(lowess ln_SCcrime_rate midbin if Margin<0   ,  sort msymbol(none) clcolor(black) clpat(solid) clwidth(thick))


,scheme(s2mono) 

;



///actual correct** panel 3*** margin vs lnSC crimerate////

rd ln_SCcrime_rate Margin, z0(0) nogr /*This is to generate IK bandwidth */
local h_opt :  display %4.2f `e(w)'
rdd_plot  ln_SCcrime_rate, includedbw(10)  control(mov_baseline) binsize(0.5)  bw(`h_opt') title("Light growth") xtitle("margin of victory (%)")   yscale(-30(10)30) xscale(-10(5)10)




graph export "Figure-4.pdf", replace


