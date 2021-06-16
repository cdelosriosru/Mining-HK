
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
foreach x in  1970 1980 1990 2000 {
	foreach w in 5000 10000 20000 30000  {
		preserve
			foreach y in  estudiantes  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum_`w'sd wells_accum
					rename npozos_`w'sd npozos
				
		

				*second order poly trend
				
					ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'`x'`w'
					
					
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store re`y'`x'`w'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store na`y'`x'`w'

				

				
				local rep_app = "append"
				
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum_`w'sd 
					rename outcome `y'
		
			}
		restore
		}
}


*** Quality ***

use "${compiled}/hk_oilwells_individual_mines.dta", clear
 
local rep_app = "replace"
foreach x in  1970 1980 1990 2000 {
	foreach w in  5000 10000 20000 30000   {

			foreach y in  pct2 { 
		
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


* stringent

foreach z in 30_{

use "${compiled}/hk_oilwells_colegio_mines.dta", clear 

foreach x in  1970  2000 {
	foreach w in  10000    {
			foreach y in  estudiantes  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum`z'`w'sd wells_accum
					rename npozos_`w'sd npozos
				
		

				*second order poly trend
				
					ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'`z'`x'
					
					
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store re`y'`z'`x'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store na`y'`z'`x'

				
				
					rename npozos npozos_`w'sd 
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum`z'`w'sd 
					rename outcome `y'
		
			}
		}
}


*** Quality ***

use "${compiled}/hk_oilwells_individual_mines.dta", clear
 
local rep_app = "replace"
foreach x in  1970 2000 {
	foreach w in   10000    {

			foreach y in  pct2 { 
		
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
				

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum`z'`w'sd 
				rename outcome `y'
		
			}
		}
}





local appi replace

	foreach y in na re ri{		
		
		esttab  `y'pct2`z'1970 `y'pct2`z'2000  `y'estudiantes`z'1970 `y'estudiantes`z'2000  using "${overleaf}/resultados/threats/qual_stringent_`z'", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			scalars(rkf)  sfmt(0 3)	
			
				local appi append

			
	}
}	






*  Main

local appi replace
foreach x in  2000  {
		foreach y in na re ri{		
		
			esttab  `y'pct2`x'10000 `y'estudiantes`x'10000 using "${overleaf}/resultados/threats/qual_10000", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}			

*  Buffer robustness
local appi replace

foreach x in 2000{
	foreach y in na re ri{		
		
		esttab  `y'pct2`x'5000 `y'pct2`x'20000 `y'pct2`x'30000 `y'estudiantes`x'5000 `y'estudiantes`x'20000 `y'estudiantes`x'30000 using "${overleaf}/resultados/threats/qual_rob_buffers", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			scalars(rkf)  sfmt(0 3)	
			
				local appi append

			
	}
}	


*  Suitability robustness
local appi replace

	foreach y in na re ri{		
		
		esttab  `y'pct2197010000 `y'pct2198010000 `y'pct2199010000 `y'estudiantes197010000 `y'estudiantes198010000 `y'estudiantes199010000 using "${overleaf}/resultados/threats/qual_rob_time", `appi' f ///
			label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			cells(b(star fmt(3)) se(par fmt(2))) ///
			scalars(rkf)  sfmt(0 3)	
			
				local appi append

			
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
					foreach y in  enrolment_rate  uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
				
						rename `y' outcome
						rename w_lb_`x'_`w' v_brent_price
						rename wells_accum`z'`w'sd wells_accum
						rename npozos_`w'sd npozos

						*second order poly trend
						
						ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
						estimates store ri`y'_`z'`x'
											
						reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
						estimates store re`y'_`z'`x'
					
						reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
						estimates store  na`y'_`z'`x'
											
						local rep_app = "append"
						
						rename npozos npozos_`w'sd 
						rename v_brent_price w_lb_`x'_`w'  			
						rename wells_accum wells_accum`z'`w'sd 
						rename outcome `y'				
					}
				}
		}
	}


	local appi replace
	foreach x in  2000  {
		foreach z in  _ {
			foreach y in na re ri{		
			
				esttab  `y'enrolment_rate_`z'`x'  `y'uni_1_`z'`x' using "${overleaf}/resultados/threats/school_`z'_10000_`t'", `appi' f ///
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
			foreach y in  enroled_he universitario  semestertohe { 
		
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
				estimates store na_`y'_`w'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}


foreach y in 10000  {

local appi replace
	foreach x in na rred riv{

	esttab   `x'_enroled_he_`y' `x'_universitario_`y' `x'_semestertohe_`y'  using "${overleaf}/resultados/threats/enrolment`y'_`t'", `appi' f  ///
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
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'
				
				reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store na_`y'_`w'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}


foreach y in 10000  {

local appi replace
	foreach x in na rred riv{


	esttab   `x'_engistemi_`y'  `x'_admin_econ_`y' `x'_others_`y' using "${overleaf}/resultados/threats/program_selection_`y'_`t'", `appi' f  ///
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



****

***Completion decisons***

foreach t in  2 3{ //1
estimates clear
use "${compiled}/hk_oilwells_individual_mines_comp.dta", clear
merge m:1 id_cole using "${hk}/harm/clean_coles.dta", gen(mer_cleancol)
keep if keep`t'==1

drop if year>2010

	local rep_app = "replace"
	foreach x in 2000 { // 1970 1980 1990  2000
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





* Main

local appi replace
foreach x in  2000  {
		foreach y in na re ri{		
		
			esttab  `y'graduado`x'10000 `y'deserted`x'10000  using "${overleaf}/resultados/threats/completion_desertion_`t'", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				mtitle(  ) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}			


	
	






}
	