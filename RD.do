/*

	Objective: Use the SRD to try and prove that the mechanism is not money, but rather the regional markets
	Author: CDR




*/

global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global oil "${data}/Petroleo"
global hk "${data}/HK"
global municipios "${data}/PoliticalBoundaries"
global results "${data}/results"
global compiled "${data}/compiled_sets"
global results "C:/Users/cdelo/Dropbox/HK_Extractives_2020/RESULTS"
global overleaf "C:/Users/cdelo/Dropbox/Apps/Overleaf/Oil - HK - Colombia"

* First: import mpios wells information. 

use "${oil}/harm/wells_measures_mpio.dta", clear 

* Create var for group with wells in 2000

gen wells_2000=1 if wells_2000_mpio==0
recode wells_2000(.=0)
label var wells_2000 "1 mpio without oil in history until 2000"

*Create var for group that never had wells. 

tempvar control
bys codmpio: egen `control'=max(wells_accum_mpio)
gen wells_never=(`control'==0 )
label var wells_never "1 mpio without oil in history until 2014"

* at the mpio level

collapse (max) wells_never wells_2000, by(codmpio)

sa "${data}/RD/boundaries.dta", replace

* now in R for the merge with the SHP, buffer, distance, intersection,etc.

* back here for estimation


* Schools have two mpios codes. One, according to their geolocation, the other one according to the data


use "${data}/RD/colegios_ids_mpios.dta", clear

gen codmpio_geo=DPTO_CCDGO+MPIO_CCDGO
destring codmpio_geo, replace
rename mpio codmpio_dta


keep id_cole lat_cole lon_cole codmpio_dta ID_cam codmpio_geo coords_x1 coords_x2


* merge with border distance data

merge 1:1 ID_cam coords_x1 coords_x2 using "${data}/RD/dis_never.dta"
keep if _merge==3
drop _merge

merge 1:1 ID_cam coords_x1 coords_x2 using "${data}/RD/dis_2000.dta"
keep if _merge==3
drop _merge


* merge with data on treatment status. First with mpio geocoded. 


rename codmpio_geo codmpio
merge m:1 codmpio using "${data}/RD/boundaries.dta"
rename codmpio codmpio_geo
keep if _merge==3 // if ==1, then it must be that the mpio in data base of school does not have any geocoded school there. If ==2 it must be that the mpio had schools in data base but not geocoded there. Either typos un writing mpio or in geocoding. Either way, cant solve it, simply drop it and pray. 
drop _merge 

* This data is actualy really versatile. I only need to merge it with either HK_school or HK_individual to make the RD at bpth levels. 

* merge at the school level 

merge 1:m id_cole using "${hk}/harm/hk_colegio.dta"
keep if _merge==3 // the rest must have been droped when merging with treatments
drop _merge




* turning negative distances of schools in control areas
replace dis_never=-1*dis_never if wells_never==1
replace dis_2000=-1*dis_2000 if wells_2000==1


gen civar="5000"
gen civar2=5000
rdrobust rentseeker_1 dis_2000, h(5000)
 rdmcplot enrolment_rate dis_never, cvar(civar2) 
 
 rdrobust codmpio_geo dis_never, h(5000) 

 
 rdplot enrolment_rate dis_never, h(2000) if dis_never>-2000 & dis_never<2000
2