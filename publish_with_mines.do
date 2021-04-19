
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
global mines "${data}/Violencia/harm"


/*------------------------------------------------------------------------------

 First create the oil wells_ for Schools and merge with schools hk 

------------------------------------------------------------------------------*/

use "${oil}/harm/wells_measures_cole.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 

*merge 1:1 id_cole year using "${oil}/harm/wells_measures_cole_extrayo.dta", nogen
* merge with HK info and prepare. 

merge 1:m id_cole year using "${hk}/harm/hk_colegio.dta"
drop if year>2014
keep if _merge==3 // periods for which there is no infon on human capital information
drop _merge

* merge with ETC indicator

merge m:1 codmpio using  "${municipios}/ETC_mpio.dta", gen(m_etc)
drop if m_etc!=3 // there is one mpio that does not exist. 
 drop _*
unique codmpio

*merge with OIL price

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

* merge with Mines Info

merge 1:1 id_cole year using "${mines}/cole_minas_antipersonas.dta", gen(m_mines)

drop if m_mines==2 // simply schools in sites with more than 200K inhabitants. 

sa "${compiled}/hk_oilwells_colegio_mines.dta", replace

/*------------------------------------------------------------------------------

 First create the oil wells_ for Schools and merge with individual hk. 

------------------------------------------------------------------------------*/ 

use "${oil}/harm/wells_measures_cole.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 


* merge with HK info and prepare. 

merge 1:m id_cole year using "${hk}/harm/hk_individual.dta"
drop if year>2014
keep if _merge==3 // periods for which there is no infon on human capital information
drop _merge

* merge with ETC indicator

merge m:1 codmpio using  "${municipios}/ETC_mpio.dta", gen(m_etc)
drop if m_etc!=3 // there is one mpio that does not exist. 
 drop _*
unique codmpio

*merge with OIL price

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

* merge with Mines Info

merge m:1 id_cole year using "${mines}/cole_minas_antipersonas.dta", gen(m_mines)
drop if m_mines==2 // simply schools in sites with more than 200K inhabitants. 

sa "${compiled}/hk_oilwells_individual_mines.dta", replace


/*------------------------------------------------------------------------------
						 SCHOOLS
------------------------------------------------------------------------------*/
use "${compiled}/hk_oilwells_colegio_mines.dta", clear

* First create your treatment variables. 

foreach y in 5000 10000 20000{

	foreach x in DESMIL INCAUTA MAP MUSE OTROS SOSP{

		recode `x'_`y'(.=0)

	}

}

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}




foreach x in  2500 5000 10000 20000 25000 30000 35000 {
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

foreach w in 10000  { // 2500 5000 20000 25000 30000 35000
	
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

foreach w in 2500 5000 10000 20000 25000 30000 35000 {
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



/*------------------------------------------------------------------------------

								ESTIMATIONS - School

------------------------------------------------------------------------------*/




local rep_app = "replace"
	foreach x in  2000 {
		foreach w in  10000  {
			preserve
	*			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

				foreach y in  enrolment_rate rentseeker_1  uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum_`w'sd wells_accum
					rename npozos_`w'sd npozos

					*second order poly trend
					
					*ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					*estimates store riv_`y'_`w'
					
					*ivreghdfe outcome MAP_`w'  (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					*estimates store riv2_`y'_`w'
					
					*reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					*estimates store rred_`y'_`w'
					
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store nai1_`y'_`w'
					
					reghdfe outcome MAP_`w'  npozos , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store nai2_`y'_`w'
					
					local rep_app = "append"
					
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum_`w'sd 
					rename outcome `y'
			
				}
			restore
			}
	}


foreach w in 10000{
/*
	local appi replace
		foreach x in rred riv riv2 {
		
		esttab  `x'_enrolment_rate_`w' `x'_rentseeker_1_`w'  `x'_uni_1_`w'  using "${overleaf}/resultados/school/mines/res_`w'", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
			scalars(rkf)  sfmt(0 3)
			
		local appi append
		
		}
		*/
	local appi replace
		foreach x in nai1 nai2 {
		
		esttab  `x'_enrolment_rate_`w' `x'_rentseeker_1_`w'  `x'_uni_1_`w'  using "${overleaf}/resultados/school/mines/naive_`w'", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
			scalars(rkf)  sfmt(0 3)
			
		local appi append
		
		}
		

	}
	
	estimates clear
* Now for the 30  yo wells 

foreach z in 30 {
local rep_app = "replace"
	foreach x in 1960 1970 1980 1990 2000 {
		foreach w in  10000  {
			preserve
			*	drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

				foreach y in  enrolment_rate rentseeker_1  uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum`z'_`w'sd wells_accum
					rename npozos_`w'sd npozos

					*second order poly trend
					
					*ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					*estimates store `y'_`z'_`x'
					
				*	ivreghdfe outcome MAP_`w'  (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r // these are the same regardless of the age of the oil wells. 
				*	estimates store riv2_`y'_`w'
					
				*	reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
				*	estimates store rred_`y'_`w'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store  na`y'_`z'_`x'
										
					local rep_app = "append"
					
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum`z'_`w'sd 
					rename outcome `y'
			
				}
			restore
			}
	}
}



local appi replace
foreach y in  1960 1970 1980 1990 2000  {
	foreach z in  30 {
		/*esttab  enrolment_rate_`z'_`y' rentseeker_1_`z'_`y' uni_1_`z'_`y' using "${overleaf}/resultados/school/mines/res_`z'_10000", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
			scalars(rkf)  sfmt(0 3)*/
			
		esttab  naenrolment_rate_`z'_`y' narentseeker_1_`z'_`y' nauni_1_`z'_`y'  using "${overleaf}/resultados/school/mines/naive_30_`w'", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
			scalars(rkf)  sfmt(0 3)
			
			
		local appi append
	}			
}


estimates clear




*1. number of students





	
local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000  {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  estudiantes  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum_`w'sd wells_accum
					rename npozos_`w'sd npozos
				
		

				*second order poly trend
				
					ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store riv_`y'
					
					
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store rred_`y'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store nai_`y'

				

				
				local rep_app = "append"
				
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum_`w'sd 
					rename outcome `y'
		
			}
		restore
		}
}

foreach w in 10000{

	local appi replace
		foreach x in nai rred riv {
		
		esttab  `x'_estudiantes  using "${overleaf}/resultados/school/mines/estudiantes_`w'", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
			scalars(rkf)  sfmt(0 3)
			
		local appi append
		
		}
	}
	
	

/*
* Now using Mines as the dependent Variable. 


local rep_app = "replace"
foreach x in  2000 {
	foreach w in 5000 10000 15000 20000  {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  MAP  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
				rename MAP_`w' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				
		

				*second order poly trend
				
				ivreghdfe outcome  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) 
				estimates store rred_`y'_`w'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome MAP_`w'
		
			}
		restore
		}
}




local appi replace
	foreach x in rred riv {

	
	
	esttab  `x'_MAP_5000 `x'_MAP_10000 `x'_MAP_15000 `x'_MAP_20000  using "${overleaf}/resultados/school/mines/explicaminas", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
	scalars(rkf)  sfmt(0 3)



	
	local appi append
	
	}
*/

/*------------------------------------------------------------------------------
						 INDIVIDUALS
------------------------------------------------------------------------------*/




use "${compiled}/hk_oilwells_individual_mines.dta", clear



* First create your treatment variables. 

foreach y in 5000 10000 20000{

	foreach x in DESMIL INCAUTA MAP MUSE OTROS SOSP{

		recode `x'_`y'(.=0)

	}

}

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}




foreach x in  2500 5000 10000 20000 25000 30000 35000 {
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

foreach w in 10000  { // 2500 5000 20000 25000 30000 35000
	
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


/*------------------------------------------------------------------------------

								ESTIMATIONS - Individual

------------------------------------------------------------------------------*/


local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
	*		drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  norent pct2  rent_seeker semestertohe universitario { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				/*
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				ivreghdfe outcome MAP_`w' i.mujer age (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv2_`y'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'
				*/
				
				reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store nai1_`y'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age npozos , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store nai2_`y'_`w'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}


foreach y in 10000  {
/*
local appi replace
	foreach x in rred riv riv2{


	esttab   `x'_pct2_`y' `x'_rent_seeker_`y'  `x'_semestertohe_`y'  `x'_universitario_`y' using "${overleaf}/resultados/individual/mines/res_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{pct2_`y'}" "\specialcell{rent_seeker_`y'}" "\specialcell{semestertohe_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)

	
		esttab   `x'_norent_`y'    using "${overleaf}/resultados/individual/mines/res2_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_non_rent_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)
		


	local appi append
	
	}
	*/
	
		local appi replace
		foreach x in nai1 nai2 {
		
		esttab  `x'_pct2_`y' `x'_rent_seeker_`y'  `x'_semestertohe_`y' `x'_universitario_`y' using "${overleaf}/resultados/individual/mines/naive_`y'", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{icfes}" "\specialcell{`rent'}" "\specialcell{`delay'}" "\specialcell{`uni'}" ) ///
			scalars(rkf)  sfmt(0 3)
			
		local appi append
		
		}
		
		
		
}

estimates clear

* Now for the 30  yo wells 

foreach z in 30 {
local rep_app = "replace"
	foreach x in 1960 1970 1980 1990 2000 {
		foreach w in  10000  {
			preserve
			*	drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

				foreach y in  norent pct2  rent_seeker semestertohe universitario { //enroled_he rent_seeker universitario deserted timetohe semestertohe
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum`z'_`w'sd wells_accum
					rename npozos_`w'sd npozos

					*second order poly trend
					/*
					ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store `y'_`z'_`x'
					*/
				*	ivreghdfe outcome MAP_`w'  (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r // these are the same regardless of the age of the oil wells. 
				*	estimates store riv2_`y'_`w'
					
				*	reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
				*	estimates store rred_`y'_`w'
					
					reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store na`y'_`z'_`x'

					
					local rep_app = "append"
					
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum`z'_`w'sd 
					rename outcome `y'
			
				}
			restore
			}
	}
}



local appi replace
foreach y in  1960 1970 1980 1990 2000  {
	foreach z in  30 {
		
		/*
		esttab  pct2_`z'_`y' rent_seeker_`z'_`y' semestertohe_`z'_`y' universitario_`z'_`y' using "${overleaf}/resultados/individual/mines/res_`z'_10000", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{ICFES}" "\specialcell{RENT}" "\specialcell{SEMESTER}"  "\specialcell{UNI}" ) ///
			scalars(rkf)  sfmt(0 3)
			
	esttab   norent_`z'_`y'    using "${overleaf}/resultados/individual/mines/res2_`z'_10000", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{NO_RENT}" ) ///
	scalars(rkf)  sfmt(0 3)
	*/
	esttab  napct2_`z'_`y' narent_seeker_`z'_`y' nasemestertohe_`z'_`y' nauniversitario_`z'_`y' using "${overleaf}/resultados/individual/mines/naive_`z'_10000", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{ICFES}" "\specialcell{RENT}" "\specialcell{SEMESTER}"  "\specialcell{UNI}" ) ///
			scalars(rkf)  sfmt(0 3)
			
		local appi append
	}		
}


estimates clear



/*------------------------------------------------------------------------------

					MUNICIPALITY LEVEL
					
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
If we really want to precent compelling evidence on the effects, we must show what is happening
at the municipality level. For this reason lets simply run all the results possible at the 
municipality level. All the basic FE must be present. 
------------------------------------------------------------------------------*/


use "${oil}/harm/wells_measures_mpio.dta", clear

* Merge with HK
merge 1:1 codmpio year using "${hk}/harm/hk_mpio.dta", gen(mer_hk)
drop if mer_hk==1 // these are simply the ones that have no HK information
drop if mer_hk==2 // these are the ones that have no time information for the wells at the municipality level is different than at the school level (it makes sense)


* merge with "violence" proxy; although you dont really need it

merge 1:1 codmpio year using "${mines}/mpio_minas_antipersonas.dta"
drop if _merge==2

* merge with ETC indicator

merge m:1 codmpio using  "${municipios}/ETC_mpio.dta", gen(m_etc)
drop if m_etc!=3 // there is one mpio that does not exist. 
unique codmpio


*merge with OIL price

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

sa "${compiled}/hk_oilwells_mpio_mines.dta", replace

* Now create the few measures that you need. 


use "${compiled}/hk_oilwells_mpio_mines.dta", clear

* First create your treatment variables. 

recode MAP(.=0)

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}





	foreach y in 1950 1960 1970 1980 1990 2000 {
	
	* SD version of wells measure
		egen wells_`y'_sd = std(wells_`y'_mpio)
	
	* basic independet var
	
		gen w_c_`y'=wells_`y'_mpio*oil_price
		gen w_b_`y'=wells_`y'_mpio*brent_price

		label var w_c_`y' "crude price * number of wells until `y'"
		label var w_b_`y' "brent price * number of wells until `y'"
		
	* created with the interaction with log prices	
		gen w_lc_`y'=wells_`y'_sd*loil_price
		gen w_lb_`y'=wells_`y'_sd*lbrent_price

		label var w_lc_`y' "log crude price *sd number of wells until `y'"
		label var w_lb_`y' "log brent price *sd number of wells until `y'"
		
	* basic in logs now
		gen  lw_c_`y'=ln(w_c_`y')
		gen  lw_b_`y'=ln(w_b_`y')
	}
	
*STD the wells stocks and flows vars

egen wells_accum_sd = std(wells_accum_mpio)
egen npozos_sd = std(npozos_mpio)
	
foreach y in 30 {
	egen wells_accum`y'_sd = std(wells_accum`y'_mpio)
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


/*------------------------------------------------------------------------------

								ESTIMATIONS - Municipality

------------------------------------------------------------------------------*/




local rep_app = "replace"
	foreach x in  2000 {
			preserve
	*			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

				foreach y in  enrolment_rate rentseeker_1 uni_1 pct2_m pct2 semestertohe_m semestertohe { //enroled_he rent_seeker universitario deserted timetohe semestertohe
			
					rename `y' outcome
					rename w_lb_`x' v_brent_price
					rename wells_accum_sd wells_accum
					rename npozos_sd npozos

					*second order poly trend
					
					ivreghdfe outcome MAP  (wells_accum=v_brent_price) , absorb(codmpio i.depto##c.c_year i.depto##c.c_year2) r
					estimates store riv_`y'
					
					ivreghdfe outcome MAP  (npozos=v_brent_price) , absorb(codmpio i.depto##c.c_year i.depto##c.c_year2) r
					estimates store riv2_`y'
					
					reghdfe outcome MAP  v_brent_price , absorb(codmpio i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store rred_`y'
					
					local rep_app = "append"
					
					rename npozos npozos_sd 
					rename v_brent_price w_lb_`x'  			
					rename wells_accum wells_accum_sd 
					rename outcome `y'
			
				}
			restore
			}
	


	local appi replace
		foreach x in rred riv riv2 {
		
		esttab  `x'_enrolment_rate `x'_rentseeker_1  `x'_uni_1 `x'_pct2_m `x'_pct2  `x'_semestertohe_m `x'_semestertohe using "${overleaf}/resultados/mpio/mines/res", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{enrolment}" "\specialcell{rent}" "\specialcell{uni}" "\specialcell{icfes_m}" "\specialcell{icfes}" "\specialcell{semester_m}" "\specialcell{semester}" ) ///
			scalars(rkf)  sfmt(0 3)
			
		local appi append
		
		}

	
	estimates clear
* Now for the 30  yo wells 

foreach z in 30 {
local rep_app = "replace"
	foreach x in 1960 1970 1980 1990 2000 {
			preserve
			*	drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

				foreach y in  enrolment_rate rentseeker_1 uni_1 pct2_m pct2 semestertohe_m semestertohe  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
			
					rename `y' outcome
					rename w_lb_`x' v_brent_price
					rename wells_accum`z'_sd wells_accum
					rename npozos_sd npozos

					*second order poly trend
					
					ivreghdfe outcome MAP  (wells_accum=v_brent_price) , absorb(codmpio i.depto##c.c_year i.depto##c.c_year2) r
					estimates store `y'_`z'_`x'
					
				*	ivreghdfe outcome MAP_`w'  (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r // these are the same regardless of the age of the oil wells. 
				*	estimates store riv2_`y'_`w'
					
				*	reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
				*	estimates store rred_`y'_`w'
					
					local rep_app = "append"
					
					rename npozos npozos_sd 
					rename v_brent_price w_lb_`x'  			
					rename wells_accum wells_accum`z'_sd 
					rename outcome `y'
			
				}
			restore
			}
	}




local appi replace
foreach y in  1960 1970 1980 1990 2000  {
	foreach z in  30 {
		esttab  enrolment_rate_`z'_`y' rentseeker_1_`z'_`y' uni_1_`z'_`y' pct2_m_`z'_`y' pct2_`z'_`y' semestertohe_m_`z'_`y' semestertohe_`z'_`y' using "${overleaf}/resultados/mpio/mines/res_`z'", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
			scalars(rkf)  sfmt(0 3)
			
		local appi append
	}		
}


estimates clear


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







/*

local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
			*drop if w_b_`x'_`w'==0 & pure_control_`w'==0 	// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in    semestertohe_w1 semestertohe_w2 { 
				rename npozos_`w'sd npozos 		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				
				*state time fixed effects 
					


				*second order poly trend
				
				ivreghdfe outcome MAP_10000 i.mujer age  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				ivreghdfe outcome MAP_10000 i.mujer age  (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv2_`y'_`w'
				
				reghdfe outcome MAP_10000 i.mujer age  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) 
				estimates store rred_`y'_`w'
				
				local rep_app = "append"
				
				rename npozos npozos_`w'sd 					
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}


foreach y in 10000  {

local appi replace
	foreach x in rred riv riv2{


	esttab   `x'_semestertohe_w1_`y' `x'_semestertohe_w2_`y'   using "${overleaf}/resultados/individual/mines/res_semester_win_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{wins1}" "\specialcell{wins2}") ///
	scalars(rkf)  sfmt(0 3)

	



	local appi append
	
	}
}

estimates clear
*/


/*------------------------------------------------------------------------------

					Now some excercies for robustness

------------------------------------------------------------------------------*/
*1. number of students


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

		* CLEANING THE CONTROL GROUP.

*generating the pure control var

foreach w in 10000 {
	tempvar control_`w'
	bys id_cole: egen `control_`w''=max(wells_accum_`w')
	gen pure_control_`w'=(`control_`w''==0 )
	label var pure_control_`w' "school without oil in buffer `w'in history until 2014"
}

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



	
local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000  {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  estudiantes  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
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


foreach y in  10000 {

local appi replace
	foreach x in rred riv {



	esttab  `x'_estudiantes_`y'    using "${overleaf}/resultados/school/estudiantes_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enrolment_rate_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)
	
	

	
	local appi append
	
	}
}






* Now age of the students. 







use "${compiled}/hk_oilwells_individual.dta", clear

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}




foreach x in 10000 {
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






foreach w in  10000 {
	
	quietly summarize wells_accum_`w' 
	generate wells_accum_`w'sd = (wells_accum_`w' -r(mean)) / r(sd)
	
	
}


* Create standarized and winsorized variables in case I want to use them instead. 

foreach x in  age age2  {

	quietly summarize `x'
	generate `x'sd = (`x'-r(mean)) / r(sd)
		
	winsor2 `x', cuts(0 99)
	rename `x'_w `x'_w1
	label var `x'_w1 "winsorized at 99"
	
	winsor2 `x', cuts(0 95)
	rename `x'_w `x'_w2
	label var `x'_w2 "winsorized at 99"
	


}

		* CLEANING THE CONTROL GROUP.

*generating the pure control var

foreach w in  10000 {
	bys id_cole: egen control_`w'=max(wells_accum_`w')
	gen pure_control_`w'=(control_`w'==0 )
	label var pure_control_`w' "school without oil in buffer `w'in history until 2014"
}



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
local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in    age   age_w1 age_w2 age2 age2_w1 age2_w2 { 
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				
				*state time fixed effects 
					


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


foreach y in 10000  {

local appi replace
	foreach x in rred riv{


	esttab   `x'_age_`y' `x'_age_w1_`y'  `x'_age_w2_`y'  `x'_age2_`y' `x'_age2_w1_`y'  `x'_age2_w2_`y'  using "${overleaf}/resultados/individual/age_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enroled_he_`y'}" "\specialcell{`x'_rent_seeker_`y'}" "\specialcell{`x'_pct2_`y'}" "\specialcell{`x'_universitario_`y'}" "\specialcell{`x'_semestertohe_`y'}") ///
	scalars(rkf)  sfmt(0 3)



	local appi append
	
	}
}





foreach x in  age age2  {


		
	winsor2 `x', cuts(5 95)
	rename `x'_w `x'_w3
	label var `x'_w3 "winsorized at 5 95"
	


}



local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in   agesd age2sd age_w3 age2_w3 { 
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				
				*state time fixed effects 
					


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


foreach y in 10000  {

local appi replace
	foreach x in rred riv{


	esttab   `x'_agesd_`y' `x'_age2sd_`y' `x'_age_w3_`y' `x'_age2_w3_`y'   using "${overleaf}/resultados/individual/age95_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enroled_he_`y'}" "\specialcell{`x'_rent_seeker_`y'}" "\specialcell{`x'_pct2_`y'}" "\specialcell{`x'_universitario_`y'}" "\specialcell{`x'_semestertohe_`y'}") ///
	scalars(rkf)  sfmt(0 3)



	local appi append
	
	}
}



estimates clear


* now only if graduated

tab graduated

/*------------------------------------------------------------------------------

					Now only before 2012 (before the reform)

------------------------------------------------------------------------------*/





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

 First create the oil wells_ for Schools and merge with schools hk 

------------------------------------------------------------------------------*/

use "${oil}/harm/wells_measures_cole.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 


* merge with HK info and prepare. 

merge 1:m id_cole year using "${hk}/harm/hk_colegio.dta"
drop if year>2012
keep if _merge==3 // periods for which there is no infon on human capital information
drop _merge

* merge with ETC indicator

merge m:1 codmpio using  "${municipios}/ETC_mpio.dta", gen(m_etc)
drop if m_etc!=3 // there is one mpio that does not exist. 
unique codmpio

*merge with OIL price

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

sa "${compiled}/hk_oilwells_colegio.dta", replace

/*------------------------------------------------------------------------------

 First create the oil wells_ for Schools and merge with individual hk. 

------------------------------------------------------------------------------*/ 

use "${oil}/harm/wells_measures_cole.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 


* merge with HK info and prepare. 

merge 1:m id_cole year using "${hk}/harm/hk_individual.dta"
drop if year>2012
keep if _merge==3 // periods for which there is no infon on human capital information
drop _merge

* merge with ETC indicator

merge m:1 codmpio using  "${municipios}/ETC_mpio.dta", gen(m_etc)
drop if m_etc!=3 // there is one mpio that does not exist. 
unique codmpio

*merge with OIL price

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

sa "${compiled}/hk_oilwells_individual.dta", replace


/*------------------------------------------------------------------------------
						 SCHOOLS
------------------------------------------------------------------------------*/

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

		* CLEANING THE CONTROL GROUP.

*generating the pure control var

foreach w in 10000 {
	tempvar control_`w'
	bys id_cole: egen `control_`w''=max(wells_accum_`w')
	gen pure_control_`w'=(`control_`w''==0 )
	label var pure_control_`w' "school without oil in buffer `w'in history until 2014"
}

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



	
local rep_app = "replace"
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


foreach y in  10000 {

local appi replace
	foreach x in rred riv {

	
	
	esttab  `x'_enrolment_rate_`y' `x'_rentseeker_1_`y'  `x'_uni_1_`y'  using "${overleaf}/resultados/school/pub32012_`y'", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
	scalars(rkf)  sfmt(0 3)



	
	local appi append
	
	}
}

/*------------------------------------------------------------------------------
						 INDIVIDUALS
------------------------------------------------------------------------------*/




use "${compiled}/hk_oilwells_individual.dta", clear

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}




foreach x in 10000 {
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






foreach w in  10000 {
	
	quietly summarize wells_accum_`w' 
	generate wells_accum_`w'sd = (wells_accum_`w' -r(mean)) / r(sd)
	
	
}


* Create standarized and winsorized variables in case I want to use them instead. 

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
		* CLEANING THE CONTROL GROUP.

*generating the pure control var

foreach w in  10000 {
	bys id_cole: egen control_`w'=max(wells_accum_`w')
	gen pure_control_`w'=(control_`w'==0 )
	label var pure_control_`w' "school without oil in buffer `w'in history until 2014"
}



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
local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in    norent pct2  rent_seeker semestertohe { 
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				
				*state time fixed effects 
					


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


foreach y in 10000  {

local appi replace
	foreach x in rred riv{


	esttab   `x'_pct2_`y' `x'_rent_seeker_`y'  `x'_semestertohe_`y'   using "${overleaf}/resultados/individual/pub12012_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enroled_he_`y'}" "\specialcell{`x'_rent_seeker_`y'}" "\specialcell{`x'_pct2_`y'}" "\specialcell{`x'_universitario_`y'}" "\specialcell{`x'_semestertohe_`y'}") ///
	scalars(rkf)  sfmt(0 3)

	
		esttab   `x'_norent_`y'    using "${overleaf}/resultados/individual/pub22012_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_non_rent_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)
		


	local appi append
	
	}
}


