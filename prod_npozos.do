/*
		El Objetivo de este código es mostrar que existe una alta correlación entre
		el número de pozos y la producción petrolera. El argumento derivará en que
		la mejor proxy de producción petrolera son el número de pozos dentro de un buffer. 
		
		Así, la evidencia que s extraiga de aquí servirá para soportar el argumento de 
		exogeneidad en la estimación. 


*/
clear all
global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global fiscal "${data}/Other-muni"
global inst "${data}/Institutional_Index/harmonized"
global reg_anh "${data}/Regalias_Produccion_ANH"
global oil_f "${data}/Petroleo"
global codmu "${data}/PoliticalBoundaries"
global prodcamp "${data}/Produccion_campos/"



/*
		FIRST 
		
			I want to prove the following: the more wells, the greater the production. 
			That would basically be enough to provide evidence that the more wells the school has
			within the buffer, the greater the associated production to the school can be.
			Poriding a graph of the form would be ideal 
*/


/*
First create IDs to merge. With reclink it merges way to many things using year. 

*/


forvalues x=2010(1)2019{
	import excel "${reg_anh}/raw/r_`x'.xlsx", sheet("Produccion y Regalias x C") firstrow clear 
	sa "${reg_anh}/raw/r_`x'.dta", replace
}

use "${reg_anh}/raw/r_2010.dta", clear

forvalues x=2011(1)2019{
	append using  "${reg_anh}/raw/r_`x'.dta"
}
rename Anio year

rename ProdGravableBlsKpc produccion

collapse (sum) produccion , by(Campo Contrato )
replace Campo=lower(substr(Campo,1,.))
replace Contrato=lower(substr(Contrato,1,.))
sort Campo Contrato
gen id_anh=_n
sa "${reg_anh}/raw/CampoContrato.dta", replace

import excel "${oil_f}/raw/wells_atributes.xlsx", firstrow sheet("wells_atributes")  clear 
gen year=year(WELL_SPUD_)
drop if year==.
ren CONTRATO Contrato
ren FIELD_ABRE Campo
sa "${oil_f}/harm/wells_atributes_clean.dta", replace 

gen pozos=1
collapse (sum) pozos, by(Campo Contrato)
replace Campo=lower(substr(Campo,1,.))
replace Contrato=lower(substr(Contrato,1,.))
sort Campo Contrato
gen id_wells=_n
sa "${oil_f}/CampoContrato.dta", replace



* ahora vemos el reclink. 

use "${reg_anh}/raw/CampoContrato.dta", clear
reclink Contrato Campo using  "${oil_f}/raw/CampoContrato.dta", gen(elmatch) idm(id_anh) idu(id_wells)  // notice that when you do this you lose all the information from the using data base that can be matched. 
duplicates tag UContrato UCampo, gen(dup)
keep if dup==0 & _merge==3 // only keeping those with one merge. 
gen id_mergec=_n // this isthe id that i will use to merge them later on. 

* Create the id datasets. 

preserve 
	keep UContrato UCampo id_mergec 
	rename UContrato Contrato
	rename UCampo Campo
	sa "${oil_f}/raw/id_merge.dta", replace
restore 

preserve 
	keep Contrato Campo id_mergec 
	sa "${reg_anh}/raw/id_merge.dta", replace
restore 

/*
Now create data bases to merge with year. 

*/
use "${reg_anh}/harm/reg_anh.dta", clear
rename ProdGravableBlsKpc produccion
rename VolumenRegaliaBlsKpc volregalias
collapse (sum) produccion volregalias, by(Campo Contrato year)
replace Campo=lower(substr(Campo,1,.))
replace Contrato=lower(substr(Contrato,1,.))
sort Campo Contrato
gen id_anh=_n
merge m:1 Campo Contrato using "${reg_anh}/raw/id_merge.dta", gen(mer_idanh)
keep if mer_idanh==3
sa "${reg_anh}/raw/CampoContrato.dta", replace


use "${oil_f}/harm/wells_atributes_clean.dta", clear
gen pozos=1
collapse (sum) pozos, by(Campo Contrato year)
sort Campo Contrato year
gen idc=Campo+Contrato
fillin idc year
*drop if year<1980
gen npozos=.
unique year
local tope=r(unique)
forvalues n = 1(1)`tope' {
	cap drop i`n'
	bys idc: g i`n' = 1 if  year[`n']>=year 
	bys idc: egen pozos`n' = total(pozos) if i`n'==1
	bys idc: replace npozos = pozos`n' if mi(npozos)
	drop  i`n'
	drop pozos`n'
}
keep if year>2010 & year<2020



replace Campo=lower(substr(Campo,1,.))
replace Contrato=lower(substr(Contrato,1,.))
sort Campo Contrato
gen id_wells=_n
merge m:1 Campo Contrato using "${oil_f}/raw/id_merge.dta", gen(mer_idwells)
keep if mer_idwells==3
sa "${oil_f}/raw/CampoContrato.dta", replace


use "${oil_f}/raw/id_merge.dta", clear

* ahora el merge. 

use "${reg_anh}/raw/CampoContrato.dta", clear
merge 1:1 id_mergec year using  "${oil_f}/raw/CampoContrato.dta", generate(elmatch)
keep if elmatch==3



* Finalmente la correlacion. 
gen produccion2=produccion/1000
reg produccion npozos i.year // este es el número de obsrvaciones tal que los matches sean siempre perfectos. Solamente podemos asumir que se mantendrá en todos los casos. Con el supuesto de que los errores en digitación son aleatorios, no tenemos ningún lio. No me parece loco el supuesto y creo que eso es en realidad lo que pasa. 
label var npozos "Number of Wells"
label var produccion "Taxable produccion (BlsKpc)"

	eststo: reghdfe produccion npozos, absorb(year) vce(robust)

	esttab using "${results}/pozos_prod.tex", label replace se depvars b(2) star(* 0.10 ** 0.05 *** 0.01)  scalars("N Observations" "r2_a Adjusted R$^2$") sfmt(%9.2gc %6.2f) keep(npozos)
	
	
	eststo: reghdfe produccion2 npozos, absorb(year) vce(robust)

	esttab using "${results}/pozos_prod_th.tex", label replace se depvars b(2) star(* 0.10 ** 0.05 *** 0.01)  scalars("N Observations" "r2_a Adjusted R$^2$") sfmt(%9.2gc %6.2f) keep(npozos)


	
	
/*-----------------------------------------------------------------------------

			Vamos a hacerlo a nivel Municipal

-------------------------------------------------------------------------------*/

* Open data base with wells information
use "${oil}/harm/wells_measures_mpio.dta", clear

* merge with Info on production

merge 1:1 codmpio year using "${prodcamp}/harm/prod_oil_mpio.dta", gen(mer_prod) keep(3)	

gen blsm=prod_mpio/1000


reghdfe blsm npozos_mpio, absorb(year codmpio)
reghdfe blsm wells_accum_mpio, absorb(year codmpio)

label var wells_accum_mpio "Number of Wells"
label var blsm "Thousands of Bls"

eststo: reghdfe blsm wells_accum_mpio, absorb(year codmpio)

esttab using "${results}/pozos_prod_mpio.tex", label replace se depvars b(2) star(* 0.10 ** 0.05 *** 0.01)  scalars("N Observations" "r2_a Adjusted R$^2$") sfmt(%9.2gc %6.2f) keep(wells_accum_mpio)


***** Now with royalties

* Open data base with wells information
use "${oil}/harm/wells_measures_mpio.dta", clear

* merge with Info on production

merge 1:1 codmpio year using "${oil}/harm/regalias_definitivas.dta", gen(mer_prod)
keep if year>2003 
recode regalias(.=0) 
*drop if wells_accum_mpio ==. 
gen post2012=(year>2011)

gen mill_reg=regalias/1000000

reghdfe mill_reg wells_accum_mpio i.post2012 i.year, absorb(codmpio) vce(r)

label var wells_accum_mpio "Number of Wells"
label var mill_reg "Royalties (Million COP)"

eststo: reghdfe mill_reg wells_accum_mpio, absorb(year codmpio) vce(r)

esttab using "${results}/pozos_royalties_mpio.tex", label replace se depvars b(2) star(* 0.10 ** 0.05 *** 0.01)  scalars("N Observations" "r2_a Adjusted R$^2$") sfmt(%9.2gc %6.2f) keep(wells_accum_mpio)



use "${oil}/harm/wells_measures_mpio.dta", clear

* merge with Info on production

merge 1:1 codmpio year using "${oil}/harm/regalias_definitivas.dta", gen(mer_prod) keep(3)
keep if year>2003 
recode regalias(.=0) 
drop if wells_accum_mpio ==. 


	