
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

							     School

------------------------------------------------------------------------------*/

use "${compiled}/hk_oilwells_colegio_mines.dta", clear 

/*
unique id_cole
merge m:1 id_cole using "${compiled}/coles1718.dta", gen(mer_18)
drop if mer_18==3
unique id_cole
merge m:1 id_cole using "${compiled}/coles2829.dta", gen(mer_29)
drop if mer_29==3
unique id_cole


unique id_cole
merge m:1 id_cole using "${compiled}/coles1828.dta", gen(mer_1828)
drop if mer_1828==3
unique id_cole
*/


foreach y in  enrolment_rate  uni_1 {
local rep_app = "replace"
	foreach x in 2000 {
		foreach w in  10000  {
			preserve
			*	drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

				foreach z in 1 15 30 45 { //enroled_he rent_seeker universitario deserted timetohe semestertohe
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum`z'_`w'sd wells_accum

					*second order poly trend
					
					ivreghdfe outcome MAP_`w'  (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'_`z'
					/*					
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
					estimates store re`y'_`z'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store  na`y'_`z'
					*/
										
					local rep_app = "append"
					
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum`z'_`w'sd 
					rename outcome `y'
			
				}
			restore
			}
	}
	
/*
	
	foreach z in ri re na{
	
		coefplot  (`z'`y'_2, aseq(2) \ `z'`y'_3, aseq(3) \ `z'`y'_4, aseq(4) \ `z'`y'_5, aseq(5)  \ ///
		`z'`y'_6, aseq(6) \ `z'`y'_7, aseq(7) \ `z'`y'_8, aseq(8) \ `z'`y'_9, aseq(9) \ `z'`y'_10, aseq(10) \  ///
		`z'`y'_11, aseq(11) \ `z'`y'_12, aseq(12) \ `z'`y'_13, aseq(13) \ `z'`y'_14, aseq(14) \ `z'`y'_15, aseq(15)  \ ///
		`z'`y'_16, aseq(16) \ `z'`y'_17, aseq(17) \ `z'`y'_18, aseq(18) \ `z'`y'_19, aseq(19) \ `z'`y'_20, aseq(20)  \ ///
		`z'`y'_21, aseq(21) \ `z'`y'_22, aseq(22) \ `z'`y'_23, aseq(23) \ `z'`y'_24, aseq(24) \ `z'`y'_25, aseq(25)  \ ///
		`z'`y'_26, aseq(26) \ `z'`y'_27, aseq(27) \ `z'`y'_28, aseq(28) \ `z'`y'_29, aseq(29) \ `z'`y'_30, aseq(30)  \ ///
		`z'`y'_31, aseq(31) \ `z'`y'_32, aseq(32) \ `z'`y'_33, aseq(33) \ `z'`y'_34, aseq(34) \ `z'`y'_35, aseq(35)  \ ///
		`z'`y'_36, aseq(36) \ `z'`y'_37, aseq(37) \ `z'`y'_38, aseq(38) \ `z'`y'_39, aseq(39) \ `z'`y'_40, aseq(40) \ ///
		`z'`y'_41, aseq(41) \ `z'`y'_42, aseq(42) \ `z'`y'_43, aseq(43) \ `z'`y'_44, aseq(44) \ `z'`y'_45, aseq(45)  \  ///
		`z'`y'_46, aseq(46) \ `z'`y'_47, aseq(47) \ `z'`y'_48, aseq(48) \ `z'`y'_49, aseq(49) \ `z'`y'_50, aseq(50) )  ///
		, drop(MAP_10000 _cons) vertical swapnames scheme(s1mono) yline(0, lcolor(red)) ciopts(recast(rcap)) xti("Years") 

		gr export "${overleaf}/resultados/school/mines/`z'`y'_time_rob.pdf", replace 

	}
	
	*/
	
	
	foreach z in ri {
		set scheme cleanplots
		coefplot  (`z'`y'_1, aseq(1)  \ ///
		`z'`y'_15, aseq(15)  \ ///
		`z'`y'_30, aseq(30)  \ ///
		`z'`y'_45, aseq(45) )  ///
		, drop(MAP_10000 _cons) vertical swapnames yline(0, lcolor(red)) ciopts(recast(rcap) color(black)) xti("Wells' Age") mcolor(black) msymbol(circle)
		
		gr export "${overleaf}/resultados/school/mines/`z'`y'_time_rob.pdf", replace 

	}

estimates clear

}


/*------------------------------------------------------------------------------

							  Individual

------------------------------------------------------------------------------*/

use "${compiled}/hk_oilwells_individual_mines.dta", clear 

/*
unique id_cole
merge m:1 id_cole using "${compiled}/coles1718.dta", gen(mer_18)
drop if mer_18==3
unique id_cole
merge m:1 id_cole using "${compiled}/coles2829.dta", gen(mer_29)
drop if mer_29==3
unique id_cole


unique id_cole
merge m:1 id_cole using "${compiled}/coles1828.dta", gen(mer_1828)
drop if mer_1828==3
unique id_cole
*/

foreach y in enroled_he universitario  others  semestertohe pct2 { //  universitario 
local rep_app = "replace"
	foreach x in 2000 {
		foreach w in  10000  {
			preserve

				foreach z in 1 15 30 45 { 
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum`z'_`w'sd wells_accum

					*second order poly trend
					
					ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'_`z'
					/*					
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
					estimates store re`y'_`z'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store  na`y'_`z'
					*/
										
					local rep_app = "append"
					
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum`z'_`w'sd 
					rename outcome `y'
			
				}
			restore
			}
	}
	
/*
	
	foreach z in ri re na{
	
		coefplot  (`z'`y'_2, aseq(2) \ `z'`y'_3, aseq(3) \ `z'`y'_4, aseq(4) \ `z'`y'_5, aseq(5)  \ ///
		`z'`y'_6, aseq(6) \ `z'`y'_7, aseq(7) \ `z'`y'_8, aseq(8) \ `z'`y'_9, aseq(9) \ `z'`y'_10, aseq(10) \  ///
		`z'`y'_11, aseq(11) \ `z'`y'_12, aseq(12) \ `z'`y'_13, aseq(13) \ `z'`y'_14, aseq(14) \ `z'`y'_15, aseq(15)  \ ///
		`z'`y'_16, aseq(16) \ `z'`y'_17, aseq(17) \ `z'`y'_18, aseq(18) \ `z'`y'_19, aseq(19) \ `z'`y'_20, aseq(20)  \ ///
		`z'`y'_21, aseq(21) \ `z'`y'_22, aseq(22) \ `z'`y'_23, aseq(23) \ `z'`y'_24, aseq(24) \ `z'`y'_25, aseq(25)  \ ///
		`z'`y'_26, aseq(26) \ `z'`y'_27, aseq(27) \ `z'`y'_28, aseq(28) \ `z'`y'_29, aseq(29) \ `z'`y'_30, aseq(30)  \ ///
		`z'`y'_31, aseq(31) \ `z'`y'_32, aseq(32) \ `z'`y'_33, aseq(33) \ `z'`y'_34, aseq(34) \ `z'`y'_35, aseq(35)  \ ///
		`z'`y'_36, aseq(36) \ `z'`y'_37, aseq(37) \ `z'`y'_38, aseq(38) \ `z'`y'_39, aseq(39) \ `z'`y'_40, aseq(40) \ ///
		`z'`y'_41, aseq(41) \ `z'`y'_42, aseq(42) \ `z'`y'_43, aseq(43) \ `z'`y'_44, aseq(44) \ `z'`y'_45, aseq(45)  \  ///
		`z'`y'_46, aseq(46) \ `z'`y'_47, aseq(47) \ `z'`y'_48, aseq(48) \ `z'`y'_49, aseq(49) \ `z'`y'_50, aseq(50) )  ///
		, drop(MAP_10000 _cons) vertical swapnames scheme(s1mono) yline(0, lcolor(red)) ciopts(recast(rcap)) xti("Years") 

		gr export "${overleaf}/resultados/school/mines/`z'`y'_time_rob.pdf", replace 

	}
	
	*/
	
	
	foreach z in ri {
		set scheme cleanplots
		coefplot  (`z'`y'_1, aseq(1)  \ ///
		`z'`y'_15, aseq(15)  \ ///
		`z'`y'_30, aseq(30)  \ ///
		`z'`y'_45, aseq(45) )  ///
		, keep(wells_accum) vertical swapnames yline(0, lcolor(red)) ciopts(recast(rcap) color(black)) xti("Wells' Age") mcolor(black) msymbol(circle)
		
		gr export "${overleaf}/resultados/individual/mines/`z'`y'_time_rob.pdf", replace 

	}

estimates clear
}

foreach y in engistemi admin_econ {
local rep_app = "replace"
	foreach x in 2000 {
		foreach w in  10000  {
			preserve
				foreach z in 1 15 30 45 { 
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum`z'_`w'sd wells_accum

					*second order poly trend
					
					ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'_`z'
					/*					
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
					estimates store re`y'_`z'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store  na`y'_`z'
					*/
										
					local rep_app = "append"
					
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum`z'_`w'sd 
					rename outcome `y'
			
				}
			restore
			}
	}
	
/*
	
	foreach z in ri re na{
	
		coefplot  (`z'`y'_2, aseq(2) \ `z'`y'_3, aseq(3) \ `z'`y'_4, aseq(4) \ `z'`y'_5, aseq(5)  \ ///
		`z'`y'_6, aseq(6) \ `z'`y'_7, aseq(7) \ `z'`y'_8, aseq(8) \ `z'`y'_9, aseq(9) \ `z'`y'_10, aseq(10) \  ///
		`z'`y'_11, aseq(11) \ `z'`y'_12, aseq(12) \ `z'`y'_13, aseq(13) \ `z'`y'_14, aseq(14) \ `z'`y'_15, aseq(15)  \ ///
		`z'`y'_16, aseq(16) \ `z'`y'_17, aseq(17) \ `z'`y'_18, aseq(18) \ `z'`y'_19, aseq(19) \ `z'`y'_20, aseq(20)  \ ///
		`z'`y'_21, aseq(21) \ `z'`y'_22, aseq(22) \ `z'`y'_23, aseq(23) \ `z'`y'_24, aseq(24) \ `z'`y'_25, aseq(25)  \ ///
		`z'`y'_26, aseq(26) \ `z'`y'_27, aseq(27) \ `z'`y'_28, aseq(28) \ `z'`y'_29, aseq(29) \ `z'`y'_30, aseq(30)  \ ///
		`z'`y'_31, aseq(31) \ `z'`y'_32, aseq(32) \ `z'`y'_33, aseq(33) \ `z'`y'_34, aseq(34) \ `z'`y'_35, aseq(35)  \ ///
		`z'`y'_36, aseq(36) \ `z'`y'_37, aseq(37) \ `z'`y'_38, aseq(38) \ `z'`y'_39, aseq(39) \ `z'`y'_40, aseq(40) \ ///
		`z'`y'_41, aseq(41) \ `z'`y'_42, aseq(42) \ `z'`y'_43, aseq(43) \ `z'`y'_44, aseq(44) \ `z'`y'_45, aseq(45)  \  ///
		`z'`y'_46, aseq(46) \ `z'`y'_47, aseq(47) \ `z'`y'_48, aseq(48) \ `z'`y'_49, aseq(49) \ `z'`y'_50, aseq(50) )  ///
		, drop(MAP_10000 _cons) vertical swapnames scheme(s1mono) yline(0, lcolor(red)) ciopts(recast(rcap)) xti("Years") 

		gr export "${overleaf}/resultados/school/mines/`z'`y'_time_rob.pdf", replace 

	}
	
	*/
	
	
	foreach z in ri {
		set scheme cleanplots
		coefplot  (`z'`y'_1, aseq(1)  \ ///
		`z'`y'_15, aseq(15)  \ ///
		`z'`y'_30, aseq(30)  \ ///
		`z'`y'_45, aseq(45) )  ///
		, keep(wells_accum) vertical swapnames ciopts(recast(rcap) color(black)) xti("Wells' Age") mcolor(black) msymbol(circle)
		
		gr export "${overleaf}/resultados/individual/mines/`z'`y'_time_rob.pdf", replace 

	}

estimates clear

}

****Completion

use "${compiled}/hk_oilwells_individual_mines_comp.dta", clear
drop if year>2010

	 
	 foreach y in graduado deserted { //  universitario 
local rep_app = "replace"
	foreach x in 2000 {
		foreach w in  10000  {
			preserve

				foreach z in 1 15 30 45 { 
			
					rename `y' outcome
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum`z'_`w'sd wells_accum

					*second order poly trend
					
					ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
					estimates store ri`y'_`z'
					/*					
					reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) // these are the same regardless of the age of the oil wells. 
					estimates store re`y'_`z'
				
					reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
					estimates store  na`y'_`z'
					*/
										
					local rep_app = "append"
					
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum`z'_`w'sd 
					rename outcome `y'
			
				}
			restore
			}
	}
	
/*
	
	foreach z in ri re na{
	
		coefplot  (`z'`y'_2, aseq(2) \ `z'`y'_3, aseq(3) \ `z'`y'_4, aseq(4) \ `z'`y'_5, aseq(5)  \ ///
		`z'`y'_6, aseq(6) \ `z'`y'_7, aseq(7) \ `z'`y'_8, aseq(8) \ `z'`y'_9, aseq(9) \ `z'`y'_10, aseq(10) \  ///
		`z'`y'_11, aseq(11) \ `z'`y'_12, aseq(12) \ `z'`y'_13, aseq(13) \ `z'`y'_14, aseq(14) \ `z'`y'_15, aseq(15)  \ ///
		`z'`y'_16, aseq(16) \ `z'`y'_17, aseq(17) \ `z'`y'_18, aseq(18) \ `z'`y'_19, aseq(19) \ `z'`y'_20, aseq(20)  \ ///
		`z'`y'_21, aseq(21) \ `z'`y'_22, aseq(22) \ `z'`y'_23, aseq(23) \ `z'`y'_24, aseq(24) \ `z'`y'_25, aseq(25)  \ ///
		`z'`y'_26, aseq(26) \ `z'`y'_27, aseq(27) \ `z'`y'_28, aseq(28) \ `z'`y'_29, aseq(29) \ `z'`y'_30, aseq(30)  \ ///
		`z'`y'_31, aseq(31) \ `z'`y'_32, aseq(32) \ `z'`y'_33, aseq(33) \ `z'`y'_34, aseq(34) \ `z'`y'_35, aseq(35)  \ ///
		`z'`y'_36, aseq(36) \ `z'`y'_37, aseq(37) \ `z'`y'_38, aseq(38) \ `z'`y'_39, aseq(39) \ `z'`y'_40, aseq(40) \ ///
		`z'`y'_41, aseq(41) \ `z'`y'_42, aseq(42) \ `z'`y'_43, aseq(43) \ `z'`y'_44, aseq(44) \ `z'`y'_45, aseq(45)  \  ///
		`z'`y'_46, aseq(46) \ `z'`y'_47, aseq(47) \ `z'`y'_48, aseq(48) \ `z'`y'_49, aseq(49) \ `z'`y'_50, aseq(50) )  ///
		, drop(MAP_10000 _cons) vertical swapnames scheme(s1mono) yline(0, lcolor(red)) ciopts(recast(rcap)) xti("Years") 

		gr export "${overleaf}/resultados/school/mines/`z'`y'_time_rob.pdf", replace 

	}
	
	*/
	
	
	foreach z in ri {
		set scheme cleanplots
		coefplot  (`z'`y'_1, aseq(1)  \ ///
		`z'`y'_15, aseq(15)  \ ///
		`z'`y'_30, aseq(30)  \ ///
		`z'`y'_45, aseq(45) )  ///
		, keep(wells_accum) vertical swapnames yline(0, lcolor(red)) ciopts(recast(rcap) color(black)) xti("Wells' Age") mcolor(black) msymbol(circle)
		
		gr export "${overleaf}/resultados/individual/mines/`z'`y'_time_rob.pdf", replace 

	}

estimates clear
}

