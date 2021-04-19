/*

 PROJECT :     	Mining - HK
 AUTHOR :			Camilo De Los Rios
 PURPOSE :			Create a quick perspective of salaries in the sector. using EAM

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
global eam "${data}/EAM"


/*------------------------------------------------------------------------------

								Merging all EAM
------------------------------------------------------------------------------*/

forvalues x=2002(1)2011{
	use "${eam}/raw/EAM_`x'.dta", clear
	ren *, lower
	destring ciiu3, replace
	rename periodo year
	destring periodo, replace
	sa, replace
}

use "${eam}/raw/EAM_`x'.dta", clear

forvalues x=200(1)2011{
	append using "${eam}/raw/EAM_`x'.dta"
}








gen ciiu_rev4c=substr(ciiu_rev4,1,4)
drop ciiu_rev4
rename ciiu_rev4c ciiu_rev4
destring ciiu_rev4, replace
drop if ciiu_rev4==.
sa "${eam}/correlativas_3_4.dta", replace

/*
			Create clean EAM
*/

use "${eam}/EAM_2008.dta", clear
ren * ,lower
sa, replace
use "${eam}/EAM_2009.dta", clear
ren * ,lower
sa, replace
use "${eam}/EAM_2010.dta", clear
ren * ,lower
sa, replace
use "${eam}/EAM_2011.dta", clear
ren * ,lower
sa, replace
use "${eam}/EAM_2012.dta", clear
ren * ,lower
capture rename ciiu_4 ciiu4
sa, replace
use "${eam}/EAM_2013.dta", clear
ren * ,lower
capture rename ciiu_4 ciiu4
sa, replace


*  Use correlatives to give the appropiate ciiu_3 code to EAM 2012 & 2013. 

foreach x in 2012 2013{
	use "${eam}/EAM_`x'.dta", clear
		foreach y in eelec fuelv totalv consmate valqcons activfi c7c3r3 c7c2r5 c7c7r5 c7r6c2{
			gen `y'perpro=`y'*100/valvfab
		}
	gen activfi2=activfi
	gen eelec2=eelec
	
	gen rate1=(activfi/persocu)*100
	gen rate2=(activfi/pertotal)*100

	
	foreach z in c4r1c9n c4r1c10n c4r2c9e c4r2c10e c4r5c1 c4r5c2 c4r5c3 c4r5c4 c4r4c9t c4r4c10t invebrta activfi persocu valagri eelec fuelv totalv consmate c3r42c3 c5r1c4{
		
		gen met`z'=`z'
		gen m5e`z'=`z'

	}

	
	
	
	collapse (sum)  pertotal pertem3 persoesc pperytem c4r1c9n c4r1c10n c4r2c9e c4r2c10e c4r5c1 c4r5c2 c4r5c3 c4r5c4 c4r4c9t c4r4c10t invebrta activfi persocu valagri eelec fuelv totalv consmate c3r42c3 c5r1c4  (mean) rate* met* (p50) m5e* , by(ciiu4 periodo)

	rename ciiu4 ciiu_rev4
	merge 1:m ciiu_rev4 using "${eam}/correlativas_3_4.dta", gen(_mergeciiu4) 
		drop if _mergeciiu4==2 // estos simplemente no están en la EAM; los que son igual a 1 simplemente, se quedaron constantes entre rev_3 y rev_4. 
	replace ciiu_rev3=ciiu_rev4 if ciiu_rev3==. // done. 
	rename ciiu_rev3 ciiu3