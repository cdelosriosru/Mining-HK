**************************************************************************************

* PROJECT :     	Mining - HK
* AUTHOR :			Camilo De Los Rios
* PURPOSE :			Merge Mining, Oil and GEO-anomalies data Bases and create the one that I need for the estimations


**************************************************************************************

      * PATHS
      
global data "C:/Users/camilodel/Desktop/IDB/MINING-HK/DATA"
global tit_min "${data}/Mineria/titulos_colombia/harm"


/*------------------------------------------------------------------------------
						
						MINING TITLES & SOLICITUDES
						
------------------------------------------------------------------------------*/

 ***	INTERSECCIONES Y CENTROIDES		***

foreach z in ce i{

     foreach x in 08 10 17 {  

          use "${tit_min}/`z'nt_mpios_oro_t_`x'", clear

          decode admin2Pcod, gen(muni)
          decode FECHA_INSC, gen(datec)
          gen codmpio=substr(muni,3,.)
          destring codmpio, replace
          tostring codmpio, replace
          gen fecha_`z'nt_t_`x'=substr(datec,1,4)
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

          decode admin2Pcod, gen(muni)
          decode FECHA_RADI, gen(datec)
          gen codmpio=substr(muni,3,.)
          destring codmpio, replace
          tostring codmpio, replace
          gen fecha_`z'nt_s_`x'=substr(datec,1,4)
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
 
 
 
 
 
 
 
 
 
***			MERGE AREA, INTERSECIONES Y CENTROIDES		***

use "${tit_min}/int_clean_t_08.dta", clear

foreach x in int cent{
     foreach y in t s{
          foreach z in 08 10 17{          
               merge 1:1 codmpio using "${tit_min}/`x'_clean_`y'_`z'.dta"
               rename _merge mer_`x'`y'`z'
          }
     }
}

sa "${tit_min}/t_s.dta", replace

***			MERGE CON JACOME		***


merge 1:1 codmpio using "${data}/Mineria/jacome78.dta"
rename _merge m_jacome

sa "${data}/Mineria/harm/t_s_j.dta", replace  // save data that has titles, solicitudes and jácome data.



/*------------------------------------------------------------------------------
						
								OIL TITLES
						
------------------------------------------------------------------------------*/

 ***	INTERSECCIONES Y CENTROIDES		***
 
foreach x in ce i {

     use "${oil}/`x'nt_mpios_oil.dta"

     gen n_prod_`x'nt = 1 if ESTAD_AREA==2
     recode n_prod_`x'nt(.=0)
     gen n_expl_`x'nt = 1 if ESTAD_AREA==1
     recode n_expl_`x'nt(.=0)
     gen n_tea_`x'nt = 1 if ESTAD_AREA==3
     recode n_tea_`x'nt(.=0)

     decode admin2Pcod, gen(muni)
     decode FECHA_FIRM, gen(datec)

     gen codmpio=substr(muni,3,.)
     destring codmpio, replace
     tostring codmpio, replace

     gen fecha_`x'nt_oil=substr(datec,1,4)  

     gen fecha_`x'nt_oil_prod=substr(datec,1,4) if n_prod_`x'nt==1
     gen fecha_`x'nt_oil_expl=substr(datec,1,4) if n_expl_`x'nt==1
     gen fecha_`x'nt_oil_tea=substr(datec,1,4) if n_tea_`x'nt==1

     keep codmpio fecha_`x'n* *_`x'nt

     sort codmpio

     collapse (min) fecha* (sum) n_*, by(codmpio)

     gen prod_`x'nt = n_prod_`x'nt/n_prod_`x'nt
     recode prod_`x'nt(.=0)
     gen expl_`x'nt = n_expl_`x'nt/n_expl_`x'nt
     recode expl_`x'nt(.=0)
     gen tea_`x'nt = n_tea_`x'nt/n_tea_`x'nt
     recode tea_`x'nt(.=0)

     gen `x'nt_oil= 1 
     recode `x'nt_oil(.=0)

          if "`x'"=="i"{
               label var n_prod_int "Número de areas en producción que intersecan al mpio a 2017"
               label var n_expl_int "Número de areas en exploración que intersecan al mpio a 2017"
               label var n_tea_int "Número de areas en TEA que intersecan al mpio a 2017"
               label var prod_int "Hay áreas en producción que intersecan al mpio a 2017"
               label var expl_int "Hay áreas en exploración que intersecan al mpio a 2017"
               label var tea_int "Hay áreas en TEA que intersecan al mpio a 2017"
               label var int_oil "Hay áreas de hidrocarburos en el municipio"
               label var fecha_int_oil "Fecha más temprana de evidencia de área de hidrocarburos que interseca al mpio a 2017"
               label var fecha_int_oil_prod "Fecha más temprana de evidencia de área en producción que interseca al mpio a 2017"
               label var fecha_int_oil_expl "Fecha más temprana de evidencia de área en explotación que interseca al mpio a 2017"
               label var fecha_int_oil_tea "Fecha más temprana de evidencia de área en TEA que interseca al mpio a 2017"
          }

          else {
               label var n_prod_cent "Número de areas en producción que tienen centroide en mpio a 2017"
               label var n_expl_cent "Número de areas en exploración que tienen centroide en mpio a 2017"
               label var n_tea_cent "Número de areas en TEA que tienen centroide en mpio a 2017"
               label var prod_cent "Hay áreas en producción que tienen centroide en mpio a 2017"
               label var expl_cent "Hay áreas en exploración que tienen centroide en mpio a 2017"
               label var tea_cent "Hay áreas en TEA que tienen centroide en mpio a 2017"
               label var cent_oil "Hay áreas de hidrocarburos qur tienen centroide en en el municipio"
               label var fecha_cent_oil "Fecha más temprana de evidencia de área de hidrocarburos que tienen centroide en mpio a 2017"
               label var fecha_cent_oil_prod "Fecha más temprana de evidencia de área en producción que tienen centroide en mpio a 2017"
               label var fecha_cent_oil_expl "Fecha más temprana de evidencia de área en explotación que tienen centroide en mpio a 2017"
               label var fecha_cent_oil_tea "Fecha más temprana de evidencia de área en TEA que tienen centroide en mpio a 2017"
          }
          
     sa "${oil}/`x'nt_oil_clean.dta", replace
     
}


***			AREA		***
          
use "${oil}/area_mpios_oil.dta", replace
decode admin2Pcod, gen(muni)
gen codmpio=substr(muni,3,.)
destring codmpio, replace
tostring codmpio, replace
rename a_inter_pc a_inter_pc_oil
keep codmpio a_inter_pc*
sort codmpio
collapse (sum) a_inter_pc, by(codmpio)
sa "${oil}/area_oil_clean.dta", replace

***			MERGE AREA, INTERSECIONES Y CENTROIDES		***

use "${oil}/int_oil_clean.dta", clear
merge 1:1 codmpio using "${oil}/cent_oil_clean.dta"
rename _merge mer_ce_geo
merge 1:1 codmpio using "${oil}/area_oil_clean.dta"
rename _merge mer_are_geo

sa "${oil}/full_oil.dta", replace


/*------------------------------------------------------------------------------
						
								GEO ANOMALIAS
						
------------------------------------------------------------------------------*/

     *** CENTROIDES E INTERSECCIONES ***
	 
foreach x in ce i {

     use "${geo}/`x'nt_mpios_geo.dta", replace

     gen potencial_a=1 if POTENCIAL==1
     recode potencial_a(.=0)
     gen potencial_m=2 if POTENCIAL==3
     recode potencial_m(.=0)
     gen potencial_b=1 if POTENCIAL==2
     recode potencial_b(.=0)

     decode admin2Pcod, gen(muni)
     gen codmpio=substr(muni,3,.)
     destring codmpio, replace
     tostring codmpio, replace
     
     keep potencial_* codmpio

     collapse (max) potencial*, by(codmpio)

     if "`x'"=="i"{
          label var potencial_a "Hay areas hasta con potencial aurífero alto que intersecan al mpio"
          label var potencial_m "Hay areas hasta con potencial aurífero medio que intersecan al mpio"
          label var potencial_b "Hay areas hasta con potencial aurífero bajo que intersecan al mpio"
     }

     else {
          label var potencial_a "Hay areas hasta con potencial aurífero alto que tienen centroide en mpio"
          label var potencial_m "Hay areas hasta con potencial aurífero medio que tienen centroide en mpio"
          label var potencial_b "Hay areas hasta con potencial aurífero bajo que tienen centroide en mpio"
     }
     sa "${geo}/`x'nt_geo_clean.dta", replace
}



      *** ÁREAS ***
          
use "${geo}/area_mpios_geo.dta", replace
decode admin2Pcod, gen(muni)
gen codmpio=substr(muni,3,.)
destring codmpio, replace
tostring codmpio, replace
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

sa "${geo}/full_geo.dta", replace


/*******************************************
            MERGE ALL OIL, MINING, GEO. 
*******************************************/

use "${data}/Mineria/harm/t_s_jac.dta", clear
merge 1:1 codmpio using "${oil}/full_oil.dta"
rename _merge mer_oil
merge 1:1 codmpio using "${geo}/full_geo.dta"
rename _merge mer_geo

sa "${data}/full-harm/t_s_jac_oil_geo.dta", replace

/*******************************************
            MERGE WITH WATER 
*******************************************/

merge 1:1 codmpio using "${agua}/agua_ideam.dta", gen(mer_agua)
compress
sa "${data}/full-harm/water_mine.dta", replace


/*******************************************
            MERGE WITH PRODUCTION 
*******************************************/

merge 1:1 codmpio using "${data}/Mineria/prod_wide.dta"
compress 
sa "${data}/full-harm/water_mine_prod.dta", replace












