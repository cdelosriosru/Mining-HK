**************************************************************************************
* PROJECT :     	Mining - HK
* AUTHOR :			Camilo De Los Rios
* PURPOSE :			Clear and prepare the fiscal data to join with oil wells data
* SOURCE :        	GitHub
**************************************************************************************

      * PATHS
      
global data "C:/Users/camilodel/Desktop/IDB/MINING-HK/DATA"
global fiscal "${data}/Other-muni"
global inst "${data}/Institutional_Index/harmonized"

cd ${fiscal}

	*CREATE AND MERGE DATA

* X=1 -> ingresos totales ; X= 18 -> Ingresos totales per cápita ;  X= 24 -> Gastos totales per cápita ; X= 27 -> Regalías per cápita (Valor efectivamente girado al municipio

import excel "raw/TerriData_Dim7_Sub1_Var1.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad codmpio
rename DatoNumérico income
rename Año year
label var income "Ingresos Totales del Municipio en COP"
sa "raw/income.dta", replace

import excel "raw/TerriData_Dim7_Sub1_Var18.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad codmpio
rename DatoNumérico income_pc
rename Año year
label var income_pc "Ingresos Totales del Municipio per cápita en COP"
sa "raw/income_pc.dta", replace

import excel "raw/TerriData_Dim7_Sub1_Var24.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad codmpio
rename DatoNumérico spend
rename Año year
label var spend "Gastos Totales del Municipio per cápita en COP"
sa "raw/spend.dta", replace

import excel "raw/TerriData_Dim7_Sub1_Var27.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad codmpio
rename DatoNumérico regalias
rename Año year
label var regalias "Per cápita, valor efectivamente girado al municipio"
sa "raw/regalias.dta", replace

use  "raw/regalias.dta", clear
merge 1:1 codmpio year using "raw/income.dta", nogen
merge 1:1 codmpio year using "raw/spend.dta", nogen
merge 1:1 codmpio year using "raw/income_pc.dta", nogen


	*CLEAN DATA

drop if codmpio=="01001" // this is Colombia

gen deptos=substr(codmpio,3,3)
drop if deptos=="000" // these are the states
drop deptos

drop if year==""
destring year, replace

foreach x in income regalias spend income_pc{
replace `x' = subinstr(`x',".", "",.) 
replace `x' = subinstr(`x',",", ".",.)
destring `x', replace 
}

order codmpio year regalias income* spend

destring codmpio, replace
tostring codmpio, replace

* MERGE DIRECT MINING AND HYDROCARBONS ROYALTIES FROM PANEL CEDE. 


merge 1:1 codmpio year using "${inst}/IGA&DNP.dta"  , gen(mer_regal) keepusing(SRAecopetrol_productor SRAecopetrol_puerto ///
SRAanh_regalias_productor SRAanh_regalias_puerto SRAingeominasanh_metal_preciosos SRAminercolcrn_metalespreciosos pobl_tot)


label var SRAecopetrol_productor "1986 - 2004 giros regalias de ecopetrol a productores. COP"
label var SRAecopetrol_puerto "1986 - 2004 giros regalias de ecopetrol a portuarios. COP"

label var SRAanh_regalias_productor "2004 - 2018 giros de la ANH a productores. COP"
label var SRAanh_regalias_puerto "2004 - 2018 giros de la ANH a portuarios. COP"

label var SRAingeominasanh_metal_preciosos "2004 - 2015 Giros de Ingeominas o ANM a extractores de metales preciosos. COP a 2016"

label var SRAminercolcrn_metalespreciosos "1995 - 2006 giros a extractores de metales preciosos. COP"


sa "harm/regalias.dta", replace




