# PROJECT :     	Mining and Human Capital
# AUTHOR :				Camilo De Los Rios Rueda
# PURPOSE :				create number of wells in MPIO. 
# DATE WRITTEN :   		8.10.2020
# LAST REVISED BY :   	Camilo De Los Rios  Rueda


#--------------------------------------------------------------------
# INITIALIZE
#--------------------------------------------------------------------

z<-c("sp","rgdal","raster","rgeos","dplyr","tidyverse","cleangeo","readstata13","geosphere","sf")


#z<-c("sp","stats","dplyr","ggplot2","ggmap","dplyr", "sf", "sp","rgdal","maptools","rgeos","raster","sf","raster","stars","maps","geosphere","foreign","tidyverse","plyr","cleangeo","hablar","haven","dplyr","maps","viridis","cartogram","tidyverse","broom","readstata13")
#lapply(z, install.packages, character.only = TRUE) 

lapply(z, library, character.only = TRUE)

#-------PATHS------
data = "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA/"
#data = "Z:/IDB/MINING-HK/DATA" # si está en dropx
oil_f = paste(data,"Petroleo", sep="")
hk_f = paste(data,"HK", sep="") 
municipios = paste(data,"PoliticalBoundaries", sep="")
compiled=paste(data,"compiled_sets", sep="")

#--------------COORDINATES-------

epsg.2062 <- "+proj=lcc +lat_1=40 +lat_0=40 +lon_0=0 +k_0=0.9988085293 +x_0=600000 +y_0=600000 +a=6378298.3 +b=6356657.142669561 +pm=madrid +units=m +no_defs"
wgs.84    <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" # ASUMÍ QUE ESTA ERA LA PROYECCIÓN DE LOS COLEGIOS


#-----Oil Wells----

setwd(oil_f)
setwd("raw")

pozos <- readOGR(dsn=".", layer="pozos_col")
pozos_st<-st_as_sf(pozos)
pozos_st<-pozos_st%>%drop_na(WELL_SPUD_)
pozos<-as(pozos_st,'Spatial')


#----------------MPIOS----------
setwd(municipios)

mpios<- readOGR(dsn=".", layer="municipios") # EPSG:4326
mpios<-clgeo_Clean(mpios)

#-----intersect MPIOS with WELLS-----

pozos<-spTransform(pozos, crs(mpios)) 



pozos_mpios<-raster::intersect(pozos,mpios)


setwd(oil_f)
setwd("harm")

pozos_mpios<-as.data.frame(pozos_mpios)
pozos_mpios %>% mutate_if(is.factor, as.character) -> pozos_mpios
save.dta13(data = pozos_mpios , file = "mpio_pozos_all.dta") 





