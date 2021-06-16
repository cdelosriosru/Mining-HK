
/*

 PROJECT :     	Mining - HK
 AUTHOR :			Camilo De Los Rios
 PURPOSE :			Dealing with selection/some threats
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





***** Number of students and quality *****

* number of students. 
use "${compiled}/hk_oilwells_colegio_mines.dta", clear 
	
local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000  {
		preserve
			foreach y in  estudiantes  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename npozos_`w'sd npozos
				
		

				*second order poly trend
				
					ivreghdfe outcome MAP_`w'  (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store riv_`y'_`w'
					
					
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store rred_`y'_`w'
				
					reghdfe outcome MAP_`w'  npozos , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store na_`y'_`w'

				

				
				local rep_app = "append"
				
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename outcome `y'
		
			}
		restore
		}
}


*** Quality ***

use "${compiled}/hk_oilwells_individual_mines.dta", clear
 
local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
	*		drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  pct2 { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age npozos , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store na_`y'_`w'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename outcome `y'
		
			}
		restore
		}
}


foreach y in 10000  {

local appi replace
	foreach x in na rred riv{


	esttab   `x'_estudiantes_`y' `x'_pct2_`y'  using "${overleaf}/resultados/new_drills/threats/qualityandnumber_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{pct2_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)


	local appi append
	
	}		
}

estimates clear



***** Cleaning Schools age and year  of first data *******



 


foreach t in 1 2 3{
estimates clear
use "${compiled}/hk_oilwells_colegio_mines.dta", clear 

merge m:1 id_cole using "${hk}/harm/clean_coles.dta", gen(mer_cleancol)

keep if keep`t'==1

	foreach z in _{
	local rep_app = "replace"
		foreach x in 2000 {
			foreach w in  10000  {
					foreach y in  enrolment_rate rentseeker_1  uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
				
						rename `y' outcome
						rename w_lb_`x'_`w' v_brent_price
						rename npozos_`w'sd npozos

						*second order poly trend
						
						ivreghdfe outcome MAP_`w'  (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
						estimates store ri`y'_`z'`x'
											
						reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
						estimates store re`y'_`z'`x'
					
						reghdfe outcome MAP_`w'  npozos , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
						estimates store  na`y'_`z'`x'
											
						local rep_app = "append"
						
						rename npozos npozos_`w'sd 
						rename v_brent_price w_lb_`x'_`w'  			
						rename outcome `y'				
					}
				}
		}
	}


	local appi replace
	foreach x in  2000  {
		foreach z in  _ {
			foreach y in na re ri{		
			
				esttab  `y'enrolment_rate_`z'`x' `y'rentseeker_1_`z'`x' `y'uni_1_`z'`x' using "${overleaf}/resultados/new_drills/threats/school_`z'_10000_`t'", `appi' f ///
					label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
					star(* 0.10 ** 0.05 *** 0.01) ///
					cells(b(star fmt(3)) se(par fmt(2))) ///
					mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
					scalars(rkf)  sfmt(0 3)	
					
			local appi append
				
			}
		}			
	}

estimates clear
}


* Individual


 


foreach t in 1 2 3{
estimates clear
use "${compiled}/hk_oilwells_individual_mines.dta", clear
merge m:1 id_cole using "${hk}/harm/clean_coles.dta", gen(mer_cleancol)
keep if keep`t'==1

**** Enrolment***

local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
			foreach y in  enroled_he universitario technic semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age npozos , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store na_`y'_`w'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename outcome `y'
		
			}
		}
}


foreach y in 10000  {

local appi replace
	foreach x in na rred riv{

	esttab   `x'_enroled_he_`y' `x'_universitario_`y' `x'_technic_`y' `x'_semestertohe_`y'  using "${overleaf}/resultados/new_drills/threats/enrolment`y'_`t'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{pct2_`y'}" "\specialcell{rent_seeker_`y'}" "\specialcell{semestertohe_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

estimates clear


***Program Selection*** 

local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
			foreach y in  engistemi admin_econ others { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (npozos=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age npozos , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store na_`y'_`w'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename outcome `y'
		
			}
		}
}


foreach y in 10000  {

local appi replace
	foreach x in na rred riv{


	esttab   `x'_engistemi_`y'  `x'_admin_econ_`y' `x'_others_`y' using "${overleaf}/resultados/new_drills/threats/program_selection_`y'_`t'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{pct2_`y'}" "\specialcell{rent_seeker_`y'}" "\specialcell{semestertohe_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)		


	local appi append
	
	}		
		
}
estimates clear
}









	