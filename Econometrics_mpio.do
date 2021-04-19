/*

 PROJECT :     	Mining - HK
 AUTHOR :			Camilo De Los Rios
 PURPOSE :			Equation 3 of the presentation. 

 Remeber all of your schools are secondary education. Bonilla has both primary and secondary, you have off course less schools. 
*/
clear all
set maxvar 120000, perm
global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global oil "${data}/Petroleo"
global hk "${data}/HK"
global municipios "${data}/PoliticalBoundaries"
global results "C:/Users/cdelo/Dropbox/HK_Extractives_2020/RESULTS/Municipality"
global compiled "${data}/compiled_sets"

/*

I created the wells measures in another dofile. 

*/


* Open data base with wells information
use "${oil}/harm/wells_measures_mpio.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 
	

* merge with HK info and prepare. 

merge 1:1 codmpio year using "${hk}/harm/hk_mpio.dta", gen(mer_hk)
drop if mer_hk==1 // these are simply the ones that have no HK information
drop if mer_hk==2 // these are the ones that have no time information for the wells at the municipality level is different than at the school level (it makes sense)


* merge with ETC indicator

merge m:1 codmpio using  "${municipios}/ETC_mpio.dta", gen(m_etc)
drop if m_etc!=3 // there is one mpio that does not exist. 
unique codmpio

*merge with OIL price

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

sa "${compiled}/hk_oilwells_mpio.dta", replace


/*
				BASIC 
				IV ESTIMATION

*/

use "${compiled}/hk_oilwells_mpio.dta", clear

forvalues y=1950(1)2001{
	
	gen w_c_`y'_mpio=wells_`y'_mpio*oil_price
	gen w_b_`y'_mpio=wells_`y'_*brent_price

	label var w_c_`y'_mpio "crude price * number of wells until `y' in `x' buf"
	label var w_b_`y'_mpio"brent price * number of wells until `y' in `x' buf"
}


*making the interacion with logs

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}

forvalues y=1950(1)2001{
	
	gen lw_c_`y'_mpio=wells_`y'_mpio*loil_price
	gen lw_b_`y'_mpio=wells_`y'_*lbrent_price

	label var lw_c_`y'_mpio "log crude price * number of wells until `y' in `x' buf"
	label var lw_b_`y'_mpio"log brent price * number of wells until `y' in `x' buf"
}

* Create winsorized variables (to account for outliers)

foreach x in  enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe timetohe_m semestertohe semestertohe_m{
	winsor2 `x', cuts(0 99)
	rename `x'_w `x'_w1
	label var `x'_w1 "winsorized at 99"
	
	winsor2 `x', cuts(1 99)
	rename `x'_w `x'_w2
	label var `x'_w2 "winsorized at 1 & 99"

}

/* 
		The most basic and naive (?) estimation with all the periods, fixed effects and nothing more. 
*/


	
forvalues x=1950(1)2001{
	local rep_app = "replace"
	foreach y in  timetohe_m semestertohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe semestertohe { // 
	
		rename `y' outcome
				
		rename w_b_`x'_mpio v_brent_price
				
		ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio year)
		parmest, saving("${results}/time_robust/ivmpio_y_m_`y'_`x'.dta") 
		outreg2 using "${results}/time_robust/ivreg_mpio_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(F-iv, e(cdf))

		local rep_app = "append"
			
		rename v_brent_price w_b_`x'_mpio 
		
		rename outcome `y'
			
	}	
	
}


/*

That was the most basic estimaiton. No I want to do some adjustments: 

1. there can be control group contamination. In the spirit of Velez et al 2020, clean the sample to have only those tht were already treated by the year in which we are using the base IV year and the pure controls. 

2. Try with the most basic trends (etc, state)

3. Try with polynomial trends (use second order first)

4. Use only the boom period 2002-2008

5. You are dismissing ports and mpios of transportation!!! (take a look at those)

6. I can use winsorized variables

7. I can also use the log of price insted of the price

8. Standardize variables. 



*/

		* CLEANING THE CONTROL GROUP.

*generating the pure control var

tempvar control
bys codmpio: egen `control'=max(wells_accum_mpio)
gen pure_control=(`control'==0 )
label var pure_control "mpio without oil in history until 2014"

tempvar control2
bys codmpio: egen `control2'=max(wells_accum_mpio) if year<2009
gen pure_control2=(`control2'==0 )
replace pure_control2=. if year>2008
label var pure_control2 "mpio without oil in history until 2009"




forvalues x=1950(1)2001{
	preserve
		drop if w_b_`x'_mpio==0 & pure_control==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)
		
		
		local rep_app = "replace"
		foreach y in  enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe timetohe_m semestertohe semestertohe_m { 
		
			rename `y' outcome
					
			rename w_b_`x'_mpio v_brent_price
					
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio year)
			parmest, saving("${results}/control_contamination/iv_`y'_`x'.dta") 
			outreg2 using "${results}/control_contamination/iv_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))

			local rep_app = "append"
				
			rename v_brent_price w_b_`x'_mpio 
			
			rename outcome `y'
	}	
	
	restore
	
}

forvalues x=1950(1)2001{
	preserve
		drop if year>2008
		drop if w_b_`x'_mpio==0 & pure_control2==0   // now the same but for the boom period 2002-2008 (how valid is this?)
		
		
		local rep_app = "replace"
		foreach y in  enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe timetohe_m semestertohe semestertohe_m { 
		
			rename `y' outcome
					
			rename w_b_`x'_mpio v_brent_price
					
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio year)
			parmest, saving("${results}/control_contamination/iv_boom_`y'_`x'.dta") 
			outreg2 using "${results}/control_contamination/iv_boom_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))

			local rep_app = "append"
				
			rename v_brent_price w_b_`x'_mpio 
			
			rename outcome `y'
	}	
	
	restore
	
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

egen t_dep=group(depto year)
egen t_etc=group(etc_id year)


		
* basic tdept and tec trends with clean control groups. 
		
forvalues x=1950(1)2001{
	preserve
		drop if w_b_`x'_mpio==0 & pure_control==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)
		
		
		local rep_app = "replace"
		foreach y in  enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe timetohe_m semestertohe semestertohe_m { 
		
			rename `y' outcome
					
			rename w_b_`x'_mpio v_brent_price
					
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio t_dep)
			parmest, saving("${results}/trends/t_dep_`y'_`x'.dta") 
			outreg2 using "${results}//trends/t_dep_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))
			
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio t_etc)
			parmest, saving("${results}/trends/t_etc_`y'_`x'.dta") 
			outreg2 using "${results}/trends/t_etc_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))

			local rep_app = "append"
				
			rename v_brent_price w_b_`x'_mpio 
			
			rename outcome `y'
	}	
	
	restore
	
}

forvalues x=1950(1)2001{
	preserve
		drop if year>2008
		drop if w_b_`x'_mpio==0 & pure_control2==0   // now the same but for the boom period 2002-2008 (how valid is this?)
		
		
		local rep_app = "replace"
		foreach y in  enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe timetohe_m semestertohe semestertohe_m { 
		
			rename `y' outcome
					
			rename w_b_`x'_mpio v_brent_price
					
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio t_dep)
			parmest, saving("${results}/trends/t_dep_boom_`y'_`x'.dta") 
			outreg2 using "${results}//trends/t_dep_boom_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))
			
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio t_etc)
			parmest, saving("${results}/trends/t_etc_boom_`y'_`x'.dta") 
			outreg2 using "${results}/trends/t_etc_boom_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))

			local rep_app = "append"
				
			rename v_brent_price w_b_`x'_mpio 
			
			rename outcome `y'
	}	
	
	restore
	
}

		
* Now polynomial trends with clean control groups. 




forvalues x=1950(1)2001{
	preserve
		drop if w_b_`x'_mpio==0 & pure_control==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)
		
		
		local rep_app = "replace"
		foreach y in  enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe timetohe_m semestertohe semestertohe_m { 
		
			rename `y' outcome
					
			rename w_b_`x'_mpio v_brent_price
					
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio i.depto##c.c_year)
			parmest, saving("${results}/poly_trends/dep1_`y'_`x'.dta") 
			outreg2 using "${results}//poly_trends/dep1_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))
			
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio i.depto##c.c_year i.depto##c.c_year2)
			parmest, saving("${results}/poly_trends/dep2_`y'_`x'.dta") 
			outreg2 using "${results}//poly_trends/dep2_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))
			
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio i.etc_id##c.c_year)
			parmest, saving("${results}/poly_trends/etc1_`y'_`x'.dta") 
			outreg2 using "${results}//poly_trends/etc1_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))
			
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio i.etc_id##c.c_year i.etc_id##c.c_year2)
			parmest, saving("${results}/poly_trends/etc2_`y'_`x'.dta") 
			outreg2 using "${results}/poly_trends/etc2_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))


			local rep_app = "append"
				
			rename v_brent_price w_b_`x'_mpio 
			
			rename outcome `y'
	}	
	
	restore
	
}



forvalues x=1950(1)2001{

	preserve
		drop if year>2008
		drop if w_b_`x'_mpio==0 & pure_control2==0   // now the same but for the boom period 2002-2008 (how valid is this?)
		
		
		local rep_app = "replace"
		foreach y in  enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe timetohe_m semestertohe semestertohe_m { 
		
			rename `y' outcome
					
			rename w_b_`x'_mpio v_brent_price
					
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio i.depto##c.c_year)
			parmest, saving("${results}/poly_trends/dep1_boom_`y'_`x'.dta") 
			outreg2 using "${results}//poly_trends/dep1_boom_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))
			
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio i.depto##c.c_year i.depto##c.c_year2)
			parmest, saving("${results}/poly_trends/dep2_boom_`y'_`x'.dta") 
			outreg2 using "${results}//poly_trends/dep2_boom_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))
			
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio i.etc_id##c.c_year)
			parmest, saving("${results}/poly_trends/etc1_boom_`y'_`x'.dta") 
			outreg2 using "${results}//poly_trends/etc1_boom_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))
			
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio i.etc_id##c.c_year i.etc_id##c.c_year2)
			parmest, saving("${results}/poly_trends/etc2_boom_`y'_`x'.dta") 
			outreg2 using "${results}/poly_trends/etc2_boom_`x'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(`y')  addstat(IV-F, e(cdf))


			local rep_app = "append"
				
			rename v_brent_price w_b_`x'_mpio 
			
			rename outcome `y'
	}	
	
	restore
	
}




		













/*







/*

/*

Now I will follow more closely the approach of Dube & Vargas. I will simply use the number of wells
drilled until 2003 as a exogenous indicator of oil presence. The price will give me the
temporal variation needed for estimation

*/

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

foreach x in 1000 2500 5000 10000{
	foreach y in 2000 2001 2002{
	
		gen cw_c_`y'_`x'=cwells_`y'_`x'*oil_price
		gen cw_b_`y'_`x'=cwells_`y'_`x'*brent_price

		label var cw_c_`y'_`x' "crude price * number of wells until `y' in `x' buf"
		label var cw_b_`y'_`x' "brent price * number of wells until `y' in `x' buf"

	}
}


foreach y in 2000 2001 2002{
	
	gen w_c_`y'_mpio=wells_`y'_mpio*oil_price
	gen w_b_`y'_mpio=wells_`y'_*brent_price

	label var w_c_`y'_mpio "crude price * number of wells until `y' in `x' buf"
	label var w_b_`y'_mpio"brent price * number of wells until `y' in `x' buf"
}



local rep_app = "replace"
foreach y in enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe{

	foreach w in 1000 2500 5000 10000{
	
		foreach z in 2000 2001 2002{
		
			rename `y' outcome
				
			rename cw_b_`z'_`w' v_brent_price
				
			reghdfe outcome v_brent_price , absorb(codmpio year) 
			outreg2 using "${results}/dube_instrument_all_mpio_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w')  addnote("year `z'")

			local rep_app = "append"
			
			preserve 
				keep if pobl_tot<200000
				reghdfe outcome v_brent_price , absorb(codmpio year) 
				outreg2 using "${results}/dube_instrument_all_mpio_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2 cttop(b_`w')  addnote("year `z'")
			restore
			
			rename v_brent_price cw_b_`z'_`w'  
			
			rename cw_c_`z'_`w' v_crude_price
			
			reghdfe outcome v_crude_price , absorb(codmpio year) 
				outreg2 using "${results}/dube_instrument_all_mpio_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w') addnote("year `z'")

			preserve 
				keep if pobl_tot<200000
				reghdfe outcome v_crude_price , absorb(codmpio year) 
				outreg2 using "${results}/dube_instrument_all_mpio_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(b_`w') addnote("year `z'")
			restore
			
			rename v_crude_price cw_c_`z'_`w' 
			rename outcome `y'
		
		
		}
	}

}





local rep_app = "append"
foreach y in enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe{
	
	foreach z in 2000 2001 2002{
		
		rename `y' outcome
				
		rename w_b_`z'_mpio v_brent_price
				
		reghdfe outcome v_brent_price , absorb(codmpio year) 
		outreg2 using "${results}/dube_instrument_all_mpio_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(mpio)  addnote("year `z'")

		local rep_app = "append"
			
		preserve 
			keep if pobl_tot<200000
			reghdfe outcome v_brent_price , absorb(codmpio year) 
			outreg2 using "${results}/dube_instrument_all_mpio_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2 cttop(mpio)  addnote("year `z'")
		restore
			
		rename v_brent_price w_b_`z'_mpio  
		
		rename w_c_`z'_mpio v_crude_price
			
		reghdfe outcome v_crude_price , absorb(codmpio year) 
		outreg2 using "${results}/dube_instrument_all_mpio_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(mpio) addnote("year `z'")

		preserve 
			keep if pobl_tot<200000
			reghdfe outcome v_crude_price , absorb(codmpio year) 
			outreg2 using "${results}/dube_instrument_all_mpio_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(mpio) addnote("year `z'")
		restore
			
		rename v_crude_price w_c_`z'_mpio 
		rename outcome `y'
		
	}
}


*/
/*

Now the IVREG at the municipality level. But we are going to do it smart. 

*/


local rep_app = "append"
foreach y in enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe{
	
	foreach z in 2001{
		
		rename `y' outcome
				
		rename w_b_`z'_mpio v_brent_price
				
		ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio year) 
		outreg2 using "${results}/ivreg_mpio_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(mpio)  addstat(F-iv, e(cdf))

		local rep_app = "append"
			
		preserve 
			keep if pobl_tot<200000
			ivreghdfe outcome (wells_accum_mpio=v_brent_price) , absorb(codmpio year) 
			outreg2 using "${results}/ivreg_mpio_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2 cttop(mpio)  addnote("year `z'")
		restore
			
		rename v_brent_price w_b_`z'_mpio  
		
		rename w_c_`z'_mpio v_crude_price
			
		ivreghdfe outcome (wells_accum_mpio=v_crude_price) , absorb(codmpio year) 
		outreg2 using "${results}/ivreg_mpio_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(mpio) addnote("year `z'")

		preserve 
			keep if pobl_tot<200000
			ivreghdfe outcome (wells_accum_mpio=v_crude_price) , absorb(codmpio year) 
			outreg2 using "${results}/ivreg_mpio_`y'.xls", `rep_app' bracket  nocons noni less(1) nor2  cttop(mpio) addnote("year `z'")
		restore
		
		rename v_crude_price w_c_`z'_mpio 
		rename outcome `y'
		
	}
}

merge m:1 codmpio using  "${municipios}/ETC_mpio.dta", gen(m_etc)


ivreghdfe enrolment_rate (wells_accum_10000=w_b_2000_10000) , absorb(id_cole year) 


reghdfe enrolment_rate wells_accum_10000 i.etc_id#i.year , absorb(id_cole year ) 


