**************************************************************************************

* PROJECT :     	Mining - HK
* AUTHOR :			Camilo De Los Rios
* PURPOSE :			Quick analysis of wells in Colombia


**************************************************************************************

      * PATHS
      
global data "C:/Users/camilodel/Desktop/IDB/MINING-HK/DATA"
global tit_min "${data}/Mineria/titulos_colombia/harm"
global oil "${data}/Petroleo/harm"
global fiscal "${data}/Other-muni/harm"
global inst "${data}/Institutional_Index/harmonized"

	* Oil Wells
use "${oil}/mpio_pozos_all_cleaned.dta", clear
gen wells_y=1 
collapse (sum) wells_y, by(codmpio spud_y)
destring spud_y, replace
drop if spud_y<2000
collapse (sum) wells_y, by(codmpio)
tempfile wells_collapsed
sa `wells_collapsed'

use "${fiscal}/regalias.dta", clear
merge m:1 codmpio using `wells_collapsed', gen(w_y)
label var wells_y "Number of wells drilled since 2000"



* Now merge it with the other measures to try to make it hiper clear what I have i this regard 

merge m:1 codmpio using "${data}/full-harm/water_mine_oil_geo_prod.dta", gen(mer_all) keepusing(fecha_int_t_08 fecha_int_t_10 fecha_int_t_17 fecha_int_oil_20 ///
fecha_cent_oil_20 fecha_int_oil_19 fecha_cent_oil_19)
drop if mer_all==2 //these are municipalities mainly in the Amazon and Vaupes. San Andres is also there

* Now merge some data from the PANEL CEDE where all the regalias are saved. THIS I PASSED TO THE CODE FROM REGALIAS DUH!

merge 1:1 codmpio year using "${inst}/IGA&DNP.dta"  , gen(mer_regal) keepusing(SRAecopetrol_productor SRAecopetrol_puerto ///
SRAanh_regalias_productor SRAanh_regalias_puerto SRAingeominasanh_metal_preciosos DI_desemp_int IGA_total)



* now dependence variables. 

gen depend_regalias_h=100*SRAanh_regalias_productor/income
bys codmpio: egen mean_depend_h=mean(depend_regalias_h)

gen depend_regalias_o=100*SRAingeominasanh_metal_preciosos/income
bys codmpio: egen mean_depend_o=mean(depend_regalias_o)

* Institutional ones
bys codmpio: egen mean_desem=mean(DI_desemp_int)
bys codmpio: egen mean_iga=mean(IGA_total)



* collapse at the municipality level* // this is to make a broad measure and have an idea.


destring fecha_int_oil_20, replace
destring fecha_cent_oil_20, replace
destring fecha_int_oil_19, replace
destring fecha_cent_oil_19, replace



collapse (first) depend_regalias* wells_y mean_desem mean_iga (max) fecha_int_t_08 fecha_int_t_10 fecha_int_t_17 fecha_int_oil_20 ///
fecha_cent_oil_20 fecha_int_oil_19 fecha_cent_oil_19, by(codmpio)
merge 1:1 codmpio using  "C:\Users\camilodel\Desktop\IDB\MINING-HK\DATA\PoliticalBoundaries\Colombia\cod_DANE.dta", gen(me_da)
drop if me_da!=3
drop if departamento=="SAN ANDRES"
gen dropi=substr(mpio,strpos(mpio,"(")+1,strpos(mpio,")"))
drop if dropi=="CD)" // JUST LEAVE MUNICIPALITIES


gen gold=1 if fecha_int_t_08!=. | fecha_int_t_10!=. | fecha_int_t_17!=.
recode gold(.=0)
gen welli=1 if well!=.
recode welli(.=0)


* so the first to make is the dependence vs abundance here:

egen p_depend_h = xtile(depend_regalias_h), n(100)
egen p_depend_o = xtile(depend_regalias_o), n(100)

gen dependent_w=1 if welli==1 & p_depend_h>=50
replace dependent_w=0 if welli==1 & p_depend_h<50
tab dependent_w // it can work!!! this is beautiful!

gen dependent_o=1 if gold==1 & p_depend_o>=50
replace dependent_o=0 if gold==1. & p_depend_o<50
tab dependent_o // it can work!!! this is beautiful!

* Now comes institutional variables here:
egen p_desem = xtile(mean_desem), n(100)
egen p_iga = xtile(mean_iga), n(100)

gen inst_g=1 if p_iga>=50
recode inst_g(.=0)

tabulate inst_g welli

tabulate inst_g gold

tabulate welli gold

tabulate dependent_o dependent_w


/*merge 1:1 codmpio using



collapse 


preserve 

	use "${oil}/mpio_pozos_all_cleaned.dta", clear
	gen well=1 
	collapse (sum) well, by(codmpio)
	tempfile wells_collapsed
	sa `wells_collapsed'

restore 

merge m:1 codmpio using `wells_collapsed', gen(w_t)

label var well "Number of wells in the municipality as of 04/2020"
*/






