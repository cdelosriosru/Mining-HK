
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

								ESTIMATIONS - School

------------------------------------------------------------------------------*/

use "${compiled}/hk_oilwells_colegio_mines.dta", clear 

foreach z in 30_ 15_{
local rep_app = "replace"
	foreach x in 1970 2000 {
		foreach w in  10000  {
			preserve
			*	drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

				foreach y in  enrolment_rate uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum`z'`w'sd wells_accum
					rename npozos_`w'sd npozos

					*second order poly trend
					
					ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'`z'`x'
										
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
					estimates store re`y'`z'`x'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store  na`y'`z'`x'
										
					local rep_app = "append"
					
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum`z'`w'sd 
					rename outcome `y'
			
				}
			restore
			}
	}
}


foreach z in _ {
local rep_app = "replace"
	foreach x in 1970 1980 1990 2000 {
		foreach w in  5000 10000 20000 30000  {
			preserve
			*	drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

				foreach y in  enrolment_rate rentseeker_1  uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum`z'`w'sd wells_accum
					rename npozos_`w'sd npozos

					*second order poly trend
					
					ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'`z'`x'`w'
										
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
					estimates store re`y'`z'`x'`w'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store  na`y'`z'`x'`w'
										
					local rep_app = "append"
					
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum`z'`w'sd 
					rename outcome `y'
			
				}
			restore
			}
	}
}
	
	
	

*  Main

local appi replace
foreach x in  2000  {
	foreach z in _ {
		foreach y in na re ri{		
		
			esttab  `y'enrolment_rate`z'`x'10000 `y'uni_1`z'`x'10000 using "${overleaf}/resultados/school/mines/res_10000", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}			
}

*  Buffer robustness
local appi replace

foreach z in _ {
foreach x in 2000{
	foreach y in na re ri{		
		
		esttab  `y'enrolment_rate`z'`x'5000 `y'enrolment_rate`z'`x'20000 `y'enrolment_rate`z'`x'30000 `y'uni_1`z'`x'5000 `y'uni_1`z'`x'20000 `y'uni_1`z'`x'30000 using "${overleaf}/resultados/school/mines/rob_buffers", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			scalars(rkf)  sfmt(0 3)	
			
				local appi append

			
	}
}	
}	


*  Suitability robustness
local appi replace

foreach z in _ {
	foreach y in na re ri{		
		
		esttab  `y'enrolment_rate`z'197010000 `y'enrolment_rate`z'198010000 `y'enrolment_rate`z'199010000 `y'uni_1`z'197010000 `y'uni_1`z'198010000 `y'uni_1`z'199010000 using "${overleaf}/resultados/school/mines/rob_time", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			scalars(rkf)  sfmt(0 3)	
			
				local appi append

			
	}
}	


*Super stringent restrictions

local appi replace

foreach z in 30_ 15_ {
	foreach y in na re ri{		
		
		esttab  `y'enrolment_rate`z'1970 `y'enrolment_rate`z'2000 `y'uni_1`z'1970 `y'uni_1`z'2000 using "${overleaf}/resultados/school/mines/rob_stringent_`z'", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			scalars(rkf)  sfmt(0 3)	
			
				local appi append

			
	}
}	




	








/*------------------------------------------------------------------------------
						 INDIVIDUALS
------------------------------------------------------------------------------*/



/*------------------------------------------------------------------------------

						IND. Enrolment

------------------------------------------------------------------------------*/
use "${compiled}/hk_oilwells_individual_mines.dta", clear



**** Enrolment***

local rep_app = "replace"
foreach x in  1970 1980 1990 2000 {
	foreach w in  5000 10000 20000 30000  {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store ri`y'_`x'`w'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store re`y'_`x'`w'
				
				reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store na`y'_`x'`w'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}

foreach z in 30_ 15_{
foreach x in  1970 2000 {
	foreach w in  10000  {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum`z'`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store ri`y'`z'`x'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store re`y'`z'`x'
				
				reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store na`y'`z'`x'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum`z'`w'sd 
				rename outcome `y'
		
			}
		}
}

}


* Main

foreach w in 10000  {

local appi replace
	foreach x in na re ri{

	
	esttab   `x'enroled_he_2000`w' `x'universitario_2000`w' `x'semestertohe_2000`w'  using "${overleaf}/resultados/individual/mines/res_`w'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}


* Buffer Robustness


local appi replace
	foreach x in na re ri{

	
	esttab   `x'enroled_he_20005000 `x'enroled_he_200020000 `x'enroled_he_200030000 `x'universitario_20005000 `x'universitario_200020000 `x'universitario_200030000	`x'semestertohe_20005000 `x'semestertohe_200020000 `x'semestertohe_200030000  using "${overleaf}/resultados/individual/mines/rob_buffers", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
	* Time Robustness


local appi replace
	foreach x in na re ri{

	
	esttab   `x'enroled_he_197010000 `x'enroled_he_198010000 `x'enroled_he_199010000 `x'universitario_197010000 `x'universitario_198010000 `x'universitario_199010000 `x'semestertohe_197010000 `x'semestertohe_198010000 `x'semestertohe_199010000  using "${overleaf}/resultados/individual/mines/rob_time", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}


*Super stringent restrictions

local appi replace

foreach z in 30_ 15_ {
	foreach y in na re ri{		
		
		esttab  `y'enroled_he`z'1970 `y'enroled_he`z'2000 `y'universitario`z'1970 `y'universitario`z'2000 `y'semestertohe`z'1970 `y'semestertohe`z'2000 using "${overleaf}/resultados/individual/mines/rob_stringent_`z'1", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			scalars(rkf)  sfmt(0 3)	
			
				local appi append

			
	}
}	




estimates clear

***Program Selection*** 

rename engistemi ste
rename admin_econ adm


foreach z in 30_ 15_{
	foreach x in  1970 2000 {
		foreach w in  10000    {
				foreach y in  ste adm others { 
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum`z'`w'sd wells_accum
					rename npozos_`w'sd npozos
				

					*second order poly trend
					
					ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'`z'`x'
					
					reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store re`y'`z'`x'
					
					reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store na`y'`z'`x'
					
					local rep_app = "append"

					rename npozos npozos_`w'sd 				
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum`z'`w'sd 
					rename outcome `y'
			
				}
			}
	}
}

foreach x in  1970 1980 1990 2000 {
	foreach w in 5000 10000 20000 30000   {
			foreach y in  ste adm others { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store ri`y'_`x'`w'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store re`y'_`x'`w'
				
				reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store na`y'_`x'`w'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}


* Main

foreach w in 10000  {

local appi replace
	foreach x in na re ri{

	
	esttab   `x'ste_2000`w' `x'adm_2000`w' `x'others_2000`w'  using "${overleaf}/resultados/individual/mines/resP_`w'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}


* Buffer Robustness


local appi replace
	foreach x in na re ri{

	
	esttab   `x'ste_20005000 `x'ste_200020000 `x'ste_200030000 `x'adm_20005000 `x'adm_200020000 `x'adm_200030000	`x'others_20005000 `x'others_200020000 `x'others_200030000  using "${overleaf}/resultados/individual/mines/robP_buffers", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
	* Time Robustness


local appi replace
	foreach x in na re ri{

	
	esttab   `x'ste_197010000 `x'ste_198010000 `x'ste_199010000 `x'adm_197010000 `x'adm_198010000 `x'adm_199010000 `x'others_197010000 `x'others_198010000 `x'others_199010000  using "${overleaf}/resultados/individual/mines/robP_time", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}


*Super stringent restrictions


local appi replace

foreach z in 30_ 15_ {
	foreach y in na re ri{		
		
		esttab  `y'ste`z'1970 `y'ste`z'2000 `y'adm`z'1970 `y'adm`z'2000 `y'others`z'1970 `y'others`z'2000 using "${overleaf}/resultados/individual/mines/robP_stringent_`z'", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			scalars(rkf)  sfmt(0 3)	
			
			local appi append

			
	}
}	

estimates clear













/*------------------------------------------------------------------------------

						IND. Completion

------------------------------------------------------------------------------*/

***Completion decisons***

foreach t in 2010 { // 2009 2015

estimates clear
use "${compiled}/hk_oilwells_individual_mines_comp.dta", clear

drop if year>`t'

	local rep_app = "replace"
	foreach x in 1970 1980 1990  { // 1970 1980 1990  2000
		foreach w in  10000  { // 5000 10000 20000 30000
				foreach y in  graduado deserted { 
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum_`w'sd wells_accum
					rename npozos_`w'sd npozos
				

					*second order poly trend
					
					ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'`x'`w'
					
					reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store re`y'`x'`w'
					
					reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store na`y'`x'`w'
					
					local rep_app = "append"

					rename npozos npozos_`w'sd 				
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum_`w'sd 
					rename outcome `y'
			
				}
			}
	}


/*------------------------------------------------------------------------------

						School. Completion

------------------------------------------------------------------------------*/

* Now using the other type of data

use "${compiled}/hk_oilwells_colegio_mines_comp.dta", clear 
rename completion_rate compr
rename desertion_rate desr

drop if year>`t'
local rep_app = "replace"
	foreach x in 1970 1980 1990  { // 1970 1980 1990  2000
		foreach w in  10000  { // 5000 10000 20000 30000
				foreach y in  compr desr  { 
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum_`w'sd wells_accum
					rename npozos_`w'sd npozos

					*second order poly trend
					
					ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'`x'`w'
										
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
					estimates store re`y'`x'`w'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store  na`y'`x'`w'
										
					local rep_app = "append"
					
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum_`w'sd 
					rename outcome `y'
			
				}
			}
	}


/*

* Main

local appi replace
foreach x in  2000  {
		foreach y in na re ri{		
		
			esttab  `y'graduado`x'10000 `y'compr`x'10000 `y'deserted`x'10000 `y'desr`x'10000 using "${overleaf}/resultados/school/mines/completion_desertion_10000", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				mtitle(  ) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}			

	
	
* Buffer Robustness

local appi replace
foreach x in  2000  {
		foreach y in na re ri{		
		
			esttab  `y'graduado`x'5000 `y'graduado`x'20000 `y'graduado`x'30000 `y'compr`x'5000 `y'compr`x'20000 `y'compr`x'30000 `y'deserted`x'5000 `y'deserted`x'20000 `y'deserted`x'30000 `y'deserted`x'10000 `y'desr`x'5000 `y'desr`x'20000 `y'desr`x'30000 using "${overleaf}/resultados/school/mines/completion_desertion_buffers", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				mtitle(  ) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}
	

*/	
	
* Time Robustness

local appi replace
		foreach y in na re ri{		
		
			esttab  `y'graduado197010000 `y'graduado198010000 `y'graduado199010000 `y'compr197010000 `y'compr198010000 `y'compr199010000 `y'deserted197010000 `y'deserted198010000 `y'deserted199010000 `y'desr197010000 `y'desr198010000 `y'desr199010000 using "${overleaf}/resultados/school/mines/completion_desertion_time", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				mtitle(  ) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
	}
	
	
	

}

* Stirngent

foreach z in 30_{

foreach t in 2010 { // 2009 2015

estimates clear
use "${compiled}/hk_oilwells_individual_mines_comp.dta", clear

drop if year>`t'

	local rep_app = "replace"
	foreach x in  1970  2000 {
		foreach w in   10000  {
				foreach y in  graduado deserted { 
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum`z'`w'sd wells_accum
					rename npozos_`w'sd npozos
				

					*second order poly trend
					
					ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'`z'`x'
					
					reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store re`y'`z'`x'
					
					reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store na`y'`z'`x'
					
					local rep_app = "append"

					rename npozos npozos_`w'sd 				
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum`z'`w'sd 
					rename outcome `y'
			
				}
			}
	}


/*------------------------------------------------------------------------------

						School. Completion

------------------------------------------------------------------------------*/

* Now using the other type of data

use "${compiled}/hk_oilwells_colegio_mines_comp.dta", clear 
rename completion_rate compr
rename desertion_rate desr

drop if year>`t'
local rep_app = "replace"
	foreach x in 1970 2000 {
		foreach w in   10000 {
				foreach y in  compr desr  { 
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum`z'`w'sd wells_accum
					rename npozos_`w'sd npozos

					*second order poly trend
					
					ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'`z'`x'
										
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
					estimates store re`y'`z'`x'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store  na`y'`z'`x'
										
					local rep_app = "append"
					
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum`z'`w'sd 
					rename outcome `y'
			
				}
			}
	}






	
	
* Super stringent Restrictions

local appi replace
foreach x in  2000  {
		foreach y in na re ri{		
		
			esttab  `y'graduado`z'1970 `y'graduado`z'2000 `y'compr`z'1970 `y'compr`z'2000 `y'deserted`z'1970 `y'deserted`z'2000  `y'desr`z'1970 `y'desr`z'2000 using "${overleaf}/resultados/school/mines/completion_superstringent_`z'", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				mtitle(  ) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}
	
	
	

}

}

/*
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

* merge with royalties 

merge 1:1 year codmpio using "${oil}/harm/regalias_definitivas.dta", gen(m_royal)
drop if m_royal==2
recode regalias(.=0)

sa "${compiled}/hk_oilwells_mpio_mines.dta", replace

* Now create the few measures that you need. 


use "${compiled}/hk_oilwells_mpio_mines.dta", clear

* First create your treatment variables. 

recode MAP(.=0)

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}





	foreach y in 1970 1980 1990 2000 {
	
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

egen regaliassd=std(regalias)


local rep_app = "replace"
	foreach x in  2000 {
			preserve
	*			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

				foreach y in  enrolment_rate rentseeker_1 uni_1 pct2_m pct2 semestertohe_m semestertohe { //enroled_he rent_seeker universitario deserted timetohe semestertohe
			
					rename `y' outcome
					rename w_lb_`x' v_brent_price
					rename npozos_sd npozos

					*second order poly trend
					
					ivreghdfe outcome MAP  (regaliassd=v_brent_price) , absorb(codmpio i.depto##c.c_year i.depto##c.c_year2) r
					estimates store riv_`y'
					
					
					reghdfe outcome MAP  v_brent_price , absorb(codmpio i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store rred_`y'
					
					reghdfe outcome MAP regaliassd, absorb(codmpio i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store na_`y'
					
					local rep_app = "append"
					
					rename npozos npozos_sd 
					rename v_brent_price w_lb_`x'  			
					rename outcome `y'
			
				}
			restore
			}
	


	local appi replace
		foreach x in na rred riv {
		
		esttab  `x'_enrolment_rate `x'_rentseeker_1  `x'_uni_1 `x'_pct2_m `x'_pct2  `x'_semestertohe_m `x'_semestertohe using "${overleaf}/resultados/mpio/mines/res_roysd", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{enrolment}" "\specialcell{rent}" "\specialcell{uni}" "\specialcell{icfes_m}" "\specialcell{icfes}" "\specialcell{semester_m}" "\specialcell{semester}" ) ///
			scalars(rkf)  sfmt(0 3)
			
		local appi append
		
		}
		
		
		
	* old



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


