# PROJECT :     	Mining and Human Capital
# AUTHOR :				Camilo De Los Rios Rueda
# PURPOSE :				create number of MAP in MPIO. 
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
minas=paste(data,"Violencia", sep="")

#--------------COORDINATES-------

epsg.2062 <- "+proj=lcc +lat_1=40 +lat_0=40 +lon_0=0 +k_0=0.9988085293 +x_0=600000 +y_0=600000 +a=6378298.3 +b=6356657.142669561 +pm=madrid +units=m +no_defs"
wgs.84    <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" # ASUMÍ QUE ESTA ERA LA PROYECCIÓN DE LOS COLEGIOS


#-----MINES----

setwd(minas)

minas<-readOGR(dsn="raw", layer="Minas_Antipersona")
minas<-clgeo_Clean(minas)
minas<-spTransform(minas,CRS(wgs.84))

MAP <- readOGR(dsn="harm", layer="map")
MUSE <- readOGR(dsn="harm", layer="muse")
DESMIL <- readOGR(dsn="harm", layer="desmil")
SOSP <- readOGR(dsn="harm", layer="sosp")
OTROS <- readOGR(dsn="harm", layer="otros")



keep_p <- c("a_o")
MAP <- MAP[,(names(MAP) %in% keep_p)]
MUSE <- MUSE[,(names(MUSE) %in% keep_p)]
DESMIL <- DESMIL[,(names(DESMIL) %in% keep_p)]
SOSP <- SOSP[,(names(SOSP) %in% keep_p)]
OTROS <- OTROS[,(names(OTROS) %in% keep_p)]



#----------------MPIOS----------
setwd(municipios)

mpios<- readOGR(dsn=".", layer="municipios") # EPSG:4326
mpios<-clgeo_Clean(mpios)

#-----intersect MPIOS with WELLS-----

MAP<-spTransform(MAP, crs(mpios)) 
MAP$MAP<-1


MAP_mpios<-raster::intersect(MAP,mpios)


setwd(compiled)

MAP_mpios<-as.data.frame(MAP_mpios)
MAP_mpios %>% mutate_if(is.factor, as.character) -> MAP_mpios
save.dta13(data = MAP_mpios , file = "mpio_MPA_all.dta") 

