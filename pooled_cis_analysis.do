clear all

ssc install outreg2

* Insert a path to your data

*import excel "G:\My Drive\ECCF\Innovation in SEE - PROF TEVDOVSKI\longitudinal-paper\code\full_ceecs.xlsx", sheet("Sheet1") firstrow
import excel "G:\My Drive\ECCF\Innovation in SEE - PROF TEVDOVSKI\longitudinal-paper\code\full_we.xlsx", sheet("Sheet1") firstrow

* generate variables 
gen lProductivity=log(Lab_prod)
gen innov_input=log(rtot_rat)
gen innov_output=log(turnmar)
gen lfsize = log(Fsize)

encode Industry, gen(ind)
*encode Country, gen(cty)

*This code estimates a CDM model for separate countries using data from the Community Innovation Surveys (CIS).

* The following countries can be selected (based on a 2010-2014 CIS sample):
* BG - Bulgaria
* CZ - Czech Republic
* HU - Hungary
* RO - Romania
* SK - Slovakia
* DE - Germany
* ES - Spain
* NO - Norway
* PT - Portugal

keep if (Country=="PT")

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

ssc install univar
univar Dec_innov innov_input innov_output lProductivity

ssc install asdoc
asdoc sum Dec_innov innov_input innov_output lProductivity, stat(N mean sd min p25 p50 p75 max) replace