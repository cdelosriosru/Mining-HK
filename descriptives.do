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
unique id_cole if urbano==1
unique id_cole if urbano==0



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

foreach x in engistemi admin_econ others semestertohe universitario{
sum `x' if enroled_he==1 
}

keep if year_prim<2011
sum graduado if enroled_he==1 

sum graduado if enroled_he==1




/*------------------------------------------------------------------------------
			Wages
------------------------------------------------------------------------------*/

use "${compiled}/hk_oilwells_individual_mines_wages_clean.dta", clear


keep year year_prim TibcpA TibcpA year_grad pct2 id_cole annonac mujer date_grad graduated enroled_he technic age exp_ min_wage wage_adj lnwage_adj

ttest wage, by(technic)



gen uni=1 if technic==0 & enroled_he==1
replace uni=2 if technic==1
replace uni=3 if enroled==0

tab enroled_he technic

forvalues x=2008(1)2014{

sum wage_adj if year==`x'
di "`x'"
}

reg wage i.uni i.year

sum TibcpA, d

gen wage_adj=TibcpA/min_wage
gen lnwage_adj=ln(wage_adj+1)



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





