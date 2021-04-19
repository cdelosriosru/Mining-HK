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

* Open data base with wells information
use "${oil}/harm/wells_measures_cole.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 


* merge with HK info and prepare. 

merge 1:1 id_cole year using "${hk}/harm/hk_colegio.dta"
drop if year>2014
keep if _merge==3 // no info on HK for a period
drop _merge

* merge with ETC indicator

merge m:1 codmpio using  "${municipios}/ETC_mpio.dta", gen(m_etc)
drop if m_etc!=3 // there is one mpio that does not exist. 
unique codmpio

*merge with OIL price

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

sa "${compiled}/hk_oilwells_school.dta", replace







/*
				BASIC 
				IV ESTIMATION

*/


use "${compiled}/hk_oilwells_school.dta", clear
/*

I am, for now, jus t going to do it for 20 and 30km. I will also simply use all the schools for now

Depending on the meeting today I will decide what can we test. 

*/


foreach x in 20000 30000 {
	foreach y in 1980 1990 2000 2001 {
	
		gen w_c_`y'_`x'=wells_`y'_`x'*oil_price
		gen w_b_`y'_`x'=wells_`y'_`x'*brent_price

		label var w_c_`y'_`x' "crude price * number of wells until `y' in `x' buf"
		label var w_b_`y'_`x' "brent price * number of wells until `y' in `x' buf"

	}
}

			
local rep_app = "replace"
foreach x in 1980 1990 2000 2001 {
	foreach w in 20000 30000{
		foreach y in enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe timetohe_m{
	
			rename `y' outcome
			rename w_b_`x'_`w' v_brent_price
			rename wells_accum_`w' wells_accum
				
			ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole year)
			parmest, saving("${results}/time_robust/school/ivschool_y_m_`y'_`x'_`w'.dta") 
			outreg2 using "${results}/ivreg_schools_`x'_`w'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))
			
			local rep_app = "append"
			
			rename v_brent_price w_b_`x'_`w'  			
			rename wells_accum wells_accum_`w' 
			rename outcome `y'
	
		}
	}
}


/*

local rep_app = "replace"

foreach y in enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe{

	foreach w in 1000 2500 5000 10000 20000 25000 30000 35000 45000 50000 60000 70000{
	
		foreach z in 2000 2001 2002{
		
			rename `y' outcome
				
			rename w_b_`z'_`w' v_brent_price
			rename wells_accum_`w' wells_accum
				
			ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole year) 
			outreg2 using "${results}/ivreg_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w')  addstat(F-iv, e(cdf))

			local rep_app = "append"
			
			preserve 
				keep if pobl_tot<200000
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole year) 
				outreg2 using "${results}/ivreg_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2 cttop(b_`w')  addstat(F-iv, e(cdf))
			restore
			
			rename v_brent_price w_b_`z'_`w'  
			
			rename w_c_`z'_`w' v_crude_price
			
			ivreghdfe outcome (wells_accum=v_crude_price) , absorb(id_cole year) 
			outreg2 using "${results}/ivreg_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w') addstat(F-iv, e(cdf))

			preserve 
				keep if pobl_tot<200000
				ivreghdfe outcome (wells_accum=v_crude_price) , absorb(id_cole year) 
				outreg2 using "${results}/ivreg_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w') addstat(F-iv, e(cdf))
			restore
			
			rename wells_accum wells_accum_`w' 
			rename v_crude_price w_c_`z'_`w' 
			rename outcome `y'
		
		
		}
	}

}


/*




* Now the estimations. 

local rep_app = "replace"
foreach y in enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m{

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
foreach y in enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m{

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
foreach y in enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe{

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








/*

now I will do a very simple IVREG
Like in Bonilla,

I will instrument the number of wells each year with the interaction between the number of wells in the first year and the international oil price.


*/





local rep_app = "replace"
foreach y in enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe{

	foreach w in 1000 2500 5000 10000{
	
		foreach z in 2000 2001 2002{
		
			rename `y' outcome
				
			rename w_b_`z'_`w' v_brent_price
			rename wells_accum_`w' wells_accum
				
			ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole year) 
			outreg2 using "${results}/ivreg_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w')  addstat(F-iv, e(cdf))

			local rep_app = "append"
			
			preserve 
				keep if pobl_tot<200000
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole year) 
				outreg2 using "${results}/ivreg_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2 cttop(b_`w')  addstat(F-iv, e(cdf))
			restore
			
			rename v_brent_price w_b_`z'_`w'  
			
			rename w_c_`z'_`w' v_crude_price
			
			ivreghdfe outcome (wells_accum=v_crude_price) , absorb(id_cole year) 
			outreg2 using "${results}/ivreg_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w') addstat(F-iv, e(cdf))

			preserve 
				keep if pobl_tot<200000
				ivreghdfe outcome (wells_accum=v_crude_price) , absorb(id_cole year) 
				outreg2 using "${results}/ivreg_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w') addstat(F-iv, e(cdf))
			restore
			
			rename wells_accum wells_accum_`w' 
			rename v_crude_price w_c_`z'_`w' 
			rename outcome `y'
		
		
		}
	}

}



* with the district time fixed effects



merge m:1 codmpio using  "${municipios}/ETC_mpio.dta", gen(m_etc)

ivreghdfe enrolment_rate (wells_accum_10000=w_b_2000_10000) , absorb(id_cole year) 


reghdfe enrolment_rate wells_accum_10000 i.etc_id#i.year , absorb(id_cole year ) 


local rep_app = "replace"
foreach y in enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe{

	foreach w in 1000 2500 5000 10000{
	
		foreach z in 2000 2001 2002{
		
			rename `y' outcome
				
			rename w_b_`z'_`w' v_brent_price
			rename wells_accum_`w' wells_accum
				
			ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole year) 
			outreg2 using "${results}/ivreg_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w')  addstat(F-iv, e(cdf))

			local rep_app = "append"
			
			preserve 
				keep if pobl_tot<200000
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(id_cole year) 
				outreg2 using "${results}/ivreg_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2 cttop(b_`w')  addstat(F-iv, e(cdf))
			restore
			
			rename v_brent_price w_b_`z'_`w'  
			
			rename w_c_`z'_`w' v_crude_price
			
			ivreghdfe outcome (wells_accum=v_crude_price) , absorb(id_cole year) 
			outreg2 using "${results}/ivreg_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w') addstat(F-iv, e(cdf))

			preserve 
				keep if pobl_tot<200000
				ivreghdfe outcome (wells_accum=v_crude_price) , absorb(id_cole year) 
				outreg2 using "${results}/ivreg_schools_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w') addstat(F-iv, e(cdf))
			restore
			
			rename wells_accum wells_accum_`w' 
			rename v_crude_price w_c_`z'_`w' 
			rename outcome `y'
		
		
		}
	}

}









