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
									PREPARE FOR SCHOOOLS
------------------------------------------------------------------------------*/

use "${compiled}/hk_oilwells_colegio.dta", clear

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}




foreach x in 2500 5000 7500 10000 12500 15000 17500 20000 25000 30000 35000{
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






foreach w in 2500 5000 7500 10000 12500 15000 17500 20000 25000 30000 35000{
	
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

foreach w in 2500 5000 7500 10000 12500 15000 17500 20000 25000 30000 35000{
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


/*------------------------------------------------------------------------------
							ESTIMATE FOR SCHOOLS
------------------------------------------------------------------------------*/
	
local rep_app = "replace"
foreach x in  2000 {
	foreach w in 2500 5000 7500 10000 12500 {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe semestertohe timetohe_m semestertohe_m { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				
				*state time fixed effects 
					
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole t_dep) r
				estimates store r1_`y'_`w'
*				parmest, escal(cdf) saving("${results}/Individual/trends/SF_`y'_`x'_`w'.dta") 
*				outreg2 using "${results}/Individual/trends/SF_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				
				*first order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) r
				estimates store r2_`y'_`w'

				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store r3_`y'_`w'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}


foreach y in 2500 5000 7500 10000 12500{

local appi replace
	foreach x in r1 r2 r3{



	esttab  `x'_enrolment_rate_`y'  `x'_uni_1_`y' `x'_uni_2_`y'  using "${overleaf}/resultados/school/tnr_a_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enrolment_rate_`y'}" "\specialcell{`x'_uni_1_`y'}" "\specialcell{`x'_uni_2_`y'}") ///
	scalars(rkf)  sfmt(0 3)
		
	esttab  `x'_rentseeker_1_`y'  `x'_rentseeker_2_`y' `x'_rentseeker_3_`y' `x'_rentseeker_4_`y'  using "${overleaf}/resultados/school/tnr_b_`y'", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_rentseeker_1_`y'}" "\specialcell{`x'_rentseeker_2_`y'}" "\specialcell{`x'_rentseeker_3_`y'}" "\specialcell{`x'_rentseeker_4_`y'}") ///
	scalars(rkf)  sfmt(0 3)


	esttab  `x'_pct2_`y'  `x'_pct2_m_`y' `x'_timetohe_`y' `x'_timetohe_m_`y' `x'_semestertohe_`y' `x'_semestertohe_m_`y'  using "${overleaf}/resultados/school/tnr_c_`y'", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_pct2_`y'}" "\specialcell{`x'_pct2_m_`y'}" "\specialcell{`x'_timetohe_`y'}" "\specialcell{`x'_timetohe_m_`y'}" "\specialcell{`x'_semestertohe_`y'}" "\specialcell{`x'_semestertohe_m_`y'}") ///
	scalars(rkf)  sfmt(0 3)
	
	local appi append
	
	}
}

estimates clear

local rep_app = "replace"
foreach x in  2000 {
	foreach w in 15000 17500 20000 25000 30000 35000 {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe semestertohe timetohe_m semestertohe_m { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				
				*state time fixed effects 
					
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole t_dep) r
				estimates store r1_`y'_`w'
*				parmest, escal(cdf) saving("${results}/Individual/trends/SF_`y'_`x'_`w'.dta") 
*				outreg2 using "${results}/Individual/trends/SF_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				
				*first order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) r
				estimates store r2_`y'_`w'

				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store r3_`y'_`w'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}

foreach y in  15000 17500 20000 25000 30000 35000{

local appi replace
	foreach x in r1 r2 r3{



	esttab  `x'_enrolment_rate_`y'  `x'_uni_1_`y' `x'_uni_2_`y'  using "${overleaf}/resultados/school/tnr_a_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enrolment_rate_`y'}" "\specialcell{`x'_uni_1_`y'}" "\specialcell{`x'_uni_2_`y'}") ///
	scalars(rkf)  sfmt(0 3)
		
	esttab  `x'_rentseeker_1_`y'  `x'_rentseeker_2_`y' `x'_rentseeker_3_`y' `x'_rentseeker_4_`y'  using "${overleaf}/resultados/school/tnr_b_`y'", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_rentseeker_1_`y'}" "\specialcell{`x'_rentseeker_2_`y'}" "\specialcell{`x'_rentseeker_3_`y'}" "\specialcell{`x'_rentseeker_4_`y'}") ///
	scalars(rkf)  sfmt(0 3)


	esttab  `x'_pct2_`y'  `x'_pct2_m_`y' `x'_timetohe_`y' `x'_timetohe_m_`y' `x'_semestertohe_`y' `x'_semestertohe_m_`y'  using "${overleaf}/resultados/school/tnr_c_`y'", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_pct2_`y'}" "\specialcell{`x'_pct2_m_`y'}" "\specialcell{`x'_timetohe_`y'}" "\specialcell{`x'_timetohe_m_`y'}" "\specialcell{`x'_semestertohe_`y'}" "\specialcell{`x'_semestertohe_m_`y'}") ///
	scalars(rkf)  sfmt(0 3)
	
	local appi append
	
	}
}


/*------------------------------------------------------------------------------
									PREPARE FOR INDIVIDUALS
------------------------------------------------------------------------------*/
cls 
estimates clear
use "${compiled}/hk_oilwells_individual.dta", clear

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}




foreach x in 2500 5000 7500 10000 12500 15000 17500 20000 25000 30000 35000{
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






foreach w in 2500 5000 7500 10000 12500 15000 17500 20000 25000 30000 35000{
	
	quietly summarize wells_accum_`w' 
	generate wells_accum_`w'sd = (wells_accum_`w' -r(mean)) / r(sd)
	
	
}


* Create standarized and winsorized variables in case I want to use them instead. 
/*
foreach x in  pct2 enroled_he rent_seeker semestertohe universitario {

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

foreach w in 2500 5000 7500 10000 12500 15000 17500 20000 25000 30000 35000{
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

sa "${compiled}/readytorun_individual.dta", replace
/*------------------------------------------------------------------------------
							ESTIMATE FOR INDIVIDUALS
------------------------------------------------------------------------------*/

local rep_app = "replace"
foreach x in  2000 {
	foreach w in 2500 5000 7500 10000 12500  {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  pct2 enroled_he rent_seeker semestertohe universitario { 
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				
				*state time fixed effects 
					
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole t_dep) r
				estimates store r1_`y'_`w'
*				parmest, escal(cdf) saving("${results}/Individual/trends/SF_`y'_`x'_`w'.dta") 
*				outreg2 using "${results}/Individual/trends/SF_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				
				*first order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) r
				estimates store r2_`y'_`w'

				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store r3_`y'_`w'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}


foreach y in 2500 5000 7500 10000 12500 {

local appi replace
	foreach x in r1 r2 r3{



	esttab  `x'_enroled_he_`y'  `x'_rent_seeker_`y' `x'_pct2_`y' `x'_universitario_`y'  `x'_semestertohe_`y'   using "${overleaf}/resultados/individual/tnr_all_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enroled_he_`y'}" "\specialcell{`x'_rent_seeker_`y'}" "\specialcell{`x'_pct2_`y'}" "\specialcell{`x'_universitario_`y'}" "\specialcell{`x'_semestertohe_`y'}") ///
	scalars(rkf)  sfmt(0 3)
		


	local appi append
	
	}
}

estimates clear

local rep_app = "replace"
foreach x in  2000 {
	foreach w in  15000 17500 20000 25000 30000 35000 {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  pct2 enroled_he rent_seeker semestertohe universitario { 
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				
				*state time fixed effects 
					
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole t_dep) r
				estimates store r1_`y'_`w'
*				parmest, escal(cdf) saving("${results}/Individual/trends/SF_`y'_`x'_`w'.dta") 
*				outreg2 using "${results}/Individual/trends/SF_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				
				*first order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year) r
				estimates store r2_`y'_`w'

				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store r3_`y'_`w'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename outcome `y'
		
			}
		restore
		}
}


foreach y in  15000 17500 20000 25000 30000 35000{

local appi replace
	foreach x in r1 r2 r3{



	esttab  `x'_enroled_he_`y'  `x'_rent_seeker_`y' `x'_pct2_`y' `x'_universitario_`y'  `x'_semestertohe_`y'   using "${overleaf}/resultados/individual/tnr_all_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enroled_he_`y'}" "\specialcell{`x'_rent_seeker_`y'}" "\specialcell{`x'_pct2_`y'}" "\specialcell{`x'_universitario_`y'}" "\specialcell{`x'_semestertohe_`y'}") ///
	scalars(rkf)  sfmt(0 3)
		


	local appi append
	
	}
}

/*------------------------------------------------------------------------------
							ESTIMATE FOR INDIVIDUALS
							GENDER HET EFFECTS
------------------------------------------------------------------------------*/



use "${compiled}/readytorun_individual.dta", clear

gen male=(mujer==0)


foreach w in 2500 5000 7500 10000 12500 15000 17500 20000 25000 30000 35000{
	
	generate ma_wells_accum_`w'sd = male*wells_accum_`w'sd
	gen ma_w_b_2000_`w'=male*lw_b_2000_`w'
	
}



estimates clear

local rep_app = "replace"
foreach x in  2000 {
	foreach w in  2500 5000 7500 10000 12500 {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in pct2 enroled_he rent_seeker semestertohe universitario {
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename ma_w_b_`x'_`w' ma_v_brent_price

				rename wells_accum_`w'sd wells_accum
				rename ma_wells_accum_`w'sd ma_wells_accum
				
				*state time fixed effects 
					
				ivreghdfe outcome male (ma_wells_accum wells_accum=v_brent_price ma_v_brent_price) , absorb(id_cole t_dep) r
			*	parmest, escal(cdf) saving("${results}/Individual/trends/ma_SF_`y'_`x'_`w'.dta") 
			*	outreg2 using "${results}/Individual/trends/ma_SF_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				estimates store r1_`y'_`w'
				
				
				*first order poly trend
				
				ivreghdfe outcome male (ma_wells_accum wells_accum=v_brent_price ma_v_brent_price) , absorb(id_cole i.depto##c.c_year) r
			*	parmest, escal(cdf) saving("${results}/Individual/poly_trends/ma_dep1_`y'_`x'_`w'.dta") 
			*	outreg2 using "${results}/Individual/poly_trends/ma_dep1_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				estimates store r2_`y'_`w'
				
				*second order poly trend
				
				ivreghdfe outcome male (ma_wells_accum wells_accum=v_brent_price ma_v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
			*	parmest, escal(cdf) saving("${results}/Individual/poly_trends/ma_dep2_`y'_`x'_`w'.dta") 
			*	outreg2 using "${results}/Individual/poly_trends/ma_dep2_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				estimates store r3_`y'_`w'
				
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w' 
				rename ma_v_brent_price ma_w_b_`x'_`w' 

				rename wells_accum wells_accum_`w'sd 
				rename ma_wells_accum ma_wells_accum_`w'sd 
				rename outcome `y'
		
			}
			restore
		}
		
}



foreach y in  2500 5000 7500 10000 12500 {

local appi replace
	foreach x in r1 r2 r3{



	esttab  `x'_enroled_he_`y'  `x'_rent_seeker_`y' `x'_pct2_`y' `x'_universitario_`y'  `x'_semestertohe_`y'   using "${overleaf}/resultados/individual/ma_tnr_all_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enroled_he_`y'}" "\specialcell{`x'_rent_seeker_`y'}" "\specialcell{`x'_pct2_`y'}" "\specialcell{`x'_universitario_`y'}" "\specialcell{`x'_semestertohe_`y'}") ///
	scalars(rkf)  sfmt(0 3)
		


	local appi append
	
	}
}








estimates clear

local rep_app = "replace"
foreach x in  2000 {
	foreach w in  15000 17500 20000{
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in pct2 enroled_he rent_seeker semestertohe universitario {
		
				rename `y' outcome
				rename lw_b_`x'_`w' v_brent_price
				rename ma_w_b_`x'_`w' ma_v_brent_price

				rename wells_accum_`w'sd wells_accum
				rename ma_wells_accum_`w'sd ma_wells_accum
				
				*state time fixed effects 
					
				ivreghdfe outcome male (ma_wells_accum wells_accum=v_brent_price ma_v_brent_price) , absorb(id_cole t_dep) r
			*	parmest, escal(cdf) saving("${results}/Individual/trends/ma_SF_`y'_`x'_`w'.dta") 
			*	outreg2 using "${results}/Individual/trends/ma_SF_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				estimates store r1_`y'_`w'
				
				
				*first order poly trend
				
				ivreghdfe outcome male (ma_wells_accum wells_accum=v_brent_price ma_v_brent_price) , absorb(id_cole i.depto##c.c_year) r
			*	parmest, escal(cdf) saving("${results}/Individual/poly_trends/ma_dep1_`y'_`x'_`w'.dta") 
			*	outreg2 using "${results}/Individual/poly_trends/ma_dep1_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				estimates store r2_`y'_`w'
				
				*second order poly trend
				
				ivreghdfe outcome male (ma_wells_accum wells_accum=v_brent_price ma_v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
			*	parmest, escal(cdf) saving("${results}/Individual/poly_trends/ma_dep2_`y'_`x'_`w'.dta") 
			*	outreg2 using "${results}/Individual/poly_trends/ma_dep2_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				estimates store r3_`y'_`w'
				
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'_`w' 
				rename ma_v_brent_price ma_w_b_`x'_`w' 

				rename wells_accum wells_accum_`w'sd 
				rename ma_wells_accum ma_wells_accum_`w'sd 
				rename outcome `y'
		
			}
			restore
		}
		
}



foreach y in  15000 17500 20000 {

local appi replace
	foreach x in r1 r2 r3{



	esttab  `x'_enroled_he_`y'  `x'_rent_seeker_`y' `x'_pct2_`y' `x'_universitario_`y'  `x'_semestertohe_`y'   using "${overleaf}/resultados/individual/ma_tnr_all_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enroled_he_`y'}" "\specialcell{`x'_rent_seeker_`y'}" "\specialcell{`x'_pct2_`y'}" "\specialcell{`x'_universitario_`y'}" "\specialcell{`x'_semestertohe_`y'}") ///
	scalars(rkf)  sfmt(0 3)
		


	local appi append
	
	}
}


	



