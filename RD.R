# PROJECT :     	Mining and Human Capital
# AUTHOR :				Camilo De Los Rios Rueda
# PURPOSE :				Make the necessary SHP transformations to build mmy RD
# DATE WRITTEN :   		1.06.2020
# LAST REVISED BY :   	Camilo De Los Rios  Rueda


#--------------------------------------------------------------------
# INITIALIZE
#--------------------------------------------------------------------

z<-c("foreign","stargazer","sp","rgdal","raster","rgeos","dplyr","tidyverse","cleangeo","readstata13","geosphere","sf")



#z<-c("sp","stats","dplyr","ggplot2","ggmap","dplyr", "sf", "sp","rgdal","maptools","rgeos","raster","sf","raster","stars","maps","geosphere","foreign","tidyverse","plyr","cleangeo","hablar","haven","dplyr","maps","viridis","cartogram","tidyverse","broom","readstata13")
#lapply(z, install.packages, character.only = TRUE)

lapply(z, library, character.only = TRUE)

#--------------COORDINATES for distances-------

epsg.2062 <- "+proj=lcc +lat_1=40 +lat_0=40 +lon_0=0 +k_0=0.9988085293 +x_0=600000 +y_0=600000 +a=6378298.3 +b=6356657.142669561 +pm=madrid +units=m +no_defs"
wgs.84    <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"




#-------PATHS------


data = "C:/Users/cdelo/Dropbox/HK_Extractives_2020/DATA/"
#data = "Z:/IDB/MINING-HK/DATA" # si est? en dropx
oil_f = paste(data,"Petroleo", sep="")
hk_f = paste(data,"HK", sep="")
municipios = paste(data,"PoliticalBoundaries", sep="")
compiled=paste(data,"compiled_sets", sep="")


rd=paste(data,"RD", sep="")

#------MPIOS shp-----
setwd(municipios)

mpios<-readOGR(dsn=".", layer="mpio_magnum_dane")
mpios_data<-st_as_sf(mpios)
mpios_data$codmpio<-paste(mpios_data$DPTO_CCDGO, mpios_data$MPIO_CCDGO, sep="")
mpios_data$codmpio <- as.numeric(mpios_data$codmpio)
#----data---
setwd(rd)
boundaries <- read.dta13("boundaries.dta")
#---merge----

mpios_bound<-merge(mpios_data,boundaries,by="codmpio")
mpios_bound<-as(mpios_bound,"Spatial")


# dissolve te boundaries for thos that never had wells (clean control group)

mpios_bound2<-st_as_sf(mpios_bound)
mpios_bound2 %>%
  st_set_geometry(NULL)

first <-
  mpios_bound2 %>%
  group_by(wells_never) %>%
  summarise()

# The same but only until 2000

mpios_bound2<-st_as_sf(mpios_bound)
mpios_bound2 %>%
  st_set_geometry(NULL)

second <-
  mpios_bound2 %>%
  group_by(wells_2000) %>%
  summarise()

# save both shps


first_shp<-as(first,"Spatial")
writeOGR(first_shp, dsn=".", layer="wells_never", driver ="ESRI Shapefile", overwrite_layer = T)

second_shp<-as(second,"Spatial")
writeOGR(second_shp, dsn=".", layer="wells_2000", driver ="ESRI Shapefile", overwrite_layer = T)

# clean them in ARCGIS (it is better to do it in that program) and then import again







#---------------create the shp with schools, and HK info------------


setwd(hk_f)

colegios <- st_read("raw/colegio_points_land.shp")

hk <- read.dta13("harm/hk_colegio.dta")

hk <-
  hk %>%
  group_by(id_cole) %>%
  summarise()


colegios_clean<-merge(colegios,hk,by="id_cole")







#----------- CREATE LINE SHP----------



setwd(rd)


wells_never_clean<-readOGR(dsn=".", layer="wells_never_clean")
wells_2000_clean<-readOGR(dsn=".", layer="wells_2000_clean")


wells_never_clean <- wells_never_clean[grepl('0',wells_never_clean$wlls_nv),]
wells_2000_clean <- wells_never_clean[grepl('0',wells_2000_clean$wells_2000),]



wells_never_clean_l = as(wells_never_clean, "SpatialLinesDataFrame")
wells_2000_clean_l = as(wells_2000_clean, "SpatialLinesDataFrame")





# --- create distance.



wells_2000_clean_l <- spTransform(wells_2000_clean_l, wgs.84)
wells_never_clean_l <- spTransform(wells_never_clean_l, wgs.84)
colegios_clean<-as(colegios_clean,'Spatial')
colegios_clean <- spTransform(colegios_clean, wgs.84)

colegios_clean$ID_cam <- 1:nrow(colegios_clean)
col <- as.data.frame(colegios_clean@data)

cents <- as.data.frame(coordinates(colegios_clean))
cents$ID_cam <- col$ID_cam

dis_never <- NULL

for (i in 1:nrow(cents)){
  print(i)
  coord <- paste0("POINT(",cents[i,1]," ",cents[i,2],")")
  print(coord)
  MAD   <- readWKT(coord, p4s=CRS(wgs.84))
  bound.proj <- spTransform(wells_never_clean_l,CRS(epsg.2062))
  MAD.proj   <- spTransform(MAD,CRS(epsg.2062))
  dis <- gDistance(MAD.proj,bound.proj) #EPSG-2062 projection, units are in meters.

  dis_never <- rbind(dis_never, dis)
}

cents$dis_never <- dis_never




colegios_clean_dta<- as.data.frame(colegios_clean, xy=TRUE, na.rm=TRUE)

write.dta(colegios_clean_dta, "colegios_ids.dta", convert.factors = "string")
write.dta(cents, "dis_never.dta", convert.factors = "string")




colegios_clean$ID_cam <- 1:nrow(colegios_clean)
col <- as.data.frame(colegios_clean@data)

cents <- as.data.frame(coordinates(colegios_clean))
cents$ID_cam <- col$ID_cam

dis_2000 <- NULL

for (i in 1:nrow(cents)){
  print(i)
  coord <- paste0("POINT(",cents[i,1]," ",cents[i,2],")")
  print(coord)
  MAD   <- readWKT(coord, p4s=CRS(wgs.84))
  bound.proj <- spTransform(wells_2000_clean_l,CRS(epsg.2062))
  MAD.proj   <- spTransform(MAD,CRS(epsg.2062))
  dis <- gDistance(MAD.proj,bound.proj) #EPSG-2062 projection, units are in meters.

  dis_2000 <- rbind(dis_2000, dis)
}

cents$dis_2000 <- dis_2000




colegios_clean_dta<- as.data.frame(colegios_clean, xy=TRUE, na.rm=TRUE)

write.dta(colegios_clean_dta, "colegios_ids.dta", convert.factors = "string")
write.dta(cents, "dis_2000.dta", convert.factors = "string")







# now the RD? this was virtually impossible. It is just better to do it all by hand and then turn to stata.
