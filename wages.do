
/*

 PROJECT :     	Mining - HK
 AUTHOR :			Camilo De Los Rios
 PURPOSE :			Mechanism (salaries)

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

 First create the oil wells_ for Schols and merge with individual hk. 

------------------------------------------------------------------------------*/ 
use "${hk}/harm/hk_individual.dta", clear

keep year_prim year pct2 enroled_he age mujer graduated id_cole TDCp* TibcpA* date_grad annonac technic
compress
gen id_ind=_n

gen exp_2008=TDCpA2008
gen exp_2009=TDCpA2008+TDCpA2009
gen exp_2010=TDCpA2008+TDCpA2009+TDCpA2010
gen exp_2011=TDCpA2008+TDCpA2009+TDCpA2010+TDCpA2011
gen exp_2012=TDCpA2008+TDCpA2009+TDCpA2010+TDCpA2011+TDCpA2012
gen exp_2013=TDCpA2008+TDCpA2009+TDCpA2010+TDCpA2011+TDCpA2012+TDCpA2013
gen exp_2014=TDCpA2008+TDCpA2009+TDCpA2010+TDCpA2011+TDCpA2012+TDCpA2013+TDCpA2014


reshape long TDCpA TibcpA exp_, i(id_ind) j(year_wage)
bys id_ind: egen maxTibcpA=max(TibcpA)
drop if maxTibcpA==.
rename year year_grad
sa "${hk}/harm/hk_individual_wages.dta", replace

* merge with wells 
rename year_wage year
merge m:1 id_cole year using "${oil}/harm/wells_measures_cole.dta", gen(mer_wells)
drop if mer_wells==2

drop if year>2014
drop mer_wells

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

sa "${compiled}/hk_oilwells_individual_mines_wages.dta", replace


/*------------------------------------------------------------------------------

Trransform data a bit. 
------------------------------------------------------------------------------*/ 



use "${compiled}/hk_oilwells_individual_mines_wages.dta", clear



* First create your treatment variables. 

foreach y in 5000 10000 20000{

	foreach x in DESMIL INCAUTA MAP MUSE OTROS SOSP{

		recode `x'_`y'(.=0)

	}

}

foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}




foreach x in  2500 5000 10000 20000 25000 30000 35000 {
	foreach y in 1960 1970 1980 1990 2000 {
	
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

foreach w in 10000  { // 2500 5000 20000 25000 30000 35000
	
	egen wells_accum_`w'sd = std(wells_accum_`w')
	egen npozos_`w'sd = std(npozos_`w')
	
	foreach y in 30 {
		egen wells_accum`y'_`w'sd = std(wells_accum`y'_`w')
	}
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

*rename non_rent_seeker_1 norent

***To capture the returns to schooling*** 

gen age2=year-annonac // the other age is the one at which the student too the icfes


gen enroled=(enroled_he==1 & year>=year_prim) // that is already enroled_he
gen grad=(graduated==1 & year>=date_grad) // that is already graduated

gen schooling_1=1 // all have highschool completed
replace schooling_1=2 if enroled==1 // incomplete tertiary education
replace schooling_1=3 if grad==1 // complete tertiaty


gen schooling_2=1 // all have highschool completed
replace schooling_2=2 if enroled==1 & technic==1 // incomplete tertiary education technical
replace schooling_2=3 if grad==1  & technic==1 // complete tertiaty education technical
replace schooling_2=4 if enroled==1 & technic==0 // incomplete tertiary education professional
replace schooling_2=5 if grad==1  & technic==0 // complete tertiaty education professional
replace schooling_2=. if technic==.

gen schooling_y=11
replace schooling_y=14 if grad==1  & technic==1
replace schooling_y=16 if grad==1  & technic==0

gen exp_y=exp/365 // number of days worked in years. 


gen exp1=age2-schooling_y-6
gen exp2=age2+exp_y-schooling_y-6
foreach x in exp1 exp2 {

	gen `x'_q=`x'*`x'
	recode `x'(.=0)
	recode `x'_q(.=0)
}



/*
**** Generating the experience var******

gen years_out=year-year_grad
replace years_out=0 if years_out<0

gen years_merc=year_prim-year_grad
replace years_merc=0 if year<=year_grad

gen days_out=years_out*365
gen days_merc=years_merc*365

rename exp exp1
gen exp2=exp1+days_out
gen exp3=exp1+days_merc

foreach x in exp1 exp2 exp3{

	gen `x'_q=`x'*`x'
	recode `x'(.=0)
	recode `x'_q(.=0)

}
*/
gen min_wage=.
replace min_wage=461500 if year==2008
replace min_wage=496900 if year==2009
replace min_wage=515000 if year==2010
replace min_wage=535600 if year==2011
replace min_wage=566700 if year==2012
replace min_wage=589500 if year==2013
replace min_wage=616000 if year==2014

gen wage_adj=TibcpA/min_wage
gen lnwage_adj=ln(wage_adj+1)

sa "${compiled}/hk_oilwells_individual_mines_wages_clean.dta", replace
/*------------------------------------------------------------------------------
								ESTIMATIONS
------------------------------------------------------------------------------*/ 
use "${compiled}/hk_oilwells_individual_mines_wages_clean.dta", clear


gen working = (TibcpA!=.)

probit working i.muje age MAP_10000 exp1 exp1_q pct2  schooling_y i.year i.depto##c.c_year, vce(r)

predict phat, xb


gen mills = exp(-.5*phat^2)/(sqrt(2*_pi)*normprob(phat))


eststo: reg ln_salary $eee i.schooling##c.patentesstd $demo1 $job $time mills, 
		vce(cl code_funarea);
drop mills phat;



ivreghdfe lnwage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age mills i.schooling_2 ( i.schooling_2##c.wells_accum_10000sd wells_accum_10000sd = w_lb_2000_10000 i.schooling_2##c.w_lb_2000_10000 ) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r

				 
				 
reghdfe wage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age i.schooling_2##c.w_lb_2000_10000  , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)


keep if year>2007

local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
	*		drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  exp1 exp2 { 
			
		
				rename `y' experiencia
				rename `y'_q experiencia_q
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe wage_adj experiencia experiencia_q pct2  MAP_`w' i.mujer age (wells_accum i.schooling_1##c.wells_accum= v_brent_price i.schooling_1##c.v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
								
				reghdfe wage_adj MAP_`w' experiencia experiencia_q pct2 i.mujer age v_brent_price i.schooling_1##c.v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'
				
				reghdfe wage_adj MAP_`w' experiencia experiencia_q pct2 i.mujer age wells_accum i.schooling_1##c.wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store nai_`y'_`w'

					
				
				
				local rep_app = "append"

				rename experiencia `y'
				rename experiencia_q `y'_q
				
				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				
			}
		restore
		}
}


foreach y in 10000  {

local appi replace
	foreach x in nai rred riv{


	esttab   `x'_exp2_`y' using "${overleaf}/resultados/individual/mines/wages2_exp_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{pct2_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}
}

/*


				
keep if year>2007

local rep_app = "replace"
foreach x in  2000 {
	foreach w in  10000   {
		preserve
	*		drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  exp2 { 
		
				rename `y' experiencia
				rename `y'_q experiencia_q
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe wage_adj experiencia experiencia_q pct2 enroled_he MAP_`w' i.mujer age (wells_accum=v_brent_price) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
								
				reghdfe wage_adj MAP_`w' experiencia experiencia_q pct2 enroled_he i.mujer age v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'
				
				reghdfe wage_adj MAP_`w' experiencia experiencia_q pct2 enroled_he i.mujer age wells_accum , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store nai_`y'_`w'

					
				
				
				local rep_app = "append"

				rename experiencia `y'
				rename experiencia_q `y'_q
				
				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				
			}
		restore
		}
}


foreach y in 10000  {

local appi replace
	foreach x in nai rred riv{


	esttab   `x'_exp2_`y' using "${overleaf}/resultados/individual/mines/wages_exp_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{pct2_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}
}















