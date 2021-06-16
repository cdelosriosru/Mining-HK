
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

local rep_app = "replace"
	foreach x in 1970 1980 1990 2000 {
		foreach w in 5000 10000 20000 30000  {
			preserve
			*	drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

				foreach y in  enrolment_rate rentseeker_1  uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename npozos_`w'sd npozos

					*second order poly trend
					
					ivreghdfe outcome MAP_`w'  (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'_`x'_`w'
										
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
					estimates store re`y'_`x'_`w'
				
					reghdfe outcome MAP_`w'  npozos , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store  na`y'_`x'_`w'
										
					local rep_app = "append"
					
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename outcome `y'
			
				}
			restore
			}
	}



*  Main
local appi replace
foreach x in  2000  {
		foreach y in na re ri{		
		
			esttab  `y'enrolment_rate_`x'_10000  `y'uni_1_`x'_10000 using "${overleaf}/resultados/new_drills/school/res_10000", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}
	
*buffer robustness
local appi replace
foreach x in  2000  {
		foreach y in na re ri{		
		
			esttab  `y'enrolment_rate_`x'_5000 `y'enrolment_rate_`x'_20000  `y'enrolment_rate_`x'_30000 `y'uni_1_`x'_5000 `y'uni_1_`x'_20000 `y'uni_1_`x'_30000 using "${overleaf}/resultados/new_drills/school/rob_buffers", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}		
	
* Suitability robustness

local appi replace

foreach y in na re ri{		
		
	esttab  `y'enrolment_rate_1970_10000 `y'enrolment_rate_1980_10000  `y'enrolment_rate_1990_10000 `y'uni_1_1970_10000 `y'uni_1_1980_10000 `y'uni_1_1990_10000 using "${overleaf}/resultados/new_drills/school/rob_time", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		scalars(rkf)  sfmt(0 3)	
				
	local appi append
			
}		




estimates clear




/*------------------------------------------------------------------------------
						 INDIVIDUALS
------------------------------------------------------------------------------*/



/*------------------------------------------------------------------------------

						IND. Enrolment

------------------------------------------------------------------------------*/
use "${compiled}/hk_oilwells_individual_mines.dta", clear

rename universitario uni
rename semestertohe smth

**** Enrolment***

local rep_app = "replace"
foreach x in 1970 1980 1990 2000 {
	foreach w in  5000 10000 20000 30000   {
			foreach y in  enroled_he uni smth { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`x'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`x'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age npozos , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store na_`y'_`x'_`w'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename outcome `y'
		
			}
		}
}
	local appi replace
* Main
foreach x in 2000{
	foreach w in 10000  {
	local appi replace
		foreach y in na rred riv{


		esttab   `y'_enroled_he_`x'_`w' `y'_uni_`x'_`w' `y'_smth_`x'_`w'  using "${overleaf}/resultados/new_drills/individual/res_`w'", `appi' f  ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{pct2_`y'}" "\specialcell{rent_seeker_`y'}" "\specialcell{smth_`y'}" ) ///
		scalars(rkf)  sfmt(0 3)

		local appi append
		
		}
	}				
}

* Buffer Robustness Time
foreach x in 2000{
	local appi replace
		foreach y in na rred riv{


		esttab   `y'_enroled_he_`x'_5000 `y'_enroled_he_`x'_20000 `y'_enroled_he_`x'_30000 `y'_uni_`x'_5000 `y'_uni_`x'_20000 `y'_uni_`x'_30000 `y'_smth_`x'_5000 `y'_smth_`x'_20000 `y'_smth_`x'_30000  using "${overleaf}/resultados/new_drills/individual/rob_buffers", `appi' f  ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
		scalars(rkf)  sfmt(0 3)

		local appi append
		
		}
	}				



foreach w in 10000{
	local appi replace
		foreach y in na rred riv{


		esttab   `y'_enroled_he_1970_10000 `y'_enroled_he_1980_10000 `y'_enroled_he_1990_10000 `y'_uni_1970_10000 `y'_uni_1980_10000 `y'_uni_1990_10000 `y'_smth_1970_10000 `y'_smth_1980_10000 `y'_smth_1990_10000  using "${overleaf}/resultados/new_drills/individual/rob_time", `appi' f  ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
		scalars(rkf)  sfmt(0 3)

		local appi append
		
		}
	}



estimates clear


***Program Selection*** 

rename engistemi stm
rename admin_econ adm


local rep_app = "replace"
foreach x in  2000 { // 1970 1980 1990 2000
	foreach w in 10000  { // 5000 10000 20000 30000 
		foreach y in  stm adm others { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`x'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`x'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age npozos , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store na_`y'_`x'_`w'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}




* Main
foreach x in 2000{
	foreach w in 10000  {
	local appi replace
		foreach y in na rred riv{


		esttab   `y'_stm_`x'_`w' `y'_adm_`x'_`w' `y'_others_`x'_`w'  using "${overleaf}/resultados/new_drills/individual/resP_`w'", `appi' f  ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			mtitle( "\specialcell{pct2_`y'}" "\specialcell{rent_seeker_`y'}" "\specialcell{others_`y'}" ) ///
		scalars(rkf)  sfmt(0 3)

		local appi append
		
		}
	}				
}

* Buffer Robustness Time
foreach x in 2000{
	local appi replace
		foreach y in na rred riv{


		esttab   `y'_stm_`x'_5000 `y'_stm_`x'_20000 `y'_stm_`x'_30000 `y'_adm_`x'_5000 `y'_adm_`x'_20000 `y'_adm_`x'_30000 `y'_others_`x'_5000 `y'_others_`x'_20000 `y'_others_`x'_30000  using "${overleaf}/resultados/new_drills/individual/robP_buffers", `appi' f  ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
		scalars(rkf)  sfmt(0 3)

		local appi append
		
		}
	}				



foreach w in 10000{
	local appi replace
		foreach y in na rred riv{


		esttab   `y'_stm_1970_10000 `y'_stm_1980_10000 `y'_stm_1990_10000 `y'_adm_1970_10000 `y'_adm_1980_10000 `y'_adm_1990_10000 `y'_others_1970_10000 `y'_others_1980_10000 `y'_others_1990_10000  using "${overleaf}/resultados/new_drills/individual/robP_time", `appi' f  ///
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
		foreach x in  2000 { // 1970 1980 1990
			foreach w in     10000 { // 5000 10000 20000 30000
					foreach y in  graduado deserted { //  graduadouni graduadotec 
				
						rename `y' outcome
						rename w_lb_`x'_`w' v_brent_price
						rename npozos_`w'sd npozos
					

						*second order poly trend
						
						ivreghdfe outcome MAP_`w' i.mujer age (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
						estimates store ri_`y'_`x'_`w'
						
						reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
						estimates store re_`y'_`x'_`w'
						
						reghdfe outcome MAP_`w' i.mujer age npozos , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
						estimates store na_`y'_`x'_`w'
						
						local rep_app = "append"

						rename npozos npozos_`w'sd 				
						rename v_brent_price w_lb_`x'_`w'  			
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
		foreach x in  2000 { // 1970 1980 1990
			foreach w in  10000 { // 5000 10000 20000 30000
				preserve
				*	drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

					foreach y in  compr desr  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
				
						rename `y' outcome
						rename w_lb_`x'_`w' v_brent_price
						rename npozos_`w'sd npozos

						*second order poly trend
						
						ivreghdfe outcome MAP_`w'  (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
						estimates store ri`y'_`x'_`w'
											
						reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
						estimates store re`y'_`x'_`w'
					
						reghdfe outcome MAP_`w'  npozos , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
						estimates store  na`y'_`x'_`w'
											
						local rep_app = "append"
						
						rename npozos npozos_`w'sd 
						rename v_brent_price w_lb_`x'_`w'  			
						rename outcome `y'
				
					}
				restore
				}
		}


	* Export the estimates


* Main

	local appi replace
	foreach x in  2000  {
			foreach y in na re ri{		
			
				esttab  `y'_graduado_`x'_10000 `y'compr_`x'_10000 `y'_deserted_`x'_10000 `y'desr_`x'_10000 using "${overleaf}/resultados/new_drills/school/completion_desertion_10000", `appi' f ///
					label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
					star(* 0.10 ** 0.05 *** 0.01) ///
					cells(b(star fmt(3)) se(par fmt(2))) ///
					scalars(rkf)  sfmt(0 3)	
					
			local appi append
				
			}
		}	
	
	
	
	
	* Buffer robustness
		
			foreach y in na re ri{		
			
				esttab  `y'_graduado_2000_5000 `y'_graduado_2000_20000 `y'_graduado_2000_30000 ///
				`y'compr_2000_5000 `y'compr_2000_20000  `y'compr_2000_30000  ///
				`y'_deserted_2000_5000 `y'_deserted_2000_20000 `y'_deserted_2000_30000  ///			
				`y'desr_2000_5000  `y'desr_2000_20000  `y'desr_2000_30000  ///
				using "${overleaf}/resultados/new_drills/school/completion_desertion_rob_buffer", `appi' f ///
					label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
					star(* 0.10 ** 0.05 *** 0.01) ///
					cells(b(star fmt(3)) se(par fmt(2))) ///
					scalars(rkf)  sfmt(0 3)	
					
			local appi append
				
			}
			
			
	
	
* Time robustness
		
			foreach y in na re ri{		
			
				esttab  `y'_graduado_1970_10000 `y'_graduado_1980_10000 `y'_graduado_1990_10000 ///
				`y'compr_1970_10000 `y'compr_1980_10000  `y'compr_1990_10000  ///
				`y'_deserted_1970_10000 `y'_deserted_1980_10000 `y'_deserted_1990_10000  ///			
				`y'desr_1970_10000  `y'desr_1980_10000  `y'desr_1990_10000  ///
				using "${overleaf}/resultados/new_drills/school/completion_desertion_rob_time", `appi' f ///
					label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
					star(* 0.10 ** 0.05 *** 0.01) ///
					cells(b(star fmt(3)) se(par fmt(2))) ///
					scalars(rkf)  sfmt(0 3)	
					
			local appi append
				
			}




}
