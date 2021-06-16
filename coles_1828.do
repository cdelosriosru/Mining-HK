use "${compiled}/hk_oilwells_colegio_mines.dta", clear 
drop _*


foreach x in  17 18  28 29 {

	local y = `x'-1
	gen entra`x'=(wells_accum`y'_10000==0 &  wells_accum`x'_10000>0)
	bys id_cole: egen max`x'=max(entra`x')
*	bys id_cole: egen min`x'=min(entra`x')

}





foreach x in 17 18  28 29{

preserve
	collapse (max) max`x', by(id_cole)
	keep if max`x'==1
	tempfile coles`x'
	sa `coles`x''
restore
}

foreach x in 17 28 {
	use `coles`x'', clear
	local y = `x'+1
	merge 1:1 id_cole using `coles`y'' // los que entran en el 18 que no entraron en el 17 o los que entran en el 29 que no entraron en el 28


	keep if _merge==2
	keep id_cole max`x'
	

	sa "${compiled}/coles`x'`y'.dta", replace

}


****************************+


use "${compiled}/hk_oilwells_colegio_mines.dta", clear 
drop _*


forvalues x=17(1)28 {

	local y = `x'-1
	gen entra`x'=(wells_accum`y'_10000==0 &  wells_accum`x'_10000>0)
	bys id_cole: egen max`x'=max(entra`x')
*	bys id_cole: egen min`x'=min(entra`x')

}





forvalues x=17(1)28 {

preserve
	collapse (max) max`x', by(id_cole)
	keep if max`x'==1
	tempfile coles`x'
	sa `coles`x''
restore
}

forvalues x=17(1)27 {
	use `coles`x'', clear
	local y = `x'+1
	merge 1:1 id_cole using `coles`y'' // los que entran en el 18 que no entraron en el 17 o los que entran en el 29 que no entraron en el 28

	keep if _merge==2
	keep id_cole max`x'	

	tempfile coles`x'
	
	sa  `coles`x''
}

 use `coles17', replace

forvalues x=17(1)27 {

	append using `coles`x''
 
 
}

gen cole=1
collapse (sum) cole, by(id_cole)
sa "${compiled}/coles1828.dta", replace


* Identifying the compliant group?
use "${compiled}/hk_oilwells_colegio_mines.dta", clear 
drop _*

capture drop compliance
reghdfe wells_accum18_10000  MAP_10000  w_b_2000_10000 , absorb(id_cole i.depto##c.c_year i.depto##c.c_year2) vce(r)
predict compliance, xb

capture drop compliance
reg wells_accum18_10000   w_b_2000_10000 , vce(r)
predict compliance, xb

sum compliance if wells_accum18_10000==0





