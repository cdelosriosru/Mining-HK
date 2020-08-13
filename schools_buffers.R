# PROJECT :     	Mining and Human Capital
# AUTHOR :				Camilo De Los Rios Rueda
# PURPOSE :				create buffers of schools and count oil wells within them. 
# DATE WRITTEN :   		1.06.2020
# LAST REVISED BY :   	Camilo De Los Rios  Rueda


#--------------------------------------------------------------------
# INITIALIZE
#--------------------------------------------------------------------

z<-c("sp","rgdal","raster","rgeos","dplyr","tidyverse","cleangeo","readstata13")


#z<-c("sp","stats","dplyr","ggplot2","ggmap","dplyr", "sf", "sp","rgdal","maptools","rgeos","raster","sf","raster","stars","maps","geosphere","foreign","tidyverse","plyr","cleangeo","hablar","haven","dplyr","maps","viridis","cartogram","tidyverse","broom","readstata13")
#lapply(z, install.packages, character.only = TRUE) 

lapply(z, library, character.only = TRUE)

#-------PATHS------
data = "C:/Users/camilodel/Desktop/IDB/MINING-HK/DATA/SERVIDOR-LUIS-PATHS/dtafiles/"
#data = "Z:/IDB/MINING-HK/DATA" # si está en dropx
oil_f = paste(data,"Petroleo", sep="")
hk_f = paste(data,"HK", sep="") 
municipios = paste(data,"PoliticalBoundaries", sep="")

#--------------COORDINATES-------

epsg.2062 <- "+proj=lcc +lat_1=40 +lat_0=40 +lon_0=0 +k_0=0.9988085293 +x_0=600000 +y_0=600000 +a=6378298.3 +b=6356657.142669561 +pm=madrid +units=m +no_defs"
wgs.84    <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" # ASUMÍ QUE ESTA ERA LA PROYECCIÓN DE LOS COLEGIOS

#--------------------------------PREPARE SCHOOLS----------------------------
setwd(hk_f)
colegio <- read.dta13("HumanCapital.dta")

colegio<-colegio%>%
  group_by(lat_cole , lon_cole)%>%
  summarize(dpto = first(CódigoDepartamento), mpio=first(CódigoMunicipio) , id_cole=first(colegio_cod))

colegio<- na.omit(colegio,lat_cole, lon_cole)
coord<-colegio[,c(2,1)]

colegio_points<-SpatialPointsDataFrame(coords=coord,data = colegio,
                                       proj4string = CRS(wgs.84))

colegio_points <- spTransform(colegio_points,CRS(epsg.2062)) # need this to have buffers in meters

#-----Oil Wells----

setwd(oil_f)

pozos<-readOGR(dsn=".", layer="POZOS_EPIS_SGC_2020_04_30")
pozos<-clgeo_Clean(pozos)
pozos<-spTransform(pozos,CRS(wgs.84))
pozos$num_pozo <- 1
pozos <- pozos[grepl('COLOMBIA',pozos$WELL_COUNT),] # extract only the relevant info. 
writeOGR(pozos, dsn=".", layer="pozos_col", driver ="ESRI Shapefile", overwrite_layer = T)
pozos <- readOGR(dsn=".", layer="pozos_col")
keep_p <- c("UWI","WELL_NAME","CONTRATO","num_pozo","WELL_SPUD_")
pozos <- pozos[,(names(pozos) %in% keep_p)]

#----------------MPIOS----------
setwd(municipios)

mpios<- readOGR(dsn=".", layer="municipios") # EPSG:4326
mpios<-clgeo_Clean(mpios)

#-----intersect MPIOS with WELLS-----


pozos_mpios<-raster::intersect(pozos,mpios)
keep_p <- c("UWI","WELL_NAME","CONTRATO","num_pozo","admin2Pcod","admin2Name","WELL_SPUD_")
pozos_mpios <- pozos_mpios[,(names(pozos_mpios) %in% keep_p)]

names(pozos_mpios)[names(pozos_mpios) == "admin2Pcod"] <- "mpio_well"
names(pozos_mpios)[names(pozos_mpios) == "admin2Name"] <- "well_mpio_name"
names(pozos_mpios)[names(pozos_mpios) == "UWI"] <- "id_well" # we wont be using this yet, but we might if we get access to production
names(pozos_mpios)[names(pozos_mpios) == "WELL_NAME"] <- "well_name"
names(pozos_mpios)[names(pozos_mpios) == "CONTRATO"] <- "well_contrato"

#---------------BUFFERS------

x <- c(1000,2500,5000,10000) # Different buffers, in meters. 
for (val in 1:4) {
 
  colegio_buf <-gBuffer(colegio_points, byid = TRUE, width = x[val]) # width is in meters
  colegio_buf <-spTransform(colegio_buf,CRS(wgs.84)) # transform to have in the same CRS as all other files
  colegio_buf@data<-data.frame(colegio_buf@data) # intersect does not work with tibble
  
  cole_wells<-raster::intersect(pozos_mpios,colegio_buf)
  
  cole_wells<-as.data.frame(cole_wells)
  cole_wells$spud<-substr(cole_wells$WELL_SPUD_,1,4)
  
  cole_wells<-cole_wells%>%
    group_by(lat_cole , lon_cole , spud, mpio_well )%>%
    summarize(dpto_cole = first(dpto), mpio_cole=first(mpio) , 
              id_cole=first(id_cole),npozos=sum(num_pozo))
  
  namevar<-(paste("npozos_",x[val], sep=""))
  names(cole_wells)[names(cole_wells) == "npozos"] <- namevar[1]  # change the name of var to identify better
  
  name<-(paste("cole_wells_",x[val], sep=""))
  print(name)
  assign(name,cole_wells)   # change the name of data frame
  
}

#------Merge and Save as dta------
setwd(data)

mer1<-merge(cole_wells_1000,cole_wells_2500,all=TRUE)
mer2<-merge(mer1,cole_wells_5000,all=TRUE)
cole_wells_all<-merge(mer2,cole_wells_10000,all=TRUE)

cole_wells_all %>% mutate_if(is.factor, as.character) -> cole_wells_all

save.dta13(data=cole_wells_all,file="cole_wells_all.dta")
