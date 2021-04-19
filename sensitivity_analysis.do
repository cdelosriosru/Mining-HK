
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


/*------------------------------------------------------------------------------

				SENSITIVITY TO IV Buffer

------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------
						 SCHOOLS
------------------------------------------------------------------------------*/

use "${compiled}/hk_oilwells_colegio_mines.dta", clear

* First create your treatment variables. 

foreach y in 5000 20000 30000 10000{

	foreach x in  MAP {

		recode `x'_`y'(.=0)

	}

}

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}




foreach x in   5000  20000  30000 10000 {
	foreach y in 1960 1970 1980 1990 2000 {
	
	* SD version of wells measure
		egen wells_`y'_`x'sd = std(wells_`y'_`x')
	
	* basic independet var
	
		gen w_c_`y'_`x'=wells_`y'_`x'*oil_price
		gen w_b_`y'_`x'=wells_`y'_`x'*brent_price

		label var w_c_`y'_`x' "crude price * number of wells until `y' in `x' buf"
		label var w_b_`y'_`x' "brent price * number of wells until `y' in `x' buf"
		
	* created with the interaction with log prices	
		gen w_lc_`y'_`x'=wells_`y'_`x'sd*loil_price
		gen w_lb_`y'_`x'=wells_`y'_`x'sd*lbrent_price

		label var w_lc_`y'_`x' "log crude price *sd number of wells until `y' in `x' buf"
		label var w_lb_`y'_`x' "log brent price *sd number of wells until `y' in `x' buf"
		
	* basic in logs now
		gen  lw_c_`y'_`x'=ln(w_c_`y'_`x')
		gen  lw_b_`y'_`x'=ln(w_b_`y'_`x')


	}
}

*STD the wells stocks and flows vars

foreach w in 5000 20000 30000 10000  { // 2500 5000 20000 25000 30000 35000
	
	egen wells_accum_`w'sd = std(wells_accum_`w')
	egen npozos_`w'sd = std(npozos_`w')
	
	foreach y in 30 {
		egen wells_accum`y'_`w'sd = std(wells_accum`y'_`w')
	}
}




* Create standarized and winsorized variables in case I want to use them instead. 
/*
foreach x in  pct2 enroled_he rent_seeker non_rent_seeker_1   semestertohe universitario{

	quietly summarize `x'
	generate `x'sd = (`x'-r(mean)) / r(sd)
		
	winsor2 `x', cuts(0 99)
	rename `x'_w `x'_w1
	label var `x'_w1 "winsorized at 99"
	
	winsor2 `x', cuts(1 99)
	rename `x'_w `x'_w2
	label var `x'_w2 "winsorized at 1 & 99"

}
*/

* This is in case you want to "clean" the control group.

*generating the pure control var

foreach w in  5000  20000  30000 10000  {
	tempvar control_`w'
	bys id_cole: egen `control_`w''=max(wells_accum_`w')
	gen pure_control_`w'=(`control_`w''==0 )
	label var pure_control_`w' "school without oil in buffer `w'in history until 2014"
	
	foreach y in 30{
	tempvar control_`w'`y'
	bys id_cole: egen `control_`w'`y''=max(wells_accum`y'_`w')
	gen pure_control_`w'`y'=(`control_`w'`y''==0 )
	label var pure_control_`w'`y' "school without oil `y' yo in buffer `w'in history until 2014"
	
	}
}

* Generate Trends to use
		
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



	
local rep_app = "replace"
	foreach x in  2000 {
		foreach w in  5000 20000 30000  {
			preserve
	*			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

				foreach y in  enrolment_rate rentseeker_1  uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum_`w'sd wells_accum
					rename npozos_`w'sd npozos

					*second order poly trend
					
					ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store riv_`y'_`w'
					
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store rred_`y'_`w'
					
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store nai1_`y'_`w'
										
					local rep_app = "append"
					
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum_`w'sd 
					rename outcome `y'
			
				}
			restore
			}
	}
	
	
local appi replace
foreach y in   enrolment_rate rentseeker_1  uni_1  {


	foreach x in nai1 rred riv {


	
	
	esttab  `x'_`y'_5000 `x'_`y'_20000 `x'_`y'_30000   using "${overleaf}/resultados/school/mines/robust_school_buffers", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{5000}" "\specialcell{15000}" "\specialcell{20000}" ) ///
	scalars(rkf)  sfmt(0 3)



	
	local appi append
	
	}
}


/*
					To the IV year
*/


	
local rep_app = "replace"
foreach x in   1970 1980 1990    {
	foreach w in  10000  {
		preserve
		*	drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  enrolment_rate rentseeker_1  uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum_`w'sd wells_accum
					rename npozos_`w'sd npozos

					*second order poly trend
					
					ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store riv_`y'_`x'
					
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store rred_`y'_`x'
					
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store nai1_`y'_`x'
										
					local rep_app = "append"
					
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum_`w'sd 
					rename outcome `y'
		
			}
		restore
		}
}

local appi replace
foreach y in   enrolment_rate rentseeker_1  uni_1  {


	foreach x in nai1 rred riv {


	
	
	esttab  `x'_`y'_1970 `x'_`y'_1980 `x'_`y'_1990   using "${overleaf}/resultados/school/mines/robust_school_time", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{1980}" "\specialcell{1990}" ) ///
	scalars(rkf)  sfmt(0 3)



	
	local appi append
	
	}
}


/*------------------------------------------------------------------------------
						 INDIVIDUALS
------------------------------------------------------------------------------*/




use "${compiled}/hk_oilwells_individual_mines.dta", clear



* First create your treatment variables. 

foreach y in 10000 5000 30000 20000{

	foreach x in  MAP {

		recode `x'_`y'(.=0)

	}

}

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}




foreach x in    10000 5000  20000  30000 { 
	foreach y in 1960 1970 1980 1990 2000 {
	
	* SD version of wells measure
		egen wells_`y'_`x'sd = std(wells_`y'_`x')
	
	* basic independet var
	
		gen w_c_`y'_`x'=wells_`y'_`x'*oil_price
		gen w_b_`y'_`x'=wells_`y'_`x'*brent_price

		label var w_c_`y'_`x' "crude price * number of wells until `y' in `x' buf"
		label var w_b_`y'_`x' "brent price * number of wells until `y' in `x' buf"
		
	* created with the interaction with log prices	
		gen w_lc_`y'_`x'=wells_`y'_`x'sd*loil_price
		gen w_lb_`y'_`x'=wells_`y'_`x'sd*lbrent_price

		label var w_lc_`y'_`x' "log crude price *sd number of wells until `y' in `x' buf"
		label var w_lb_`y'_`x' "log brent price *sd number of wells until `y' in `x' buf"
		
	* basic in logs now
		gen  lw_c_`y'_`x'=ln(w_c_`y'_`x')
		gen  lw_b_`y'_`x'=ln(w_b_`y'_`x')


	}
}

*STD the wells stocks and flows vars

foreach w in 10000 5000  20000  30000  { // 2500 5000 20000 25000 30000 35000
	
	egen wells_accum_`w'sd = std(wells_accum_`w')
	egen npozos_`w'sd = std(npozos_`w')
	
	foreach y in 30 {
		egen wells_accum`y'_`w'sd = std(wells_accum`y'_`w')
	}
}


/* Create standarized and winsorized variables in case I want to use them instead. 

foreach x in  semestertohe  {

	quietly summarize `x'
	generate `x'sd = (`x'-r(mean)) / r(sd)
		
	winsor2 `x', cuts(0 99)
	rename `x'_w `x'_w1
	label var `x'_w1 "winsorized at 99"
	
	winsor2 `x', cuts(0 95)
	rename `x'_w `x'_w2
	label var `x'_w2 "winsorized at 99"
	


}

sum semestertohe*,d

*/
		* CLEANING THE CONTROL GROUP.
/*
*generating the pure control var

foreach w in  10000 {
	bys id_cole: egen control_`w'=max(wells_accum_`w')
	gen pure_control_`w'=(control_`w'==0 )
	label var pure_control_`w' "school without oil in buffer `w'in history until 2014"
}
*/


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

rename non_rent_seeker_1 norent

rename non_rent_seeker_1 norent
local rep_app = "replace"
foreach x in  2000 {
	foreach w in  5000 30000 20000    {
		preserve
			*drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in    pct2  rent_seeker semestertohe universitario { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'
				
				
				reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store nai1_`y'_`w'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}

local appi replace

foreach y in pct2  rent_seeker semestertohe universitario {


	foreach x in nai1 rred riv{


	esttab   `x'_`y'_5000 `x'_`y'_20000 `x'_`y'_30000 using "${overleaf}/resultados/individual/mines/robust_individual_buffers", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{5000}" "\specialcell{15000}" "\specialcell{20000}" ) ///
	scalars(rkf)  sfmt(0 3)


		


	local appi append
	
	}
}

/*
				Robust to years
*/


local rep_app = "replace"
foreach x in  1970 1980  1990 {
	foreach w in  10000    {
		preserve
			*drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in    pct2  rent_seeker semestertohe universitario { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`x'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`x'
				
				
				reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store nai1_`y'_`x'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}

local appi replace

foreach y in pct2  rent_seeker semestertohe universitario {


	foreach x in nai1 rred riv{


	esttab   `x'_`y'_1970 `x'_`y'_1980 `x'_`y'_1990 using "${overleaf}/resultados/individual/mines/robust_individual_time", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{5000}" "\specialcell{15000}" "\specialcell{20000}" ) ///
	scalars(rkf)  sfmt(0 3)


		


	local appi append
	
	}
}



