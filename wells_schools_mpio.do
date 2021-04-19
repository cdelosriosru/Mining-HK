/*

	This is going to create the wells measures for schools
	and municipalities alike



*/

* paths

global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global oil "${data}/Petroleo"
global hk "${data}/HK"
global municipios "${data}/PoliticalBoundaries"
global results "${data}/results"
global compiled "${data}/compiled_sets"
global results "C:/Users/cdelo/Dropbox/HK_Extractives_2020/RESULTS"


* create the data base with all the municipalities and schools. this is only because I hate to do recodes and fillins

use "${hk}/harm/hk_colegio.dta", clear

preserve
	sort id_cole year
	bys id_cole: egen firstyear_cole=min(year)
	collapse (first) firstyear_cole, by(id_cole)
	tempfile coles_id
	label var firstyear_cole "First year of data from highschool"
	sa `coles_id'
restore

preserve
	keep id_cole codmpio
	collapse (first) codmpio, by(id_cole)
	tempfile coles_mpio
	sa `coles_mpio'
restore

preserve
	sort id_cole year
	gen years_cole=1
	collapse (first) years_cole, by(id_cole year)
	drop years_cole
	gen a=1
	bys id_cole: egen years_cole=total(a)
	drop a
	collapse (first) years_cole, by(id_cole)
	merge 1:1 id_cole using `coles_id'
	drop _merge
	merge m:1 id_cole using `coles_mpio'
	label var years_cole "Number of year there is data from highschool"
	drop _merge
	sa "${hk}/harm/coles_id.dta", replace
restore

preserve
	gen a=1
	collapse (first) a, by(codmpio)
	sa "${hk}/harm/coles_mpio.dta", replace
restore


/*------------------------------------------------------------------------------


					SCHOOL LEVEL


------------------------------------------------------------------------------*/

use "${data}/compiled_sets/cole_wells_all_bycole.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 
drop lat_cole lon_cole
* First I will make the same cleaning as before. 
rename mpio_cole codmpio
merge m:1 codmpio using "${municipios}/poblacion_mpios.dta", gen (mer_pobl) // there is one municipality code: the 27086 that does not belong to any municipality really. 
drop if pobl_tot>200000
drop if mer_pobl!=3 // the info in the using that has no wells
drop pobl_tot mer_pobl
drop codmpio

* Now, merge with all other school to have every school in your sample when calculating.  
merge m:1 id_cole using "${hk}/harm/coles_id.dta"
drop if _merge==1 // schools that have no time in HK information. Just 116 schools

destring spud, gen(year)
drop if year==111 // 4 observations. This must be some typing error in the source

replace year=firstyear_cole if  _merge==2

drop if year==. // None. I cleaned it in R

collapse (sum) npozos_* (first) spud codmpio years_cole firstyear_cole, by(id_cole year) // its the only info that I need for the moment. The rest will come from merging it with the HK data


*drop if year<1950 // just the really old wells. THIS IS DUMB this gives me really important information. 



fillin id_cole year // to make a balanced panel

foreach x in codmpio years_cole firstyear_cole{
	bys id_cole: egen `x'_2=max(`x')
	replace `x'=`x'_2 if `x'==.
	drop `x'_2
}


unique year
local tope=r(unique)

	/* This measure does not consider the number of years that an oil well might be active. we could have a little bit of dicussion about this in the 
	paper*/

foreach x in 5000 10000 20000 30000 {
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


	*Now I can take into account the "age" of the oil well
	
foreach y in 30 15 {
	foreach x in 5000  10000 20000 30000 {
	gen wells_accum`y'_`x'=.

		forvalues n = 1(1)`tope' {
			cap drop i`n'
			bys id_cole: gen i`n' = 1 if  year[`n']>=year & (year[`n']-year) <= `y'
			bys id_cole: egen pozos`n' = total(npozos_`x') if i`n'==1
			bys id_cole: replace wells_accum`y'_`x' = pozos`n' if mi(wells_accum`y'_`x')
			drop  i`n'
			drop pozos`n'
		}

	label var wells_accum`y'_`x' "Accumulated number of wells until year and `y' yo wells"
	}
}



/* Now my suitability measure comes from the fact that a lot of oil wells have been drilled in a particular region
for this reason I have to consider all the oil wells, regardless of their age. */

foreach x in  5000  10000 20000 30000 {
	foreach y in 1970 1980 1990 2000 2014 { // I could make this longer to do all the robustness checks. 
		gen wells_`y'_`x'=wells_accum_`x' if year==`y'
		sort id_cole wells_`y'_`x'
		bys id_cole: replace wells_`y'_`x'=wells_`y'_`x'[1]
		label var wells_`y'_`x' "Accumulated number of wells until `y' in `x'km buff"
		
	}
}






* The HK data after 2014 has a lot of missings. So I am going to leave it until 2014. 
	

drop if year<2002 | year>2014


foreach x in   5000 10000 20000  30000 {

	recode npozos_`x'(.=0)
	recode wells_accum_`x'(.=0)
	
	foreach y in 30 15 {
		recode wells_accum`y'_`x'(.=0)
	}
	
	foreach y in  1970 1980 1990 2000  2014{
		recode wells_`y'_`x'(.=0)
	}
}


sa "${oil}/harm/wells_measures_cole.dta", replace

/*------------------------------------------------------------------------------


					MUNICIPALITY LEVEL


------------------------------------------------------------------------------*/

use "${oil}/harm/mpio_pozos_all_cleaned.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 
destring codmpio, replace
merge m:1 codmpio using "${hk}/harm/coles_mpio.dta"
drop if _merge==1 // simply mpios without HK info. 


destring spud_y, gen(year)
drop if year==111 // 4 observations. This must be some typing error in the source

replace year=2000 if _merge==2 // for the municiplaities that do not have oil wells. 

drop if year==. // 1063 observations. Simply wells without spud date. Some mpios get out of the sample. 
gen npozos_mpio=1 if spud_y!=""
collapse (sum) npozos_mpio, by(codmpio year) // its the only info that I need for the moment. The rest will come from merging it with the HK data
*drop if year<1950 // just the really old wells. THIS IS DUMB this gives me really important information. 
fillin codmpio year // to make a balanced panel

unique year
local tope=r(unique)


gen wells_accum_mpio=.

forvalues n = 1(1)`tope' {
	cap drop i`n'
	bys codmpio: gen i`n' = 1 if  year[`n']>=year // & (year[`n']-year) <= 50
	bys codmpio: egen pozos`n' = total(npozos_mpio) if i`n'==1
	bys codmpio: replace wells_accum_mpio = pozos`n' if mi(wells_accum_mpio)
	drop  i`n'
	drop pozos`n'
}

label var wells_accum_mpio "Accumulated number of wells until year in mpio"
label var npozos_mpio "Number of wells drilled in that year in mpio"

foreach y in 30 15 {
	gen wells_accum`y'_mpio=.
	forvalues n = 1(1)`tope' {
		cap drop i`n'
		bys codmpio: gen i`n' = 1 if  year[`n']>=year & (year[`n']-year) <= `y'
		bys codmpio: egen pozos`n' = total(npozos_mpio) if i`n'==1
		bys codmpio: replace wells_accum`y'_mpio = pozos`n' if mi(wells_accum`y'_mpio)
		drop  i`n'
		drop pozos`n'
	}
	label var wells_accum`y'_mpio "Accumulated number of wells until year and `y' yo wells in mpio"
}


/* Now my suitability measure comes from the fact that a lot of oil wells have been drilled in a particular region
for this reason I have to consider all the oil wells, regardless of their age. */


forvalues y=1970(10)2000{

		gen wells_`y'_mpio=wells_accum_mpio if year==`y'
		sort codmpio wells_`y'_mpio
		bys codmpio: replace wells_`y'_mpio=wells_`y'_mpio[1]
		label var wells_`y'_mpio "Accumulated number of wells until `y' in mpio"
	}	


drop if year<2002 | year>2014
destring codmpio, replace

* just in case

foreach x in  mpio{

	recode npozos_`x'(.=0)
	recode wells_accum_`x'(.=0)
	
	foreach y in 30 15 {
		recode wells_accum`y'_`x'(.=0)
	}
	
	foreach y in 1970 1980 1990 2000{
		recode wells_`y'_`x'(.=0)
	}
}

unique codmpio

sa "${oil}/harm/wells_measures_mpio.dta", replace
use "${oil}/harm/wells_measures_mpio.dta", clear

forvalues x=20000{

unique codmpio if npozos_mpio>0 & wells_2001_mpio>0

}


*merge 1:1 codmpio year using "${data}/compiled_sets/wells_cole_merge_mpio"

/*

/*

							EXTRA BUFFERS

*/


* create the data base with all the municipalities and schools. this is only because I hate to do recodes and fillins

use "${hk}/harm/hk_colegio.dta", clear

preserve
	sort id_cole year
	bys id_cole: egen firstyear_cole=min(year)
	collapse (first) firstyear_cole, by(id_cole)
	tempfile coles_id
	label var firstyear_cole "First year of data from highschool"
	sa `coles_id'
restore

preserve
	keep id_cole codmpio
	collapse (first) codmpio, by(id_cole)
	tempfile coles_mpio
	sa `coles_mpio'
restore

preserve
	sort id_cole year
	gen years_cole=1
	collapse (first) years_cole, by(id_cole year)
	drop years_cole
	gen a=1
	bys id_cole: egen years_cole=total(a)
	drop a
	collapse (first) years_cole, by(id_cole)
	merge 1:1 id_cole using `coles_id'
	drop _merge
	merge m:1 id_cole using `coles_mpio'
	label var years_cole "Number of year there is data from highschool"
	drop _merge
	sa "${hk}/harm/coles_id.dta", replace
restore

preserve
	gen a=1
	collapse (first) a, by(codmpio)
	sa "${hk}/harm/coles_mpio.dta", replace
restore




use "${data}/compiled_sets/cole_wells_all_bycole_extra.dta", clear // remember that this data has information on the mpio where wells are located!!! I will use that information to calculate a royalty weight. But I dont need it now. 
drop lat_cole lon_cole
* First I will make the same cleaning as before. 
rename mpio_cole codmpio
merge m:1 codmpio using "${municipios}/poblacion_mpios.dta", gen (mer_pobl) // there is one municipality code: the 27086 that does not belong to any municipality really. 
drop if pobl_tot>200000
drop if mer_pobl!=3 // the info in the using that has no wells
drop pobl_tot mer_pobl
drop codmpio

* Now, merge with all other school to have every school in your sample when calculating.  
merge m:1 id_cole using "${hk}/harm/coles_id.dta"
drop if _merge==1 // schools that have no time in HK information. Just 116 schools

destring spud, gen(year)
drop if year==111 // 4 observations. This must be some typing error in the source

replace year=firstyear_cole if  _merge==2

drop if year==. // None. I cleaned it in R

collapse (sum) npozos_* (first) spud codmpio years_cole firstyear_cole, by(id_cole year) // its the only info that I need for the moment. The rest will come from merging it with the HK data


*drop if year<1950 // just the really old wells. THIS IS DUMB this gives me really important information. 



fillin id_cole year // to make a balanced panel

foreach x in codmpio years_cole firstyear_cole{
	bys id_cole: egen `x'_2=max(`x')
	replace `x'=`x'_2 if `x'==.
	drop `x'_2
}


unique year
local tope=r(unique)

foreach x in 7500 12500 15000 17500{
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

foreach x in  7500 12500 15000 17500{
	foreach y in 1980 1990 2000 2001 2014 { // I could make this longer to do all the robustness checks. 
		gen wells_`y'_`x'=wells_accum_`x' if year==`y'
		sort id_cole wells_`y'_`x'
		bys id_cole: replace wells_`y'_`x'=wells_`y'_`x'[1]
		label var wells_`y'_`x' "Accumulated number of wells until `y' in `x'km buff"
		
	}
}

drop if year<2002 | year>2014


foreach x in  7500 12500 15000 17500{
	recode npozos_`x'(.=0)
	recode wells_accum_`x'(.=0)
	
	foreach y in 1980 1990 2000 2001 2014{
		recode wells_`y'_`x'(.=0)
	}
}


sa "${oil}/harm/wells_measures_cole_extra.dta", replace





