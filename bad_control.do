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





**** Bad Control *****



use "${compiled}/hk_oilwells_colegio_mines.dta", clear 

local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000  {
	
	preserve
				
	rename MAP_`w' outcome
	rename w_lb_`x'_`w' v_brent_price
	rename wells_accum_`w'sd wells_accum
	rename npozos_`w'sd npozos

	*second order poly trend
					
	ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
	estimates store riv_`w'
					
	reghdfe outcome  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
	estimates store rred_`w'
					
	reghdfe outcome   wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
	estimates store nai_`w'
					
	local rep_app = "append"
					
	rename npozos npozos_`w'sd 
	rename v_brent_price w_lb_`x'_`w'  			
	rename wells_accum wells_accum_`w'sd 
	rename outcome MAP_`w'
		
	}
	restore
}

local appi replace
foreach w in nai rred riv{		
	esttab  `w'_10000 using "${overleaf}/resultados/school/mines/badcontrol_10000", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{Bad Control}" ) ///
		scalars(rkf)  sfmt(0 3)
			
	local appi append	
}




	