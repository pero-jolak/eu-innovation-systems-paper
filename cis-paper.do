* This code needs to be run separately for each country in order to reproduce the results from the manuscript.
clear all


* Insert a path to your data

*import excel "/Users/jolakoskip/Desktop/full_ceecs.xlsx", sheet("Sheet1") firstrow
import excel "/Users/jolakoskip/Desktop/full_we.xlsx", sheet("Sheet1") firstrow

* generate variables 
gen lProductivity=log(Lab_prod)
gen innov_input=log(rtot_rat)
gen innov_output=log(turnmar)
gen lfsize = log(Fsize)

encode Industry, gen(ind)
*encode Country, gen(cty)

*Choose a country
* The countries need to be specified below through their 2-digit ISO code.
* The options are:
* Bulgaria - BG
* Czech Republic - CZ
* Hungary - HU
* Romania - RO
* Slovakia - SK
* Germany - DE
* Spain EC
* Norway NO
* Portugal PT

keep if (Country=="ES")

* DECISION TO INNOVATE
probit Dec_innov lfsize Marnat Mareur Maroth GP Inaba Org_innov Mark_innov i.year, robust
margins, dydx(*)

outreg2 using wes_decision_to_innovate.doc, dec(3) ctitle(Decision to innovate) replace 

predict Edec_innov 
gen mills = exp(-.5*Edec_innov^2)/(sqrt(2*_pi)*normprob(Edec_innov))

* INNOVATION INPUT
heckman innov_input lfsize Marnat Mareur Maroth GP Inaba Org_innov Mark_innov Funloc Fungmt Funeu i.year, select(Dec_innov = lfsize Marnat Mareur Maroth GP Inaba Org_innov Mark_innov i.year) robust iter(20)
*margins, dydx(*)

outreg2 using wes_innovation_input.doc, dec(3) ctitle(innovation_input) replace 

* predict expected RND Intensity *
predict Einnov_input 

* INNOVATION OUTPUT + LABOUR PRODUCTIVITY
reg3 (innov_output lfsize mills Einnov_input lProductivity Org_innov Mark_innov Funloc Fungmt Funeu i.year) (lProductivity lfsize innov_output Inpdtg1 Inpdtg2 Org_innov Mark_innov i.year), 
*margins, dydx(*)

* Inpdtg1 Inpdtg2 Inpsdv1 Inpsdv2
outreg2 using wes_innovation_output.doc, dec(3) ctitle(innovation_output) replace 
