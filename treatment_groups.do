/*------------------------------------------------------------------------------

PROJECT :     	Mining - HK
AUTHOR :			Camilo De Los Rios
PURPOSE :			Assessment of different treatment groups that can be created


------------------------------------------------------------------------------*/





*Paths

*Basic setting

*Softest measures possible


gen gold_1=1 if int_t_08==1
replace gold_1=1 if int_t_10==1
replace gold_1=1 if int_t_17==1
replace gold_1=1 if int_s_08==1
replace gold_1=1 if int_s_10==1
replace gold_1=1 if int_s_17==1
recode gold_1(.=0)
label var gold_1 "1 if there are any title or requestst in any period intersecting mpio"

gen oil_1=1 if int_oil_19==1
replace oil_1=1 if int_oil_20==1
recode oil_1(.=0)
label var oil_1 "1 if there are any hydrocarbon areas intersecting mpio"

gen oil_12=1 if int_oil_19==1
replace oil_12=1 if int_oil_20==1
replace oil_12=1 if int_oil_20==1
replace oil_12=1 if well==1
recode oil_12(.=0)
label var oil_12 "1 if there are any hydrocarbon areas intersecting mpio or wells in mpio"

* Softest made a bit harder

gen gold_2=1 if int_t_08==1
replace gold_2=1 if cent_t_10==1
replace gold_2=1 if cent_t_17==1
replace gold_2=1 if cent_s_08==1
replace gold_2=1 if cent_s_10==1
replace gold_2=1 if cent_s_17==1
recode gold_2(.=0)
label var gold_2 "1 if there are any title or requestst in any period with centroid in mpio"

gen oil_2=1 if cent_oil_19==1
replace oil_2=1 if cent_oil_20==1
recode oil_2(.=0)
label var oil_2 "1 if there are any hydrocarbon areas with centroid in mpio"

gen oil_22=1 if cent_oil_19==1
replace oil_22=1 if cent_oil_20==1
replace oil_22=1 if cent_oil_20==1
replace oil_22=1 if well==1
recode oil_22(.=0)
label var oil_22 "1 if there are any hydrocarbon areas with centroid in mpio or wells in mpio"


* Harder for Gold

gen gold_3=1 if int_t_08==1
replace gold_3=1 if int_t_10==1
replace gold_3=1 if int_t_17==1
recode gold_3(.=0)
label var gold_3 "1 if there are any titles in any period intersecting mpio"

* A bit Harder for Gold

gen gold_4=1 if cent_t_08==1
replace gold_4=1 if cent_t_10==1
replace gold_4=1 if cent_t_17==1
recode gold_4(.=0)
label var gold_4 "1 if there are any titles in any period intersecting mpio"

* Harder for Oil

gen oil_3=1 if prod_int_19==1
replace oil_3=1 if prod_int_20==1
recode oil_3(.=0)
label var oil_3 "1 if there are any production hydrocarbon areas intersecting mpio"

* Harder for Oil

gen oil_32=1 if prod_int_19==1
replace oil_32=1 if prod_int_20==1
replace oil_32=1 if well==1
recode oil_32(.=0)
label var oil_32 "1 if there are any production hydrocarbon areas intersecting mpio or wells in mpio"


* Harder for Oil

gen oil_4=1 if prod_cent_19==1
replace oil_4=1 if prod_cent_20==1
recode oil_4(.=0)
label var oil_4 "1 if there are any production hydrocarbon areas with centroid in mpio"


* Yet another for gold_1

gen gold_5=1 if int_t_08==1
replace gold_5=1 if int_t_10==1
replace gold_5=1 if int_t_17==1
replace gold_5=1 if int_potencial_a==1
recode gold_5(.=0)
label var gold_5 "1 if there are any gold titles intersecting or high potential gold areas intersecting mpio"

* A bit harder for another of gold_1

gen gold_6=1 if cent_t_08==1
replace gold_6=1 if cent_t_10==1
replace gold_6=1 if cent_t_17==1
replace gold_6=1 if int_potencial_a==1
recode gold_6(.=0)
label var gold_5 "1 if there are any gold titles with centroid or high potential gold areas intersecting mpio"


* Now the areas are not calculated correctly. I have to do it again, by hand. R code is not working properly. 


* Harder for Oil

gen oil_3=1 if prod_int_19==1
replace oil_3=1 if prod_int_20==1
recode oil_3(.=0)
label var oil_3 "1 if there are any production hydrocarbon areas intersecting mpio"

* Harder for Oil

gen oil_32=1 if prod_int_19==1
replace oil_32=1 if prod_int_20==1
replace oil_32=1 if well==1
recode oil_32(.=0)
label var oil_32 "1 if there are any production hydrocarbon areas intersecting mpio or wells in mpio"


gen sihay=1 if prod_int_19==1 | prod_int_20==1
tab sihay
tab sihay if well==1








