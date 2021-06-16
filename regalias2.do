/*------------------------------------------------------------------------------
Objective: create descriptive stats and context graphs
-------------------------------------------------------------------------------*/

clear all
cls
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

 Fixing the ANH royalties that I got from the webpage for 2004-2011.


*/

use "${oil}/reg_anh.dta", replace
replace regalias_prod="." if regalias_prod=="" | regalias_prod=="-"
destring regalias_prod, replace
sa, replace


* now create the dta from the other data. 

forvalues x=2011(1)2016{

	import excel "${oil}/Produccion_campos/definitiva_`x'.xlsx", sheet("Produccion y Regalias x C") firstrow clear

	rename Anio year
	rename Municipio mpio
	rename Departamento dpto
	rename RegaliasCOP regalias
	
	collapse (sum) regalias, by(year mpio dpto)
	
	tempfile reg_`x'
	sa `reg_`x''

}


use `reg_2011'
forvalues x=2012(1)2016{
	append using `reg_`x''
}

replace dpto="N. DE SANTANDER" if dpto=="NORTE DE SANTANDER"
drop if dpto=="DEPARTAMENTO NN"

replace mpio="MOMPOX" if mpio=="MOMPOS"
replace mpio="SAN JOSE DEL FRAGUA" if mpio=="SAN JOSE DE FRAGUA"
replace mpio="VILLANUEVA" if mpio=="VILLA NUEVA"
replace mpio="LA JAGUA DE IBIRICO" if mpio=="LA JAGUA IBIRICO"
replace mpio="SAN MARTIN" if mpio=="SAN MARTÍN"
replace mpio="PIJIÑO DEL CARMEN" if mpio=="PIJINO DEL CARMEN"
replace mpio="CASTILLA LA NUEVA" if mpio=="CASTILLA NUEVA"
replace mpio="SAN CARLOS DE GUAROA" if mpio=="SAN CAARLOS GUAROA"
replace mpio="SAN MARTIN" if mpio=="SAN MARTIN"
replace mpio="VISTAHERMOSA" if mpio=="VISTA HERMOSA"
replace mpio="PUERTO GUZMAN" if mpio=="PUERTO GUZMÁN"
replace mpio="PURIFICACION" if mpio=="PURIFICACIÓN"


replace dpto="LA GUAJIRA" if dpto=="GUAJIRA"


rename dpto departamento 


merge m:1 departamento mpio using  "${municipios}/cod_DANE.dta", keep(3) nogen

destring codmpio, replace

merge 1:1 codmpio year using "${oil}/reg_anh.dta"

replace regalias=regalias_prod if year<2012

keep codmpio year regalias

sa "${oil}/harm/regalias_definitivas.dta", replace











