/*------------------------------------------------------------------------------

 PROJECT :     	Mining - HK
 AUTHOR :		Camilo De Los Rios
 PURPOSE :		Create Human Capital Accumulation Measures.
				I am going to create a data set at the individual level, school level,
				and municipality level. That is the best that we can do.
				
				Each data set will be created separete so as to be able to include other measures in case we need 
				or think of them. 


------------------------------------------------------------------------------*/


global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global oil "${data}/Petroleo"
global hk "${data}/HK"
global municipios "${data}/PoliticalBoundaries"
global results "${data}/results"
global municipios "${data}/PoliticalBoundaries"


/*

	CLEAN THE ORIGINAL DATA SET TO MAKE IT EASIER TO MANAGE


*/
use "${hk}/harm/hk_colegio.dta", clear

* first leave only the individuals that have info on the location of the schools and the school id

drop if year>2014
gen first_year=year
gen numb_years=1
gen second_year=year-1


collapse (min) first_year second_year (sum) numb_years, by(id_cole)

gen keep1=(first_year==2002)
gen keep2=(first_year==2002 | first_year==2003)
gen keep3=(numb_years>5)

sa "${hk}/harm/clean_coles.dta", replace