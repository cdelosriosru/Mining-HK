
/*------------------------------------------------------------------------------
Objective: create descriptive stats and context graphs
-------------------------------------------------------------------------------*/

clear all
cls
global data "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA"
global oil "${data}/Petroleo"
global hk "${data}/HK"
global municipios "${data}/PoliticalBoundaries"
global results "${data}/results"
global compiled "${data}/compiled_sets"
global results "C:/Users/cdelo/Dropbox/HK_Extractives_2020/RESULTS"
global overleaf "C:/Users/cdelo/Dropbox/Apps/Overleaf/Oil - HK - Colombia"


/*------------------------------------------------------------------------------
		Pink Sheet data
-------------------------------------------------------------------------------*/

import excel "${data}/pinksheet.xlsx", sheet("Monthly Prices") cellrange(A7:CV734) firstrow case(lower) clear
tempfile prices
sa `prices'
import excel "${data}/pinksheet.xlsx", sheet("Monthly Indices") cellrange(A10:P734) firstrow case(lower) clear

merge 1:1 a using `prices'
gen year=substr(a,1,4)
foreach x in crude_brent crude_wti{
	replace `x'="." if `x'==".."
	destring `x', replace
}
collapse (mean) ienergy imetmin ibasemet ipreciousmet crude_petro crude_brent crude_wti, by(year)
destring year, replace
drop if year> 2018
drop if year<1985

label var ienergy "Energy Index"
label var imetmin "Metals & Minerals Index"
label var ibasemet "Base Metals Index"
label var ipreciousmet "Precious Metals Index"
label var crude_petro "Crude Price ($/bbl)"
label var crude_brent "Brent Price ($/bbl)"
label var ienergy "WTI price ($/bbl)"

sa "${data}/context/prices.dta", replace


/*------------------------------------------------------------------------------
			Natural Resources Rents
-------------------------------------------------------------------------------*/

wbopendata, country(LCN;COL) indicator(NY.GDP.MKTP.KD.ZG) long clear 




wbopendata, country(LCN;COL) indicator(NY.GDP.TOTL.RT.ZS; NY.GDP.PETR.RT.ZS; NY.GDP.COAL.RT.ZS; NY.GDP.MINR.RT.ZS; NY.GDP.MKTP.KD.ZG) long clear
drop if year<2000
drop if year>2018

foreach x in totl petr coal minr{

	bys countrycode: egen media10_`x'=mean(ny_gdp_`x'_rt_zs) if year>2007
	rename ny_gdp_`x'_rt_zs rents_`x'
}

rename ny_gdp_mktp_kd_zg gdp_growth


keep rents_* gdp_growth countrycode year

sa "${data}/context/rents_gdp.dta", replace

/*------------------------------------------------------------------------------
					 CONTEXT GRAPHS
-------------------------------------------------------------------------------*/

use "${data}/context/prices.dta", clear
merge 1:m year using "${data}/context/rents_gdp.dta"
keep if _merge==3


egen id=group(countrycode)
tsset id year, yearly
generate yeari = mofd(year) 
 

gen period=8 if year>2001 & year<2015
gen period2=-2 if year>2001 & year<2015

 
twoway (area period year,  lwidth(0) color(gs14) fintensity(inten50)) ///
(area period2 year,  lwidth(0) color(gs14) fintensity(inten50)) ///
(tsline gdp_growth if countrycode=="COL",  yaxis(1) lpattern(dash) lcolor(black))  ///
(tsline gdp_growth if countrycode=="LCN",  yaxis(1) lcolor(black) lpattern(dot)) ///
(tsline crude_petro, yaxis(2) lcolor(black) lpattern(solid)),  legend(pos(6)) legend(row(1)) ///
legend(order(1 "Study Period" 3 "Colombia" 4 "LAC" 5 "Oil Price (right axis)" )) ///
legend(ring(1))  ///
ytitle("GDP growth (%)") ///
ytitle("$/bbl", axis(2))  ///
xtitle("Year")  ///
xlabel(2000(3)2018) ///
 scheme(plotplainblind) // note("Oil price is an equally weighted measure of Brent, Dubai and WTI spot prices" "Source: Authors' calculations based on World Bank's pink sheet data and development indicators.", size(vsmall))
gr export "${overleaf}/graphs/gdpgrowth.pdf", replace


twoway (area period year,  lwidth(0) color(gs14) fintensity(inten50)) ///
(area period2 year,  lwidth(0) color(gs14) fintensity(inten50)) ///
(tsline rents_petr if countrycode=="COL",  yaxis(1) lpattern(dash) lcolor(black))  ///
(tsline rents_petr if countrycode=="LCN",  yaxis(1) lcolor(black) lpattern(dot)) ///
(tsline crude_petro, yaxis(2) lcolor(black) lpattern(solid)),  legend(pos(6)) legend(row(1)) ///
legend(order(1 "Study Period" 3 "Colombia" 4 "LAC" 5 "Oil Price (right axis)" )) ///
legend(ring(1))  ///
ytitle("Oil rents as % of GDP") ///
ytitle("$/bbl", axis(2))  ///
xtitle("Year")  ///
xlabel(2000(3)2018) ///
 scheme(plotplainblind) // note("Oil price is an equally weighted measure of Brent, Dubai and WTI spot prices" "Source: Authors' calculations based on World Bank's pink sheet data and development indicators.", size(vsmall))
gr export "${overleaf}/graphs/oilrents.pdf", replace

/*------------------------------------------------------------------------------
				Number of wells drilled by year and oil price
-------------------------------------------------------------------------------*/

use "${oil}/harm/wells_atributes_clean.dta", clear

gen wells=1 
collapse (sum) wells, by(year)
merge 1:1 year using "${data}/context/prices.dta"
keep if _merge==3

tsset year, yearly
 
twoway (tsline wells,  yaxis(1) lpattern(dash) lcolor(black))  ///
(tsline crude_petro,  yaxis(2) lcolor(black) lpattern(solid)),  legend(pos(6)) legend(row(1)) ///
legend(order(1 "Wells Drilled" 2 "Oil Price (right axis)" )) ///
legend(ring(1))  ///
ytitle("Number of Wells Drilled") ///
ytitle("$/bbl", axis(2))  ///
xtitle("Year")  ///
xlabel(1985(11)2018) ///
text(600 1996 "Correlation = 0.92", size(small) place(n)) ///
scheme(plotplainblind) // note("Oil price is an equally weighted measure of Brent, Dubai and WTI spot prices. The number of wells is a flow rather than a stock" "Source: Authors' calculations based on World Bank's pink sheet data and ANH data.", size(vsmall)) 
gr export "${overleaf}/graphs/wells.pdf", replace











