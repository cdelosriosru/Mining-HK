**************************************************************************************
* PROJECT :     	Mining - HK
* AUTHOR :		Camilo De Los Rios
* PURPOSE :		Estimations and descriptive data for HK paper
* SOURCE :          GitHub
**************************************************************************************

      * PATHS
      
global data "C:/Users/camilodel/Desktop/IDB/MINING-HK/DATA"
global resultados "C:/Users/camilodel/Desktop/IDB/MINING-HK/RESULTS"
global tit_min "${data}/Mineria/titulos_colombia/harm"
global geo "${data}/Mineria/geo/harm"
global oil "${data}/Petroleo/harm"
global agua "${data}/Agua/oferta_Colombia/harm"

/*******************************************
          clean and prepare data set 
*******************************************/


use "${data}/full-harm/water_mine_prod.dta", clear

destring fecha*, replace
recode n_*(.=0)

foreach x in int cent{
  foreach y in s t{
    foreach z in 08 10 17{
      recode `x'_`y'_`z' (.=0)
    }
  }
}

foreach x in int cent{
  foreach y in prod expl tea{
      recode `y'_`x' (.=0)
      recode n_`y'_`x' (.=0)
  }
}


foreach x in n_s_jacome area_jacome jacome potencial_a potencial_m potencial_b a_inter_pc_geo a_inter_pc_oil{
  recode `x' (.=0)
}

recode oro*(.=0)

drop *mer* secondname mpio2 m_jacome

/*******************************************
         Start resilience analysis
         
         started toi think this is useless.... let's try something else....
         
         code at the end, starts with :THE REAL THING
*******************************************/
/*
cd "${resultados}"

* Production and titles, solicitudes and Jacome

forvalues x = 2004(1)2011{
     sum oro`x' if oro`x'!=0 & jacome==1
     scalar a=r(N)
     sum oro`x' if oro`x'!=0
     scalar b=r(N)
     scalar j`x'=a/b
}

foreach k in t s{
     foreach y in ce i{
          foreach z in 08 10 17{
               forvalues x = 2004(1)2011{
                    sum oro`x' if oro`x'!=0 & `y'nt_`k'_`z'==1
                    scalar a=r(N)
                    sum oro`x' if oro`x'!=0
                    scalar b=r(N)
                    scalar j_`y'_`k'_`z'_`x'=a/b
               }
          }
     }
}
matrix A = (j2004,j2005,j2006,j2007,j2008,j2009,j2010,j2011 \ ///
j_i_t_08_2004, j_i_t_08_2005, j_i_t_08_2006, j_i_t_08_2007, j_i_t_08_2008, j_i_t_08_2009, j_i_t_08_2010, j_i_t_08_2011 \ ///
j_i_t_10_2004, j_i_t_10_2005, j_i_t_10_2006, j_i_t_10_2007, j_i_t_10_2008, j_i_t_10_2009, j_i_t_10_2010, j_i_t_10_2011 \ ///
j_i_t_17_2004, j_i_t_17_2005, j_i_t_17_2006, j_i_t_17_2007, j_i_t_17_2008, j_i_t_17_2009, j_i_t_17_2010, j_i_t_17_2011 \ ///
j_ce_t_08_2004, j_ce_t_08_2005, j_ce_t_08_2006, j_ce_t_08_2007, j_ce_t_08_2008, j_ce_t_08_2009, j_ce_t_08_2010, j_ce_t_08_2011 \ ///
j_ce_t_10_2004, j_ce_t_10_2005, j_ce_t_10_2006, j_ce_t_10_2007, j_ce_t_10_2008, j_ce_t_10_2009, j_ce_t_10_2010, j_ce_t_10_2011 \ ///
j_ce_t_17_2004, j_ce_t_17_2005, j_ce_t_17_2006, j_ce_t_17_2007, j_ce_t_17_2008, j_ce_t_17_2009, j_ce_t_17_2010, j_ce_t_17_2011 \ ///
j_i_s_08_2004, j_i_s_08_2005, j_i_s_08_2006, j_i_s_08_2007, j_i_s_08_2008, j_i_s_08_2009, j_i_s_08_2010, j_i_s_08_2011 \ ///
j_i_s_10_2004, j_i_s_10_2005, j_i_s_10_2006, j_i_s_10_2007, j_i_s_10_2008, j_i_s_10_2009, j_i_s_10_2010, j_i_s_10_2011 \ ///
j_i_s_17_2004, j_i_s_17_2005, j_i_s_17_2006, j_i_s_17_2007, j_i_s_17_2008, j_i_s_17_2009, j_i_s_17_2010, j_i_s_17_2011 \ ///
j_ce_s_08_2004, j_ce_s_08_2005, j_ce_s_08_2006, j_ce_s_08_2007, j_ce_s_08_2008, j_ce_s_08_2009, j_ce_s_08_2010, j_ce_s_08_2011 \ ///
j_ce_s_10_2004, j_ce_s_10_2005, j_ce_s_10_2006, j_ce_s_10_2007, j_ce_s_10_2008, j_ce_s_10_2009, j_ce_s_10_2010, j_ce_s_10_2011 \ ///
j_ce_s_17_2004, j_ce_s_17_2005, j_ce_s_17_2006, j_ce_s_17_2007, j_ce_s_17_2008, j_ce_s_17_2009, j_ce_s_17_2010, j_ce_s_17_2011 )

matrix rownames A = Jacome y08 y10 y17 y08 y10 y17 y08 y10 y17 y08 y10 y17
matrix colnames A =  p2004 p2005 p2006 p2007 p2008 p2009 p2010 p2011 

outtable using "analysis/sum_prod_other", mat(A) cap("Resilencia en producción de oro vs otros") f(%9.2f) replace


* Production itself

forvalues x=2005(1)2011{
     local y=`x'-1
     forvalues z=2004(1)`y'{
          sum oro`x' if oro`x'!=0 & oro`z'!=0
          scalar a=r(N)
          sum oro`x' if oro`x'!=0
          scalar b=r(N)
          scalar j_`x'_`z'=a/b
          scalar n_`x'=r(N)
     }
}

matrix A = (n_2005, n_2006, n_2007, n_2008, n_2009, n_2010, n_2011 \ ///
j_2005_2004, j_2006_2004, j_2007_2004, j_2008_2004, j_2009_2004, j_2010_2004, j_2011_2004 \ ///
., j_2006_2005, j_2007_2005, j_2008_2005, j_2009_2005, j_2010_2005, j_2011_2005 \ ///
., ., j_2007_2006, j_2008_2006, j_2009_2006, j_2010_2006, j_2011_2006 \ ///
., ., ., j_2008_2007, j_2009_2007, j_2010_2007, j_2011_2007 \ ///
., ., ., ., j_2009_2008, j_2010_2008, j_2011_2008 \ ///
., ., ., ., ., j_2010_2009, j_2011_2009 \ ///
., ., ., ., ., ., j_2011_2010)

matrix colnames A =  p2005 p2006 p2007 p2008 p2009 p2010 p2011 
matrix rownames A =  observaciones p2005 p2006 p2007 p2008 p2009 p2010 p2011

outtable using "analysis/sum_prod_prod", mat(A) cap("Resilencia en producción de oro vs Producción años pasados") f(%9.2f) replace

*now the titles and solicitudes vs themselves


foreach k in t s{
     foreach y in ce i{
          foreach z in 08 10 17{
               foreach w in 08 10 17{
                    sum `y'nt_`k'_`z' if `y'nt_`k'_`z'==1 &  `y'nt_`k'_`w'==1
                    scalar a=r(N)
                    sum `y'nt_`k'_`z' if `y'nt_`k'_`z'==1
                    scalar b=r(N)
                    scalar j_`y'_`k'_`z'_`w'=a/b
               }
          }
     }
}

foreach k in t s{
     foreach y in ce i{
          foreach z in 08 10 17{
               sum `y'nt_`k'_`z' if `y'nt_`k'_`z'==1 &  jacome==1
               scalar a=r(N)
               sum `y'nt_`k'_`z' if `y'nt_`k'_`z'==1
               scalar b=r(N)
               scalar j_`y'_`k'_`z'=a/b
               scalar n_`z'=r(N)
          }
     }
}



matrix define A=(n_08 , n_10 , n_17 \ ///
j_i_t_08 , j_i_t_10 , j_i_t_17 \ ///
. , j_i_t_10_08 , j_i_t_17_08 \ ///
. , . , j_i_t_17_10 \ ///
. , j_ce_t_10_08 , j_ce_t_17_08 \ ///
. , . , j_ce_t_17_10 \ ///
. , j_i_s_10_08 , j_i_s_17_08 \ ///
. , . , j_i_s_17_10 \ ///
. , j_ce_s_10_08 , j_ce_s_17_08 \ ///
. , . , j_ce_s_17_10)


outtable using "analysis/sum_tit_tit", mat(A) cap("Resilencia en titulación de oro vs titulación años pasados y Jacome") f(%9.2f) replace
*/

/*******************************************
          THE REAL THING
*******************************************/

cd "${resultados}"
sum jacome if jacome==1
scalar c=r(N)
forvalues x = 2004(1)2011{
     sum oro`x' if oro`x'>0 & jacome==1
     scalar a=r(N)
     scalar y`x'=a/c
}
forvalues x = 2004(1)2011{
     sum oro`x' if oro`x'>0 & jacome==0
     scalar a=r(N)
     sum oro`x' if oro`x'>0
     scalar b=r(N)
     scalar n`x'=a/b
     scalar n_`x'=r(N)
}


matrix A = ( y2004, y2005, y2006, y2007, y2008, y2009, y2010, y2011 \ ///
n2004, n2005, n2006, n2007, n2008, n2009, n2010, n2011 \ ///
n_2004, n_2005, n_2006, n_2007, n_2008, n_2009, n_2010, n_2011 )

matrix colnames A  = 2004 2005 2006 2007 2008 2009 2010 2011
matrix rownames A  = y  n observations

outtable using "analysis/prod_jac", mat(A) cap("resilencia producción vs Jacome. definiciones 1 y 2") f(%9.2f) replace


forvalues x=2005(1)2011{
     local y=`x'-1
     forvalues z=2004(1)`y'{
          sum oro`x' if oro`x'>0 & oro`z'>0
          scalar a=r(N)
          sum oro`x' if oro`z'>0
          scalar b=r(N)
          scalar j_`x'_`z'=a/b
          scalar n_`x'=r(N)
     }
}

matrix A = (n_2005, n_2006, n_2007, n_2008, n_2009, n_2010, n_2011 \ ///
j_2005_2004, j_2006_2004, j_2007_2004, j_2008_2004, j_2009_2004, j_2010_2004, j_2011_2004 \ ///
., j_2006_2005, j_2007_2005, j_2008_2005, j_2009_2005, j_2010_2005, j_2011_2005 \ ///
., ., j_2007_2006, j_2008_2006, j_2009_2006, j_2010_2006, j_2011_2006 \ ///
., ., ., j_2008_2007, j_2009_2007, j_2010_2007, j_2011_2007 \ ///
., ., ., ., j_2009_2008, j_2010_2008, j_2011_2008 \ ///
., ., ., ., ., j_2010_2009, j_2011_2009 \ ///
., ., ., ., ., ., j_2011_2010)

matrix colnames A =  p2005 p2006 p2007 p2008 p2009 p2010 p2011 
matrix rownames A =  observaciones p2004 p2005 p2006 p2007 p2008 p2009 p2010 

outtable using "analysis/prod_prod_y", mat(A) cap("Resilencia en producción de oro vs Producción años pasados. defi 7") f(%9.2f) replace


forvalues x=2005(1)2011{
     local y=`x'-1
     forvalues z=2004(1)`y'{
          sum oro`x' if oro`x'>0 & oro`z'==0
          scalar a=r(N)
          sum oro`x' if oro`x'>0
          scalar b=r(N)
          scalar j_`x'_`z'=a/b
          scalar n_`x'=r(N)
     }
}

matrix A = (n_2005, n_2006, n_2007, n_2008, n_2009, n_2010, n_2011 \ ///
j_2005_2004, j_2006_2004, j_2007_2004, j_2008_2004, j_2009_2004, j_2010_2004, j_2011_2004 \ ///
., j_2006_2005, j_2007_2005, j_2008_2005, j_2009_2005, j_2010_2005, j_2011_2005 \ ///
., ., j_2007_2006, j_2008_2006, j_2009_2006, j_2010_2006, j_2011_2006 \ ///
., ., ., j_2008_2007, j_2009_2007, j_2010_2007, j_2011_2007 \ ///
., ., ., ., j_2009_2008, j_2010_2008, j_2011_2008 \ ///
., ., ., ., ., j_2010_2009, j_2011_2009 \ ///
., ., ., ., ., ., j_2011_2010)

matrix colnames A =  p2005 p2006 p2007 p2008 p2009 p2010 p2011 
matrix rownames A =  observaciones p2004 p2005 p2006 p2007 p2008 p2009 p2010

outtable using "analysis/prod_prod_n", mat(A) cap("Resilencia en producción de oro vs Producción años pasados. defi 8") f(%9.2f) replace


foreach k in t s{
     foreach y in ce i{
          foreach z in 08 10 17{
               sum `y'nt_`k'_`z' if `y'nt_`k'_`z'==1 &  jacome==1
               scalar a=r(N)
               scalar y_`y'_`k'_`z'=a/c

          }
     }
}

foreach k in t s{
     foreach y in ce i{
          foreach z in 08 10 17{
               sum `y'nt_`k'_`z' if `y'nt_`k'_`z'==1 &  jacome==0
               scalar a=r(N)
               sum `y'nt_`k'_`z' if `y'nt_`k'_`z'==1
               scalar b=r(N)
               scalar n_`y'_`k'_`z'=a/b
               scalar n_`z'=r(N)
          }
     }
}


matrix A = (y_i_t_08 , y_i_t_10 , y_i_t_17 \ /// 
n_i_t_08 , n_i_t_10 , n_i_t_17 \ /// 
y_ce_t_08 , y_ce_t_10 , y_ce_t_17 \ /// 
n_ce_t_08 , n_ce_t_10 , n_ce_t_17 \ /// 
y_i_s_08 , y_i_s_10 , y_i_s_17 \ /// 
n_i_s_08 , n_i_s_10 , n_i_s_17 \ /// 
y_ce_s_08 , y_ce_s_10 , y_ce_s_17 \ /// 
n_ce_s_08 , n_ce_s_10 , n_ce_s_17 \ /// 
n_08 , n_10 , n_17 ) 

matrix colnames A  = 08 10 17
matrix rownames A  = yit nit ycet ncet yis nis yces nces observations  

outtable using "analysis/tit_sol_jac", mat(A) cap("resilencia titulos/solicitudes vs Jacome. Definiciones 3 y 4") f(%9.2f) replace


foreach k in t s{
     foreach y in ce i{
          foreach z in 08 10 17{
               foreach w in 08 10 17{
                    sum `y'nt_`k'_`z' if `y'nt_`k'_`z'==1 &  `y'nt_`k'_`w'==1
                    scalar a=r(N)
                    sum `y'nt_`k'_`w' if `y'nt_`k'_`w'==1
                    scalar b=r(N)
                    scalar j_`y'_`k'_`z'_`w'=a/b
               }
          }
     }
}

matrix define A=( j_i_t_10_08 , j_i_t_17_08 \ ///
 . , j_i_t_17_10 \ ///
 j_ce_t_10_08 , j_ce_t_17_08 \ ///
 . , j_ce_t_17_10 \ ///
 j_i_s_10_08 , j_i_s_17_08 \ ///
 . , j_i_s_17_10 \ ///
 j_ce_s_10_08 , j_ce_s_17_08 \ ///
 . , j_ce_s_17_10)
 
 matrix colnames A  = 10 17
 matrix rownames A  = yit08 yit10 ycet08 ycet10 yis08 yis10 yces08 yces10

outtable using "analysis/tit_sol_themselves", mat(A) cap("resilencia titulos/solicitudes vs themselves") f(%9.2f) replace


foreach k in t s{
     foreach y in ce i{
          foreach z in 08 10 17{
               foreach w in 08 10 17{
                    sum `y'nt_`k'_`z' if `y'nt_`k'_`z'==1 &  `y'nt_`k'_`w'==0
                    scalar a=r(N)
                    sum `y'nt_`k'_`w' if `y'nt_`k'_`z'==1
                    scalar b=r(N)
                    scalar j_`y'_`k'_`z'_`w'=a/b
               }
          }
     }
}


matrix define A=( j_i_t_10_08 , j_i_t_17_08 \ ///
 . , j_i_t_17_10 \ ///
 j_ce_t_10_08 , j_ce_t_17_08 \ ///
 . , j_ce_t_17_10 \ ///
 j_i_s_10_08 , j_i_s_17_08 \ ///
 . , j_i_s_17_10 \ ///
 j_ce_s_10_08 , j_ce_s_17_08 \ ///
 . , j_ce_s_17_10)
 
 matrix colnames A  = 10 17
 matrix rownames A  = yit08 yit10 ycet08 ycet10 yis08 yis10 yces08 yces10

outtable using "analysis/tit_sol_themselves2", mat(A) cap("resilencia titulos/solicitudes vs themselves. definiciones 5 y 6") f(%9.2f) replace

