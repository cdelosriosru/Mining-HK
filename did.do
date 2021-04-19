 
 
/*

 PROJECT :     	Mining - HK
 AUTHOR :			Camilo De Los Rios
 PURPOSE :			Equation 3 of the presentation. 

 Remeber alll of your schools are secondary education. Bonilla has both primary and secondary, you have off course less schools. 
*/
clear all
set maxvar 120000, perm
global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global oil "${data}/Petroleo"
global hk "${data}/HK"
global municipios "${data}/PoliticalBoundaries"
global results "${data}/results"
global compiled "${data}/compiled_sets"
global results "C:/Users/cdelo/Dropbox/HK_Extractives_2020/RESULTS"
global overleaf "C:/Users/cdelo/Dropbox/Apps/Overleaf/Oil - HK - Colombia"


* * Now a simple DiD * *
 
 
 
use "${compiled}/hk_oilwells_colegio.dta", clear

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}




foreach x in  10000 {
	foreach y in  2000 {
	
		quietly summarize wells_`y'_`x'
		generate wells_`y'_`x'sd = (wells_`y'_`x'-r(mean)) / r(sd)
	
	
		gen w_c_`y'_`x'=wells_`y'_`x'*oil_price
		gen w_b_`y'_`x'=wells_`y'_`x'*brent_price

		label var w_c_`y'_`x' "crude price * number of wells until `y' in `x' buf"
		label var w_b_`y'_`x' "brent price * number of wells until `y' in `x' buf"
		
		
		gen lw_c_`y'_`x'=wells_`y'_`x'sd*loil_price
		gen lw_b_`y'_`x'=wells_`y'_`x'sd*lbrent_price

		label var lw_c_`y'_`x' "log crude price *sd number of wells until `y' in `x' buf"
		label var lw_b_`y'_`x' "log brent price *sd number of wells until `y' in `x' buf"

	}
}

* now with logs






foreach w in 10000 {
	
	quietly summarize wells_accum_`w' 
	generate wells_accum_`w'sd = (wells_accum_`w' -r(mean)) / r(sd)
	
	
}



		* CLEANING THE CONTROL GROUP.

*generating the pure control var

foreach w in 10000 {
	tempvar control_`w'
	bys id_cole: egen `control_`w''=max(wells_accum_`w')
	gen pure_control_`w'=(`control_`w''==0 )
	label var pure_control_`w' "school without oil in buffer `w'in history until 2014"
}




* the diff variable

gen treated=0 if w_b_2000_10000==0 & pure_control_10000!=0
replace treated=1 if wells_accum_10000!=0 & year==2002
replace treated=1 if npozos_10000!=0 & treated==.

tab treated

david kakzon. 



* preguntas para submuestras de carbon y litio 


bys id_cole: egen elmax=max(treated)
gen elyearb=treated*year
bys id_cole: egen elyear=min(elyearb)
replace treated=1 if year>=elyear
recode treated(.=0)
drop elmax elyear*




		* TRENDS
		
* creating department variable
tempvar codmpios
tostring codmpio, gen(`codmpios')
replace `codmpios'="0"+`codmpios' if codmpio<10000
gen deptos=substr(`codmpios',1,2)
destring deptos, gen(depto)

*creating a centered year variable

gen c_year=year-2001
gen c_year2=c_year*c_year
gen c_year3=c_year*c_year2
gen c_year4=c_year*c_year3

* creating simple year group vars
egen t_mpio=group(codmpio year)
egen t_dep=group(depto year)
egen t_etc=group(etc_id year)


reghdfe enrolment_rate treated , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) 



foreach x in  2000 {
	foreach w in  10000  {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  enrolment_rate rentseeker_1  uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				
		

				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) 
				estimates store rred_`y'_`w'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}
