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
use "${hk}/raw/HumanCapital_isic.dta", clear // la version del paper se hizo con los datos sin isic. Chequear que de lo mismo después. 

* first leave only the individuals that have info on the location of the schools and the school id

keep if lat_cole!=. & lon_cole!=. & colegio_cod!=.
/*
 unique CódigoMunicipio
Number of unique values of CódigoMunicipio is  1108
*/

rename CódigoMunicipio codmpio
merge m:1 codmpio using "${municipios}/poblacion_mpios.dta", gen (mer_pobl) // there is one municipality code: the 27086 that does not belong to any municipality really. 
drop if mer_pobl!=3
unique codmpio

/*
unique codmpio
Number of unique values of codmpio is  1107
*/


*drop if pobl_tot>200000
gen pob200=1 if pobl_tot>200000
recode  pob200(.=0) 

drop if pob200==1 // las diferencias sutiles que tenia pueden ser porque calculo con toda la poblacion. Necesito calcular con la poblacion que usamos (desviaciones estandar y esas cosas)

gen pob100=1 if pobl_tot>100000
recode  pob100(.=0) 

unique codmpio

/*
unique codmpio
Number of unique values of codmpio is  1081
*/

compress

drop if colegio_cod==19257 | colegio_cod==52936 | colegio_cod==116657 |	colegio_cod==32649 | colegio_cod==69146 | colegio_cod==78071 | colegio_cod==87403 |	colegio_cod==104968 | colegio_cod==109900 |	colegio_cod==147116 | colegio_cod==37622 | colegio_cod==19265 |	colegio_cod==19273 | colegio_cod==36392 | colegio_cod==128918 | colegio_cod==128926 | colegio_cod==32631 |	colegio_cod==156323 | colegio_cod==30932 | colegio_cod==48058 | colegio_cod==10736 | colegio_cod==95729 | colegio_cod==154864 | colegio_cod==15081 // these are schools that ere either in San andres or that the geocode is not correct. 


sa "${hk}/raw/HumanCapital_clean.dta", replace


/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------

								INDIVIDUAL LEVEL
								
--------------------------------------------------------------------------------

------------------------------------------------------------------------------*/

		* Create Human Cpital Accumulation Measures
* Open raw human capital

use "${hk}/raw/HumanCapital_clean.dta", clear


* keep only variables that you need. 

keep prog_area periodo year periodoprimiparo pct2 Cale_A colegio_cod codmpio ies annonac mujer desertor academico universitario publica lat_cole lon_cole oficial urbano  date_grad graduado pob200 pob100 id //TDCp* TibcpA* TDCs* TibcsA* 

rename id id_individuo

label var prog_area "Area of HEI program"
label var periodo "Period of ICFES"
label var periodoprimiparo "Periodo en el que entró a la IES"
label var pct2 "Percentil of student in ICFES exit exam"
label var Cale_A "Colegio calendario A (enero-diciembre)"
label var colegio_cod "codigo del colegio donde se graduó"
label var codmpio "Municipality of high school" // a esto le puedo hacer un double check
label var year "Año de graduación secundaria" // a esto le puedo hacer un double check
label var mujer "1 = female"
label var annonac "año de nacimiento"
label var desertor "=1 if deserted from HEI" 
label var academico "=1 if academic high school"
label var universitario "=1 if academic HEI"
label var publica "=1 if HEI is public"
label var oficial "=1 if school is public"
label var urbano "=1 if urban school"
label var date_grad "year of graduation from HEI"
label var graduado "graduated from HEI"
label var pob200 "municipality has over 200k inhabitants"
label var pob100 "municipality has over 100k inhabitants"
label var id_individuo "individual random id"


* Important Value labels

label define vals_prog_area 1 "Agronomia, veterinaria y afines" 2 "Bellas Artes" 3 "Ciencias de la Educacion" 4 "Ciencias de la Salud" 5 "Ciencias Sociales, derecho, ciencias politicas" 6 "Economia Administracion, Contaduria y afines" 7 "Humanidades y ciencias religiosas" 8 "Ingenieria, arquitectura, urbanismo y afines" 9 "Matematicas y ciencias naturales"


label values prog_area vals_prog_area

					* Create the HK outcomes 

tostring periodo, g(periodos)   // notice that I am doing everything at the year level. I will also prepare the code for the semester level. The dummy of Calendar A or B should be able to control this.  
gen year_period=substr(periodos,1,4)
drop if year_period=="."  // take out those observation that do not have time info. 

gen graduated=1 if year!=. // Almost everybody in this data is graduated. This was obvious from the beginning since the ICFES is a graduation test. 
recode graduated(.=0) // a very small portion
label var graduated "Actually graduated from high school"

gen enroled_he=1 if periodoprimiparo!=. // for the enrolment rate
recode enroled_he(.=0)
label var enroled_he "enroled in higher education"


gen rent_seeker=1 if prog_area==5 | prog_area==6
replace rent_seeker=0 if enroled_he==1 & rent_seeker==.
label var rent_seeker "went to a rent seeking programm (econ, scipol,etc)"

gen non_rent_seeker_1=1 if prog_area==8 // definition according to Ebbeke, Laajaj & Omgba
replace non_rent_seeker_1=0 if enroled_he==1 & non_rent_seeker_1==.
label var non_rent_seeker "went to a non-rent seeking programm (ingeniería, etc) Ebbeke et al"

gen non_rent_seeker_2=1 if prog_area==8 | prog_area==9 // making it a little bit broader
replace non_rent_seeker_2=0 if enroled_he==1 & non_rent_seeker_2==.
label var non_rent_seeker_2 "went to a non rent seeking programm (ingeniería, sciences,etc) my extended version"

gen technic=1 if universitario==0
replace technic=0 if universitario==1
label var technic "=1 if it is technical HEI"

gen private=1 if publica==0
replace private=0 if publica==1

label var private "Private HEI"

rename desertor deserted
rename publica public
rename academico academic

rename colegio_cod id_cole // to merge it with info of number of wells.

* creating a measure of how long it takes to go to the university

tostring periodoprimiparo, gen(year_prim)
replace year_prim=substr(year_prim,1,4)
destring year_prim, replace
gen timetohe=year_prim-year

replace timetohe=. if timetohe<0 // this is impossible and must be due to digiting errors or what do I know, but it should not exist
label var timetohe "Time from graduation date to first year in college"



* I am going to refine that measure a little bit. 

tempvar primiyear
tempvar primihalf
tempvar preriodoprimiparosa
tostring periodoprimiparo, gen(`preriodoprimiparosa')
gen `primihalf'=substr(`preriodoprimiparosa',5,1)
gen `primiyear'=substr(`preriodoprimiparosa',1,4)
gen preriodoprimiparos=`primiyear'+"/0"+`primihalf'
gen per_prim=halfyearly(preriodoprimiparos,"YH")
format per_prim %th


tempvar icfesyear
tempvar icfeshalf
tempvar icfespera
gen `icfespera'= periodos
gen `icfeshalf'=substr(`icfespera',5,1)
gen `icfesyear'=substr(`icfespera',1,4)
gen icfesper=`icfesyear'+"/0"+`icfeshalf'
gen per_icf=halfyearly(icfesper,"YH")
format per_icf %th
tab per_prim
tab per_icf


gen semestertohe=per_prim-per_icf
replace semestertohe=. if semestertohe<=0 // this is impossible. No student is able to enrol in HE without ICFES. 
label var semestertohe "Time from graduation date to first semester in college"

**** How long it takes to graduated

gen timetograd=date_grad-year_prim
replace timetograd=. if timetograd<=0 

*but this should affect all of my other variables as well 

foreach x in private technic non_rent_seeker_2 non_rent_seeker_1 rent_seeker enroled_he public universitario deserted {
	
	sum `x' if semestertohe==. // I will better do it with semesters rather than years. The first results that I ran were with timetohe.  
	sum `x' if timetohe==. // I will better do it with semesters rather than years. The first results that I ran were with timetohe.  

	*replace `x'==. if semestertohe==. // I lose too way to many observations. 
	
}

destring year_period, gen(year2)
gen age=year2-annonac
gen age2=age
replace age2=. if age<14 //reaññy weird to have those values


* Create like a quality measures

bys id_cole: egen qual_over=mean(pct2) // the reason why this do not serve is because they are simpply captured by the school FE
bys id_cole: egen qual_over_sd=sd(pct2) // captured by the school FE

label var qual_over "Mean of ICFES pctile by school using all students and years"
label var qual_over_sd "SD of ICFES pctile by school using all students and years"


*label define vals_prog_area 1 "Agronomia, veterinaria y afines" 2 "Bellas Artes" 3 "Ciencias de la Educacion" 4 "Ciencias de la Salud" 5 "Ciencias Sociales, derecho, ciencias politicas" 6 "Economia Administracion, Contaduria y afines" 7 "Humanidades y ciencias religiosas" 8 "Ingenieria, arquitectura, urbanismo y afines" 9 "Matematicas y ciencias naturales"

* 5 y 6 rent seeker
* New enrolment type decisions
gen tec_eng=1 if technic==1 & rent_seeker==1
replace tec_eng=0 if technic==1 & rent_seeker!=1

gen stemi=(prog_area==9)
gen engi=(prog_area==8)
gen engistemi=(prog_area==8 | prog_area==9)
gen humanidades=(prog_area==2 | prog_area==7 | prog_area==3)
gen health=(prog_area==1 | prog_area==4)
gen admin_econ=(prog_area==5 | prog_area==6)

gen others=(prog_area==1 | prog_area==4 | prog_area==2 | prog_area==7 | prog_area==3)

foreach x in stemi engi engistemi humanidades health admin_econ others{

	replace `x'=. if enroled_he==0
	
	gen tec`x'=technic*`x'
	replace tec`x'=. if technic==0
	
	gen pro`x'=universitario*`x'
	replace pro`x'=. if universitario==0

	

}


*Immediate and Late enrollment as in the Chile Paper

gen ti_enrol1=0 if enroled_he==0 // no enrollment
replace ti_enrol1=1 if enroled_he==1 & semestertohe<3 // immediate enrollment
replace ti_enrol1=2 if enroled_he==1 & semestertohe>2 // late enrollment


gen ti_enrol2=0 if enroled_he==0 // no enrollment
replace ti_enrol2=1 if enroled_he==1 & semestertohe<2 // immediate enrollment
replace ti_enrol2=2 if enroled_he==1 & semestertohe>1 // late enrollment




compress

sa "${hk}/harm/hk_individual.dta", replace




/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------

								SCHOOL LEVEL
								
--------------------------------------------------------------------------------

------------------------------------------------------------------------------*/

use "${hk}/harm/hk_individual.dta", clear
*drop _*
foreach x in pct2 timetohe semestertohe{
	gen `x'_m=`x'
}

gen pct2_sd=pct2
label var pct2_sd "SD of ICFES"
label var pct2_m "Meadian of ICFES"
label var timetohe_m "Meadian of time to HEI"
gen estudiantes=1

foreach x in 1 2 {
	
	gen imen_`x'=1 if ti_enrol`x'==1
	recode imen_`x'(.=0)
	gen laen_`x'=1 if ti_enrol`x'==2
	recode laen_`x'(.=0)

	
}

* collapse at the school level
cd "${data}"
include copylabels // To copy the labels. You have to have this code. 
collapse (sd) pct2_sd (median) pct2_m timetohe_m semestertohe_m (mean) qual_over* pct2 timetohe semestertohe (sum) graduado estudiantes graduated enroled_he rent_seeker non_rent_seeker_1 non_rent_seeker_2 universitario technic deserted public private imen_* laen_* (first) urbano oficial academic codmpio Cale_A lat_cole lon_cole pob200 pob100, by(year_period id_cole)
include attachlabels // To copy the labels. You have to have this code. 


*enrolment and completion rates

gen enrolment_rate=(enroled_he*100)/graduated
label var enrolment_rate "Higher education enrolment rate"

gen completion_rate=(graduado*100)/enroled_he
label var completion_rate "Higher education completion rate"

gen desertion_rate=(deserted*100)/enroled_he
label var desertion_rate "Higher education desertion rate"

*late and immediate enrolment rates
foreach x in 1 2 {
	gen imen`x'_rate=(imen_`x'*100)/graduated
	label var imen`x'_rate "Imeadiate enrolment rate version `x'"
	gen laen`x'_rate=(laen_`x'*100)/graduated
	label var laen`x'_rate "Late enrolment rate version `x'"

}

	* this are the same measures in Ebbeke
	
gen rentseeker_1=(rent_seeker-non_rent_seeker_1)*100/enroled_he
label var rentseeker_1 "rent seeker enroled intensity Ebbeke et al"

gen rentseeker_2=(rent_seeker-non_rent_seeker_2)*100/enroled_he
label var rentseeker_2 "rent seeker enroled intensity My extended version"

* This are my versions (more straightforward?)
gen rentseeker_3=(rent_seeker/non_rent_seeker_1)*100 // the results with either should be the same. Are constant and homogeneous transformations. 
label var rentseeker_3 "proportion of rent seeker Ebbeke et al"

gen rentseeker_4=(rent_seeker/non_rent_seeker_1)*100 // the results with either should be the same. Are constant and homogeneous transformations.
label var rentseeker_4 "proportion of rent seeker My extended version"


*Technical vs academic

gen uni_1=(universitario-technic)*100/enroled_he
label var uni_1 "academic program enroled intensity"

* This are my versions (more straightforward?)
gen uni_2=(universitario/technic)*100 // the results with either should be the same. Are constant and homogeneous transformations. 
label var uni_2 "proportion of academic HE program enroled"



destring year_period, gen(year)
compress
sa "${hk}/harm/hk_colegio.dta", replace




***** For completion and desertion I could take another appoach ****

use "${hk}/harm/hk_individual.dta", clear

*drop year_period year _*
*rename year_prim year


* collapse at the school level
cd "${data}"
include copylabels // To copy the labels. You have to have this code. 
collapse (sum) graduado deserted enroled_he (first) pob200, by(year id_cole)
include attachlabels // To copy the labels. You have to have this code. 



gen completion_rate=(graduado*100)/enroled_he
gen desertion_rate=(deserted*100)/enroled_he


label var completion_rate "Higher education completion rate"
label var desertion_rate "Higher education desertion rate"

compress
sa "${hk}/harm/hk_colegio_comp.dta", replace
**# Bookmark #1
/*

/*-----------------------------------------------------------------------------

					MUNICIPALITY LEVEL

-----------------------------------------------------------------------------*/

* collapse at the mpio level

use "${hk}/harm/hk_individual.dta", clear

foreach x in pct2 timetohe semestertohe{

	gen `x'_m=`x'

}


cd "${data}"
include copylabels // To copy the labels. You have to have this code. 
collapse (median) pct2_m timetohe_m semestertohe_m (mean) pct2 timetohe semestertohe (sum) graduated enroled_he rent_seeker non_rent_seeker_1 non_rent_seeker_2 universitario technic deserted public private, by(year_period codmpio)
include attachlabels // To copy the labels. You have to have this code. 



gen enrolment_rate=(enroled_he*100)/graduated
label var enrolment_rate "Higher education enrolment rate"

	* this are the same measures in Ebbeke
	
gen rentseeker_1=(rent_seeker-non_rent_seeker_1)*100/enroled_he
label var rentseeker_1 "rent seeker enroled intensity Ebbeke et al"

gen rentseeker_2=(rent_seeker-non_rent_seeker_2)*100/enroled_he
label var rentseeker_2 "rent seeker enroled intensity My extended version"

* This are my versions (more straightforward?)
gen rentseeker_3=(rent_seeker/non_rent_seeker_1)*100 // the results with either should be the same. Are constant and homogeneous transformations. 
label var rentseeker_3 "proportion of rent seeker Ebbeke et al"

gen rentseeker_4=(rent_seeker/non_rent_seeker_1)*100 // the results with either should be the same. Are constant and homogeneous transformations.
label var rentseeker_4 "proportion of rent seeker My extended version"


*Technical vs academic

gen uni_1=(universitario-technic)*100/enroled_he
label var uni_1 "academic program enroled intensity"

* This are my versions (more straightforward?)
gen uni_2=(universitario/technic)*100 // the results with either should be the same. Are constant and homogeneous transformations. 
label var uni_2 "proportion of academic HE program enroled"

gen deserted_rate=deserted/enroled_he
label var deserted_rate "desertors rate"


destring year_period, gen(year)
compress
sa "${hk}/harm/hk_mpio.dta", replace

