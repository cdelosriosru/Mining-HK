# PROJECT :     	Mining and Human Capital
# AUTHOR :				Camilo De Los Rios Rueda
# PURPOSE :				create buffers of schools and count oil wells within them.
# DATE WRITTEN :   		1.06.2020
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
#data = "Z:/IDB/MINING-HK/DATA" # si est? en dropx
oil_f = paste(data,"Petroleo", sep="")
hk_f = paste(data,"HK", sep="")
municipios = paste(data,"PoliticalBoundaries", sep="")
compiled=paste(data,"Violencia/harm", sep="")
minas=paste(data,"Violencia", sep="")

#--------------COORDINATES-------

epsg.2062 <- "+proj=lcc +lat_1=40 +lat_0=40 +lon_0=0 +k_0=0.9988085293 +x_0=600000 +y_0=600000 +a=6378298.3 +b=6356657.142669561 +pm=madrid +units=m +no_defs"
wgs.84    <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" # ASUM? QUE ESTA ERA LA PROYECCI?N DE LOS COLEGIOS

#--------------------------------PREPARE SCHOOLS----------------------------
setwd(hk_f)
setwd("raw")


colegio_points<-readOGR(dsn=".", layer="colegio_points")

colegio_points <- spTransform(colegio_points,CRS(epsg.2062)) # need this to have buffers in meters

#-----Minas Antipersona----

setwd(minas)

minas<-readOGR(dsn="raw", layer="Minas_Antipersona")
minas<-clgeo_Clean(minas)
minas<-spTransform(minas,CRS(wgs.84))

MAP <- minas[grepl('Accidente por MAP',minas$tipo_event),]
MUSE <- minas[grepl('Accidente por MUSE',minas$tipo_event),]
DESMIL <- minas[grepl('Desminado militar en operaciones',minas$tipo_event),]
INCAUTA <- minas[grepl('Incautaciones',minas$tipo_event),]
SOSP <- minas[grepl('Sospecha de campo minado',minas$tipo_event),]
OTROS <- minas[grepl(c('Arsenal almacenada|Municiones sin explotar|Producci?n de Minas (F?brica)|Sospecha de campo minado'),minas$tipo_event),]

writeOGR(MAP, dsn="harm", layer="map", driver ="ESRI Shapefile", overwrite_layer = T)
writeOGR(MUSE, dsn="harm", layer="muse", driver ="ESRI Shapefile", overwrite_layer = T)
writeOGR(DESMIL, dsn="harm", layer="desmil", driver ="ESRI Shapefile", overwrite_layer = T)
writeOGR(SOSP, dsn="harm", layer="sosp", driver ="ESRI Shapefile", overwrite_layer = T)
writeOGR(OTROS, dsn="harm", layer="otros", driver ="ESRI Shapefile", overwrite_layer = T)


keep_p <- c("a_o")
MAP <- MAP[,(names(MAP) %in% keep_p)]
MUSE <- MUSE[,(names(MUSE) %in% keep_p)]
DESMIL <- DESMIL[,(names(DESMIL) %in% keep_p)]
SOSP <- SOSP[,(names(SOSP) %in% keep_p)]
OTROS <- OTROS[,(names(OTROS) %in% keep_p)]

#
MAP<-readOGR(dsn="harm", layer="map")


#---------------MAP------

x <- c(5000,10000,15000, 20000, 30000) # Different buffers, in meters.

MAP$MAP<-1

for (val in 1:length(x)) {

  colegio_buf <-gBuffer(colegio_points, byid = TRUE, width = x[val]) # width is in meters
  colegio_buf <-spTransform(colegio_buf,CRS(wgs.84)) # transform to have in the same CRS as all other files
  colegio_buf@data<-data.frame(colegio_buf@data) # intersect does not work with tibble

  cole_MAP<-raster::intersect(MAP,colegio_buf)

  cole_MAP<-as.data.frame(cole_MAP)

  cole_MAP<-cole_MAP%>%
    group_by(lat_cole , lon_cole , id_cole, a_o )%>%
    summarize(dpto_cole = first(dpto), mpio_cole=first(mpio) , MAP=sum(MAP))

  namevar<-(paste("MAP_",x[val], sep=""))
  names(cole_MAP)[names(cole_MAP) == "MAP"] <- namevar[1]  # change the name of var to identify better

  name<-(paste("cole_MAP_",x[val], sep=""))
  print(name)
  assign(name,cole_MAP)   # change the name of data frame

}


setwd(compiled)

mer1<-merge(cole_MAP_10000,cole_MAP_5000,all=TRUE)
mer2<-merge(mer1,cole_MAP_15000,all=TRUE)
mer3<-merge(mer2,cole_MAP_20000,all=TRUE)
cole_MAP_all<-merge(mer3,cole_MAP_30000,all=TRUE)

cole_MAP_all %>% mutate_if(is.factor, as.character) -> cole_MAP_all

save.dta13(data=cole_MAP_all,file="cole_MAP_all.dta")

rm(mer1,mer2,cole_MAP_all,cole_MAP_10000,cole_MAP_5000,cole_MAP_15000,cole_MAP_20000)

#---------------MUSE------

x <- c(5000,10000,15000, 20000) # Different buffers, in meters.

MUSE$MUSE<-1

for (val in 1:length(x)) {

  colegio_buf <-gBuffer(colegio_points, byid = TRUE, width = x[val]) # width is in meters
  colegio_buf <-spTransform(colegio_buf,CRS(wgs.84)) # transform to have in the same CRS as all other files
  colegio_buf@data<-data.frame(colegio_buf@data) # intersect does not work with tibble

  cole_MUSE<-raster::intersect(MUSE,colegio_buf)

  cole_MUSE<-as.data.frame(cole_MUSE)

  cole_MUSE<-cole_MUSE%>%
    group_by(lat_cole , lon_cole , id_cole, a_o )%>%
    summarize(dpto_cole = first(dpto), mpio_cole=first(mpio) , MUSE=sum(MUSE))

  namevar<-(paste("MUSE_",x[val], sep=""))
  names(cole_MUSE)[names(cole_MUSE) == "MUSE"] <- namevar[1]  # change the name of var to identify better

  name<-(paste("cole_MUSE_",x[val], sep=""))
  print(name)
  assign(name,cole_MUSE)   # change the name of data frame

}


setwd(compiled)

mer1<-merge(cole_MUSE_10000,cole_MUSE_5000,all=TRUE)
mer2<-merge(mer1,cole_MUSE_15000,all=TRUE)
cole_MUSE_all<-merge(mer2,cole_MUSE_20000,all=TRUE)

cole_MUSE_all %>% mutate_if(is.factor, as.character) -> cole_MUSE_all

save.dta13(data=cole_MUSE_all,file="cole_MUSE_all.dta")

rm(mer1,mer2,cole_MUSE_all,cole_MUSE_10000,cole_MUSE_5000,cole_MUSE_15000,cole_MUSE_20000)


#---------------DESMIL------

x <- c(5000,10000,15000, 20000) # Different buffers, in meters.

DESMIL$DESMIL<-1

for (val in 1:length(x)) {

  colegio_buf <-gBuffer(colegio_points, byid = TRUE, width = x[val]) # width is in meters
  colegio_buf <-spTransform(colegio_buf,CRS(wgs.84)) # transform to have in the same CRS as all other files
  colegio_buf@data<-data.frame(colegio_buf@data) # intersect does not work with tibble

  cole_DESMIL<-raster::intersect(DESMIL,colegio_buf)

  cole_DESMIL<-as.data.frame(cole_DESMIL)

  cole_DESMIL<-cole_DESMIL%>%
    group_by(lat_cole , lon_cole , id_cole, a_o )%>%
    summarize(dpto_cole = first(dpto), mpio_cole=first(mpio) , DESMIL=sum(DESMIL))

  namevar<-(paste("DESMIL_",x[val], sep=""))
  names(cole_DESMIL)[names(cole_DESMIL) == "DESMIL"] <- namevar[1]  # change the name of var to identify better

  name<-(paste("cole_DESMIL_",x[val], sep=""))
  print(name)
  assign(name,cole_DESMIL)   # change the name of data frame

}


setwd(compiled)

mer1<-merge(cole_DESMIL_10000,cole_DESMIL_5000,all=TRUE)
mer2<-merge(mer1,cole_DESMIL_15000,all=TRUE)
cole_DESMIL_all<-merge(mer2,cole_DESMIL_20000,all=TRUE)

cole_DESMIL_all %>% mutate_if(is.factor, as.character) -> cole_DESMIL_all

save.dta13(data=cole_DESMIL_all,file="cole_DESMIL_all.dta")

rm(mer1,mer2,cole_DESMIL_all,cole_DESMIL_10000,cole_DESMIL_5000,cole_DESMIL_15000,cole_DESMIL_20000)


#---------------INCAUTA------

x <- c(5000,10000,15000, 20000) # Different buffers, in meters.

INCAUTA$INCAUTA<-1

for (val in 1:length(x)) {

  colegio_buf <-gBuffer(colegio_points, byid = TRUE, width = x[val]) # width is in meters
  colegio_buf <-spTransform(colegio_buf,CRS(wgs.84)) # transform to have in the same CRS as all other files
  colegio_buf@data<-data.frame(colegio_buf@data) # intersect does not work with tibble

  cole_INCAUTA<-raster::intersect(INCAUTA,colegio_buf)

  cole_INCAUTA<-as.data.frame(cole_INCAUTA)

  cole_INCAUTA<-cole_INCAUTA%>%
    group_by(lat_cole , lon_cole , id_cole, a_o )%>%
    summarize(dpto_cole = first(dpto), mpio_cole=first(mpio) , INCAUTA=sum(INCAUTA))

  namevar<-(paste("INCAUTA_",x[val], sep=""))
  names(cole_INCAUTA)[names(cole_INCAUTA) == "INCAUTA"] <- namevar[1]  # change the name of var to identify better

  name<-(paste("cole_INCAUTA_",x[val], sep=""))
  print(name)
  assign(name,cole_INCAUTA)   # change the name of data frame

}


setwd(compiled)

mer1<-merge(cole_INCAUTA_10000,cole_INCAUTA_5000,all=TRUE)
mer2<-merge(mer1,cole_INCAUTA_15000,all=TRUE)
cole_INCAUTA_all<-merge(mer2,cole_INCAUTA_20000,all=TRUE)

cole_INCAUTA_all %>% mutate_if(is.factor, as.character) -> cole_INCAUTA_all

save.dta13(data=cole_INCAUTA_all,file="cole_INCAUTA_all.dta")

rm(mer1,mer2,cole_INCAUTA_all,cole_INCAUTA_10000,cole_INCAUTA_5000,cole_INCAUTA_15000,cole_INCAUTA_20000)



#---------------OTROS------

x <- c(5000,10000,15000, 20000) # Different buffers, in meters.

OTROS$OTROS<-1

for (val in 1:length(x)) {

  colegio_buf <-gBuffer(colegio_points, byid = TRUE, width = x[val]) # width is in meters
  colegio_buf <-spTransform(colegio_buf,CRS(wgs.84)) # transform to have in the same CRS as all other files
  colegio_buf@data<-data.frame(colegio_buf@data) # intersect does not work with tibble

  cole_OTROS<-raster::intersect(OTROS,colegio_buf)

  cole_OTROS<-as.data.frame(cole_OTROS)

  cole_OTROS<-cole_OTROS%>%
    group_by(lat_cole , lon_cole , id_cole, a_o )%>%
    summarize(dpto_cole = first(dpto), mpio_cole=first(mpio) , OTROS=sum(OTROS))

  namevar<-(paste("OTROS_",x[val], sep=""))
  names(cole_OTROS)[names(cole_OTROS) == "OTROS"] <- namevar[1]  # change the name of var to identify better

  name<-(paste("cole_OTROS_",x[val], sep=""))
  print(name)
  assign(name,cole_OTROS)   # change the name of data frame

}


setwd(compiled)

mer1<-merge(cole_OTROS_10000,cole_OTROS_5000,all=TRUE)
mer2<-merge(mer1,cole_OTROS_15000,all=TRUE)
cole_OTROS_all<-merge(mer2,cole_OTROS_20000,all=TRUE)

cole_OTROS_all %>% mutate_if(is.factor, as.character) -> cole_OTROS_all

save.dta13(data=cole_OTROS_all,file="cole_OTROS_all.dta")

rm(mer1,mer2,cole_OTROS_all,cole_OTROS_10000,cole_OTROS_5000,cole_OTROS_15000,cole_OTROS_20000)



#---------------SOSP------

x <- c(5000,10000,15000, 20000) # Different buffers, in meters.

SOSP$SOSP<-1

for (val in 1:length(x)) {

  colegio_buf <-gBuffer(colegio_points, byid = TRUE, width = x[val]) # width is in meters
  colegio_buf <-spTransform(colegio_buf,CRS(wgs.84)) # transform to have in the same CRS as all other files
  colegio_buf@data<-data.frame(colegio_buf@data) # intersect does not work with tibble

  cole_SOSP<-raster::intersect(SOSP,colegio_buf)

  cole_SOSP<-as.data.frame(cole_SOSP)

  cole_SOSP<-cole_SOSP%>%
    group_by(lat_cole , lon_cole , id_cole, a_o )%>%
    summarize(dpto_cole = first(dpto), mpio_cole=first(mpio) , SOSP=sum(SOSP))

  namevar<-(paste("SOSP_",x[val], sep=""))
  names(cole_SOSP)[names(cole_SOSP) == "SOSP"] <- namevar[1]  # change the name of var to identify better

  name<-(paste("cole_SOSP_",x[val], sep=""))
  print(name)
  assign(name,cole_SOSP)   # change the name of data frame

}


setwd(compiled)

mer1<-merge(cole_SOSP_10000,cole_SOSP_5000,all=TRUE)
mer2<-merge(mer1,cole_SOSP_15000,all=TRUE)
cole_SOSP_all<-merge(mer2,cole_SOSP_20000,all=TRUE)

cole_SOSP_all %>% mutate_if(is.factor, as.character) -> cole_SOSP_all

save.dta13(data=cole_SOSP_all,file="cole_SOSP_all.dta")

rm(mer1,mer2,cole_SOSP_all,cole_SOSP_10000,cole_SOSP_5000,cole_SOSP_15000,cole_SOSP_20000)









