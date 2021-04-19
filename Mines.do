/*

Objective: this dofile is going to create a clean data set with the number of mines in the buffer of the school



*/

global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global oil "${data}/Petroleo"
global mines "${data}/Violencia/harm"
global hk "${data}/HK"
global municipios "${data}/PoliticalBoundaries"
global results "${data}/results"
global compiled "${data}/compiled_sets"
global results "C:/Users/cdelo/Dropbox/HK_Extractives_2020/RESULTS"


* Collapse data bases.

foreach x in DESMIL INCAUTA MAP MUSE OTROS SOSP{

	use "${mines}/cole_`x'_all.dta", clear
	rename a_o year
	collapse (sum) `x'_*, by(id_cole year)

	sa "${mines}/cole_`x'_allc.dta", replace

}

* Merge data bases

use "${mines}/cole_MAP_allc.dta", clear

foreach x in DESMIL INCAUTA MAP MUSE OTROS SOSP{
	merge 1:1 year id_cole using "${mines}/cole_`x'_allc.dta", gen(mer_`x')
}

* give labels

foreach x in 5000 10000 15000 20000{

	replace OTROS_`x'=OTROS_`x'-SOSP_`x' 

	label var MAP_`x' "Minas Anti Personas en buffer `x' "
	label var MUSE_`x' "Accidente por Municiones sin Explosionar en buffer `x' "
	label var DESMIL_`x' "Desminado Militar en operaciones en buffer `x' "
	label var INCAUTA_`x' "Incautaciones en buffer `x' "
	label var SOSP_`x' "Sospecha de Campo Minado en buffer `x' "
	label var OTROS_`x' "Arsenal almacenado, Municiones sin Explotar, Fábrica de MAP en buffer `x' "

}

*recode 

foreach y in 5000 10000 15000 20000{

	foreach x in DESMIL INCAUTA MAP MUSE OTROS SOSP{

		recode `x'_`y'(.=0)

	}

}


sa "${mines}/cole_minas_antipersonas.dta", replace


/*------------------------------------------------------------------------------
							MUNICIPALITY LEVEL
------------------------------------------------------------------------------*/


* Collapse data bases.


use "${compiled}/mpio_MPA_all.dta", clear
rename a_o year
gen codmpio=substr(admin2Pcod,3,5) 
collapse (sum) MAP, by(codmpio year)
destring codmpio, replace

sa "${mines}/mpio_minas_antipersonas.dta", replace