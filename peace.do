des spud_y
gen nwells=1
collapse (sum) nwells, by(spud_y codmpio)
rename spud_y year

merge m:1 codmpio using "C:\Users\cdelo\Dropbox\The Colors of Peace\DATA\farc.dta"

drop _merge

fillin codmpio year

recode nwells(.=0)
sort codmpio FARC1 

bys codmpio: egen farcsi=max(FARC1)

recode farcsi(.=0)

destring year, replace
tab year

tab year
unique codmpio


append using "C:\Users\cdelo\Dropbox\The Colors of Peace\DATA\cod_DANE.dta"


keep year codmpio nwells farcsi

unique codmpio

fillin codmpio year
drop _fillin
recode farcsi(.=0)
recode nwells(.=0)

tab year


gen paz=1 if year>2014
recode paz(.=0)

gen FARC= farcsi*paz


reghdfe wells_accum FARC if year<2017 & year>2012, absorb(year codmpio) vce(cluster codmpio)



unique year
local tope=r(unique)

*gen wells_accum=.

	forvalues n = 1(1)`tope' {
		cap drop i`n'
		bys codmpio: gen i`n' = 1 if  year[`n']>=year // & (year[`n']-year) <= 50
		bys codmpio: egen pozos`n' = total(nwells) if i`n'==1
		bys codmpio: replace wells_accum = pozos`n' if mi(wells_accum)
		drop  i`n'
		drop pozos`n'
	}




