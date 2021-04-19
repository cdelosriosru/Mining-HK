/*

 PROJECT :     	Mining - HK
 AUTHOR :			Camilo De Los Rios
 PURPOSE :			Explore some mechanisms. RD, age and number of people

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


/* 

			Age

*/


use "${hk}/harm/hk_individual.dta", clear


gen age=year-annonac


gen age2=age
replace age2=. if age<15 | age>50



gen age2_m=age2
gen age_m =age

gen age2_sd=age2
gen age_sd=age


* collapse at the school level
cd "${data}"
include copylabels // To copy the labels. You have to have this code. 
collapse (median) age_m age2_m (mean) age age2 (sd) age_sd age2_sd (sum) graduated  , by(year_period id_cole)
include attachlabels // To copy the labels. You have to have this code. 



destring year_period, gen(year)
compress
sa "${hk}/harm/hk_colegio_mechanism.dta", replace





use "${oil}/harm/wells_measures_cole.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 


* merge with HK info and prepare. 

merge 1:m id_cole year using "${hk}/harm/hk_colegio_mechanism.dta"
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


local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in    age age2 age_m age2_m age_sd age2_sd graduated{ 
		
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


	esttab   `x'_age_`y' `x'_age2_`y'  `x'_age_m_`y' `x'_age2_m_`y' `x'_age_sd_`y' `x'_age2_sd_`y'  `x'_graduated_`y'   using "${overleaf}/resultados/school/age_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{age}" "\specialcell{winsor 99}" "\specialcell{winsor 95}" "\specialcell{winsor 0 99}") ///
	scalars(rkf)  sfmt(0 3)

	



	local appi append
	
	}
}


