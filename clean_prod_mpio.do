
/*

 PROJECT :     	Mining - HK
 AUTHOR :			Camilo De Los Rios
 PURPOSE :			Producción municipal. 

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
global prodcamp "${data}/Produccion_campos/"


/*------------------------------------------------------------------------------

 First create the oil wells_ for Schools and merge with schools hk 

------------------------------------------------------------------------------*/

forvalues x=2011(1)2016{

	import excel "${prodcamp}/raw/definitiva_`x'", sheet("Produccion y Regalias x C") firstrow case(lower) clear
	keep if tipohidrocarburo=="O"
	collapse (sum) prodgravableblskpc, by(departamento municipio)
	gen year=`x'
	rename prodgravableblskpc prod_mpio
	label var prod_mpio "prodgravableblskpc"
	sa "${prodcamp}/raw/definitiva_`x'.dta", replace

}

use "${prodcamp}/raw/definitiva_2011.dta", clear
forvalues x=2012(1)2016{

	append using "${prodcamp}/raw/definitiva_`x'.dta"
}

replace departamento="N. DE SANTANDER" if departamento=="NORTE DE SANTANDER"
tab municipio



replace municipio="PURIFICACION" if municipio=="PURIFICACIÓN"
replace municipio="PUERTO GUZMAN" if municipio=="PUERTO GUZMÁN"
replace municipio="SAN MARTIN" if municipio=="SAN MARTÍN"
replace municipio="CASTILLA LA NUEVA" if municipio=="CASTILLA NUEVA"
replace municipio="MOMPOX" if municipio=="MOMPOS"
replace municipio="PIJIÑO DEL CARMEN" if municipio=="PIJINO DEL CARMEN"
replace municipio="SAN CARLOS DE GUAROA" if municipio=="SAN CAARLOS GUAROA"
replace municipio="SAN JOSE DEL FRAGUA" if municipio=="SAN JOSE DE FRAGUA"
replace municipio="VILLANUEVA" if municipio=="VILLA NUEVA"
replace municipio="VISTAHERMOSA" if municipio=="VISTA HERMOSA"

* add municipality codes
rename municipio mpio
merge m:1 departamento mpio using "${municipios}/cod_DANE.dta", keep(2 3) // Some mpios in the original data base are non-existent or labeles as "unknown"
destring codmpio, replace
drop _merge
replace year=2011 if year==.
tsset codmpio year
tsfill, full
recode prod_mpio(.=0)

bys codmpio: egen prom_prod_mpio=mean(prod_mpio)
gen prom_prod_mpio2=prom_prod_mpio
recode prom_prod_mpio2(0=.)

sa "${prodcamp}/harm/prod_oil_mpio.dta", replace












