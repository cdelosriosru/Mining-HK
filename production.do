**************************************************************************************
* PROJECT :     	Mining - HK
* AUTHOR :				Camilo De Los Rios
* PURPOSE :				clear and merge production data
* SOURCE :        GitHub
**************************************************************************************

      * PATHS
      
global data "C:/Users/camilodel/Desktop/IDB/MINING-HK/DATA"
global tit_min "${data}/Mineria"
global geo "${data}/Mineria/geo/harm"
global oil "${data}/Petroleo/harm"
global agua "${data}/Agua/oferta_Colombia/harm"
global inst "${data}/PoliticalBoundaries/Colombia"

import delimited "${tit_min}/produccion_col.csv", clear
rename ÿþyearoffecha year
replace gr=subinstr(gr,",","",.)
rename gr oro
destring oro, replace
label var oro "produccion de oro"
drop if quarteroffecha=="Total"
drop if year<2004
rename departamento dpto
rename municipio mpio
drop if mpio=="Total"
replace dpto="N. DE SANTANDER" if dpto=="NORTE _DE_SANTANDER"
replace dpto="VALLE DEL CAUCA"  if dpto == "VALLE_DEL_CAUCA"
replace mpio="LA PEDRERA (CD)" if mpio=="LA PEDRERA"
replace mpio="PUERTO ARICA (CD)" if mpio=="PUERTO ARICA"
replace mpio="PUERTO SANTANDER (CD)" if mpio=="PUERTO SANTANDER"
replace mpio="TARAPACA (CD)" if mpio=="TARAPACA"
replace mpio="MOMPOX" if mpio=="MOMPOS"
replace mpio="MAGUI" if mpio=="MAGsI"
replace mpio="PEÑOL" if mpio=="PEÐOL"


merge m:1 dpto mpio using "${inst}/cod_DANE.dta"
drop if _merge!=3
drop _merge
collapse (sum) oro, by (codmpio year)
reshape wide oro, i(codmpio) j(year)
recode oro*(.=0)
sa "${tit_min}/prod_wide.dta"














