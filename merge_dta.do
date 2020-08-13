/**************************************************************************************

 PROJECT :     	Mining - HK
 AUTHOR :			Camilo De Los Rios
 PURPOSE :			Merge Mining, Oil and GEO-anomalies data Bases and create the one that I need for the estimations

BUGGS TO FIX:
					There are some variables created in R that do not have vald
					STATA names. I have to fix it in R because it is, i think, 
					impossible to do here. But I am to tired to do it now, so...
					for now I am going to keep only the vars that I use

**************************************************************************************/

      * PATHS
      
global data "C:/Users/camilodel/Desktop/IDB/MINING-HK/DATA"
global tit_min "${data}/Mineria/titulos_colombia/harm"
global oil "${data}/Petroleo/harm"
global geo "${data}/Mineria/geo/harm"
global agua "${data}/Agua/oferta_Colombia/harm"

/*------------------------------------------------------------------------------
						
						MINING TITLES & SOLICITUDES
						
------------------------------------------------------------------------------*/

 ***	INTERSECCIONES Y CENTROIDES		***


foreach z in ce i{

     foreach x in 08 10 17 {  

          use "${tit_min}/`z'nt_mpios_oro_t_`x'", clear
			
		  capture drop coord* // bug to be fixed
		  capture drop na* // bug to be fixed
			
          gen codmpio=substr(admin2Pcod,3,.)
          gen fecha_`z'nt_t_`x'=substr(FECHA_INSC,1,4)
          destring fecha_`z'nt_t_`x', replace
          gen n_`z'nt_t_`x'=1
          keep codmpio fecha_`z'nt_t_`x' n_`z'nt*
          sort codmpio fecha_`z'nt_t_`x'
          collapse (min) fecha_`z'nt_t_`x' (sum) n_`z'nt_t_`x', by(codmpio)
          gen `z'nt_t_`x'=1

          if "`z'"=="i"{
               label var fecha_`z'nt_t_`x' "Fecha más temprana de evidencia de títulos de oro que intersecan al mpio según shp de 20 `x'"
               label var n_`z'nt_t_`x' "Número de títulos de oro que intersecan al mpio al 20`x'"
               label var `z'nt_t_`x' "Hay títulos de oro que intersecan al mpio al 20`x'"
          }
          
          else{
               label var fecha_`z'nt_t_`x' "Fecha más temprana de evidencia de títulos de oro que tienen centroide en mpio según shp de 20 `x'"
               label var n_`z'nt_t_`x' "Número de títulos de oro que tienen centroide en mpio al 20`x'"
               label var `z'nt_t_`x' "Hay títulos de oro que tienen centroide en mpio al 20`x'" 
          }
          
          sa "${tit_min}/`z'nt_clean_t_`x'.dta", replace

          use "${tit_min}/`z'nt_mpios_oro_s_`x'", clear
		  
		  capture drop coord* // bug to be fixed
		  capture drop na* // bug to be fixed

          gen codmpio=substr(admin2Pcod,3,.)
          gen fecha_`z'nt_s_`x'=substr(FECHA_RADI,1,4)
          destring fecha_`z'nt_s_`x', replace
          gen n_`z'nt_s_`x'=1
          keep codmpio fecha_`z'nt_s_`x' *`z'nt*
          sort codmpio fecha_`z'nt_s_`x'
          collapse (min) fecha_`z'nt_s_`x' (sum) n_`z'nt_s_`x', by(codmpio)
          gen `z'nt_s_`x'=1

          if "`z'"=="i"{
               label var fecha_`z'nt_s_`x' "Fecha más temprana de evidencia de solicitudes de oro que intersecan al mpio según shp de 20 `x'"
               label var n_`z'nt_s_`x' "Número de solicitudes de oro que intersecan al mpio al 20`x'"
               label var `z'nt_s_`x' "Hay solicitudes de oro que intersecan al mpio al 20`x'" 
          }
          
          else{
               label var fecha_`z'nt_s_`x' "Fecha más temprana de evidencia de solicitudes de oro que tienen centroide en mpio según shp de 20 `x'"
               label var n_`z'nt_s_`x' "Número de solicitudes de oro que tienen centroide en mpio al 20`x'"
               label var `z'nt_s_`x' "Hay solicitudes de oro que tienen centroide en mpio al 20`x'" 
          }
          sa "${tit_min}/`z'nt_clean_s_`x'.dta", replace
     }
}
    
 
***			AREA		***
 
 
foreach x in 08 10 17 {  

	use "${tit_min}/area_mpios_oro_t_`x'", clear
		  
    capture drop coord* // bug to be fixed
	capture drop na* // bug to be fixed
		  
	gen codmpio=substr(admin2Pcod,3,.)
	keep codmpio a_inter_pc
	sort codmpio
	
	collapse (sum) a_inter_pc, by(codmpio)
	
	rename a_inter_pc area_inter_t_`x'
	label var area_inter_t_`x' "Area del municipio que tiene títulos mineras de oro segun shp de 20`x'"
	sa "${tit_min}/area_clean_t_`x'.dta", replace 
	
	use "${tit_min}/area_mpios_oro_s_`x'", clear

    capture drop coord* // bug to be fixed
	capture drop na* // bug to be fixed
	
	gen codmpio=substr(admin2Pcod,3,.)
	keep codmpio a_inter_pc
	sort codmpio
	
	collapse (sum) a_inter_pc, by(codmpio)
	
	rename a_inter_pc area_inter_s_`x'
	label var area_inter_s_`x' "% Area del municipio que tiene solicutudes mineras de oro segun shp de 20`x'"
	
	sa "${tit_min}/area_clean_s_`x'.dta", replace 
	 		 
}
		  

***			MERGE AREA, INTERSECIONES Y CENTROIDES		***

use "${tit_min}/int_clean_t_08.dta", clear

foreach x in int cent area{
     foreach y in t s{
          foreach z in 08 10 17{          
               merge 1:1 codmpio using "${tit_min}/`x'_clean_`y'_`z'.dta"
               rename _merge mer_`x'`y'`z'
          }
     }
}


*sa "${tit_min}/t_s.dta", replace

***			MERGE WITH JACOME		***

destring codmpio, replace
tostring codmpio, replace 

merge 1:1 codmpio using "${data}/Mineria/jacome78.dta"
rename _merge m_jacome

sa "${data}/Mineria/harm/t_s_j.dta", replace  // save data that has titles, solicitudes and jAcome data.



/*------------------------------------------------------------------------------
						
								OIL TITLES
						
------------------------------------------------------------------------------*/


 ***	INTERSECCIONES Y CENTROIDES		***
 
foreach x in ce i {

	foreach z in 19 20 {

     use "${oil}/`x'nt_mpios_oil_`z'.dta"
	 
	 capture drop coord* // bug to be fixed
	 capture drop na* // bug to be fixed
	 
     gen n_prod_`x'nt_`z' = 1 if ESTAD_AREA=="PRODUCCION"
     recode n_prod_`x'nt_`z'(.=0)
     gen n_expl_`x'nt_`z' = 1 if ESTAD_AREA=="EXPLORACION"
     recode n_expl_`x'nt_`z'(.=0)
     gen n_tea_`x'nt_`z' = 1 if ESTAD_AREA=="TEA"
     recode n_tea_`x'nt_`z'(.=0)

     gen codmpio=substr(admin2Pcod,3,.)

     gen fecha_`x'nt_oil_`z'=substr(FECHA_FIRM,1,4)  

     gen fecha_`x'nt_oil_prod_`z'=substr(FECHA_FIRM,1,4) if n_prod_`x'nt_`z'==1
     gen fecha_`x'nt_oil_expl_`z'=substr(FECHA_FIRM,1,4) if n_expl_`x'nt_`z'==1
     gen fecha_`x'nt_oil_tea_`z'=substr(FECHA_FIRM,1,4) if n_tea_`x'nt_`z'==1

     keep codmpio fecha_`x'n* *_`x'nt_`z'

     sort codmpio

     collapse (min) fecha* (sum) n_*, by(codmpio)

     gen prod_`x'nt_`z' = n_prod_`x'nt_`z'/n_prod_`x'nt_`z'
     recode prod_`x'nt_`z'(.=0)
     gen expl_`x'nt_`z' = n_expl_`x'nt_`z'/n_expl_`x'nt_`z'
     recode expl_`x'nt_`z'(.=0)
     gen tea_`x'nt_`z' = n_tea_`x'nt_`z'/n_tea_`x'nt_`z'
     recode tea_`x'nt_`z'(.=0)

     gen `x'nt_oil_`z'= 1 
     recode `x'nt_oil_`z'(.=0)

          if "`x'"=="i"{
               label var n_prod_int_`z' "Número de areas en producción que intersecan al mpio a 20`z'"
               label var n_expl_int_`z' "Número de areas en exploración que intersecan al mpio a 20`z'"
               label var n_tea_int_`z' "Número de areas en TEA que intersecan al mpio a 20`z'"
               label var prod_int_`z' "Hay áreas en producción que intersecan al mpio a 20`z'"
               label var expl_int_`z' "Hay áreas en exploración que intersecan al mpio a 20`z'"
               label var tea_int_`z' "Hay áreas en TEA que intersecan al mpio a 20`z'"
               label var int_oil_`z' "Hay áreas de hidrocarburos en el municipio"
               label var fecha_int_oil_`z' "Fecha más temprana de evidencia de área de hidrocarburos que interseca al mpio a 20`z'"
               label var fecha_int_oil_prod_`z' "Fecha más temprana de evidencia de área en producción que interseca al mpio a 20`z'"
               label var fecha_int_oil_expl_`z' "Fecha más temprana de evidencia de área en explotación que interseca al mpio a 20`z'"
               label var fecha_int_oil_tea_`z' "Fecha más temprana de evidencia de área en TEA que interseca al mpio a 20`z'"
          }

          else {
               label var n_prod_cent_`z' "Número de areas en producción que tienen centroide en mpio a 20`z'"
               label var n_expl_cent_`z' "Número de areas en exploración que tienen centroide en mpio a 20`z'"
               label var n_tea_cent_`z' "Número de areas en TEA que tienen centroide en mpio a 20`z'"
               label var prod_cent_`z' "Hay áreas en producción que tienen centroide en mpio a 20`z'"
               label var expl_cent_`z' "Hay áreas en exploración que tienen centroide en mpio a 20`z'"
               label var tea_cent_`z' "Hay áreas en TEA que tienen centroide en mpio a 20`z'"
               label var cent_oil_`z' "Hay áreas de hidrocarburos qur tienen centroide en en el municipio"
               label var fecha_cent_oil_`z' "Fecha más temprana de evidencia de área de hidrocarburos que tienen centroide en mpio a 20`z'"
               label var fecha_cent_oil_prod_`z' "Fecha más temprana de evidencia de área en producción que tienen centroide en mpio a 20`z'"
               label var fecha_cent_oil_expl_`z' "Fecha más temprana de evidencia de área en explotación que tienen centroide en mpio a 20`z'"
               label var fecha_cent_oil_tea_`z' "Fecha más temprana de evidencia de área en TEA que tienen centroide en mpio a 20`z'"
          }
          
     sa "${oil}/`x'nt_oil_clean_`z'.dta", replace
    
	} 
}


***			AREAS		***
          
foreach x in 19 20{

	use "${oil}/area_mpios_oil_`x'.dta", replace
	
	capture drop coord* // bug to be fixed
	capture drop na* // bug to be fixed
		
	gen codmpio=substr(admin2Pcod,3,.)
	keep codmpio a_inter_pc*
	sort codmpio
	
	collapse (sum) a_inter_pc, by(codmpio)
	
	rename a_inter_pc area_inter_oil_`x'
	label var area_inter_oil_`x' "% Area del municipio que tiene contratos petroleros a 20`x'"
	
	sa "${oil}/area_oil_clean_`x'.dta", replace
}


***			MERGE AREA, INTERSECIONES Y CENTROIDES		***

use "${oil}/int_oil_clean_19.dta", clear

foreach x in int cent area{
	foreach z in 19 20{          
		merge 1:1 codmpio using "${oil}/`x'_oil_clean_`z'.dta"
		rename _merge mer_`x'`z'
	}
}

destring codmpio, replace
tostring codmpio, replace

sa "${oil}/full_oil.dta", replace




/*------------------------------------------------------------------------------
						
								GEO ANOMALIAS
						
------------------------------------------------------------------------------*/

     *** CENTROIDES E INTERSECCIONES ***
	 
foreach x in ce i {

     use "${geo}/`x'nt_mpios_geo.dta", replace

	 capture drop coord* // bug to be fixed
	 capture drop na* // bug to be fixed
	 
     gen `x'nt_potencial_a=1 if POTENCIAL=="Alto"
     recode `x'nt_potencial_a(.=0)
     gen `x'nt_potencial_m=2 if POTENCIAL=="Medio"
     recode `x'nt_potencial_m(.=0)
     gen `x'nt_potencial_b=1 if POTENCIAL=="Bajo"
     recode `x'nt_potencial_b(.=0)

     gen codmpio=substr(admin2Pcod,3,.)
     
     keep *potencial_* codmpio

     collapse (max) *potencial*, by(codmpio)

     if "`x'"=="i"{
          label var `x'nt_potencial_a "Hay areas hasta con potencial aurífero alto que intersecan al mpio"
          label var `x'nt_potencial_m "Hay areas hasta con potencial aurífero medio que intersecan al mpio"
          label var `x'nt_potencial_b "Hay areas hasta con potencial aurífero bajo que intersecan al mpio"
     }

     else {
          label var `x'nt_potencial_a "Hay areas hasta con potencial aurífero alto que tienen centroide en mpio"
          label var `x'nt_potencial_m "Hay areas hasta con potencial aurífero medio que tienen centroide en mpio"
          label var `x'nt_potencial_b "Hay areas hasta con potencial aurífero bajo que tienen centroide en mpio"
     }
     sa "${geo}/`x'nt_geo_clean.dta", replace
}



      *** ÁREAS ***
          
use "${geo}/area_mpios_geo.dta", replace

	 capture drop coord* // bug to be fixed
	 capture drop na* // bug to be fixed
	 
gen codmpio=substr(admin2Pcod,3,.)
rename a_inter_pc a_inter_pc_geo
keep codmpio a_inter_pc*
sort codmpio

collapse (sum) a_inter_pc, by(codmpio)

sa "${geo}/area_geo_clean.dta", replace

           *** MERGE DATA ***

use "${geo}/int_geo_clean.dta", clear
merge 1:1 codmpio using "${geo}/cent_geo_clean.dta"
rename _merge mer_ce_geo
merge 1:1 codmpio using "${geo}/area_geo_clean.dta"
rename _merge mer_are_geo

destring codmpio, replace
tostring codmpio, replace

sa "${geo}/full_geo.dta", replace


/*******************************************
            MERGE ALL OIL, MINING, GEO. 
*******************************************/

use "${data}/Mineria/harm/t_s_j.dta", clear
merge 1:1 codmpio using "${oil}/full_oil.dta"
rename _merge mer_oil
merge 1:1 codmpio using "${geo}/full_geo.dta"
rename _merge mer_geo

*sa "${data}/full-harm/t_s_jac_oil_geo.dta", replace

/*******************************************
            MERGE WITH WATER 
*******************************************/

merge 1:1 codmpio using "${agua}/agua_ideam.dta", gen(mer_agua)
compress
*sa "${data}/full-harm/water_mine_oil_geo.dta", replace


/*******************************************
            MERGE WITH PRODUCTION 
*******************************************/

merge 1:1 codmpio using "${data}/Mineria/prod_wide.dta"
compress 
sa "${data}/full-harm/water_mine_oil_geo_prod.dta", replace


/*------------------------------------------------------------------------------
						
								OIL WELLS
			These come in panel, so will be treated different
------------------------------------------------------------------------------*/

use "${oil}/mpio_pozos_all.dta", clear

* gen variables that might be usefull

gen spud_y=substr(WELL_SPUD_,1,4)
gen spud_s=substr(WELL_SPUD_,6,2)
destring spud_s, replace 
replace spud_s=1 if spud_s<6 // first semester of the year
replace spud_s=2 if spud_s>5 // second semester of the year

gen codmpio=substr(admin2Pcod,3,5) 

* rename to easier names

rename CLAS_FINAL clas_f 
rename WELL_STA_1 status_w
rename WELL_COMPL compl_w
rename CONTRATO contrato
rename WELL_LONGI long_w
rename WELL_LATIT lat_w

*give intuitive labels 

label var spud_y "Starting year of well drilling"
label var spud_s "Semester of well drilling; second or first"
label var clas_f "Final classification of well"
label var status_w "Status of well as of 04/2020"
label var compl_w "Well completion date"
label var contrato "Name of oil contract where the well is located"
label var long_w "coordinate of well Longitude"
label var lat_w "coordinate of well Latitude"


keep codmpio spud_y spud_s clas_f status_w compl_w contrato long_w lat_w

destring codmpio, replace
tostring codmpio, replace 


sa "${oil}/mpio_pozos_all_cleaned.dta", replace

gen nwell=1

collapse (sum) nwell (min) spud_y, by(codmpio)

gen well=1

merge 1:1 codmpio using "${data}/full-harm/water_mine_oil_geo_prod.dta", gen(mer_well)

sa "${data}/full-harm/water_mine_oil_geo_prod.dta", replace








