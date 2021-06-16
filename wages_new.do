
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


use "${compiled}/hk_oilwells_individual_mines.dta", clear

tempfile hkmerge
capture drop TDCpA* TibcpA* TDCsA* TibcsA*
collapse (first) w_* wells* npo* c_* t_* lo* lb* DESMIL* INCAUTA* MAP* MUSE* OTROS* SOS* depto*, by(year id_cole)
sa `hkmerge'


/*
* Drop those that wont be used. 


gen dropi_wagep=1
gen dropi_wages=1

forvalues x=2008(1)2014{

	replace dropi_wagep=0 if TibcpA`x'!=. // simply indicate those that should NOT be dropped (those with at least one year of wage info)
	replace dropi_wages=0 if TibcsA`x'!=. // simply indicate those that should NOT be dropped (those with at least one year of wage info)

}

gen nodropi=1 if dropi_wagep!=dropi_wages

drop if dropi_wagep==1 & nodropi==. 
drop if dropi_wages==1 & nodropi==. 



sa "${hk}/harm/hk_individual_wages_wel.dta", replace
*/

/*
 Now reshape


*/
/*
use "${hk}/harm/hk_individual.dta", clear


keep year_prim year pct2 enroled_he age mujer graduated id_cole TDCp* TibcpA* TDCs* TibcsA* date_grad annonac technic
compress
gen id_ind=_n

gen exp_2008=TDCpA2008
gen exp_2009=TDCpA2008+TDCpA2009
gen exp_2010=TDCpA2008+TDCpA2009+TDCpA2010
gen exp_2011=TDCpA2008+TDCpA2009+TDCpA2010+TDCpA2011
gen exp_2012=TDCpA2008+TDCpA2009+TDCpA2010+TDCpA2011+TDCpA2012
gen exp_2013=TDCpA2008+TDCpA2009+TDCpA2010+TDCpA2011+TDCpA2012+TDCpA2013
gen exp_2014=TDCpA2008+TDCpA2009+TDCpA2010+TDCpA2011+TDCpA2012+TDCpA2013+TDCpA2014


gen exps_2008=TDCsA2008
gen exps_2009=TDCsA2008+TDCsA2009
gen exps_2010=TDCsA2008+TDCsA2009+TDCsA2010
gen exps_2011=TDCsA2008+TDCsA2009+TDCsA2010+TDCsA2011
gen exps_2012=TDCsA2008+TDCsA2009+TDCsA2010+TDCsA2011+TDCsA2012
gen exps_2013=TDCsA2008+TDCsA2009+TDCsA2010+TDCsA2011+TDCsA2012+TDCsA2013
gen exps_2014=TDCsA2008+TDCsA2009+TDCsA2010+TDCsA2011+TDCsA2012+TDCsA2013+TDCsA2014




reshape long TDCpA TibcpA TDCsA TibcsA exp_ exps_, i(id_ind) j(year_wage)

foreach x in s p{
	bys id_ind: egen maxTibc`x'A=max(Tibc`x'A)
	gen drop`x'=(maxTibc`x'A==.)
}


gen nodropi=1 if drops!=dropp

drop if nodropi!=1 & drops==1
drop if nodropi!=1 & drops==1
rename year year_grad

sa "${hk}/harm/hk_individual_wages.dta", replace

* merge with wells 

*/
use "${hk}/harm/hk_individual_wages.dta", clear
rename year_wage year
merge m:1 id_cole year using `hkmerge', gen(mer_wells2)
sum TibcsA if mer_wells2==3
drop if mer_wells==2

drop if year>2014
drop mer_wells





/*------------------------------------------------------------------------------

Trransform data a bit. 
------------------------------------------------------------------------------*/ 



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
gen exps_y=exps/365 // number of days worked in years. 


gen exp1=age2-schooling_y-6

foreach x in s_ _{
	gen exp`x'2=age2+exp`x'y-schooling_y-6
}

foreach x in exp1 exps_2 exp_2 {

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

rename exp_ exp1
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

foreach x in p s{
gen wage`x'_adj=Tibc`x'A/min_wage
gen lnwage`x'_adj=ln(wage`x'_adj+1)
}


sa "${compiled}/hk_oilwells_individual_mines_wages_clean.dta", replace
/*------------------------------------------------------------------------------
								ESTIMATIONS
------------------------------------------------------------------------------*/ 
use "${compiled}/hk_oilwells_individual_mines_wages_clean.dta", clear

drop _*

gen working = (TibcpA!=.)

probit working i.muje age MAP_10000 exp1 exp1_q pct2  schooling_y i.year i.depto##c.c_year, vce(r)

predict phat, xb


gen mills = exp(-.5*phat^2)/(sqrt(2*_pi)*normprob(phat))





gen techenrol=technic*enroled
replace techenrol=. if enroled==0


drop if year>2011

/*
ivreghdfe lnwage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age enroled_he ( i.enroled_he##c.wells_accum_10000sd wells_accum_10000sd = w_lb_2000_10000 i.enroled_he##c.w_lb_2000_10000 ) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
ivreghdfe lnwage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age enroled ( i.enroled##c.wells_accum_10000sd wells_accum_10000sd = w_lb_2000_10000 i.enroled##c.w_lb_2000_10000 ) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r

ivreghdfe wage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age enroled_he ( i.enroled_he##c.wells_accum_10000sd wells_accum_10000sd = w_lb_2000_10000 i.enroled_he##c.w_lb_2000_10000 ) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r

*/

ivreghdfe wage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age enroled mills ( i.enroled##c.wells_accum_10000sd wells_accum_10000sd = w_lb_2000_10000 i.enroled##c.w_lb_2000_10000 ) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r

/*
ivreghdfe wage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age techenrol ( i.techenrol##c.wells_accum_10000sd wells_accum_10000sd = w_lb_2000_10000 i.techenrol##c.w_lb_2000_10000 ) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r



ivreghdfe wage_adj exp2 exp2_q pct2  MAP_10000 i.mujer age enroled_he ( wells_accum_10000sd = w_lb_2000_10000  ) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r







eststo: reg ln_salary $eee i.schooling##c.patentesstd $demo1 $job $time mills, 
		vce(cl code_funarea);
drop mills phat;



ivreghdfe lnwage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age mills i.schooling_2 ( i.schooling_2##c.wells_accum_10000sd wells_accum_10000sd = w_lb_2000_10000 i.schooling_2##c.w_lb_2000_10000 ) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r

				 
				 
reghdfe wage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age i.schooling_2##c.w_lb_2000_10000  , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)


keep if year>2007
* i.schooling_1
*/
foreach x in  2000 {
	foreach w in  10000   {
		*preserve
	*		drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  exp1 { // exp2
			
		
				rename `y' experiencia
				rename `y'_q experiencia_q
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe wage_adj experiencia experiencia_q pct2  MAP_`w' i.mujer age enroled (i.enroled##c.wells_accum wells_accum = v_brent_price i.enroled##c.v_brent_price), absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
								
				reghdfe wage_adj   experiencia experiencia_q pct2  MAP_`w' i.mujer age enroled v_brent_price i.enroled##c.v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'
				
				reghdfe wage_adj MAP_`w' experiencia experiencia_q pct2 i.mujer age enroled i.enroled##c.wells_accum wells_accum, absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store nai_`y'_`w'

					
				
				
				local rep_app = "append"

				rename experiencia `y'
				rename experiencia_q `y'_q
				
				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				
			}
		*restore
		}
}


foreach y in 10000  {

local appi replace
	*foreach x in nai rred riv{


	esttab   nai_exp1_`y' rred_exp1_`y' riv_exp1_`y' using "${overleaf}/resultados/individual/mines/wages_new_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{pct2_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}
	
	
	
foreach x in  2000 {
	foreach w in  10000   {
		*preserve
	*		drop if w_b_`x'_`w'==0 & pure_control_`w'==0 
			
			// drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  exp1 { // exp2
			
		
				rename `y' experiencia
				rename `y'_q experiencia_q
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
			

				*second order poly trend
				
				ivreghdfe wage_adj experiencia experiencia_q pct2  MAP_`w' i.mujer age enroled mills (i.enroled##c.wells_accum wells_accum = v_brent_price i.enroled##c.v_brent_price), absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
								
				reghdfe wage_adj   experiencia experiencia_q pct2  MAP_`w' i.mujer age enroled mills v_brent_price i.enroled##c.v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'
				
				reghdfe wage_adj MAP_`w' experiencia experiencia_q pct2 i.mujer age enroled mills i.enroled##c.wells_accum wells_accum, absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store nai_`y'_`w'

					
				
				
				local rep_app = "append"

				rename experiencia `y'
				rename experiencia_q `y'_q
				
				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				
			}
		*restore
		}
}


foreach y in 10000  {

local appi replace
	*foreach x in nai rred riv{


	esttab   nai_exp1_`y' rred_exp1_`y' riv_exp1_`y' using "${overleaf}/resultados/individual/mines/wages2_new_mills_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{pct2_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

	
	
*}

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















