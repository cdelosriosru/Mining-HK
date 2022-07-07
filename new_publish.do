
/*

 PROJECT :     	Mining - HK
 AUTHOR :			Camilo De Los Rios
 PURPOSE :			Equation 3 of the presentation. 

 Remeber alll of your schools are secondary education. Bonilla has both primary and secondary, you have off course less schools. 
*/
clear all
set maxvar 32767, perm
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

						Enrolment

------------------------------------------------------------------------------*/
estimates clear
use "${compiled}/hk_oilwells_individual_mines.dta", clear



drop if pob200==1

rename engistemi ste
rename admin_econ adm

* Main
estimates clear


* Main
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe ste adm  { // others
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year  i.depto##c.c_year2 ) cluster(cohortdepto)
				estimates store ri`y'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year  i.depto##c.c_year2 ) vce(cluster cohortdepto)
				estimates store re`y'
				
				reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year  i.depto##c.c_year2 ) vce(cluster cohortdepto)
				estimates store na`y'
			
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}


local appi replace
	foreach x in na re ri{

	
	esttab   `x'enroled_he `x'universitario  `x'ste `x'adm `x'semestertohe using "${overleaf}/resultados/new_2022/individual/mines/res_enrol_10k", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
		
/*------------------------------------------------------------------------------

						COMPLETION

------------------------------------------------------------------------------*/


foreach t in 2010 { // 2009 2015

estimates clear
use "${compiled}/hk_oilwells_individual_mines_comp.dta", clear

rename engistemi ste
rename admin_econ adm
tostring periodoprimiparo, gen(year_prim)
replace year_prim=substr(year_prim,1,4)
destring year_prim, replace

gen timetograd=date_grad-year_prim
replace timetograd=. if timetograd<=0 

foreach prof in ste adm universitario{
gen `prof'_grad=1 if `prof'==1 & graduado==1
replace `prof'_grad=0 if `prof'==1 & graduado==0

gen `prof'_des=1 if `prof'==1 & deserted==1
replace `prof'_des=0 if `prof'==1 & deserted==0


}

drop if pob200==1

drop if year>`t'

	local rep_app = "replace"
	foreach x in 2000  { // 1970 1980 1990  2000
		foreach w in  10000  { // 5000 10000 20000 30000
				foreach y in  graduado deserted ste_grad adm_grad  adm_des ste_des universitario_grad universitario_des timetograd{ 
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum_`w'sd wells_accum
					rename npozos_`w'sd npozos
				

					*second order poly trend
					
					ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year  i.depto##c.c_year2) cluster(cohortdepto)
					estimates store ri`y'
					
					reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year  i.depto##c.c_year2 ) vce(cluster cohortdepto)
					estimates store re`y'
					
					reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year  i.depto##c.c_year2) vce(cluster cohortdepto)
					estimates store na`y'
					
					local rep_app = "append"

					rename npozos npozos_`w'sd 				
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum_`w'sd 
					rename outcome `y'
			
				}
			}
	}


local appi replace
foreach x in  2000  {
		foreach y in na re ri{		
		
			esttab  `y'graduado `y'universitario_grad `y'ste_grad `y'adm_grad  `y'deserted `y'universitario_des  `y'ste_des `y'adm_des `y'timetograd using "${overleaf}/resultados/new_2022/school/mines/completion_desertion_types_10000", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				mtitle(  ) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}			
	

}




/*------------------------------------------------------------------------------

						QUALITY AND NUMBER OF STUDENTS

------------------------------------------------------------------------------*/

estimates clear

* number of students. 
use "${compiled}/hk_oilwells_colegio_mines.dta", clear 
drop if pob200==1
	
local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000  {
		preserve
			foreach y in  estudiantes  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum_`w'sd wells_accum
					rename npozos_`w'sd npozos
				
		

				*second order poly trend
				
					ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortdepto)
					estimates store ri`y'
					
					
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(cluster cohortdepto)
					estimates store re`y'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(cluster cohortdepto)
					estimates store na`y'

				

				
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
drop if pob200==1
 
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000     {

			foreach y in  pct2 { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortdepto)
				estimates store ri`y'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(cluster cohortdepto)
				estimates store re`y'
				
				reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(cluster cohortdepto)
				estimates store na`y'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}


local appi replace
foreach x in  2000  {
		foreach y in na re ri{		
		
			esttab  `y'pct2 `y'estudiantes using "${overleaf}/resultados/NEW_2022/threats/qual_10000", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}			


	
	
	
/*------------------------------------------------------------------------------

						Het. Effects? 

------------------------------------------------------------------------------*/

			* ENROLLMENT

estimates clear
use "${compiled}/hk_oilwells_individual_mines.dta", clear
drop if pob200==1
rename engistemi ste
rename admin_econ adm

* Main
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe ste adm  { // others
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum c.wells_accum#i.oficial=v_brent_price c.v_brent_price#i.oficial) , absorb(id_cole i.depto##c.c_year  i.depto##c.c_year2 ) cluster(cohortdepto)
				estimates store ri`y'
				xlincom wells_accum+1.oficial#c.wells_accum, post
				estimates store ri2`y'
			
				reghdfe outcome MAP_`w' i.mujer age v_brent_price c.v_brent_price#i.oficial, absorb(id_cole i.depto##c.c_year  i.depto##c.c_year2 ) vce(cluster cohortdepto)
				estimates store re`y'
				xlincom v_brent_price+1.oficial#c.v_brent_price, post
				estimates store re2`y'

				
				reghdfe outcome MAP_`w' i.mujer age wells_accum c.wells_accum#i.oficial , absorb(id_cole i.depto##c.c_year  i.depto##c.c_year2 ) vce(cluster cohortdepto)
				estimates store na`y'
				xlincom wells_accum+1.oficial#c.wells_accum, post
				estimates store na2`y'
		
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}


local appi replace
	foreach x in na na2 re re2 ri ri2{

	
	esttab   `x'enroled_he `x'universitario  `x'ste `x'adm `x'semestertohe using "${overleaf}/resultados/new_2022/heteffects/reenrol_10k", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

	*COMPLETION
	
foreach t in 2010 { // 2009 2015

estimates clear
use "${compiled}/hk_oilwells_individual_mines_comp.dta", clear

rename engistemi ste
rename admin_econ adm
tostring periodoprimiparo, gen(year_prim)
replace year_prim=substr(year_prim,1,4)
destring year_prim, replace

gen timetograd=date_grad-year_prim
replace timetograd=. if timetograd<=0 

foreach prof in ste adm universitario{
gen `prof'_grad=1 if `prof'==1 & graduado==1
replace `prof'_grad=0 if `prof'==1 & graduado==0

gen `prof'_des=1 if `prof'==1 & deserted==1
replace `prof'_des=0 if `prof'==1 & deserted==0


}

drop if pob200==1

drop if year>`t'

	local rep_app = "replace"
	foreach x in 2000  { // 1970 1980 1990  2000
		foreach w in  10000  { // 5000 10000 20000 30000
				foreach y in  graduado deserted ste_grad adm_grad  adm_des ste_des universitario_grad universitario_des timetograd{ 
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum_`w'sd wells_accum
					rename npozos_`w'sd npozos
				

					*second order poly trend
					
					ivreghdfe outcome MAP_`w' i.mujer age (wells_accum c.wells_accum#i.oficial=v_brent_price c.v_brent_price#i.oficial) , absorb(id_cole i.depto##c.c_year  i.depto##c.c_year2) cluster(cohortdepto)
					estimates store ri`y'
					xlincom wells_accum+1.oficial#c.wells_accum, post
					estimates store ri2`y'

					
					reghdfe outcome MAP_`w' i.mujer age v_brent_price c.v_brent_price#i.oficial, absorb(id_cole i.depto##c.c_year  i.depto##c.c_year2 ) vce(cluster cohortdepto)
					estimates store re`y'
					xlincom v_brent_price+1.oficial#c.v_brent_price, post
					estimates store re2`y'

					
					reghdfe outcome MAP_`w' i.mujer age wells_accum c.wells_accum#i.oficial, absorb(id_cole i.depto##c.c_year  i.depto##c.c_year2) vce(cluster cohortdepto)
					estimates store na`y'
					xlincom wells_accum+1.oficial#c.wells_accum, post
					estimates store na2`y'

					
					local rep_app = "append"

					rename npozos npozos_`w'sd 				
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum_`w'sd 
					rename outcome `y'
			
				}
			}
	}


local appi replace
foreach x in  2000  {
		foreach y in na na2 re re2 ri ri2{		
		
			esttab  `y'graduado `y'universitario_grad `y'ste_grad `y'adm_grad  `y'deserted `y'universitario_des  `y'ste_des `y'adm_des `y'timetograd using "${overleaf}/resultados/new_2022/heteffects/compl_des_ht", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				mtitle(  ) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}			
	

}

	
	/*--------------------------------------------------------------------------
	
						ROBUSTNESS ESTIMATIONS HERE
	
	--------------------------------------------------------------------------*/
		
		
	
	