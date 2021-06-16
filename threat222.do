***** Cleaning Schools age and year  of first data *******



 


foreach t in  2 3{
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
						estimates store ri`y'_`z'`x'`t'
											
						reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
						estimates store re`y'_`z'`x'`t'
					
						reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
						estimates store  na`y'_`z'`x'`t'
											
						local rep_app = "append"
						
						rename npozos npozos_`w'sd 
						rename v_brent_price w_lb_`x'_`w'  			
						rename wells_accum wells_accum`z'`w'sd 
						rename outcome `y'				
					}
				}
		}
	}



}

	local appi replace
	foreach x in  2000  {
		foreach z in  _ {
			foreach y in na re ri{		
			
				esttab  `y'enrolment_rate_`z'`x'2 `y'enrolment_rate_`z'`x'3  `y'uni_1_`z'`x'2 `y'uni_1_`z'`x'3 using "${overleaf}/resultados/threats/school_`z'_10000_all", `appi' f ///
					label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
					star(* 0.10 ** 0.05 *** 0.01) ///
					cells(b(star fmt(3)) se(par fmt(2))) ///
					mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
					scalars(rkf)  sfmt(0 3)	
					
			local appi append
				
			}
		}			
	}

	
	

* Individual


 


foreach t in  2 3{
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
				estimates store riv_`y'_`w'`t'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'`t'
				
				reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store na_`y'_`w'`t'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}






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
				estimates store riv_`y'_`w'`t'
				
				reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'`t'
				
				reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store na_`y'_`w'`t'
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}


}


foreach y in 10000  {

local appi replace
	foreach x in na rred riv{

	esttab   `x'_enroled_he_`y'2 `x'_enroled_he_`y'3 `x'_universitario_`y'2 `x'_universitario_`y'3 `x'_semestertohe_`y'2 `x'_semestertohe_`y'3  using "${overleaf}/resultados/threats/enrolment`y'_all", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{pct2_`y'}" "\specialcell{rent_seeker_`y'}" "\specialcell{semestertohe_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}



foreach y in 10000  {

local appi replace
	foreach x in na rred riv{


	esttab   `x'_engistemi_`y'2 `x'_engistemi_`y'3  `x'_admin_econ_`y'2 `x'_admin_econ_`y'3 `x'_others_`y'2 `x'_others_`y'3 using "${overleaf}/resultados/threats/program_selection_`y'_all", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{pct2_`y'}" "\specialcell{rent_seeker_`y'}" "\specialcell{semestertohe_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)		


	local appi append
	
	}		
		
}


****

***Completion decisons***
estimates clear
foreach t in  2 3{ //1
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
					estimates store ri`y'`x'`w'`t'
					
					reghdfe outcome MAP_`w' i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store re`y'`x'`w'`t'
					
					reghdfe outcome MAP_`w' i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store na`y'`x'`w'`t'
					
					local rep_app = "append"

					rename npozos npozos_`w'sd 				
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum_`w'sd 
					rename outcome `y'
			
				}
			}
	}

}


* Main

local appi replace
foreach x in  2000  {
		foreach y in na re ri{		
		
			esttab  `y'graduado`x'100002 `y'graduado`x'100003 `y'deserted`x'100002 `y'deserted`x'100003  using "${overleaf}/resultados/threats/completion_desertion_all", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				mtitle(  ) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}	