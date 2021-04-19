/*


Objective: Prepare all the descriptive statistics of the paper 



*/

* paths

global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global oil "${data}/Petroleo"
global hk "${data}/HK"
global municipios "${data}/PoliticalBoundaries"
global results "${data}/results"
global compiled "${data}/compiled_sets"
global results "C:/Users/cdelo/Dropbox/HK_Extractives_2020/RESULTS"


* Number of treated per year of IV measure

use "${compiled}/hk_oilwells_colegio_mines.dta", clear



foreach x in 5000 10000 20000 30000{
di "`x'"
	foreach y in   2000 {
		unique id_cole if wells_`y'_`x'>0
	}
	
	sum wells_accum_`x' MAP_`x'
}

unique id_cole



/*
preserve


collapse (mean) wells_*_*, by(id_cole)



hist wells_2000_5000  if wells_2000_5000>10, bin(20)

hist wells_2000_5000  if wells_2000_5000<=10, bin(10)


restore
*/

/*------------------------------------------------------------------------------

								HK DESCRIPTIVES - SCHOOLS 
								
------------------------------------------------------------------------------*/


use "${compiled}/hk_oilwells_colegio_mines.dta", clear

cls



sum enrolment_rate rentseeker_1  uni_1
unique id

use "${compiled}/hk_oilwells_individual_mines.dta", clear

sum pct2 enroled_he if pct2!=.

foreach x in rent_seeker non_rent_seeker_1 semestertohe universitario{
sum `x' if enroled_he==1 
}

/*
sum non_rent_seeker_1 if enroled_he==1 

sum semestertohe if enroled_he==1 
sum universitario if enroled_he==1 

sum universitario

foreach x in 1 0{

di "`x'"

sum pct2 if mujer==`x'
sum enroled_he if pct2!=. & mujer==`x'
sum non_rent_seeker_1 if enroled_he==1 & mujer==`x'

sum rent_seeker if enroled_he==1 & mujer==`x'
sum semestertohe if enroled_he==1 & mujer==`x'
sum universitario if enroled_he==1 & mujer==`x'
}


/*------------------------------------------------------------------------------

								HK DESCRIPTIVES - SCHOOLS 
								
------------------------------------------------------------------------------*/



use "${hk}/harm/hk_colegio.dta", clear
sum enrolment_rate rentseeker_1 uni_1


collapse (first) urbano oficial, by(id_cole)
tab urbano
tab oficial
unique id_cole





