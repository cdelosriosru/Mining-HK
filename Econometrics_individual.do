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
									PREPARE
------------------------------------------------------------------------------*/

use "${compiled}/hk_oilwells_individual.dta", clear

foreach x in 5000 20000 30000 {
	foreach y in 1990  2000 {
	
		gen w_c_`y'_`x'=wells_`y'_`x'*oil_price
		gen w_b_`y'_`x'=wells_`y'_`x'*brent_price

		label var w_c_`y'_`x' "crude price * number of wells until `y' in `x' buf"
		label var w_b_`y'_`x' "brent price * number of wells until `y' in `x' buf"

	}
}

* now with logs

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}


foreach x in 5000 20000 30000 {
	foreach y in 1990  2000 {
	
		gen lw_c_`y'_`x'=wells_`y'_`x'*loil_price
		gen lw_b_`y'_`x'=wells_`y'_`x'*lbrent_price

		label var lw_c_`y'_`x' "log crude price * number of wells until `y' in `x' buf"
		label var lw_b_`y'_`x' "log brent price * number of wells until `y' in `x' buf"

	}
}


* Create winsorized variables (to account for outliers)

foreach x in  enroled_he rent_seeker universitario deserted timetohe semestertohe {
	winsor2 `x', cuts(0 99)
	rename `x'_w `x'_w1
	label var `x'_w1 "winsorized at 99"
	
	winsor2 `x', cuts(1 99)
	rename `x'_w `x'_w2
	label var `x'_w2 "winsorized at 1 & 99"

}


		* CLEANING THE CONTROL GROUP.

*generating the pure control var

foreach w in 5000 20000 30000{
	tempvar control_`w'
	bys codmpio: egen `control_`w''=max(wells_accum_`w')
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
									ESTIMATE
------------------------------------------------------------------------------*/



* BENCHMARK REGRESSIONS. 

local rep_app = "replace"
foreach x in 1990  2000 {
	foreach w in 5000 20000 30000{
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  pct2 { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
				rename `y' outcome
				rename w_b_`x'_`w' v_brent_price
				rename wells_accum_`w' wells_accum
				
				*state time fixed effects 
					
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole t_dep)
				parmest, escal(cdf) saving("${results}/Individual/trends/SF_`y'_`x'_`w'.dta") 
				outreg2 using "${results}/Individual/trends/SF_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				
				*first order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year)
				parmest, escal(cdf) saving("${results}/Individual/poly_trends/dep1_`y'_`x'_`w'.dta") 
				outreg2 using "${results}/Individual/poly_trends/dep1_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				
				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2)
				parmest, escal(cdf) saving("${results}/Individual/poly_trends/dep2_`y'_`x'_`w'.dta") 
				outreg2 using "${results}/Individual/poly_trends/dep2_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))

				
				
				local rep_app = "append"
				
				rename v_brent_price w_b_`x'_`w'  			
				rename wells_accum wells_accum_`w' 
				rename outcome `y'
		
			}
		restore
		}
}






local rep_app = "replace"
foreach x in 1990  2000 {
	foreach w in 5000 20000 30000{
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in pct2 { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
				rename `y' outcome
				rename w_b_`x'_`w' v_brent_price
				rename wells_accum_`w' wells_accum
				
				*state time fixed effects 
					
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole t_mpio)
				parmest, escal(cdf) saving("${results}/Individual/trends/MF_`y'_`x'_`w'.dta") 
				outreg2 using "${results}/Individual/trends/MF_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				
				*first order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year)
				parmest, escal(cdf) saving("${results}/Individual/poly_trends/mpio1_`y'_`x'_`w'.dta") 
				outreg2 using "${results}/Individual/poly_trends/mpio1_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				
				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)
				parmest, escal(cdf) saving("${results}/Individual/poly_trends/mpio2_`y'_`x'_`w'.dta") 
				outreg2 using "${results}/Individual/poly_trends/mpio2_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))

				
				
				local rep_app = "append"
				
				rename v_brent_price w_b_`x'_`w'  			
				rename wells_accum wells_accum_`w' 
				rename outcome `y'
		
			}
		restore
		}
}



/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

 	HETEROGENITY BY GENDER
SE QUEDO AQUI EL CODIGO. 
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

gen male=(mujer==0)

foreach w in 5000 20000 30000{
	gen ma_wells_accum_`w'=male*wells_accum_`w'
	foreach x in  1990  2000 {
			gen ma_w_b_`x'_`w'=male*w_b_`x'_`w'
	}
}


local rep_app = "replace"
foreach x in 1990  2000 {
	foreach w in 5000 20000 30000{
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in enroled_he rent_seeker universitario deserted timetohe semestertohe pct2 {
		
				rename `y' outcome
				rename w_b_`x'_`w' v_brent_price
				rename ma_w_b_`x'_`w' ma_v_brent_price

				rename wells_accum_`w' wells_accum
				rename ma_wells_accum_`w' ma_wells_accum
				
				*state time fixed effects 
					
				ivreghdfe outcome male (ma_wells_accum wells_accum=v_brent_price ma_v_brent_price) , absorb(id_cole t_dep)
				parmest, escal(cdf) saving("${results}/Individual/trends/ma_SF_`y'_`x'_`w'.dta") 
				outreg2 using "${results}/Individual/trends/ma_SF_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				
				*first order poly trend
				
				ivreghdfe outcome male (ma_wells_accum wells_accum=v_brent_price ma_v_brent_price) , absorb(id_cole i.depto##c.c_year)
				parmest, escal(cdf) saving("${results}/Individual/poly_trends/ma_dep1_`y'_`x'_`w'.dta") 
				outreg2 using "${results}/Individual/poly_trends/ma_dep1_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				
				*second order poly trend
				
				ivreghdfe outcome male (ma_wells_accum wells_accum=v_brent_price ma_v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2)
				parmest, escal(cdf) saving("${results}/Individual/poly_trends/ma_dep2_`y'_`x'_`w'.dta") 
				outreg2 using "${results}/Individual/poly_trends/ma_dep2_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))

				
				
				local rep_app = "append"
				
				rename v_brent_price w_b_`x'_`w' 
				rename ma_v_brent_price ma_w_b_`x'_`w' 

				rename wells_accum wells_accum_`w' 
				rename ma_wells_accum ma_wells_accum_`w' 
				rename outcome `y'
		
			}
			restore
		}
		
}

local rep_app = "replace"
foreach x in 1990  2000 {
	foreach w in 5000 20000 30000{
		preserve
			drop if w_b_`x'_`w'==0 & pure_control_`w'==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in enroled_he rent_seeker universitario deserted timetohe semestertohe pct2 {
		
				rename `y' outcome
				rename w_b_`x'_`w' v_brent_price
				rename ma_w_b_`x'_`w' ma_v_brent_price

				rename wells_accum_`w' wells_accum
				rename ma_wells_accum_`w' ma_wells_accum
				
				*state time fixed effects 
					
				ivreghdfe outcome male (ma_wells_accum wells_accum=v_brent_price ma_v_brent_price) , absorb(id_cole t_mpio)
				parmest, escal(cdf) saving("${results}/Individual/trends/ma_MF_`y'_`x'_`w'.dta") 
				outreg2 using "${results}/Individual/trends/ma_MF_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				
				*first order poly trend
				
				ivreghdfe outcome male (ma_wells_accum wells_accum=v_brent_price ma_v_brent_price) , absorb(id_cole i.codmpio##c.c_year)
				parmest, escal(cdf) saving("${results}/Individual/poly_trends/ma_mpio1_`y'_`x'_`w'.dta") 
				outreg2 using "${results}/Individual/poly_trends/ma_mpio1_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
				
				*second order poly trend
				
				ivreghdfe outcome male (ma_wells_accum wells_accum=v_brent_price ma_v_brent_price) , absorb(id_cole i.codmpio##c.c_year i.codmpio##c.c_year2)
				parmest, escal(cdf) saving("${results}/Individual/poly_trends/ma_mpio2_`y'_`x'_`w'.dta") 
				outreg2 using "${results}/Individual/poly_trends/ma_mpio2_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))

				
				
				local rep_app = "append"
				
				rename v_brent_price w_b_`x'_`w' 
				rename ma_v_brent_price ma_w_b_`x'_`w' 

				rename wells_accum wells_accum_`w' 
				rename ma_wells_accum ma_wells_accum_`w' 
				rename outcome `y'
		
			}
			restore
		}
}



/*





* Open data base with HK information
use "${data}/compiled_sets/cole_wells_all_bycole.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 


	*Prepare data on wells by schools
	
destring spud, gen(year)
drop if year==111 // 4 observations. This must be some typing error in the source
drop if year==. // 1993 observations. Simply wells without spud date
collapse (sum) npozos_* (first) spud, by(id_cole year) // its the only info that I need for the moment. The rest will come from merging it with the HK data
*drop if year<1950 // just the really old wells. THIS IS DUMB this gives me really important information. 
fillin id_cole year // to make a balanced panel

unique year
local tope=r(unique)

foreach x in 1000 2500 5000 10000{
gen wells_accum_`x'=.

	forvalues n = 1(1)`tope' {
		cap drop i`n'
		bys id_cole: gen i`n' = 1 if  year[`n']>=year // & (year[`n']-year) <= 50
		bys id_cole: egen pozos`n' = total(npozos_`x') if i`n'==1
		bys id_cole: replace wells_accum_`x' = pozos`n' if mi(wells_accum_`x')
		drop  i`n'
		drop pozos`n'
	}

label var wells_accum_`x' "Accumulated number of wells until year"
label var npozos_`x' "Number of wells drilled in that year"
}

foreach x in 1000 2500 5000 10000{
	foreach y in 2000 2001  2002{
		gen wells_`y'_`x'=wells_accum_`x' if year==`y'
		sort id_cole wells_`y'_`x'
		bys id_cole: replace wells_`y'_`x'=wells_`y'_`x'[1]
		label var wells_`y'_`x' "Accumulated number of wells until `y' in `x'km buff"
		
	}
}

drop if year<2002 | year>2014

* merge with HK info and prepare. 

merge 1:m id_cole year using "${hk}/harm/hk_indivdual.dta"
drop if _merge==1 // this are simply the ones that have no information on HK accumulation
drop if year>2014

foreach x in 1000 2500 5000 10000{
	recode npozos_`x'(.=0)
	recode wells_accum_`x'(.=0)
	
	foreach y in 2000 2001 2002{
		recode wells_`y'_`x'(.=0)
	}
}

sa "${compiled}/hk_oilwells_individual.dta", replace




* Now merge with population in year 2005. 
use "${compiled}/hk_oilwells_individual.dta", clear
merge m:1 codmpio using "${municipios}/poblacion_mpios.dta", gen (mer_pobl)
drop if mer_pobl!=3 // either the school has no geographic information or there are no schools in the municipality. The later is the case for 15 very small mpios (I checked it by hand)


* Now the estimations. 

local rep_app = "replace"
foreach y in deserted pct2 { // enroled_he non_rent_seeker_1 non_rent_seeker_2 universitario deserted pct2

	foreach w in 1000 2500 5000 10000{
		
		rename `y' outcome
			
		rename npozos_`w' pozos_yearly
			
		reghdfe outcome pozos_yearly , absorb(id_cole year) 
		outreg2 using "${results}/first_all_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w')
		
		local rep_app = "append"
		
		preserve 
			keep if pobl_tot<200000
			reghdfe outcome pozos_yearly , absorb(id_cole year) 
			outreg2 using "${results}/first_all_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2 cttop(b_`w')
		restore
		
		rename pozos_yearly npozos_`w' 
		
		rename wells_accum_`w' pozos_total
		
		reghdfe outcome pozos_total , absorb(id_cole year) 
			outreg2 using "${results}/first_all_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w')

		preserve 
			keep if pobl_tot<200000
			reghdfe outcome pozos_total , absorb(id_cole year) 
			outreg2 using "${results}/first_all_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w')
		restore
		
		rename pozos_total wells_accum_`w' 
		rename outcome `y'
	}

}

/* Now I will make a much more defendable approach

1. total number of wells in buffer interacted with oil price

*/

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

foreach x in 1000 2500 5000 10000{
	bys id_cole: egen tot_pozos_`x'=total(npozos_`x')
	gen well_crude_price_`x'=tot_pozos_`x'*oil_price
	gen well_brent_price_`x'=tot_pozos_`x'*brent_price

}


local rep_app = "replace"
foreach y in  enroled_he non_rent_seeker_1 non_rent_seeker_2 universitario deserted pct2{

	foreach w in 1000 2500 5000 10000{
		
		rename `y' outcome
			
		rename well_brent_price_`w' v_brent_price
			
		reghdfe outcome v_brent_price , absorb(id_cole year) 
		outreg2 using "${results}/interact_all_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w')
		
		local rep_app = "append"
		
		preserve 
			keep if pobl_tot<200000
			reghdfe outcome v_brent_price , absorb(id_cole year) 
			outreg2 using "${results}/interact_all_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2 cttop(b_`w')
		restore
		
		rename v_brent_price well_brent_price_`w'  
		
		rename well_crude_price_`w' v_crude_price
		
		reghdfe outcome v_crude_price , absorb(id_cole year) 
			outreg2 using "${results}/interact_all_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w')

		preserve 
			keep if pobl_tot<200000
			reghdfe outcome v_crude_price , absorb(id_cole year) 
			outreg2 using "${results}/interact_all_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w')
		restore
		
		rename v_crude_price well_crude_price_`w' 
		rename outcome `y'
	}

}


/*

Now I will follow more closely the approach of Dube & Vargas. I will simply use the number of wells
drilled until 2003 as a exogenous indicator of oil presence. The price will give me the
temporal variation needed for estimation

*/

foreach x in 1000 2500 5000 10000{
	foreach y in 2000 2001 2002{
	
		gen w_c_`y'_`x'=wells_`y'_`x'*oil_price
		gen w_b_`y'_`x'=wells_`y'_`x'*brent_price

		label var w_c_`y'_`x' "crude price * number of wells until `y' in `x' buf"
		label var w_b_`y'_`x' "brent price * number of wells until `y' in `x' buf"

	}
}


*rename v_brent_price w_b_2000_1000

*rename outcome enrolment_rate

local rep_app = "replace"
foreach y in  enroled_he non_rent_seeker_1 non_rent_seeker_2 universitario deserted pct2{

	foreach w in 1000 2500 5000 10000{
	
		foreach z in 2000 2001 2002{
		
			rename `y' outcome
				
			rename w_b_`z'_`w' v_brent_price
				
			reghdfe outcome v_brent_price , absorb(id_cole year) 
			outreg2 using "${results}/dube_instrument_all_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w')  addnote("year `z'")

			local rep_app = "append"
			
			preserve 
				keep if pobl_tot<200000
				reghdfe outcome v_brent_price , absorb(id_cole year) 
				outreg2 using "${results}/dube_instrument_all_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2 cttop(b_`w')  addnote("year `z'")
			restore
			
			rename v_brent_price w_b_`z'_`w'  
			
			rename w_c_`z'_`w' v_crude_price
			
			reghdfe outcome v_crude_price , absorb(id_cole year) 
				outreg2 using "${results}/dube_instrument_all_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w') addnote("year `z'")

			preserve 
				keep if pobl_tot<200000
				reghdfe outcome v_crude_price , absorb(id_cole year) 
				outreg2 using "${results}/dube_instrument_all_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w') addnote("year `z'")
			restore
			
			rename v_crude_price w_c_`z'_`w' 
			rename outcome `y'
		
		
		}
	}

}

