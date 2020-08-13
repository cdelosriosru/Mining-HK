/**************************************************************************************

 PROJECT :     	Mining - HK
 AUTHOR :			Camilo De Los Rios
 PURPOSE :			Equation 3 of the proposal. Also with m and not 
 WHERE: This code will run in the server of Luis.

**************************************************************************************/

* PATHS


global data "C:/Users/camilodel/Desktop/IDB/MINING-HK/DATA/SERVIDOR-LUIS-PATHS/dtafiles"
global oil "${data}/Petroleo"
global hk "${data}/HK"
global municipios "${data}/PoliticalBoundaries"
global results "${data}/results"

/*------------------------------------------------------------------------------
									ROYALTIES 																
------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------
first create measure of royalties by the number of wells drilled every year
in buffers. 														
------------------------------------------------------------------------------*/

global regalias SRAanh_regalias_productor SRAecopetrol_productor

use "${data}/cole_wells_all.dta", clear

gen codmpio=substr(mpio_well,3,5)
destring codmpio, replace


gen year=spud
destring year, replace
drop if year<1984 // we dont have royalties for years before 1984
drop if year==2020 // neither for 2020
drop if year==. // drop also when there is no info of the years.

merge m:1 codmpio year using "${municipios}/regalias.dta", gen(mer_wellmpio) keepusing(SRAanh_regalias_productor pobl_tot SRAecopetrol_productor) // this will have a lot of merges in missing from master (we dont have all the years for royalties)

foreach x in $regalias {
	rename `x' w_`x'
}

drop if mer_wellmpio==2 & mpio_cole==. // drop obs that were only in the using data

drop codmpio 
drop if year<2000


			* Create measures of royalties by municipality of the wells and spud. 

sort id_cole year

gen w_SRAanh_reg_prod_pc=w_SRAanh_regalias_productor/pobl_tot
gen w_SRAecopetrol_prod_pc=w_SRAecopetrol_productor/pobl_tot

foreach x in 1000 2500 5000 10000{
	by id_cole year: egen regalias_anh_`x'=mean(w_SRAanh_regalias_productor) if npozos_`x'!=.
	label var regalias_anh_`x' "2004 - 2018 producer royalties mean.Wells mpio in `x'm buffer"
	
	bys id_cole year: egen regalias_eco_`x'=mean(w_SRAecopetrol_productor) if npozos_`x'!=.
	label var regalias_eco_`x' "1986 - 2004 producer royalties mean.Wells mpio in `x'm buffer"

	gen regalias_oil_w_`x'= regalias_anh_`x'
	replace regalias_oil_w_`x'=regalias_eco_`x' if regalias_anh_`x'==.	
	label var regalias_oil_w_`x' "86-18 producer royalties mean.Wells mpio in `x'm buf"
	
				* Per Capita measures
	
	by id_cole year: egen regalias_anh_pc_`x'=mean(w_SRAanh_reg_prod_pc) if npozos_`x'!=.
	label var regalias_anh_pc_`x' "2004 - 2018 producer royalties mean percapita.Mpios where the wells are in `x'km buffer"
	
	bys id_cole year: egen regalias_eco_pc_`x'=mean(w_SRAecopetrol_prod_pc) if npozos_`x'!=.
	label var regalias_eco_pc_`x' "1986 - 2004 producer royalties mean percapita.Mpios where the wells are in `x'km buffer"

	gen regalias_oil_pc_w_`x'= regalias_anh_pc_`x'
	replace regalias_oil_pc_w_`x'=regalias_eco_pc_`x' if regalias_anh_pc_`x'==.
	label var regalias_oil_pc_w_`x' "86-18 producer royalties mean percap.Wells mpio in `x'm buf"
	
}

foreach x in 1000 2500 5000 10000{
	by id_cole year: egen tot_pozos_`x'=total(npozos_`x')
	
	gen regaliasw_anh_`x'=(npozos_`x'*w_SRAanh_regalias_productor)/tot_pozos_`x'
	label var regaliasw_anh_`x' "2004 - 2018 producer royalties mean. mpios where the wells are in `x'm buffer.weighted"

	gen regaliasw_eco_`x'=(npozos_`x'*w_SRAecopetrol_productor)/tot_pozos_`x'
	label var regaliasw_eco_`x' "86-04 producer royalties mean. mpios where the wells are in `x'm buffer.weighted"

	gen regaliasw_oil_w_`x'= regalias_anh_`x'
	replace regaliasw_oil_w_`x'=regalias_eco_`x' if regalias_anh_`x'==.
	label var regaliasw_oil_w_`x' "86-18 producer royalties mean.Wells mpio in`x'm buf weighted"
	
				* Per Capita measures
		
	gen regaliasw_anh_pc_`x'=(npozos_`x'*w_SRAanh_reg_prod_pc)/tot_pozos_`x'
	label var regaliasw_anh_pc_`x' "2004 - 2018 producer royalties mean percap.Mpios where the wells are in `x'km buffer.weighted"

	gen regaliasw_eco_pc_`x'=(npozos_`x'*w_SRAecopetrol_prod_pc)/tot_pozos_`x'
	label var regaliasw_eco_pc_`x' "1986 - 2004 producer royalties mean percapita.Mpios where the wells are in `x'km buffer.weighted"

	gen regaliasw_oil_pc_w_`x'= regalias_anh_pc_`x'
	replace regaliasw_oil_pc_w_`x'=regalias_eco_pc_`x' if regalias_anh_`x'==.
	label var regaliasw_oil_pc_w_`x' "86-18 producer royalties mean percap.Wells mpio in `x'm buf.Weighted"
}


			*Collapse at the schol level. 
keep *_oil* tot_pozos* year id_cole

foreach v of var* {
    local `v'l: var label `v'
}
collapse (first) *_oil* tot_pozos*, by(year id_cole)
foreach v of var* {
    label var `v' `"``v'l'"'
}
compress

sa "${data}/regalias_pozos_spud.dta", replace // we could put this in a tempfile


/*------------------------------------------------------------------------------
create measure of royalties by number of wells drilled regardless of the year drilled
This is a measure of endowment that does not consider timing.. Might be cleaner.  														
------------------------------------------------------------------------------*/

use "${data}/cole_wells_all.dta", clear

gen year=spud
destring year, replace
drop if year<1970 // drop really old wells
drop if year==2020 // neither for 2020


collapse (sum) npozos* (first) mpio_cole, by(id_cole mpio_well)

expand 20 // need this to be able to merge. 
sort id_cole mpio_well
by id_cole mpio_well: gen year=_n
replace year=year+1999

gen codmpio=substr(mpio_well,3,5)
destring codmpio, replace


merge m:1 codmpio year using "${municipios}/regalias.dta", gen(mer_wellmpio) keepusing(SRAanh_regalias_productor pobl_tot SRAecopetrol_productor) // this will have a lot of merges in missing from master (we dont have all the years for royalties)
drop if mer_wellmpio==2 & mpio_cole==. // drop obs that were only in the using data

foreach x in $regalias {
	rename `x' w_`x'
}


drop codmpio 


			* Create measures of royalties by municipality of the wells regardless of spud. 

sort id_cole year

gen w_SRAanh_reg_prod_pc=w_SRAanh_regalias_productor/pobl_tot
gen w_SRAecopetrol_prod_pc=w_SRAecopetrol_productor/pobl_tot

foreach x in 1000 2500 5000 10000{
	by id_cole year: egen regalias_anh_`x'=mean(w_SRAanh_regalias_productor) if npozos_`x'!=.
	label var regalias_anh_`x' "2004 - 2018 producer royalties mean.Mpios where the wells are in `x'km buffer total"
	
	bys id_cole year: egen regalias_eco_`x'=mean(w_SRAecopetrol_productor) if npozos_`x'!=.
	label var regalias_eco_`x' "1986 - 2004 producer royalties mean.Mpios where the wells are in `x'km buffer total"

	gen regalias_oil_sw_`x'= regalias_anh_`x'
	replace regalias_oil_sw_`x'=regalias_eco_`x' if regalias_anh_`x'==.	
	label var regalias_oil_sw_`x' "86-18 producer royalties mean.Wells mpio in `x'm buf total"
	
				* Per Capita measures
	
	by id_cole year: egen regalias_anh_pc_`x'=mean(w_SRAanh_reg_prod_pc) if npozos_`x'!=.
	label var regalias_anh_pc_`x' "2004 - 2018 producer royalties mean percapita.Wells mpio in `x'm buf total"
	
	bys id_cole year: egen regalias_eco_pc_`x'=mean(w_SRAecopetrol_prod_pc) if npozos_`x'!=.
	label var regalias_eco_pc_`x' "1986 - 2004 producer royalties mean percapita.Mpios where the wells are in `x'km buffer total"

	gen regalias_oil_pc_sw_`x'= regalias_anh_pc_`x'
	replace regalias_oil_pc_sw_`x'=regalias_eco_pc_`x' if regalias_anh_pc_`x'==.
	label var regalias_oil_pc_sw_`x' "86-18 producer royalties mean.Wells mpio in`x'm buf total"
	
}

foreach x in 1000 2500 5000 10000{
	by id_cole year: egen tot_pozos_`x'=total(npozos_`x')
	
	gen regaliasw_anh_`x'=(npozos_`x'*w_SRAanh_regalias_productor)/tot_pozos_`x'
	label var regaliasw_anh_`x' "2004 - 2018 producer royalties mean. mpios where the wells are in `x'km buffer total.weighted" 

	gen regaliasw_eco_`x'=(npozos_`x'*w_SRAecopetrol_productor)/tot_pozos_`x'
	label var regaliasw_eco_`x' "1986 - 2004 producer royalties mean. mpios where the wells are in `x'km buffer total.weighted"

	gen regaliasw_oil_sw_`x'= regalias_anh_`x'
	replace regaliasw_oil_sw_`x'=regalias_eco_`x' if regalias_anh_`x'==.
	label var regaliasw_oil_sw_`x' "86-18 producer royalties mean.Wells mpio in `x'm buf total.weighted"
	
				* Per Capita measures
		
	gen regaliasw_anh_pc_`x'=(npozos_`x'*w_SRAanh_reg_prod_pc)/tot_pozos_`x'
	label var regaliasw_anh_pc_`x' "2004 - 2018 producer royalties mean percapita.Mpios where the wells are in `x'km buffer total.weighted"

	gen regaliasw_eco_pc_`x'=(npozos_`x'*w_SRAecopetrol_prod_pc)/tot_pozos_`x'
	label var regaliasw_eco_pc_`x' "1986 - 2004 producer royalties mean percapita.Mpios where the wells are in `x'km buffer total.weighted"

	gen regaliasw_oil_pc_sw_`x'= regalias_anh_pc_`x'
	replace regaliasw_oil_pc_sw_`x'=regalias_eco_pc_`x' if regalias_anh_`x'==.
	label var regaliasw_oil_pc_sw_`x' "86-18 producer royalties mean percapita.Wells mpio in `x'm buf total.weighted"
	
	rename tot_pozos_`x' tot_sw_pozos_`x'
}


			*Collapse at the schol level. 
keep *_oil* tot_sw_pozos* year id_cole

foreach v of var* {
    local `v'l: var label `v'
}
collapse (first) *_oil* tot_sw_pozos*, by(year id_cole)
foreach v of var* {
    label var `v' `"``v'l'"'
}

*sa "${data}/regalias_pozos_spud.dta", replace // dont really need to save this


/*------------------------------------------------------------------------------
				merge both data sets.  														
------------------------------------------------------------------------------*/
merge 1:1 id_cole year using "${data}/regalias_pozos_spud.dta"

drop if year<2002 
drop if year>2015

erase "${data}/regalias_pozos_spud.dta" // to free space of the disk

sa "${data}/regalias_colegios.dta", replace // we could put this in a tempfile

/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------

								HUMAN CAPITAL
								
--------------------------------------------------------------------------------

------------------------------------------------------------------------------*/

		* Create Human Cpital Accumulation Measures

use "${hk}/HumanCapital.dta", clear

* keep only variables that you need. 

keep prog_area periodo year periodoprimiparo pct2 Cale_A colegio_cod CódigoMunicipio

rename CódigoMunicipio codmpio

* Important Value labels

label define vals_prog_area 1 "Agronomia, veterinaria y afines" 2 "Bellas Artes" 3 "Ciencias de la Educacion" 4 "Ciencias de la Salud" 5 "Ciencias Sociales, derecho, ciencias politicas" 6 "Economia Administracion, Contaduria y afines" 7 "Humanidades y ciencias religiosas" 8 "Ingenieria, arquitectura, urbanismo y afines" 9 "Matematicas y ciencias naturales"


label values prog_area vals_prog_area

					* Create the HK outcomes 

tostring periodo, g(periodos)   // notice that I am doing everything at the year level. I will also prepare the code for the semester level. The dummy of Calendar A or B should be able to control this.  
gen year_periodo=substr(periodos,1,4)

gen graduados=1 if year!=. // for the enrolment rate
recode graduados(.=0)

gen enroled_he=1 if periodoprimiparo!=. // for the enrolment rate
recode enroled_he(.=0)

gen pct2_m=pct2  // for the median and mean of icfes measure

gen rent_seeker=1 if prog_area==5 | prog_area==6
recode rent_seeker(.=0)
gen non_rent_seeker_1=1 if prog_area==8 // definition according to Ebbeke, Laajaj & Omgba
recode non_rent_seeker_1(.=0)
gen non_rent_seeker_2=1 if prog_area==8 | prog_area==9
recode non_rent_seeker_2(.=0)

				* collapse at the  school year level

collapse (median) pct2 (mean) pct2_m (sum) graduado enroled_he rent_seeker non_rent_seeker_1 non_rent_seeker_2 (first) codmpio Cale_A, by(year_periodo colegio_cod)

gen enrolment_rate=(enroled_he*100)/graduados
gen rentseeker_1=(rent_seeker-non_rent_seeker_1)*100/enroled_he
gen rentseeker_2=(rent_seeker-non_rent_seeker_2)*100/enroled_he

label var pct2 "Icfes std measure median by school / year"
label var pct2_m "Icfes std measure mean by school / year"
label var enrolment_rate "enrolment rate by school / year"
label var rentseeker_1 "(sociales+econ-inge)*100/total. enroled intensity rent seeker Ebbeke et al"
label var rentseeker_2 "(sociales+econ-inge-puras)*100/total enroled intensity rent seeker harder"


keep colegio_cod year_periodo pct2 pct2_m Cale_A enrolment_rate rentseeker_1 rentseeker_2 codmpio

/*------------------------------------------------------------------------------
									MERGE 
							prices and royalties
------------------------------------------------------------------------------*/

ren colegio_cod id_cole
 
rename year_periodo year // notice that this is the year in which the student presented the icfes. It usually is the same year as graduation but we could make a simple sensibility test for this. 
destring year, replace
drop if year>2014 // where the boom ended
drop if codmpio==. // there are schools with no georeferentiation 

merge m:1 codmpio year using "${municipios}/regalias.dta", gen(mer_royalties) keepusing( SRAanh_regalias_productor SRAecopetrol_productor pobl_tot)
drop if mer_royalties==2 // I hope that this is only due to the sample. Are there schools in every municipality of Colombia? 

merge 1:1 year id_cole  using "${data}/regalias_colegios.dta", gen(mer_regalias_cole)
* los que no se hacce el merge debe ser por dos razones: 1. si es del master, porque no tiene pozos en ningun buffer. Si es del using, porque hay años para los que no presentó nadie el icfes de ese colegio. 

merge m:1 year using "${oil}/oil_price.dta", gen(mer_price)
drop if mer_price==2

erase "${data}/regalias_colegios.dta" // to free space of the disk

sa "${hk}/hk_total_well.dta", replace // we could put this in a tempfile

/*------------------------------------------------------------------------------
									ROYALTIES 2.0

for the schools that do not have wells, there are no royalties sofar.
Thus, I will assign the royalties of the municipality where they are located
------------------------------------------------------------------------------*/

gen SRAanh_reg_prod_pc=SRAanh_regalias_productor/pobl_tot
gen SRAecopetrol_prod_pc=SRAecopetrol_productor/pobl_tot


foreach x in regalias_oil_sw_1000 regalias_oil_pc_sw_1000 regalias_oil_sw_2500 regalias_oil_pc_sw_2500 regalias_oil_sw_5000 regalias_oil_pc_sw_5000 regalias_oil_sw_10000 regalias_oil_pc_sw_10000 regaliasw_oil_sw_1000 regaliasw_oil_pc_sw_1000 regaliasw_oil_sw_2500 regaliasw_oil_pc_sw_2500 regaliasw_oil_sw_5000 regaliasw_oil_pc_sw_5000 regaliasw_oil_sw_10000 regaliasw_oil_pc_sw_10000 regalias_oil_w_1000 regalias_oil_pc_w_1000 regalias_oil_w_2500 regalias_oil_pc_w_2500 regalias_oil_w_5000 regalias_oil_pc_w_5000 regalias_oil_w_10000 regalias_oil_pc_w_10000 regaliasw_oil_w_1000 regaliasw_oil_pc_w_1000 regaliasw_oil_w_2500 regaliasw_oil_pc_w_2500 regaliasw_oil_w_5000 regaliasw_oil_pc_w_5000 regaliasw_oil_w_10000 regaliasw_oil_pc_w_10000{

replace `x'=SRAanh_reg_prod_pc if `x'==.
replace `x'=SRAecopetrol_prod_pc if `x'==.
recode `x'(.=0)

}

/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

									ESTIMATIONS
									
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
									TREATMENTS
	These are the two most simple treatment status that we could think of
	Start from here and then we'll se what else can we do. 
------------------------------------------------------------------------------*/

foreach x in 1000 2500 5000 10000{

	recode tot_sw_pozos_`x'(.=0)
	gen treat_1_`x'=1 if tot_sw_pozos_`x'>=1  
	recode treat_1_`x'(.=0)
	label var treat_1_`x' "treated if in buf there has been any well past, present or future"
}

foreach x in 1000 2500 5000 10000{

	recode tot_pozos_`x'(.=0)
	gen treat_2_`x'=1 if tot_pozos_`x'>=1  
	recode treat_2_`x'(.=0)
	label var treat_2_`x' "treated if in buf there was a well drilled in buff in that year"
}

/*------------------------------------------------------------------------------
									REG
------------------------------------------------------------------------------*/
capture mkdir "${data}/results" 

foreach y in pct2 pct2_m enrolment_rate rentseeker_1 rentseeker_2 {

local rep_app="replace"

foreach x in 1000 2500 5000 10000{

		rename treat_1_`x' treat_a
		rename regalias_oil_pc_w_`x' regalias_control

		reghdfe `y' treat_a##c.brent_price  regalias_control, absorb(i.year i.id_cole)  
		outreg2 using "${results}/r_t1_`y'.xls", `rep_app' addtext(Buffer, `x') ctitle(_oil_pc_w_)
		local rep_app="append"
		
		rename regalias_control regalias_oil_pc_w_`x'
		rename regaliasw_oil_pc_w_`x' regalias_control
		
		reghdfe `y' treat_a##c.brent_price  regalias_control, absorb(i.year i.id_cole)  
		outreg2 using "${results}/r_t1_`y'.xls", `rep_app' addtext(Buffer, `x') ctitle(w_oil_pc_w_)

		rename regalias_control regaliasw_oil_pc_w_`x'
		rename regalias_oil_pc_sw_`x' regalias_control
		
		reghdfe `y' treat_a##c.brent_price  regalias_control, absorb(i.year i.id_cole)  
		outreg2 using "${results}/r_t1_`y'.xls", `rep_app' addtext(Buffer, `x') ctitle(_oil_pc_sw_)

		rename regalias_control regalias_oil_pc_sw_`x'
		rename regaliasw_oil_pc_sw_`x' regalias_control
		
		reghdfe `y' treat_a##c.brent_price  regalias_control, absorb(i.year i.id_cole)  
		outreg2 using "${results}/r_t1_`y'.xls", `rep_app' addtext(Buffer, `x') ctitle(w_oil_pc_sw_)

		rename regalias_control regaliasw_oil_pc_sw_`x' 
		rename treat_a treat_1_`x' 
	}
}



foreach y in pct2 pct2_m enrolment_rate rentseeker_1 rentseeker_2 {

local rep_app="replace"

foreach x in 1000 2500 5000 10000{

		rename treat_2_`x' treat_a
		rename regalias_oil_pc_w_`x' regalias_control

		reghdfe `y' treat_a##c.brent_price  regalias_control, absorb(i.year i.id_cole)  
		outreg2 using "${results}/r_t2_`y'.xls", `rep_app' addtext(Buffer, `x') ctitle(_oil_pc_w_)
		local rep_app="append"
		
		rename regalias_control regalias_oil_pc_w_`x'
		rename regaliasw_oil_pc_w_`x' regalias_control
		
		reghdfe `y' treat_a##c.brent_price  regalias_control, absorb(i.year i.id_cole)  
		outreg2 using "${results}/r_t2_`y'.xls", `rep_app' addtext(Buffer, `x') ctitle(w_oil_pc_w_)

		rename regalias_control regaliasw_oil_pc_w_`x'
		rename regalias_oil_pc_sw_`x' regalias_control
		
		reghdfe `y' treat_a##c.brent_price  regalias_control, absorb(i.year i.id_cole)  
		outreg2 using "${results}/r_t2_`y'.xls", `rep_app' addtext(Buffer, `x') ctitle(_oil_pc_sw_)

		rename regalias_control regalias_oil_pc_sw_`x'
		rename regaliasw_oil_pc_sw_`x' regalias_control
		
		reghdfe `y' treat_a##c.brent_price  regalias_control, absorb(i.year i.id_cole)  
		outreg2 using "${results}/r_t2_`y'.xls", `rep_app' addtext(Buffer, `x') ctitle(w_oil_pc_sw_)

		rename regalias_control regaliasw_oil_pc_sw_`x' 
		rename treat_a treat_2_`x' 
	}
}


foreach y in pct2 pct2_m enrolment_rate rentseeker_1 rentseeker_2 {

local rep_app="replace"

foreach x in 1000 2500 5000 10000{

		rename tot_pozos_`x' treat_a
		rename regalias_oil_pc_w_`x' regalias_control

		reghdfe `y' treat_a  regalias_control, absorb(i.year i.id_cole)  
		outreg2 using "${results}/r_poz_spud_`y'.xls", `rep_app' addtext(Buffer, `x') ctitle(_oil_pc_w_)
		local rep_app="append"
		
		rename regalias_control regalias_oil_pc_w_`x'
		rename regaliasw_oil_pc_w_`x' regalias_control
		
		reghdfe `y' treat_a  regalias_control, absorb(i.year i.id_cole)  
		outreg2 using "${results}/r_poz_spud__`y'.xls", `rep_app' addtext(Buffer, `x') ctitle(w_oil_pc_w_)

		rename regalias_control regaliasw_oil_pc_w_`x'
		rename regalias_oil_pc_sw_`x' regalias_control
		
		reghdfe `y' treat_a  regalias_control, absorb(i.year i.id_cole)  
		outreg2 using "${results}/r_poz_spud_2_`y'.xls", `rep_app' addtext(Buffer, `x') ctitle(_oil_pc_sw_)

		rename regalias_control regalias_oil_pc_sw_`x'
		rename regaliasw_oil_pc_sw_`x' regalias_control
		
		reghdfe `y' treat_a  regalias_control, absorb(i.year i.id_cole)  
		outreg2 using "${results}/r_poz_spud__`y'.xls", `rep_app' addtext(Buffer, `x') ctitle(w_oil_pc_sw_)

		rename regalias_control regaliasw_oil_pc_sw_`x' 
		rename treat_a tot_pozos_`x' 
	}
}

tabout treat_1_1000 treat_1_2500 treat_1_5000 treat_1_10000 using "${results}/treat2.xls", oneway replace

tabout treat_2_1000 treat_2_2500 treat_2_5000 treat_2_10000 using "${results}/treat2.xls", oneway replace








