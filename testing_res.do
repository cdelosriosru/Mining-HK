
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



use "${compiled}/hk_oilwells_individual_mines.dta", clear



**** Enrolment***





* Main
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(id_cole)
				estimates store ri1`y'_`x'`w'
				
				* depto, 2nd order, rubust ESTEEE
								
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store ri2`y'_`x'`w'				
				
				* MPIO, 2nd order, rubust
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2) r
				estimates store ri3`y'_`x'`w'				
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(id_cole)
				estimates store ri4`y'_`x'`w'		
				
				
				
				preserve
					
				drop if pob200==1
					
					

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(id_cole)
				estimates store ri5`y'_`x'`w'
				
				* depto, 2nd order, rubust ESTE
								
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store ri6`y'_`x'`w'				
				
				* MPIO, 2nd order, rubust
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2) r
				estimates store ri7`y'_`x'`w'				
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(id_cole)
				estimates store ri8`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w' ri5`x'_2000`w' ri6`x'_2000`w' ri7`x'_2000`w' ri8`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_1_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

estimates clear 

local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			
								
				preserve
					
				drop if pob100==1
					
					

				*depto, 2nd order, cluster ESTE
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(id_cole)
				estimates store ri1`y'_`x'`w'
				
				* depto, 2nd order, rubust ESTE
								
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store ri2`y'_`x'`w'				
				
				* MPIO, 2nd order, rubust ESTE
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2) r
				estimates store ri3`y'_`x'`w'				
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(id_cole)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				preserve
					
				drop if urban==1
					
					

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(id_cole)
				estimates store ri5`y'_`x'`w'
				
				* depto, 2nd order, rubust ESTE
								
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store ri6`y'_`x'`w'				
				
				* MPIO, 2nd order, rubust
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2) r
				estimates store ri7`y'_`x'`w'				
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(id_cole)
				estimates store ri8`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w' ri5`x'_2000`w' ri6`x'_2000`w' ri7`x'_2000`w' ri8`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_2_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}




*** The same as before but with only linear trends




* Main
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(id_cole)
				estimates store ri1`y'_`x'`w'
				
				* depto, linear trend, rubust
								
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) r
				estimates store ri2`y'_`x'`w'				
				
				* MPIO, linear trend, rubust
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year) r
				estimates store ri3`y'_`x'`w'				
				
				* MPIO, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(id_cole)
				estimates store ri4`y'_`x'`w'		
				
				
				
				preserve
					
				drop if pob200==1
					
					

				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(id_cole)
				estimates store ri5`y'_`x'`w'
				
				* depto, linear trend, rubust
								
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) r
				estimates store ri6`y'_`x'`w'				
				
				* MPIO, linear trend, rubust
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year) r
				estimates store ri7`y'_`x'`w'				
				
				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(id_cole)
				estimates store ri8`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w' ri5`x'_2000`w' ri6`x'_2000`w' ri7`x'_2000`w' ri8`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_3_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

estimates clear 

local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			
								
				preserve
					
				drop if pob100==1
					
					

				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(id_cole)
				estimates store ri1`y'_`x'`w'
				
				* depto,  linear trend, rubust
								
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) r
				estimates store ri2`y'_`x'`w'				
				
				* MPIO,  linear trend, rubust
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year) r
				estimates store ri3`y'_`x'`w'				
				
				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(id_cole)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				preserve
					
				drop if urban==1
					
					

				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(id_cole)
				estimates store ri5`y'_`x'`w'
				
				* depto,  linear trend, rubust
								
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) r
				estimates store ri6`y'_`x'`w'				
				
				* MPIO,  linear trend, rubust
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year) r
				estimates store ri7`y'_`x'`w'				
				
				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(id_cole)
				estimates store ri8`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w' ri5`x'_2000`w' ri6`x'_2000`w' ri7`x'_2000`w' ri8`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_4_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}





****** cluster mpio year*****






* Main
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(codmpio year)
				estimates store ri1`y'_`x'`w'
				
				
				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(id_cole year)
				estimates store ri2`y'_`x'`w'
				
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(id_cole year)
				estimates store ri3`y'_`x'`w'	
				
				
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(codmpio year)
				estimates store ri4`y'_`x'`w'		
				
				
				

				
				preserve
					
				drop if pob200==1
					
					

				*depto, 2nd order, cluster ESTE PERO OJO. 
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(codmpio year)
				estimates store ri5`y'_`x'`w'
				

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(id_cole year)
				estimates store ri6`y'_`x'`w'
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(id_cole year)
				estimates store ri7`y'_`x'`w'
				
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(codmpio year)
				estimates store ri8`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w' ri5`x'_2000`w' ri6`x'_2000`w' ri7`x'_2000`w' ri8`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_5_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

estimates clear 

local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			
								
				preserve
					
				drop if pob100==1
					
					

				*depto, 2nd order, cluster ESTE
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(codmpio year)
				estimates store ri1`y'_`x'`w'
				
				*depto, 2nd order, cluster ESTE
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(id_cole year)
				estimates store ri2`y'_`x'`w'

				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(id_cole year)
				estimates store ri3`y'_`x'`w'

	
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(codmpio year)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				preserve
					
				drop if urban==1
					
					

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(codmpio year)
				estimates store ri5`y'_`x'`w'
				
				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(id_cole year)
				estimates store ri6`y'_`x'`w'
				

				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(id_cole year)
				estimates store ri7`y'_`x'`w'


				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(codmpio year)
				estimates store ri8`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w' ri5`x'_2000`w' ri6`x'_2000`w' ri7`x'_2000`w' ri8`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_6_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}




*** The same as before but with only linear trends


estimates clear

* Main
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(codmpio year)
				estimates store ri1`y'_`x'`w'

				
				
				
				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(id_cole year)
				estimates store ri2`y'_`x'`w'
				
				
				* MPIO, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(id_cole year)
				estimates store ri3`y'_`x'`w'	

				
				* MPIO, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(codmpio year)
				estimates store ri4`y'_`x'`w'		
				
				
				
				preserve
					
				drop if pob200==1
					
					

				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(codmpio year)
				estimates store ri5`y'_`x'`w'
				
				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(id_cole year)
				estimates store ri6`y'_`x'`w'
				

				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(id_cole year)
				estimates store ri7`y'_`x'`w'

				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(codmpio year)
				estimates store ri8`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w' ri5`x'_2000`w' ri6`x'_2000`w' ri7`x'_2000`w' ri8`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_7_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

estimates clear 

local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			
								
				preserve
					
				drop if pob100==1
					
					

				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(codmpio year)
				estimates store ri1`y'_`x'`w'
				
				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(id_cole year)
				estimates store ri2`y'_`x'`w'
				
				
				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(id_cole year)
				estimates store ri3`y'_`x'`w'

				
				
				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(codmpio year)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				preserve
					
				drop if urban==1
					
					

				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(codmpio year)
				estimates store ri5`y'_`x'`w'
				
				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(id_cole year)
				estimates store ri6`y'_`x'`w'
				

				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(id_cole year)
				estimates store ri7`y'_`x'`w'


				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(codmpio year)
				estimates store ri8`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w' ri5`x'_2000`w' ri6`x'_2000`w' ri7`x'_2000`w' ri8`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_8_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

**# Bookmark #1


use "${compiled}/hk_oilwells_individual_mines.dta", clear

egen cohortmpio=group(codmpio year)
egen cohortcole=group(id_cole year)
egen cohortdepto=group(depto year)


**** Enrolment***





* Main






****** cluster dpto year*****


estimates clear



* Main
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(depto year)
				estimates store ri1`y'_`x'`w'
			
				
				
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(depto year)
				estimates store ri2`y'_`x'`w'		
				
				
				

				
				preserve
					
				drop if pob200==1
					
					

				*depto, 2nd order, cluster ESTE PERO OJO. 
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(depto year)
				estimates store ri3`y'_`x'`w'
				

				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(depto year)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_9_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

estimates clear 

local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			
								
				preserve
					
				drop if pob100==1
					
					

				*depto, 2nd order, cluster ESTE
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(depto year)
				estimates store ri1`y'_`x'`w'
				

	
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(depto year)
				estimates store ri2`y'_`x'`w'

				
				restore
				
				
				preserve
					
				drop if urban==1
					
					

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(depto year)
				estimates store ri3`y'_`x'`w'
				


				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(depto year)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_10_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}




*** The same as before but with only linear trends


estimates clear

* Main
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(depto year)
				estimates store ri1`y'_`x'`w'
				
				
				* MPIO, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(depto year)
				estimates store ri2`y'_`x'`w'		
				
				
				
				preserve
					
				drop if pob200==1
					
					

				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(depto year)
				estimates store ri3`y'_`x'`w'


				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(depto year)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_11_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

estimates clear 

local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			
								
				preserve
					
				drop if pob100==1
					
					

				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(depto year)
				estimates store ri1`y'_`x'`w'
				
				
				
				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(depto year)
				estimates store ri2`y'_`x'`w'

				
				restore
				
				
				preserve
					
				drop if urban==1
					
					

				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(depto year)
				estimates store ri3`y'_`x'`w'
				


				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(depto year)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_12_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}






**# Bookmark #2
* Main
use "${compiled}/hk_oilwells_individual_mines.dta", clear
egen cohortmpio=group(codmpio year)
egen cohortcole=group(id_cole year)
egen cohortdepto=group(depto year)


				preserve
					
				drop if pob200==1
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			
	
				
				
				

				

					
					

				*depto, 2nd order, cluster ESTE PERO OJO. 
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(codmpio year)
				estimates store ri`y'_`x'`w'
				
				reghdfe outcome MAP_`w'  v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2)  vce(cluster codmpio year) 
				estimates store re`y'`z'`x'`w'
				
				reghdfe outcome MAP_`w'  wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(cluster codmpio year)
				estimates store  na`y'`z'`x'`w'


				
		
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
		restore
				

local appi replace
foreach x in  2000  {
		foreach y in na re ri{		
		
	esttab  `y'enroled_he`x'10000   `y'universitario`x'10000 `y'semestertohe`x'10000 using "${overleaf}/resultados/new_2022/school/mines/noisic/finaltest", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}		
	
	local appi append
foreach x in  2000  {
		foreach y in ri{		
		
	esttab  `y'enroled_he_`x'10000   `y'universitario_`x'10000 `y'semestertohe_`x'10000 using "${overleaf}/resultados/new_2022/school/mines/noisic/finaltest", `appi' f ///
				label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
				star(* 0.10 ** 0.05 *** 0.01) ///
				cells(b(star fmt(3)) se(par fmt(2))) ///
				scalars(rkf)  sfmt(0 3)	
				
		local appi append
			
		}
	}	
**# Bookmark #EMPIEZA AQUI LAS COHORTES

use "${compiled}/hk_oilwells_individual_mines.dta", clear



****** cluster mpio year*****

egen cohortmpio=group(codmpio year)
egen cohortcole=group(id_cole year)
egen cohortdepto=group(depto year)



* Main
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortmpio)
				estimates store ri1`y'_`x'`w'
				
				
				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortcole)
				estimates store ri2`y'_`x'`w'
				
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(cohortcole)
				estimates store ri3`y'_`x'`w'	
				
				
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(cohortmpio)
				estimates store ri4`y'_`x'`w'		
				
				
				

				
				preserve
					
				drop if pob200==1
					
					

				*depto, 2nd order, cluster ESTE PERO OJO. 
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortmpio)
				estimates store ri5`y'_`x'`w'
				

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortcole)
				estimates store ri6`y'_`x'`w'
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(cohortcole)
				estimates store ri7`y'_`x'`w'
				
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(cohortmpio)
				estimates store ri8`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w' ri5`x'_2000`w' ri6`x'_2000`w' ri7`x'_2000`w' ri8`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_205_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

estimates clear 

local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			
								
				preserve
					
				drop if pob100==1
					
					

				*depto, 2nd order, cluster ESTE
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortmpio)
				estimates store ri1`y'_`x'`w'
				
				*depto, 2nd order, cluster ESTE
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortcole)
				estimates store ri2`y'_`x'`w'

				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(cohortcole)
				estimates store ri3`y'_`x'`w'

	
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(cohortmpio)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				preserve
					
				drop if urban==1
					
					

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortmpio)
				estimates store ri5`y'_`x'`w'
				
				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortcole)
				estimates store ri6`y'_`x'`w'
				

				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(cohortcole)
				estimates store ri7`y'_`x'`w'


				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(cohortmpio)
				estimates store ri8`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w' ri5`x'_2000`w' ri6`x'_2000`w' ri7`x'_2000`w' ri8`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_206_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}




*** The same as before but with only linear trends


estimates clear

* Main
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(cohortmpio)
				estimates store ri1`y'_`x'`w'

				
				
				
				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(cohortcole)
				estimates store ri2`y'_`x'`w'
				
				
				* MPIO, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(cohortcole)
				estimates store ri3`y'_`x'`w'	

				
				* MPIO, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(cohortmpio)
				estimates store ri4`y'_`x'`w'		
				
				
				
				preserve
					
				drop if pob200==1
					
					

				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(cohortmpio)
				estimates store ri5`y'_`x'`w'
				
				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(cohortcole)
				estimates store ri6`y'_`x'`w'
				

				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(cohortcole)
				estimates store ri7`y'_`x'`w'

				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(cohortmpio)
				estimates store ri8`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w' ri5`x'_2000`w' ri6`x'_2000`w' ri7`x'_2000`w' ri8`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_207_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

estimates clear 

local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			
								
				preserve
					
				drop if pob100==1
					
					

				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(cohortmpio)
				estimates store ri1`y'_`x'`w'
				
				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(cohortcole)
				estimates store ri2`y'_`x'`w'
				
				
				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(cohortcole)
				estimates store ri3`y'_`x'`w'

				
				
				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(cohortmpio)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				preserve
					
				drop if urban==1
					
					

				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(cohortmpio)
				estimates store ri5`y'_`x'`w'
				
				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(cohortcole)
				estimates store ri6`y'_`x'`w'
				

				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(cohortcole)
				estimates store ri7`y'_`x'`w'


				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(cohortmpio)
				estimates store ri8`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w' ri5`x'_2000`w' ri6`x'_2000`w' ri7`x'_2000`w' ri8`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_208_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

**# Bookmark #1


use "${compiled}/hk_oilwells_individual_mines.dta", clear
egen cohortmpio=group(codmpio year)
egen cohortcole=group(id_cole year)
egen cohortdepto=group(depto year)



**** Enrolment***





* Main






****** cluster dpto year*****


estimates clear



* Main
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortdepto)
				estimates store ri1`y'_`x'`w'
			
				
				
				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(cohortdepto)
				estimates store ri2`y'_`x'`w'		
				
				
				

				
				preserve
					
				drop if pob200==1
					
					

				*depto, 2nd order, cluster ESTE PERO OJO. 
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortdepto)
				estimates store ri3`y'_`x'`w'
				

				
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(cohortdepto)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_209_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

estimates clear 

local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			
								
				preserve
					
				drop if pob100==1
					
					

				*depto, 2nd order, cluster ESTE
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortdepto)
				estimates store ri1`y'_`x'`w'
				

	
				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(cohortdepto)
				estimates store ri2`y'_`x'`w'

				
				restore
				
				
				preserve
					
				drop if urban==1
					
					

				*depto, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(cohortdepto)
				estimates store ri3`y'_`x'`w'
				


				* MPIO, 2nd order, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)  cluster(cohortdepto)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_210_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}




*** The same as before but with only linear trends


estimates clear

* Main
local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(cohortdepto)
				estimates store ri1`y'_`x'`w'
				
				
				* MPIO, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(cohortdepto)
				estimates store ri2`y'_`x'`w'		
				
				
				
				preserve
					
				drop if pob200==1
					
					

				*depto, linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(cohortdepto)
				estimates store ri3`y'_`x'`w'


				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(cohortdepto)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_211_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}

estimates clear 

local rep_app = "replace"
foreach x in   2000 {
	foreach w in   10000    {
			foreach y in  enroled_he universitario semestertohe { 
		
				rename `y' outcome
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			
								
				preserve
					
				drop if pob100==1
					
					

				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(cohortdepto)
				estimates store ri1`y'_`x'`w'
				
				
				
				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(cohortdepto)
				estimates store ri2`y'_`x'`w'

				
				restore
				
				
				preserve
					
				drop if urban==1
					
					

				*depto,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) cluster(cohortdepto)
				estimates store ri3`y'_`x'`w'
				


				* MPIO,  linear trend, cluster
				
				ivreghdfe outcome MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)  cluster(cohortdepto)
				estimates store ri4`y'_`x'`w'

				
				restore
				
				
				
				local rep_app = "append"

				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		}
}
foreach w in 10000  {

local appi replace
	foreach x in enroled_he universitario semestertohe{

	
	esttab   ri1`x'_2000`w' ri2`x'_2000`w' ri3`x'_2000`w' ri4`x'_2000`w'  using "${overleaf}/resultados/new_2022/individual/mines/noisic/test_212_`x'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

		
		
		
}




