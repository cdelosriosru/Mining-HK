/**************************************************************************************

 PROJECT :     	Mining - HK
 AUTHOR :			Camilo De Los Rios
 PURPOSE :		Create measures of dependence on the royaltes. One of the main ideas in this 
				literature is that it is not the abundance but rather the dependence
				on the natural resources that is bad for the country. We are going
				to check it at the municipality level. 

With the new royalties that I created this makes much more sense. I still have to edit this. 

**************************************************************************************/

      * PATHS
      
global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global tit_min "${data}/Mineria/titulos_colombia/harm"
global oil "${data}/Petroleo/harm"
global fiscal "${data}/Other-muni/harm"
global inst "${data}/Institutional_Index/harmonized"
global reg_anh "${data}/Regalias_Produccion_ANH"
global compiled "${data}/compiled_sets"

	* Import and prepare the oil wells by municipality. 
	
use "${oil}/mpio_pozos_all_cleaned.dta", clear
gen wells=1 
collapse (sum) wells, by(codmpio spud_y)
destring spud_y, replace
drop if spud_y==.
drop if spud_y<1980
fillin codmpio spud_y
gen wells_30=.
unique spud_y
local tope=r(unique)
forvalues n = 1(1)`tope' {
	cap drop i`n'
	bys codmpio: gen i`n' = 1 if  spud_y[`n']>=spud_y & (spud_y[`n']-spud_y) <= 30
	bys codmpio: egen pozos`n' = total(wells) if i`n'==1
	bys codmpio: replace wells_30 = pozos`n' if mi(wells_30)
	drop  i`n'
	drop pozos`n'
}

rename spud_y year
destring codmpio, replace

tempfile wells_collapsed
sa `wells_collapsed'

* Merge the data with royalties and income. 

use "${reg_anh}/harm/reg_anh.dta", clear
merge 1:1 codmpio year using `wells_collapsed', gen(w_y)
bys codmpio: egen totpozos_mpio_2000=total(wells) if year>=2000
bys codmpio: egen totpozos_mpio=total(wells)
label var totpozos_mpio_2000 "Number of wells drilled since 2000"
label var totpozos_mpio "Number of wells drilled since 1980"
label var wells_30 "Number of wells drilled until that year and not older than 30 years"
label var wells "Number of wells drilled in that year"
drop if w_y==2 // years 2020, 1980-1983.

foreach x in wells_30 wells totpozos_mpio totpozos_mpio_2000{
	recode `x'(.=0)
}



* GENERATING DEPENDENCE MEASURE; I guess abundance y very straight forward: total number of wells. We could be much more sophisticates and make a measuresof how responsive is the number of wells in each municipality depending on the oil price ¿and controling for violence?
gen depend_trib=regalias_oil_producers/ing_trib


* the basic var... 

gen depend_inc=regalias_oil_producers/income
replace depend_inc=. if regalias_oil_producers==0 | regalias_oil_producers==. // otherwise I am not counting it right

*A pooled measure

egen p_depend_inc_h = xtile(depend_inc) if depend_inc!=. , n(100)
gen dependent_inc_w=1 if p_depend_inc_h>=50 & p_depend_inc_h!=.
replace dependent_inc_w=0 if  p_depend_inc_h<50  & p_depend_inc_h!=.
label var dependent_inc_w "dependence created on the pooled sample"

* A yearly measure 

bys year: egen p_depend_inc_hy = xtile(depend_inc) if depend_inc!=. , n(100)
bys year: gen dependent_inc_wy=1 if p_depend_inc_hy>=50 & p_depend_inc_hy!=.
replace dependent_inc_wy=0 if p_depend_inc_hy<50  & p_depend_inc_hy!=.
label var dependent_inc_wy "dependence created on a year by year basis"

* now an Aggregate measure. 
preserve 
	collapse (sum) depend_inc, by(codmpio)
	egen p_depend_inc_ha = xtile(depend_inc) if depend_inc!=. & depend_inc>0 , n(100)
	gen dependent_inc_wa=1 if p_depend_inc_ha>=50 & p_depend_inc_ha!=.
	replace dependent_inc_wa=0 if  p_depend_inc_ha<50  & p_depend_inc_ha!=.
	label var dependent_inc_wa "dependence created aggregating all years"
	tab dependent_inc_wa
	tempfile aggregated
	sa `aggregated'
restore 

merge m:1 codmpio using `aggregated', gen(m_agr)


tab dependent_inc_w // perfect 
tab dependent_inc_wy // perfect 
tab dependent_inc_wa if year>=2000 & year<=2017 // this certainly increases the number of dependent and non dependent mpios. Obvious.  


sa "${compiled}/regalias_dependent.dta", replace





tab dependent_wy // perfect 
tab dependent_w // perfect 


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






