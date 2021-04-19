**************************************************************************************
* PROJECT :     	Mining - HK
* AUTHOR :			Camilo De Los Rios
* PURPOSE :			Clear and prepare the fiscal data to join with oil wells data
* SOURCE :        	GitHub
**************************************************************************************

      * PATHS
      
global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global fiscal "${data}/Other-muni"
global inst "${data}/Institutional_Index/harmonized"
global reg_anh "${data}/Regalias_Produccion_ANH"
global codmu "${data}/PoliticalBoundaries"

	*Getting data from FUT. I downloaded this information from TERRIDATA. 

* X=1 -> ingresos totales ; X= 18 -> Ingresos totales per cápita ;  X= 24 -> Gastos totales per cápita ; X= 27 -> Regalías per cápita (Valor efectivamente girado al municipio; x=3 -> ingresos tributarios

import excel "${fiscal}/raw/TerriData_Dim7_Sub1_Var1.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad codmpio
rename DatoNumérico income
rename Año year
label var income "Ingresos Totales del Municipio en COP"
tempfile income
sa `income'

import excel "${fiscal}/raw/TerriData_Dim7_Sub1_Var18.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad codmpio
rename DatoNumérico income_pc
rename Año year
label var income_pc "Ingresos Totales del Municipio per cápita en COP"

tempfile income_pc
sa `income_pc'

import excel "${fiscal}/raw/TerriData_Dim7_Sub1_Var24.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad codmpio
rename DatoNumérico spend
rename Año year
label var spend "Gastos Totales del Municipio per cápita en COP"
tempfile spend
sa `spend'


import excel "${fiscal}/raw/TerriData_Dim7_Sub1_Var3.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad codmpio
rename DatoNumérico ing_trib
rename Año year
label var ing_trib "Ingresos tributarios"
tempfile ing_trib
sa `ing_trib'

import excel "${fiscal}/raw/TerriData_Dim7_Sub1_Var6.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad codmpio
rename DatoNumérico spend_tot
rename Año year
label var spend_tot "Gastos Totales"
tempfile spend_tot
sa `spend_tot'


import excel "${fiscal}/raw/TerriData_Dim7_Sub1_Var27.xlsx", sheet ("Datos") firstrow clear
keep CódigoEntidad DatoNumérico Año 
rename CódigoEntidad codmpio
rename DatoNumérico regalias
rename Año year
label var regalias "Per cápita, valor efectivamente girado al municipio"
tempfile regalias
sa `regalias'

use  `regalias', clear
merge 1:1 codmpio year using `income', nogen
merge 1:1 codmpio year using `spend', nogen
merge 1:1 codmpio year using `income_pc', nogen
merge 1:1 codmpio year using `ing_trib', nogen
merge 1:1 codmpio year using `spend_tot', nogen


	*CLEAN DATA

drop if codmpio=="01001" // this is Colombia

gen deptos=substr(codmpio,3,3)
drop if deptos=="000" // these are the states
drop deptos

drop if year==""
destring year, replace

foreach x in income regalias spend income_pc ing_trib spend_tot{ // data comes from excel with commas. I prefer to fix that here. 
replace `x' = subinstr(`x',".", "",.) 
replace `x' = subinstr(`x',",", ".",.)
destring `x', replace 
}
foreach x in income ing_trib spend_tot{ // data comes from excel with commas. I prefer to fix that here. 
replace `x'=`x'*1000000 // la variable estaba en millones de pesos. 
}
order codmpio year regalias income* spend

destring codmpio, replace
tostring codmpio, replace

* MERGE DIRECT MINING AND HYDROCARBONS ROYALTIES FROM PANEL CEDE. 


merge 1:1 codmpio year using "${inst}/IGA&DNP.dta"  , gen(mer_regal) keepusing(SGR_total SGR_adirectas SGR_adirectas_minera SGR_adirectas_hidrocarburos SRAecopetrol_productor SRAecopetrol_puerto SRAanh_regalias_productor SRAanh_regalias_puerto SRAcarbocol_minercolcrn_carbon SRAminercolcrn_metalespreciosos SRAminercolcnr_esmeraldas SRAminercolcnr_niquel SRAingeominasanh_carbon SRAingeominasanh_esmeraldas SRAingeominasanh_metal_preciosos SRAingeominasanh_niquel SRAingeominasanh_hierro SRAingeominasanh_sal SRAingeominasanh_yeso SRAingeominasanh_minerales_otros SRAingeominasanh_giros_totales SRAingeominasanh_rendimientos)

/*
						use this afterwards when cleaning data. 

Las variables SRAecopetrol_productor y SRAecopetrol_puerto corresponden a los giros de Ecopetrol entre 1986 y 2003. Se distingue entre los municipios productores de hidrocarburos y los que funcionaban como puertos para transportar los recursos naturales explotados. Los giros del año 2004 corresponden a liquidaciones de 2003.
*/


label var SGR_total							"Total transferencias en SGR.T:12,13,15,17"
label var SGR_adirectas						"Asignaciones Directas del SGR.T:12,13,15,17 "
label var SGR_adirectas_minera				"Asignaciones Directas Mineras del SGR.T:12,13,15,17 "		
label var SGR_adirectas_hidrocarburos		"Asignaciones Directas Hidrocarburos del SGR.T:12,13,15,17 "
label var SRAecopetrol_productor			"giros ecopetrol a productores. 1896-2004"
label var SRAecopetrol_puerto				"giros ecopetrol a portuarios. 1896-2004"
label var SRAanh_regalias_productor			"giros ANH a productores. 2004-2018"
label var SRAanh_regalias_puerto			"giros ANH a portuarios. 2004-2018"
label var SRAcarbocol_minercolcrn_carbon	"giros por carbón. 1996-2006"
label var SRAminercolcrn_metalespreciosos	"giros por metales preciosos. 1996-2006"
label var SRAminercolcnr_esmeraldas			"giros por esmeraldas. 1996-2005"
label var SRAminercolcnr_niquel				"giros por niquel. 1996-2004"
label var SRAingeominasanh_carbon			"giros por carbón. 2004-2015"
label var SRAingeominasanh_esmeraldas		"giros por esmeraldas. 2004-2016"
label var SRAingeominasanh_metal_preciosos 	"giros por metales preciosos. 2004-2015"
label var SRAingeominasanh_niquel			"giros por niquel. 2004-2015"
label var SRAingeominasanh_hierro			"giros por hierro. 2004-2014"
label var SRAingeominasanh_sal				"giros por sal. 2007-2015"
label var SRAingeominasanh_yeso				"giros por yeso. 2007-2016"
label var SRAingeominasanh_minerales_otros	"giros por otros minerales. 2005-2015"
label var SRAingeominasanh_giros_totales	"giros totales por minería. 2004-2016"
label var SRAingeominasanh_rendimientos		"giros de rendimientos de minería. 2005-2016"



sa "${fiscal}/harm/regalias.dta", replace


* Correct the royalties of ecopetrol for 2003


keep codmpio year SRAecopetrol_productor SRAecopetrol_puerto
keep if year==2003 | year==2004
tempfile regalias_ecop
foreach x in SRAecopetrol_productor SRAecopetrol_puerto{
bys codmpio: egen `x'_cam=total(`x')
replace `x'_cam=. if year==2004 
*drop `x'
}

sa `regalias_ecop'

use "${fiscal}/harm/regalias.dta", clear

merge 1:1 codmpio year using `regalias_ecop', nogen

foreach x in SRAecopetrol_productor SRAecopetrol_puerto{
replace `x'_cam=`x' if year!=2003 & year!=2004
}


* Create som variables that you can use

egen oil_producers = rowtotal(SRAanh_regalias_productor SRAecopetrol_productor) // I'd smply use this one. 
egen oil_producers2 = rowtotal(SRAanh_regalias_productor SRAecopetrol_productor_cam) 

egen oil_puertos = rowtotal(SRAanh_regalias_puerto SRAecopetrol_puerto) // I'd smply use this one. 
egen oil_puertos2 = rowtotal(SRAanh_regalias_puerto SRAecopetrol_puerto_cam) 


egen mining = rowtotal(SRAminercolcnr_niquel SRAminercolcnr_esmeraldas SRAminercolcrn_metalespreciosos SRAcarbocol_minercolcrn_carbon SRAingeominasanh_giros_totales SRAingeominasanh_rendimientos)

egen mining_preciosos = rowtotal( SRAminercolcrn_metalespreciosos SRAingeominasanh_metal_preciosos  )

destring codmpio, replace

sa, replace



* Now, I downloades the Royalties from the ANH. That is a much more reliable source and I trust it more. 


forvalues x=2010(1)2019{
	import excel "${reg_anh}/raw/r_`x'.xlsx", sheet("Produccion y Regalias x C") firstrow clear 
	sa "${reg_anh}/raw/r_`x'.dta", replace
}

use "${reg_anh}/raw/r_2010.dta", clear

forvalues x=2011(1)2019{
	append using  "${reg_anh}/raw/r_`x'.dta"
}
rename Anio year
sa "${reg_anh}/harm/reg_anh.dta", replace

/*
			Now I will merge this data with the other royalties data to have a comlete data set on oil royalties. The data compiledIfby the CEDE is not so aquarate (or so it seems) and I need the royalties to make our trends and royalties control. 
			


*/


* there are some 


use "${reg_anh}/harm/reg_anh.dta", clear

collapse (first) year, by(Departamento Municipio)
rename Departamento departamento
rename Municipio mpio
sort departamento mpio
gen id_anh=_n
reclink departamento mpio using "${codmu}/cod_DANE.dta", idm(id_anh) idu(codmpio) gen(elmatch)
drop if _merge==1
br if elmatch!=1 // al matches are good excep the one from Sincé, Sucre. Changed that manually to codmpio=70742
replace codmpio="70742" if mpio=="SINCE" & departamento=="SUCRE"
keep departamento mpio codmpio 
tempfile municipios_code
sa `municipios_code'

use "${reg_anh}/harm/reg_anh.dta", clear
rename Departamento departamento
rename Municipio mpio
merge m:1 departamento mpio using `municipios_code'
drop if _merge!=3 // these are non identified municipalities. 
drop _merge
destring codmpio, replace
collapse (sum) ProdGravableBlsKpc RegaliasCOP, by(codmpio departamento mpio year)
rename ProdGravableBlsKpc produccion_anh
label var produccion_anh "producción petrolera en el municipio segun los datos de la anh. " 
rename RegaliasCOP regalias_anh
label var regalias_anh "regalias petroleras por produccion en el municipio segun los datos de la anh. " 

merge 1:1 year codmpio using "${fiscal}/harm/regalias.dta"
drop _merge

gen regalias_oil_producers=regalias_anh
replace regalias_oil_producers=oil_producers if regalias_oil_producers==. // this improves the number of obsrevations after 2010.

sa "${reg_anh}/harm/reg_anh.dta", replace // this is the actual data that I should use for the estimations. 








