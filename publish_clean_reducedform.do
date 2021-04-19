
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
drop if year>2014
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
drop if year>2014
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
	
	quietly summarize npozos_`w'
	generate npozos_`w'sd = (npozos_`w' -r(mean)) / r(sd)

	
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

estimates clear
******** n pozos

foreach y in  10000 {

local appi replace
	foreach x in rred riv {



	esttab  `x'_enrolment_rate_`y'    using "${overleaf}/resultados/school/pub1_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enrolment_rate_`y'}" "\specialcell{`x'_uni_1_`y'}" "\specialcell{`x'_uni_2_`y'}") ///
	scalars(rkf)  sfmt(0 3)
	
	
	esttab  `x'_rentseeker_1_`y'  `x'_uni_1_`y'  using "${overleaf}/resultados/school/pub2_`y'", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
	scalars(rkf)  sfmt(0 3)
	
	
	esttab  `x'_enrolment_rate_`y' `x'_rentseeker_1_`y'  `x'_uni_1_`y'  using "${overleaf}/resultados/school/pub3_`y'", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
	scalars(rkf)  sfmt(0 3)



	
	local appi append
	
	}
}

local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000  {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  enrolment_rate rentseeker_1  uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename npozos_`w'sd wells_accum
				
		

				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) 
				estimates store rred_`y'_`w'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum npozos_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}


foreach y in  10000 {

local appi replace
	foreach x in rred riv {



	esttab  `x'_enrolment_rate_`y'    using "${overleaf}/resultados/school/pub1_`y'2", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enrolment_rate_`y'}" "\specialcell{`x'_uni_1_`y'}" "\specialcell{`x'_uni_2_`y'}") ///
	scalars(rkf)  sfmt(0 3)
	
	
	esttab  `x'_rentseeker_1_`y'  `x'_uni_1_`y'  using "${overleaf}/resultados/school/pub2_`y'2", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
	scalars(rkf)  sfmt(0 3)
	
	
	esttab  `x'_enrolment_rate_`y' `x'_rentseeker_1_`y'  `x'_uni_1_`y'  using "${overleaf}/resultados/school/pub3_`y'2", `appi' f ///
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
	
	quietly summarize npozos_`w' 
	generate npozos_`w'sd = (npozos_`w' -r(mean)) / r(sd)

	
	
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


	esttab   `x'_pct2_`y' `x'_rent_seeker_`y'  `x'_semestertohe_`y'   using "${overleaf}/resultados/individual/pub1_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enroled_he_`y'}" "\specialcell{`x'_rent_seeker_`y'}" "\specialcell{`x'_pct2_`y'}" "\specialcell{`x'_universitario_`y'}" "\specialcell{`x'_semestertohe_`y'}") ///
	scalars(rkf)  sfmt(0 3)

	
		esttab   `x'_norent_`y'    using "${overleaf}/resultados/individual/pub2_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_non_rent_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)
		


	local appi append
	
	}
}



local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in    semestertohe_w1 semestertohe_w2 { 
		
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


	esttab   `x'_semestertohe_w1_`y' `x'_semestertohe_w2_`y'   using "${overleaf}/resultados/individual/semester_win_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{wins1}" "\specialcell{wins2}") ///
	scalars(rkf)  sfmt(0 3)

	



	local appi append
	
	}
}

estimates clear

******** n pozos

local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in    norent pct2  rent_seeker semestertohe { 
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename npozos_`w'sd wells_accum
				
				*state time fixed effects 
					


				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) 
				estimates store rred_`y'_`w'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum npozos_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}


foreach y in 10000  {

local appi replace
	foreach x in rred riv{


	esttab   `x'_pct2_`y' `x'_rent_seeker_`y'  `x'_semestertohe_`y'   using "${overleaf}/resultados/individual/pub1_`y'2", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enroled_he_`y'}" "\specialcell{`x'_rent_seeker_`y'}" "\specialcell{`x'_pct2_`y'}" "\specialcell{`x'_universitario_`y'}" "\specialcell{`x'_semestertohe_`y'}") ///
	scalars(rkf)  sfmt(0 3)

	
		esttab   `x'_norent_`y'    using "${overleaf}/resultados/individual/pub2_`y'2", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_non_rent_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)
		


	local appi append
	
	}
}



local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in    semestertohe_w1 semestertohe_w2 { 
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename npozos_`w'sd wells_accum
				
				*state time fixed effects 
					


				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) 
				estimates store rred_`y'_`w'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum npozos_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}


foreach y in 10000  {

local appi replace
	foreach x in rred riv{


	esttab   `x'_semestertohe_w1_`y' `x'_semestertohe_w2_`y'   using "${overleaf}/resultados/individual/semester_win_`y'2", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{wins1}" "\specialcell{wins2}") ///
	scalars(rkf)  sfmt(0 3)

	



	local appi append
	
	}
}

estimates clear


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
	
	quietly summarize npozos_`w' 
	generate npozos_`w'sd = (npozos_`w' -r(mean)) / r(sd)

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


*** npozos 

local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000  {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  estudiantes  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename npozos_`w'sd wells_accum
				
		

				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) 
				estimates store rred_`y'_`w'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum npozos_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}


foreach y in  10000 {

local appi replace
	foreach x in rred riv {



	esttab  `x'_estudiantes_`y'    using "${overleaf}/resultados/school/estudiantes_`y'2", `appi' f  ///
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
	
	quietly summarize npozos_`w' 
	generate npozos_`w'sd = (npozos_`w' -r(mean)) / r(sd)

	
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

****npozos_


local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in    age   age_w1 age_w2 age2 age2_w1 age2_w2 { 
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename npozos_`w'sd wells_accum
				
				*state time fixed effects 
					


				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) 
				estimates store rred_`y'_`w'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum npozos_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}


foreach y in 10000  {

local appi replace
	foreach x in rred riv{


	esttab   `x'_age_`y' `x'_age_w1_`y'  `x'_age_w2_`y'  `x'_age2_`y' `x'_age2_w1_`y'  `x'_age2_w2_`y'  using "${overleaf}/resultados/individual/age_`y'2", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enroled_he_`y'}" "\specialcell{`x'_rent_seeker_`y'}" "\specialcell{`x'_pct2_`y'}" "\specialcell{`x'_universitario_`y'}" "\specialcell{`x'_semestertohe_`y'}") ///
	scalars(rkf)  sfmt(0 3)



	local appi append
	
	}
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
				rename npozos_`w'sd wells_accum
				
				*state time fixed effects 
					


				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
				
				reghdfe outcome v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) 
				estimates store rred_`y'_`w'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum npozos_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}


foreach y in 10000  {

local appi replace
	foreach x in rred riv{


	esttab   `x'_agesd_`y' `x'_age2sd_`y' `x'_age_w3_`y' `x'_age2_w3_`y'   using "${overleaf}/resultados/individual/age95_`y'2", `appi' f  ///
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


