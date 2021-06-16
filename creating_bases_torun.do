
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

 First create the oil wells_ for Schools and merge with schools hk 

------------------------------------------------------------------------------*/

use "${oil}/harm/wells_measures_cole.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 

*merge 1:1 id_cole year using "${oil}/harm/wells_measures_cole_extrayo.dta", nogen
* merge with HK info and prepare. 

merge 1:m id_cole year using "${hk}/harm/hk_colegio.dta"
drop if year>2014
keep if _merge==3 // periods for which there is no infon on human capital information
drop _merge

* merge with ETC indicator

merge m:1 codmpio using  "${municipios}/ETC_mpio.dta", gen(m_etc)
drop if m_etc!=3 // there is one mpio that does not exist. 
 drop _*
unique codmpio

*merge with OIL price

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

* merge with Mines Info

merge 1:1 id_cole year using "${mines}/cole_minas_antipersonas.dta", gen(m_mines)

drop if m_mines==2 // simply schools in sites with more than 200K inhabitants. 

* Clean the landmines variables... 

foreach y in 5000 10000 20000 30000{

	foreach x in DESMIL INCAUTA MAP MUSE OTROS SOSP{

		recode `x'_`y'(.=0)

	}

}

* log prices

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}


* Creating my instrument


foreach w in 5000 10000 20000 30000{
	gen wells_new_accum_`w'=wells_accum_`w'-wells_2000_`w'
}

foreach x in  5000 10000 20000 30000 {
	foreach y in 1970 1980 1990 2000 {
	
	* SD version of wells measure
		egen wells_`y'_`x'sd = std(wells_`y'_`x')
	
	* basic independet var
	
		gen w_c_`y'_`x'=wells_`y'_`x'*oil_price
		gen w_b_`y'_`x'=wells_`y'_`x'*brent_price

		label var w_c_`y'_`x' "crude price * number of wells until `y' in `x' buf"
		label var w_b_`y'_`x' "brent price * number of wells until `y' in `x' buf"
		
	* created with the interaction with log prices	
		gen w_lc_`y'_`x'=wells_`y'_`x'sd*loil_price
		gen w_lb_`y'_`x'=wells_`y'_`x'sd*lbrent_price

		label var w_lc_`y'_`x' "log crude price *sd number of wells until `y' in `x' buf"
		label var w_lb_`y'_`x' "log brent price *sd number of wells until `y' in `x' buf"
		
	* basic in logs now
		gen  lw_c_`y'_`x'=ln(w_c_`y'_`x')
		gen  lw_b_`y'_`x'=ln(w_b_`y'_`x')


	}
}

*STD the Wells measure

foreach w in 5000 10000 20000 30000  { 
	
	egen wells_accum_`w'sd = std(wells_accum_`w')
	egen wells_new_accum_`w'sd = std(wells_new_accum_`w')

	egen npozos_`w'sd = std(npozos_`w')
	

}


foreach y in 1 2 3 4 5 15 30 45 {
	egen wells_accum`y'_10000sd = std(wells_accum`y'_10000)
}


	
	
* Now I need to do the same but for graduation..... The treatment is a bit different since they should receive the schock the first year of enrolmentent


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


* This is in case you want to "clean" the control group.

*generating the pure control var

foreach w in 5000 10000 20000 30000 {
	tempvar control_`w'
	bys id_cole: egen `control_`w''=max(wells_accum_`w')
	gen pure_control_`w'=(`control_`w''==0 )
	label var pure_control_`w' "school without oil in buffer `w'in history until 2014"
	
	foreach y in 30{
	tempvar control_`w'`y'
	bys id_cole: egen `control_`w'`y''=max(wells_accum`y'_`w')
	gen pure_control_`w'`y'=(`control_`w'`y''==0 )
	label var pure_control_`w'`y' "school without oil `y' yo in buffer `w'in history until 2014"
	
	}
}
*/
* Generate Trends to use
		
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

drop _*

sa "${compiled}/hk_oilwells_colegio_mines.dta", replace
/*------------------------------------------------------------------------------

Now for Compleition

------------------------------------------------------------------------------*/ 


use "${oil}/harm/wells_measures_cole.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 

*merge 1:1 id_cole year using "${oil}/harm/wells_measures_cole_extrayo.dta", nogen
* merge with HK info and prepare. 

merge 1:m id_cole year using "${hk}/harm/hk_colegio_comp.dta"
drop if year>2014
keep if _merge==3 // periods for which there is no infon on human capital information
drop _merge

* merge with ETC indicator

merge m:1 codmpio using  "${municipios}/ETC_mpio.dta", gen(m_etc)
drop if m_etc!=3 // there is one mpio that does not exist. 
 drop _*
unique codmpio

*merge with OIL price

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

* merge with Mines Info

merge 1:1 id_cole year using "${mines}/cole_minas_antipersonas.dta", gen(m_mines)

drop if m_mines==2 // simply schools in sites with more than 200K inhabitants. 

* Clean the landmines variables... 

foreach y in 5000 10000 20000 30000{

	foreach x in DESMIL INCAUTA MAP MUSE OTROS SOSP{

		recode `x'_`y'(.=0)

	}

}

* log prices

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}


* Creating my instrument


foreach x in  5000 10000 20000 30000 {
	foreach y in 1970 1980 1990 2000 {
	
	* SD version of wells measure
		egen wells_`y'_`x'sd = std(wells_`y'_`x')
	
	* basic independet var
	
		gen w_c_`y'_`x'=wells_`y'_`x'*oil_price
		gen w_b_`y'_`x'=wells_`y'_`x'*brent_price

		label var w_c_`y'_`x' "crude price * number of wells until `y' in `x' buf"
		label var w_b_`y'_`x' "brent price * number of wells until `y' in `x' buf"
		
	* created with the interaction with log prices	
		gen w_lc_`y'_`x'=wells_`y'_`x'sd*loil_price
		gen w_lb_`y'_`x'=wells_`y'_`x'sd*lbrent_price

		label var w_lc_`y'_`x' "log crude price *sd number of wells until `y' in `x' buf"
		label var w_lb_`y'_`x' "log brent price *sd number of wells until `y' in `x' buf"
		
	* basic in logs now
		gen  lw_c_`y'_`x'=ln(w_c_`y'_`x')
		gen  lw_b_`y'_`x'=ln(w_b_`y'_`x')


	}
}

*STD the Wells measure

foreach w in 5000 10000 20000 30000  { 
	
	egen wells_accum_`w'sd = std(wells_accum_`w')
	egen npozos_`w'sd = std(npozos_`w')
	

}


foreach y in 1 2 3 4 5 15 30 45 {
	egen wells_accum`y'_10000sd = std(wells_accum`y'_10000)
}


	
	
* Now I need to do the same but for graduation..... The treatment is a bit different since they should receive the schock the first year of enrolmentent


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


* This is in case you want to "clean" the control group.

*generating the pure control var

foreach w in 5000 10000 20000 30000 {
	tempvar control_`w'
	bys id_cole: egen `control_`w''=max(wells_accum_`w')
	gen pure_control_`w'=(`control_`w''==0 )
	label var pure_control_`w' "school without oil in buffer `w'in history until 2014"
	
	foreach y in 30{
	tempvar control_`w'`y'
	bys id_cole: egen `control_`w'`y''=max(wells_accum`y'_`w')
	gen pure_control_`w'`y'=(`control_`w'`y''==0 )
	label var pure_control_`w'`y' "school without oil `y' yo in buffer `w'in history until 2014"
	
	}
}
*/
* Generate Trends to use
		
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

drop _*

sa "${compiled}/hk_oilwells_colegio_mines_comp.dta", replace


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
 drop _*
unique codmpio

*merge with OIL price

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

* merge with Mines Info

merge m:1 id_cole year using "${mines}/cole_minas_antipersonas.dta", gen(m_mines)
drop if m_mines==2 // simply schools in sites with more than 200K inhabitants. 





* Cleaning landmines

foreach y in 5000 10000 20000 30000{

	foreach x in DESMIL INCAUTA MAP MUSE OTROS SOSP{

		recode `x'_`y'(.=0)

	}

}

*log prices.

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}


* creating the instrument. 


foreach x in  5000 10000 20000 30000 {
	foreach y in 1970 1980 1990 2000 {
	
	* SD version of wells measure
		egen wells_`y'_`x'sd = std(wells_`y'_`x')
	
	* basic independet var
	
		gen w_c_`y'_`x'=wells_`y'_`x'*oil_price
		gen w_b_`y'_`x'=wells_`y'_`x'*brent_price

		label var w_c_`y'_`x' "crude price * number of wells until `y' in `x' buf"
		label var w_b_`y'_`x' "brent price * number of wells until `y' in `x' buf"
		
	* created with the interaction with log prices	
		gen w_lc_`y'_`x'=wells_`y'_`x'sd*loil_price
		gen w_lb_`y'_`x'=wells_`y'_`x'sd*lbrent_price

		label var w_lc_`y'_`x' "log crude price *sd number of wells until `y' in `x' buf"
		label var w_lb_`y'_`x' "log brent price *sd number of wells until `y' in `x' buf"
		
	* basic in logs now
		gen  lw_c_`y'_`x'=ln(w_c_`y'_`x')
		gen  lw_b_`y'_`x'=ln(w_b_`y'_`x')


	}
}

*STD the wells stocks and flows vars

foreach w in 5000 10000 20000 30000   { 
	
	egen wells_accum_`w'sd = std(wells_accum_`w')
	egen npozos_`w'sd = std(npozos_`w')

}


foreach y in 1 2 3 4 5 15 30 45 {
	egen wells_accum`y'_10000sd = std(wells_accum`y'_10000)
}



	

/* Create standarized and winsorized variables in case I want to use them instead. 

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

*/
		* CLEANING THE CONTROL GROUP.
/*
*generating the pure control var

foreach w in  10000 {
	bys id_cole: egen control_`w'=max(wells_accum_`w')
	gen pure_control_`w'=(control_`w'==0 )
	label var pure_control_`w' "school without oil in buffer `w'in history until 2014"
}
*/


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


drop _*

sa "${compiled}/hk_oilwells_individual_mines.dta", replace




/*------------------------------------------------------------------------------

Now for Compleition

------------------------------------------------------------------------------*/ 

use "${oil}/harm/wells_measures_cole.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 
*drop year
rename year year_prim  // I need the schock to bbe in the year in wich they entered the HEI

* merge with HK info and prepare. 

merge 1:m id_cole year_prim using "${hk}/harm/hk_individual.dta"
drop year
rename year_prim year
drop if year>2014
keep if _merge==3 // periods for which there is no infon on human capital information
drop _merge

* merge with ETC indicator

merge m:1 codmpio using  "${municipios}/ETC_mpio.dta", gen(m_etc)
drop if m_etc!=3 // there is one mpio that does not exist. 
 drop _*
unique codmpio

*merge with OIL price

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

* merge with Mines Info

merge m:1 id_cole year using "${mines}/cole_minas_antipersonas.dta", gen(m_mines)
drop if m_mines==2 // simply schools in sites with more than 200K inhabitants. 





* Cleaning landmines

foreach y in 5000 10000 20000 30000{

	foreach x in DESMIL INCAUTA MAP MUSE OTROS SOSP{

		recode `x'_`y'(.=0)

	}

}

*log prices.

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}


* creating the instrument. 


foreach x in  5000 10000 20000 30000 {
	foreach y in 1970 1980 1990 2000 {
	
	* SD version of wells measure
		egen wells_`y'_`x'sd = std(wells_`y'_`x')
	
	* basic independet var
	
		gen w_c_`y'_`x'=wells_`y'_`x'*oil_price
		gen w_b_`y'_`x'=wells_`y'_`x'*brent_price

		label var w_c_`y'_`x' "crude price * number of wells until `y' in `x' buf"
		label var w_b_`y'_`x' "brent price * number of wells until `y' in `x' buf"
		
	* created with the interaction with log prices	
		gen w_lc_`y'_`x'=wells_`y'_`x'sd*loil_price
		gen w_lb_`y'_`x'=wells_`y'_`x'sd*lbrent_price

		label var w_lc_`y'_`x' "log crude price *sd number of wells until `y' in `x' buf"
		label var w_lb_`y'_`x' "log brent price *sd number of wells until `y' in `x' buf"
		
	* basic in logs now
		gen  lw_c_`y'_`x'=ln(w_c_`y'_`x')
		gen  lw_b_`y'_`x'=ln(w_b_`y'_`x')


	}
}

*STD the wells stocks and flows vars

foreach w in 5000 10000 20000 30000   { 
	
	egen wells_accum_`w'sd = std(wells_accum_`w')
	egen npozos_`w'sd = std(npozos_`w')

}


foreach y in 1 2 3 4 5 15 30 45 {
	egen wells_accum`y'_10000sd = std(wells_accum`y'_10000)
}




/* Create standarized and winsorized variables in case I want to use them instead. 

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

*/
		* CLEANING THE CONTROL GROUP.
/*
*generating the pure control var

foreach w in  10000 {
	bys id_cole: egen control_`w'=max(wells_accum_`w')
	gen pure_control_`w'=(control_`w'==0 )
	label var pure_control_`w' "school without oil in buffer `w'in history until 2014"
}
*/


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


drop _*

sa "${compiled}/hk_oilwells_individual_mines_comp.dta", replace


