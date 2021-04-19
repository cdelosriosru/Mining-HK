

global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global oil "${data}/Petroleo"
global hk "${data}/HK"
global municipios "${data}/PoliticalBoundaries"
global compiled "${data}/compiled_sets"
global results "C:/Users/cdelo/Dropbox/HK_Extractives_2020/RESULTS/Municipality"
global overleaf "C:/Users/cdelo/Dropbox/Apps/Overleaf/Oil - HK - Colombia/resultados"

/*------------------------------------------------------------------------------

			MUNICIPALITY LEVEL

------------------------------------------------------------------------------*/

**	clean control group


* Prepare data

foreach k in iv iv_boom{

	forvalues x=1950(1)2001{

		foreach y in  timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {  
			
			use "${results}/control_contamination/`k'_`y'_`x'.dta", clear
				
			gen year=`x'
				
			sa, replace
		}
	}

	foreach y in timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {
	  
		use "${results}/control_contamination/`k'_`y'_1950.dta", clear
		
		forvalues x=1951(1)2001{

			append using "${results}/control_contamination/`k'_`y'_`x'.dta"
		}
		
		replace estimate = 0 if estimate == .
		replace min95 = 0 if min95 == .
		replace max95 = 0 if max95 == .
		sort year
		sa "${results}/control_contamination/`k'_`y'.dta", replace
	}


	*graph 


	foreach y in  timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {

		use "${results}/control_contamination/`k'_`y'.dta", clear
		twoway (connected estimate year , lc(gs0) ) ///
		(rcap min95 max95 year , lc(gs12) fc(gs12)), ///
		xlabel(1950(10)2000) ///
		xtitle("`k' base year") ///
		ytitle("Coefficient") ///
		title("`y'") ///
		yline(0, lc(red) ) ///
		ylabel(, grid ) ///
		graphregion(color(white)) /// 
		legend(off)

		gr export "${overleaf}/mpio/control_contamination/r_`k'_`y'.pdf", replace
	}

}


* basic trends

foreach trend in t_dep t_etc{
	foreach k in _ _boom_{

		forvalues x=1950(1)2001{

			foreach y in  timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {  
				
				use "${results}/trends/`trend'`k'`y'_`x'.dta", clear
					
				gen year=`x'
					
				sa, replace
			}
		}

		foreach y in timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {
		  
			use "${results}/trends/`trend'`k'`y'_1950.dta", clear
			
			forvalues x=1951(1)2001{

				append using "${results}/trends/`trend'`k'`y'_`x'.dta"
			}
			
			replace estimate = 0 if estimate == .
			replace min95 = 0 if min95 == .
			replace max95 = 0 if max95 == .
			sort year
			sa "${results}/trends/`trend'`k'`y'.dta", replace
		}


		*graph 


		foreach y in  timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {

			use "${results}/trends/`trend'`k'`y'.dta", clear
			twoway (connected estimate year , lc(gs0) ) ///
			(rcap min95 max95 year , lc(gs12) fc(gs12)), ///
			xlabel(1950(10)2000) ///
			xtitle("`k' base year") ///
			ytitle("Coefficient") ///
			title("`y'") ///
			yline(0, lc(red) ) ///
			ylabel(, grid ) ///
			graphregion(color(white)) /// 
			legend(off)

			gr export "${overleaf}/mpio/trends/`trend'`k'`y'.pdf", replace
		}

	}
}





* polynomial trends

foreach trend in dep1 dep2 etc1 etc2{
	foreach k in _ _boom_{

		forvalues x=1950(1)2001{

			foreach y in  timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {  
				
				use "${results}/poly_trends/`trend'`k'`y'_`x'.dta", clear
					
				gen year=`x'
					
				sa, replace
			}
		}

		foreach y in timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {
		  
			use "${results}/poly_trends/`trend'`k'`y'_1950.dta", clear
			
			forvalues x=1951(1)2001{

				append using "${results}/poly_trends/`trend'`k'`y'_`x'.dta"
			}
			
			replace estimate = 0 if estimate == .
			replace min95 = 0 if min95 == .
			replace max95 = 0 if max95 == .
			sort year
			sa "${results}/poly_trends/`trend'`k'`y'.dta", replace
		}


		*graph 


		foreach y in  timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {

			use "${results}/poly_trends/`trend'`k'`y'.dta", clear
			twoway (connected estimate year , lc(gs0) ) ///
			(rcap min95 max95 year , lc(gs12) fc(gs12)), ///
			xlabel(1950(10)2000) ///
			xtitle("`k' base year") ///
			ytitle("Coefficient") ///
			title("`y'") ///
			yline(0, lc(red) ) ///
			ylabel(, grid ) ///
			graphregion(color(white)) /// 
			legend(off)

			gr export "${overleaf}/mpio/poly_trends/`trend'`k'`y'.pdf", replace
		}

	}
}








/*------------------------------------------------------------------------------


								INDIVIDUAL LEVEL

------------------------------------------------------------------------------*/

global results "C:/Users/cdelo/Dropbox/HK_Extractives_2020/RESULTS/Individual"
global overleaf "C:/Users/cdelo/Dropbox/Apps/Overleaf/Oil - HK - Colombia/resultados"



foreach x in 1990 2000 {
	foreach w in 5000 20000 30000 {
		foreach y in  pct2 { //enroled_he rent_seeker universitario deserted timetohe semestertohe { 
		
			use "${results}/trends/SF_`y'_`x'_`w'.dta" , clear
			gen year=`x'
			gen buffer=`w'
			sa, replace
			
			use "${results}/poly_trends/dep1_`y'_`x'_`w'.dta" , clear
			gen year=`x'
			gen buffer=`w'
			sa, replace
			
			use "${results}/poly_trends/dep2_`y'_`x'_`w'" , clear
			gen year=`x'
			gen buffer=`w'
			sa, replace
			
		}
	}
}

*------- STATE FIXED EFFECTS--------

foreach y in pct2 { //enroled_he rent_seeker universitario deserted timetohe semestertohe { 

	foreach w in 5000 20000 30000{

	use "${results}/trends/SF_`y'_1990_`w'.dta" , clear
	append using "${results}/trends/SF_`y'_2000_`w'.dta"
	
	replace estimate = 0 if estimate == .
	replace min95 = 0 if min95 == .
	replace max95 = 0 if max95 == .
	sort year
	sa "${results}/trends/SF_`y'_`w'.dta", replace
}

	use "${results}/trends/SF_`y'_5000.dta", clear
	append using "${results}/trends/SF_`y'_20000.dta"
	append using "${results}/trends/SF_`y'_30000.dta"

	sa "${results}/trends/SF_`y'.dta", replace 
}

*graph 


foreach y in   pct2 { //enroled_he rent_seeker universitario deserted timetohe semestertohe { 
gr drop _all
	use "${results}/trends/SF_`y'.dta", clear
	
	twoway (connected estimate year if buffer==5000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==5000 , lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("5km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (a_`y')
	
	twoway (connected estimate year if buffer==20000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==20000 , lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("20km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (b_`y')
	
	twoway (connected estimate year if buffer==30000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==30000, lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("30km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (c_`y')
	
	gr combine a_`y' b_`y' c_`y'

	gr export "${overleaf}/individual/r_`y'.pdf", replace
}


*------- POLY TREND 1--------

foreach y in pct2 { //enroled_he rent_seeker universitario deserted timetohe semestertohe { 

	foreach w in 5000 20000 30000{

	use "${results}/poly_trends/dep1_`y'_1990_`w'.dta" , clear
	append using "${results}/poly_trends/dep1_`y'_2000_`w'.dta"
	
	replace estimate = 0 if estimate == .
	replace min95 = 0 if min95 == .
	replace max95 = 0 if max95 == .
	sort year
	sa "${results}/poly_trends/dep1_`y'_`w'.dta", replace
}

	use "${results}/poly_trends/dep1_`y'_5000.dta", clear
	append using "${results}/poly_trends/dep1_`y'_20000.dta"
	append using "${results}/poly_trends/dep1_`y'_30000.dta"

	sa "${results}/poly_trends/dep1_`y'.dta", replace 
}

*graph 


foreach y in   pct2 { //enroled_he rent_seeker universitario deserted timetohe semestertohe { 
gr drop _all
	use "${results}/poly_trends/dep1_`y'.dta", clear
	
	twoway (connected estimate year if buffer==5000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==5000 , lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("5km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (a_`y')
	
	twoway (connected estimate year if buffer==20000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==20000 , lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("20km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (b_`y')
	
	twoway (connected estimate year if buffer==30000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==30000, lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("30km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (c_`y')
	
	gr combine a_`y' b_`y' c_`y'

	gr export "${overleaf}/individual/dep1_`y'.pdf", replace
}



*------- POLY TREND 2--------

foreach y in pct2 { //enroled_he rent_seeker universitario deserted timetohe semestertohe { 

	foreach w in 5000 20000 30000{

	use "${results}/poly_trends/dep2_`y'_1990_`w'.dta" , clear
	append using "${results}/poly_trends/dep2_`y'_2000_`w'.dta"
	
	replace estimate = 0 if estimate == .
	replace min95 = 0 if min95 == .
	replace max95 = 0 if max95 == .
	sort year
	sa "${results}/poly_trends/dep2_`y'_`w'.dta", replace
}

	use "${results}/poly_trends/dep2_`y'_5000.dta", clear
	append using "${results}/poly_trends/dep2_`y'_20000.dta"
	append using "${results}/poly_trends/dep2_`y'_30000.dta"

	sa "${results}/poly_trends/dep2_`y'.dta", replace 
}

*graph 


foreach y in  pct2 { //enroled_he rent_seeker universitario deserted timetohe semestertohe { 
gr drop _all
	use "${results}/poly_trends/dep2_`y'.dta", clear
	
	twoway (connected estimate year if buffer==5000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==5000 , lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("5km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (a_`y')
	
	twoway (connected estimate year if buffer==20000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==20000 , lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("20km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (b_`y')
	
	twoway (connected estimate year if buffer==30000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==30000, lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("30km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (c_`y')
	
	gr combine a_`y' b_`y' c_`y'

	gr export "${overleaf}/individual/dep2_`y'.pdf", replace
}



/*------------------------------------------------------------------------------
							
							GENDER HET EFFECT

------------------------------------------------------------------------------*/

foreach x in 1990 2000 {
	foreach w in 5000 20000 30000 {
		foreach y in  enroled_he rent_seeker universitario deserted timetohe semestertohe { 
		
			use "${results}/trends/ma_SF_`y'_`x'_`w'.dta" , clear
			gen year=`x'
			gen buffer=`w'
			sa, replace
			
			use "${results}/poly_trends/ma_dep1_`y'_`x'_`w'.dta" , clear
			gen year=`x'
			gen buffer=`w'
			sa, replace
			
			use "${results}/poly_trends/ma_dep2_`y'_`x'_`w'" , clear
			gen year=`x'
			gen buffer=`w'
			sa, replace
			
		}
	}
}

*------- STATE FIXED EFFECTS--------

	use "${results}/trends/ma_SF_enroled_he_1990_5000.dta" , clear

foreach y in enroled_he rent_seeker universitario deserted timetohe semestertohe {

	foreach w in 5000 20000 30000{

	use "${results}/trends/ma_SF_`y'_1990_`w'.dta" , clear
	append using "${results}/trends/ma_SF_`y'_2000_`w'.dta"
	
	replace estimate = 0 if estimate == .
	replace min95 = 0 if min95 == .
	replace max95 = 0 if max95 == .
	sort year
	sa "${results}/trends/ma_SF_`y'_`w'.dta", replace
}

	use "${results}/trends/ma_SF_`y'_5000.dta", clear
	append using "${results}/trends/ma_SF_`y'_20000.dta"
	append using "${results}/trends/ma_SF_`y'_30000.dta"

	sa "${results}/trends/ma_SF_`y'.dta", replace 
}

*graph 


foreach y in   enroled_he rent_seeker universitario deserted timetohe semestertohe {
gr drop _all
	use "${results}/trends/ma_SF_`y'.dta", clear
		keep if parm=="ma_wells_accum"

	twoway (connected estimate year if buffer==5000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==5000 , lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("5km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (a_`y')
	
	twoway (connected estimate year if buffer==20000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==20000 , lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("20km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (b_`y')
	
	twoway (connected estimate year if buffer==30000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==30000, lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("30km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (c_`y')
	
	gr combine a_`y' b_`y' c_`y'

	gr export "${overleaf}/individual/ma_r_`y'.pdf", replace
}








*------- POLY TREND 1--------

foreach y in enroled_he rent_seeker universitario deserted timetohe semestertohe { // pct2

	foreach w in 5000 20000 30000{

	use "${results}/poly_trends/ma_dep1_`y'_1990_`w'.dta" , clear
	append using "${results}/poly_trends/ma_dep1_`y'_2000_`w'.dta"
	
	replace estimate = 0 if estimate == .
	replace min95 = 0 if min95 == .
	replace max95 = 0 if max95 == .
	sort year
	sa "${results}/poly_trends/ma_dep1_`y'_`w'.dta", replace
}

	use "${results}/poly_trends/ma_dep1_`y'_5000.dta", clear
	append using "${results}/poly_trends/ma_dep1_`y'_20000.dta"
	append using "${results}/poly_trends/ma_dep1_`y'_30000.dta"

	sa "${results}/poly_trends/ma_dep1_`y'.dta", replace 
}

*graph 


foreach y in   enroled_he rent_seeker universitario deserted timetohe semestertohe {
gr drop _all
	use "${results}/poly_trends/ma_dep1_`y'.dta", clear
		keep if parm=="ma_wells_accum"

	twoway (connected estimate year if buffer==5000  , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==5000 , lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("5km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (a_`y')
	
	twoway (connected estimate year if buffer==20000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==20000 , lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("20km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (b_`y')
	
	twoway (connected estimate year if buffer==30000  , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==30000, lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("30km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (c_`y')
	
	gr combine a_`y' b_`y' c_`y'

	gr export "${overleaf}/individual/ma_dep1_`y'.pdf", replace
}



*------- POLY TREND 2--------

foreach y in enroled_he rent_seeker universitario deserted timetohe semestertohe { // pct2

	foreach w in 5000 20000 30000{

	use "${results}/poly_trends/ma_dep2_`y'_1990_`w'.dta" , clear
	append using "${results}/poly_trends/ma_dep2_`y'_2000_`w'.dta"
	
	replace estimate = 0 if estimate == .
	replace min95 = 0 if min95 == .
	replace max95 = 0 if max95 == .
	sort year
	sa "${results}/poly_trends/ma_dep2_`y'_`w'.dta", replace
}

	use "${results}/poly_trends/ma_dep2_`y'_5000.dta", clear
	append using "${results}/poly_trends/ma_dep2_`y'_20000.dta"
	append using "${results}/poly_trends/ma_dep2_`y'_30000.dta"

	sa "${results}/poly_trends/ma_dep2_`y'.dta", replace 
}

*graph 

	use "${results}/poly_trends/ma_dep2_semestertohe.dta", clear

foreach y in   enroled_he rent_seeker universitario deserted timetohe semestertohe {
gr drop _all
	use "${results}/poly_trends/ma_dep2_`y'.dta", clear
	keep if parm=="ma_wells_accum"
	
	twoway (connected estimate year if buffer==5000, lc(gs0) ) ///
	(rcap min95 max95 year if buffer==5000 , lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("5km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (a_`y')
	
	twoway (connected estimate year if buffer==20000, lc(gs0) ) ///
	(rcap min95 max95 year if buffer==20000 , lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("20km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (b_`y')
	
	twoway (connected estimate year if buffer==30000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==30000, lc(gs12) fc(gs12)), ///
	xlabel(1990(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("30km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (c_`y')
	
	gr combine a_`y' b_`y' c_`y'

	gr export "${overleaf}/individual/ma_dep2_`y'.pdf", replace
}








/*

* Prepare data



forvalues x=1950(1)2001{

	foreach y in  timetohe_m { // enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe
		
		use "${results}/time_robust/ivmpio_y_m_`y'_`x'.dta", clear
			
		gen year=`x'
			
		sa, replace
	}
}

foreach y in timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {
  
	use "${results}/time_robust/ivmpio_y_m_`y'_1950.dta", clear
	
	forvalues x=1951(1)2001{

		append using "${results}/time_robust/ivmpio_y_m_`y'_`x'.dta"
	}
	
	replace estimate = 0 if estimate == .
	replace min95 = 0 if min95 == .
	replace max95 = 0 if max95 == .
	sort year
	sa "${results}/time_robust/ivmpio_y_m_`y'.dta", replace
}


*graph 


foreach y in  timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {

	use "${results}/time_robust/ivmpio_y_m_`y'.dta", clear
	twoway (connected estimate year , lc(gs0) ) ///
	(rcap min95 max95 year , lc(gs12) fc(gs12)), ///
	xlabel(1950(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("`y'") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off)

	gr export "${results}/time_robust/r_`y'.pdf", replace
}




/*

			School  LEVEL

*/

* Prepare data

foreach x in 1980 1990 2000 {
	foreach w in 20000 30000 {
		foreach y in  timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe { 
		
			use "${results}/time_robust/school/ivschool_y_m_`y'_`x'_`w'.dta" , clear
			gen year=`x'
			gen buffer=`w'
			sa, replace
			
		}
	}
}

foreach y in timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {

	foreach w in 20000 30000{

	use "${results}/time_robust/school/ivschool_y_m_`y'_2000_`w'.dta" , clear

	
	foreach x in 1980 1990{

		append using "${results}/time_robust/school/ivschool_y_m_`y'_`x'_`w'.dta"
	}
	
	replace estimate = 0 if estimate == .
	replace min95 = 0 if min95 == .
	replace max95 = 0 if max95 == .
	sort year
	sa "${results}/time_robust/school/ivschool_y_m_`y'_`w'.dta", replace
}

	use "${results}/time_robust/school/ivschool_y_m_`y'_20000.dta", clear
	append using "${results}/time_robust/school/ivschool_y_m_`y'_30000.dta"
	sa "${results}/time_robust/school/ivschool_y_m_`y'.dta", replace 
}

*graph 


foreach y in  timetohe_m enrolment_rate rentseeker_1 rentseeker_2 rentseeker_3 rentseeker_4 uni_1 uni_2 pct2 pct2_m timetohe {
gr drop _all
	use "${results}/time_robust/school/ivschool_y_m_`y'.dta", clear
	twoway (connected estimate year if buffer==20000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==20000 , lc(gs12) fc(gs12)), ///
	xlabel(1980(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("20km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (a_`y')
	
	twoway (connected estimate year if buffer==30000 , lc(gs0) ) ///
	(rcap min95 max95 year if buffer==30000, lc(gs12) fc(gs12)), ///
	xlabel(1980(10)2000) ///
	xtitle("IV base year") ///
	ytitle("Coefficient") ///
	title("30km buffer") ///
	yline(0, lc(red) ) ///
	ylabel(, grid ) ///
	graphregion(color(white)) /// 
	legend(off) ///
	name (b_`y')
	
	gr combine a_`y' b_`y'

	gr export "${results}/time_robust/school/r_`y'.pdf", replace
}



