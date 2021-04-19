
cls
clear
global mpios "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA/PoliticalBoundaries"
global placebo "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA/Placebo_suitability"
 import excel "${placebo}/anuario_1946_edited.xlsx", sheet("Hoja1") firstrow allstring clear

gen cerdos2 = subinstr(cerdos,".","",.)
replace cerdos2="." if cerdos2==" "
replace cerdos2="." if cerdos2=="—"
destring cerdos2, replace


replace cerdos2=9623 if mpio=="CARTAGENA...___________" // error in importing. 


gen mpios2=substr(mpio,1,length(mpio)-strpos(mpio,"."))

gen largo=length(mpio)

drop mpios2
gen mpios2=subinstr(mpio,".","",.)
gen mpios3=subinstr(mpios2,"-","",.)
gen mpios4=subinstr(mpios3,"_","",.)
gen mpios5=subinstr(mpios4,",","",.)
gen mpios6=subinstr(mpios5," —","",.) // the rest was edited by hand
drop mpio
rename mpios6 mpio
drop mpios*
gen id_censo=_n
rename mpio_censo mpio 
rename dpto_censo departamento_censo
sa "${placebo}/mpios_fixed" 
use"${placebo}/mpios_fixed", clear


reclink mpio using "${mpios}/cod_DANE.dta", idmaster(id_censo) idusing(codmpio) gen(reclinked) 


* edited by hand 


use"${placebo}/fixed", clear



keep if var11==.

sa "${placebo}/fixed_clean.dta", replace
* only 620. That's abput half. 

use"${placebo}/fixed_clean", clear

keep departamento_censo mpio cerdos2 codmpio
rename mpio mpio_censo
merge 1:1 codmpio using "${mpios}/cod_DANE.dta"
sa "${placebo}/checknow", replace

use "${placebo}/checknow", clear

* now filling the missing by hand.
sa, replace
recode cerdos2(.=0)
keep if cerdos2>=0
rename cerdos2 cerdos
keep codmpio cerdos

sa "${placebo}/clean.dta", replace



/*------------------------------------------------------------------------------
								ESTIMATE
------------------------------------------------------------------------------*/


global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global oil "${data}/Petroleo"
global hk "${data}/HK"
global municipios "${data}/PoliticalBoundaries"
global results "C:/Users/cdelo/Dropbox/HK_Extractives_2020/RESULTS/Municipality"
global compiled "${data}/compiled_sets"
global overleaf "C:/Users/cdelo/Dropbox/Apps/Overleaf/Oil - HK - Colombia"

/*

I created the wells measures in another dofile. 

*/


* Open data base with wells information
use "${oil}/harm/wells_measures_mpio.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 
	

* merge with HK info and prepare. 

merge 1:1 codmpio year using "${hk}/harm/hk_mpio.dta", gen(mer_hk)
drop if mer_hk==1 // these are simply the ones that have no HK information
drop if mer_hk==2 // these are the ones that have no time information for the wells at the municipality level is different than at the school level (it makes sense)


* merge with pork

merge m:1 codmpio using  "${placebo}/clean.dta", gen(mer_pork)
*when mer_pork==" is mainly because of the big cities. When equal to 1 is because those municipalities did not exist back in 1946

*merge with OIL price

merge m:1 year using  "${oil}/raw/oil_price.dta", gen (m_oilprice)
drop if m_oilprice==2 // years that are not in the sample

sa "${placebo}/hk_oilwells_mpio.dta", replace


/*
				BASIC 
				IV ESTIMATION

*/

use "${placebo}/hk_oilwells_mpio.dta", clear



foreach x in oil_price brent_price{
	gen l`x'=ln(`x')
}
*The normal oil
foreach y in  2000 {

	quietly summarize wells_`y'_mpio
	generate wells_`y'sd = (wells_`y'_mpio-r(mean)) / r(sd)
	
	
	gen w_c_`y'=wells_`y'_mpio*oil_price
	gen w_b_`y'_`x'=wells_`y'_mpio*brent_price

	label var w_c_`y' "crude price * number of wells until `y' "
	label var w_b_`y'_`x' "brent price * number of wells until `y'"
		
		
	gen lw_c_`y'=wells_`y'sd*loil_price
	gen lw_b_`y'=wells_`y'sd*lbrent_price

	label var lw_c_`y' "log crude price *sd number of wells until `y'"
	label var lw_b_`y' "log brent price *sd number of wells until `y'"

}

* Now the porks



quietly summarize cerdos
generate porksd = (cerdos-r(mean)) / r(sd)
	
gen lw_pork=porksd*lbrent_price

label var lw_pork "log brent price *sd number of porks slaughterd in 1946"




* now the estimations


quietly summarize wells_accum_mpio
generate wells_accum_sd = (wells_accum_mpio -r(mean)) / r(sd)
	
	



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


tempvar control
bys codmpio: egen `control'=max(wells_accum_mpio)
gen pure_control=(`control'==0 )
label var pure_control "mpio without oil in history until 2014"


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


* with oil
	
local rep_app = "replace"
foreach x in  2000 {
		preserve
			drop if w_b_`x'==0 & pure_control==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  enrolment_rate rentseeker_1  uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
				rename `y' outcome
				rename lw_b_`x' v_brent_price
				rename wells_accum_sd wells_accum
				
		

				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(codmpio i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'
				
				reghdfe outcome v_brent_price , absorb(codmpio i.depto##c.c_year i.depto##c.c_year2) 
				estimates store rred_`y'
				
				local rep_app = "append"
				
				rename v_brent_price lw_b_`x'  			
				rename wells_accum wells_accum_sd 
				rename outcome `y'
		
			}
		restore
		}





local appi replace
	foreach x in rred riv {



	esttab  `x'_enrolment_rate    using "${overleaf}/resultados/mpio/clean/pub1", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enrolment_rate}" "\specialcell{`x'_uni_1}" "\specialcell{`x'_uni_2}") ///
	scalars(rkf)  sfmt(0 3)
	
	
	esttab  `x'_rentseeker_1  `x'_uni_1  using "${overleaf}/resultados/mpio/clean/pub2", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
	scalars(rkf)  sfmt(0 3)
	
	
	esttab  `x'_enrolment_rate `x'_rentseeker_1  `x'_uni_1  using "${overleaf}/resultados/mpio/clean/pub3", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
	scalars(rkf)  sfmt(0 3)



	
	local appi append
	
}




* with porks
	
local rep_app = "replace"
foreach x in  2000 {
		preserve
			drop if w_b_`x'==0 & pure_control==0 // drop those that did not have wells in x year but will eventually have (to account for control group contamination)

			foreach y in  enrolment_rate rentseeker_1  uni_1  { //enroled_he rent_seeker universitario deserted timetohe semestertohe
		
				rename `y' outcome
				rename lw_pork v_brent_price
				rename wells_accum_sd wells_accum
				
		

				*second order poly trend
				
				ivreghdfe outcome (wells_accum=v_brent_price) , absorb(codmpio i.depto##c.c_year i.depto##c.c_year2) r
				estimates store riv_`y'
				
				reghdfe outcome v_brent_price , absorb(codmpio i.depto##c.c_year i.depto##c.c_year2) 
				estimates store rred_`y'
				
				local rep_app = "append"
				
				rename v_brent_price lw_pork  			
				rename wells_accum wells_accum_sd 
				rename outcome `y'
		
			}
		restore
		}





local appi replace
	foreach x in rred riv {



	esttab  `x'_enrolment_rate    using "${overleaf}/resultados/mpio/placebo/pub1", `appi' f  ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{`x'_enrolment_rate}" "\specialcell{`x'_uni_1}" "\specialcell{`x'_uni_2}") ///
	scalars(rkf)  sfmt(0 3)
	
	
	esttab  `x'_rentseeker_1  `x'_uni_1  using "${overleaf}/resultados/mpio/placebo/pub2", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
	scalars(rkf)  sfmt(0 3)
	
	
	esttab  `x'_enrolment_rate `x'_rentseeker_1  `x'_uni_1  using "${overleaf}/resultados/mpio/placebo/pub3", `appi' f ///
		label booktabs b(3) p(3) eqlabels(none) alignment(S) noconstant ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle( "\specialcell{Rent}" "\specialcell{`Uni'}" ) ///
	scalars(rkf)  sfmt(0 3)



	
	local appi append
	
}





