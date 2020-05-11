**************************************************************************************
* PROJECT :     	Mining - HK
* AUTHOR :			Camilo De Los Rios
* PURPOSE :			Clear and prepare the fiscal data to join with oil wells data
* SOURCE :        	GitHub
**************************************************************************************

      * PATHS
      
global data "C:/Users/camilodel/Desktop/IDB/MINING-HK/DATA"
global fiscal "${data}/Other-muni"

cd ${fiscal}

	*CREATE AND MERGE DATA

* X= 18 -> Ingresos totales per cápita ;  X= 24 -> Gastos totales per cápita ; X= 27 -> Regalías per cápita (Valor efectivamente girado al municipio
import excel "raw/TerriData_Dim7_Sub1_Var18.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad cod_mpio
rename DatoNumérico income
rename Año year
label var income "Ingresos Totales del Municipio per cápita en COP"
sa "raw/income.dta", replace

import excel "raw/TerriData_Dim7_Sub1_Var24.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad cod_mpio
rename DatoNumérico spend
rename Año year
label var spend "Gastos Totales del Municipio per cápita en COP"
sa "raw/spend.dta", replace

import excel "raw/TerriData_Dim7_Sub1_Var27.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad cod_mpio
rename DatoNumérico regalias
rename Año year
label var regalias "Per cápita, valor efectivamente girado al municipio"
sa "raw/regalias.dta", replace

use  "raw/regalias.dta", clear
merge 1:1 cod_mpio year using "raw/income.dta", nogen
merge 1:1 cod_mpio year using "raw/spend.dta", nogen


	*CLEAN DATA

drop if cod_mpio=="01001" // this is Colombia

gen deptos=substr(cod_mpio,3,3)
drop if deptos=="000" // these are the states
drop deptos

drop if year==""
destring year, replace

foreach x in income regalias spend{
replace `x' = subinstr(`x',".", "",.) 
replace `x' = subinstr(`x',",", ".",.)
destring `x', replace 
}

order cod_mpio year regalias income spend

sa "harm/regalias.dta", replace




