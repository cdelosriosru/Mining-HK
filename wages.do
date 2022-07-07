
/*

 PROJECT :     	Mining - HK
 AUTHOR :			Camilo De Los Rios
 PURPOSE :			Mechanism (salaries)

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




/*

	CLEAN THE ORIGINAL DATA SET TO MAKE IT EASIER TO MANAGE*/
	
	
use "${hk}/raw/HumanCapital_clean.dta", clear 

/*
	Experience and income for individuals 
*/

keep  id colegio_cod TDCp* TibcpA* TDCs* TibcsA* codigo_actividad_economica_* departamento* municipio*

rename id id_individuo
rename colegio_cod id_cole

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


compress

forvalues x=2008(1)2014{
	
	rename codigo_actividad_economica_`x' isic_`x'
}
destring isic_2012, replace
destring departamento_2012, replace
drop if municipio_2008=="0-1" // weird values
forvalues x=2008(1)2013{
	
	destring municipio_`x', replace
}

foreach x in TibcpA TibcsA isic_ departamento_ municipio_{
	forvalues y=2008(1)2014{
	gen a`x'`y'=`x'`y'
	gen b`x'`y'=`x'`y'
	}
	replace a`x'2012=`x'2011
	replace b`x'2012=`x'2013
}

reshape long TDCpA TibcpA TDCsA TibcsA exp_ exps_  isic_ departamento_ municipio_ aTibcpA aTibcsA aisic_ adepartamento_ amunicipio_ bTibcpA bTibcsA bisic_ bdepartamento_ bmunicipio_, i(id_individuo) j(year_wage)

foreach x in s p{
	bys id_ind: egen maxTibc`x'A=max(Tibc`x'A)
	gen drop`x'=(maxTibc`x'A==.)   // gen droping var if there is no data
}

gen nodropi=1 if drops!=dropp // dont drop if there is at least some data
drop if nodropi!=1 & drops==1  // drop if there is no data and, in particular, no health data. 
*drop if nodropi!=1 & drops==1
*rename year year_grad // we dont really need this because we can simply merge with the hk individual data. 
sa "${hk}/harm/hk_individual_wages_2022.dta", replace
use "${hk}/harm/hk_individual_wages_2022.dta", clear
rename year_wage year

* merge with school level covariates because there is info of wells for every year

merge m:1 id_cole year using  "${compiled}/hk_oilwells_colegio_mines.dta", gen(m_welcole)

drop year_period pct2_sd pct2_m timetohe_m semestertohe_m qual_over qual_over_sd pct2 timetohe semestertohe graduado estudiantes graduated enroled_he rent_seeker non_rent_seeker_1 non_rent_seeker_2 universitario technic deserted public private imen_1 imen_2 laen_1 laen_2 urbano oficial academic Cale_A lat_cole lon_cole pob200 pob100 enrolment_rate completion_rate desertion_rate imen1_rate laen1_rate imen2_rate laen2_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2

* merge with individual level HK because I need to test the balance. 
rename year year_wage 

merge m:1 id_individuo using  "${hk}/harm/hk_individual.dta", gen(m_whkind)

keep if m_whkind==3


sa "${compiled}/hk_oilwells_individual_mines_wages_clean.dta", replace

use "${compiled}/hk_oilwells_individual_mines_wages_clean.dta", clear


***To capture the returns to schooling*** 
drop age2 _*
gen age2=year_wage -annonac // the other age is the one at which the student too the icfes


gen enroled=(enroled_he==1 & year_wage>=year_prim) // that is already enroled_he
gen grad=(graduated==1 & year_wage>=date_grad) // that is already graduated

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
rename exp_ exp
rename exps_ exps

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
replace min_wage=461500 if year_wage==2008
replace min_wage=496900 if year_wage==2009
replace min_wage=515000 if year_wage==2010
replace min_wage=535600 if year_wage==2011
replace min_wage=566700 if year_wage==2012
replace min_wage=589500 if year_wage==2013
replace min_wage=616000 if year_wage==2014

xtset id_individuo year_wage
spbalance
xtset, clear

*gen  Tibcp2A=TibcpA
*replace Tibcp2A=TibcsA if year==2012

foreach x in p s{
	foreach y in aT bT T{
		gen `y'_wage`x'_adj=`y'ibc`x'A/min_wage
		gen `y'_lnwage`x'_adj=ln(`y'_wage`x'_adj+1)
	}
}

*** Add cluster information from Balza et al. 
foreach x in ai bi i{
rename `x'sic_ isic
replace isic=. if isic==9999 | isic==473 // these do not exist in the ISIC codes but are in the data

merge m:1 isic using "${data}/industry_clusters.dta", gen(m_`x'clus)

	foreach y in label_id label_id2 extractives_c extractives_p cluster_strong2 ext_c_cluster ext_p_cluster ext_all_cluster extractives_oil ext_oil_cluster{
	
	if `x'=="ai" {
		rename `y' aT`y'
	}
	if `x'=="bi" {
		rename `y' bT`y'
	}
	if `x'=="i" {
		rename `y' T`y'
	}
	
	
	}

rename isic `x'sic_ 

}
drop if m_iclus==2
compress
sa "${compiled}/hk_oilwells_individual_mines_wages_clean.dta", replace

/*------------------------------------------------------------------------------
								ESTIMATIONS
------------------------------------------------------------------------------*/ 
use "${compiled}/hk_oilwells_individual_mines_wages_clean.dta", clear
drop if pob200==1

gen random=runiform()
keep if random<0.1

capture drop _*

foreach x in s p {
	foreach y in aT bT T{
		gen `y'working_`x' = (`y'ibc`x'A!=.)
		probit `y'working_`x' i.muje age MAP_10000 exp1 exp1_q pct2  schooling_y i.year i.depto##c.c_year, vce(r)
		predict `y'phat, xb
		gen `y'mills_`x' = exp(-.5*`y'phat^2)/(sqrt(2*_pi)*normprob(`y'phat))
		drop `y'phat
	}
}

gen techenrol=technic*enroled
replace techenrol=. if enroled==0

foreach y in exp1 exps_2 exp_2 { 
foreach j in p s{
	foreach ju in aT bT T{
		foreach x in  2000 {
			foreach w in  10000   {
		
				rename `y' experiencia
				rename `y'_q experiencia_q
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
				rename `ju'mills_`j' mills 

				*second order poly trend
				
				ivreghdfe `ju'_wage`j'_adj experiencia experiencia_q pct2  MAP_`w' i.mujer age mills i.enroled (wells_accum c.wells_accum#i.enroled = v_brent_price c.v_brent_price#i.enroled), absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(id_cole)
				estimates store ri`y'`ju'`j'
								
				reghdfe `ju'_wage`j'_adj   experiencia experiencia_q pct2  MAP_`w' i.mujer age mills v_brent_price c.v_brent_price#i.enroled i.enroled , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(cluster id_cole)
				estimates store re`y'`ju'`j'
				
				reghdfe `ju'_wage`j'_adj MAP_`w' experiencia experiencia_q pct2 i.mujer age mills c.wells_accum#i.enroled wells_accum i.enroled, absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(cluster id_cole)
				estimates store na`y'`ju'`j'

					
				
				
				local rep_app = "append"

				rename experiencia `y'
				rename experiencia_q `y'_q
				
				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				rename mills `ju'mills_`j'  

				
			}
		}
	}
}

local appi replace
foreach tipo in na re ri{
	esttab   `tipo'`y'aTp `tipo'`y'aTs `tipo'`y'bTp `tipo'`y'bTs `tipo'`y'Tp `tipo'`y'Ts using "${overleaf}/resultados/new_2022/individual/mines/wages`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
}
estimates clear

}	
	


******** Probability of Working in xtractive sector ********

use "${compiled}/hk_oilwells_individual_mines_wages_clean.dta", clear
drop if pob200==1

gen random=runiform()
keep if random<0.1

estimates clear 

foreach y in  exp1 exp_2 exps_2 { 
	foreach j in p s{
		foreach ju in aT bT T{
			foreach x in  2000 {
				foreach w in  10000   {
					foreach yi in extractives_c extractives_p extractives_oil {
					
					rename `y' experiencia
					rename `y'_q experiencia_q
					rename w_lb_`x'_`w' v_brent_price
					rename wells_accum_`w'sd wells_accum
					rename npozos_`w'sd npozos
					rename `ju'mills_`j'  mills
					rename `yi' outcome
		

					*second order poly trend
					
					ivreghdfe outcome experiencia experiencia_q pct2  MAP_`w' i.mujer age  mills i.enroled (wells_accum c.wells_accum#i.enroled  = v_brent_price c.v_brent_price#i.enroled), absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(id_cole)
					estimates store ri`y'`ju'`yi'`j'
									
					reghdfe outcome  experiencia experiencia_q pct2  MAP_`w' i.mujer age enroled mills i.enroled v_brent_price i.enroled#c.v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(cluster id_cole)
					estimates store re`y'`ju'`yi'`j'
					
					reghdfe outcome MAP_`w' experiencia experiencia_q pct2 i.mujer age enroled mills i.enroled#c.wells_accum wells_accum i.enroled, absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(cluster id_cole)
					estimates store na`y'`ju'`yi'`j'

						
					rename `yi' outcome
					rename `ju'mills_`j'  mills
					rename experiencia `y'
					rename experiencia_q `y'_q
					rename npozos npozos_`w'sd 				
					rename v_brent_price w_lb_`x'_`w'  			
					rename wells_accum wells_accum_`w'sd 
					
				}
			}
		}
	}
}
foreach j in p s{
local appi replace
	foreach tipo in na re ri{
	esttab   `tipo'`y'aTextractives_c`j' `tipo'`y'bTextractives_c`j'  `tipo'`y'Textractives_c`j' ///
	`tipo'`y'aTextractives_c`j'  `tipo'`y'bTextractives_c`j'  `tipo'`y'Textractives_c`j' ///
	`tipo'`y'aTextractives_oil`j'  `tipo'`y'bTextractives_oil`j'  `tipo'`y'Textractives_oil`j' ///	
	using "${overleaf}/resultados/new_2022/individual/mines/prob_employ_1`y'_`j'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
		}
	}
}	
	
estimates clear 

foreach y in  exp1 exp_2 exps_2 { // 

foreach j in p s{
	foreach ju in aT bT T{
		foreach x in  2000 {
			foreach w in  10000   {
				foreach yi in  ext_c_cluster ext_p_cluster ext_all_cluster  ext_oil_cluster {
		
		
				rename `y' experiencia
				rename `y'_q experiencia_q
				rename w_lb_`x'_`w' v_brent_price
				rename wells_accum_`w'sd wells_accum
				rename npozos_`w'sd npozos
				rename `ju'mills_`j'  mills
				rename `yi' outcome
	

				*second order poly trend
				
				ivreghdfe outcome experiencia experiencia_q pct2  MAP_`w' i.mujer age  mills i.enroled (wells_accum c.wells_accum#i.enroled  = v_brent_price c.v_brent_price#i.enroled), absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) cluster(id_cole)
				estimates store ri`y'`ju'`yi'`j'
								
				reghdfe outcome  experiencia experiencia_q pct2  MAP_`w' i.mujer age enroled mills i.enroled v_brent_price i.enroled#c.v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(cluster id_cole)
				estimates store re`y'`ju'`yi'`j'
				
				reghdfe outcome MAP_`w' experiencia experiencia_q pct2 i.mujer age enroled mills i.enroled#c.wells_accum wells_accum i.enroled, absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(cluster id_cole)
				estimates store na`y'`ju'`yi'`j'

					
				rename `yi' outcome
				rename `ju'mills_`j'  mills
				rename experiencia `y'
				rename experiencia_q `y'_q
				rename npozos npozos_`w'sd 				
				rename v_brent_price w_lb_`x'_`w'  			
				rename wells_accum wells_accum_`w'sd 
				
			}
		}
	}
}
}
foreach j in p s{
local appi replace
	foreach tipo in na re ri{
	esttab   `tipo'`y'aText_c_cluster`j' `tipo'`y'bText_c_cluster`j'  `tipo'`y'Text_c_cluster`j' ///
	`tipo'`y'aText_p_cluster`j'  `tipo'`y'bText_p_cluster`j'  `tipo'`y'Text_p_cluster`j' ///
	`tipo'`y'aText_all_cluster`j'  `tipo'`y'bText_all_cluster`j'  `tipo'`y'Text_all_cluster`j' ///	
	`tipo'`y'aText_oil_cluster`j'  `tipo'`y'bText_oil_cluster`j'  `tipo'`y'Text_oil_cluster`j' ///	
	using "${overleaf}/resultados/new_2022/individual/mines/prob_employ_2`y'_`j'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
		}
	}
}	















/*
/*------------------------------------------------------------------------------
								ESTIMATIONS
------------------------------------------------------------------------------*/ 
use "${compiled}/hk_oilwells_individual_mines_wages_clean.dta", clear

capture drop _*

foreach x in s p p2{
	gen working_`x' = (Tibc`x'A!=.)

	probit working_`x' i.muje age MAP_10000 exp1 exp1_q pct2  schooling_y i.year i.depto##c.c_year, vce(r)

	predict phat, xb


	gen mills_`x' = exp(-.5*phat^2)/(sqrt(2*_pi)*normprob(phat))


	drop phat
}


gen techenrol=technic*enroled
replace techenrol=. if enroled==0


*drop if year>2011

/*
ivreghdfe lnwage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age enroled_he ( i.enroled_he##c.wells_accum_10000sd wells_accum_10000sd = w_lb_2000_10000 i.enroled_he##c.w_lb_2000_10000 ) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
ivreghdfe lnwage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age enroled ( i.enroled##c.wells_accum_10000sd wells_accum_10000sd = w_lb_2000_10000 i.enroled##c.w_lb_2000_10000 ) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r

ivreghdfe wage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age enroled_he ( i.enroled_he##c.wells_accum_10000sd wells_accum_10000sd = w_lb_2000_10000 i.enroled_he##c.w_lb_2000_10000 ) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r

*/

*ivreghdfe wage_adj exp1 exp1_q pct2  MAP_10000 i.mujer age enroled mills ( i.enroled##c.wells_accum_10000sd wells_accum_10000sd = w_lb_2000_10000 i.enroled##c.w_lb_2000_10000 ) , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r

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
foreach j in p s p2{

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
				
				ivreghdfe wage`j'_adj experiencia experiencia_q pct2  MAP_`w' i.mujer age enroled (i.enroled##c.wells_accum wells_accum = v_brent_price i.enroled##c.v_brent_price), absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
								
				reghdfe wage`j'_adj   experiencia experiencia_q pct2  MAP_`w' i.mujer age enroled v_brent_price i.enroled##c.v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'
				
				reghdfe wage`j'_adj MAP_`w' experiencia experiencia_q pct2 i.mujer age enroled i.enroled##c.wells_accum wells_accum, absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
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


	esttab   nai_exp1_`y' rred_exp1_`y' riv_exp1_`y' using "${overleaf}/resultados/individual/mines/wages`j'_NEW_new_`y'", `appi' f  ///
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
				
				ivreghdfe wage`j'_adj experiencia experiencia_q pct2  MAP_`w' i.mujer age enroled mills_`j' (i.enroled##c.wells_accum wells_accum = v_brent_price i.enroled##c.v_brent_price), absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'_`w'
								
				reghdfe wage`j'_adj   experiencia experiencia_q pct2  MAP_`w' i.mujer age enroled mills_`j' v_brent_price i.enroled##c.v_brent_price , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
				estimates store rred_`y'_`w'
				
				reghdfe wage`j'_adj MAP_`w' experiencia experiencia_q pct2 i.mujer age enroled mills_`j' i.enroled##c.wells_accum wells_accum, absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
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


	esttab   nai_exp1_`y' rred_exp1_`y' riv_exp1_`y' using "${overleaf}/resultados/individual/mines/wages2`j'_NEW_new_mills_`y'", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{pct2_`y'}" ) ///
	scalars(rkf)  sfmt(0 3)

	local appi append
	
	}

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















