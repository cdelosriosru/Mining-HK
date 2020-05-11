# PROJECT :     	Mining and Human Capital
# AUTHOR :				Camilo De Los Rios Rueda
# PURPOSE :				merge oil titles with municipalities in Colombia. 
#                 This creates the data bases necessary to perform the 
#                 econometric analysis. I have three ways of measuring oil
# DATE WRITTEN :   		21.02.2020
# LAST REVISION DATE: 	29.04.2020
# LAST REVISED BY :   	Camilo De Los Rios  Rueda


#--------------------------------------------------------------------
# INITIALIZE
#--------------------------------------------------------------------

z<-c("sp","stats","dplyr","ggplot2","ggmap","dplyr", "sf", "sp","rgdal","maptools","rgeos","raster","sf","raster","stars","maps","geosphere","foreign","tidyverse","plyr","cleangeo","hablar","haven","dplyr","maps","viridis","cartogram","tidyverse","broom","readstata13")
#lapply(z, install.packages, character.only = TRUE) 

lapply(z, library, character.only = TRUE) 
#--------------------------------------------------------------------
#-------PATHS------
#--------------------------------------------------------------------
data = "C:/Users/camilodel/Desktop/IDB/MINING-HK/DATA"
#data = "Z:/IDB/MINING-HK/DATA" # si está en dropx
oil_f = paste(data,"/Petroleo", sep="")
geo_f = paste(data,"/Mineria/geo", sep="") #poner si esta en el hard drive
municipios = paste(data,"/PoliticalBoundaries/Colombia", sep="")

#-----------------------------------IMPORTING FILES----------------------------------------

setwd(municipios)

mpios<- readOGR(dsn="municipios", layer="municipios") # EPSG:4326
mpios$a_m_km2<-area(mpios)/1000000 # create the area of each municipality; it might be useful. 

#-------------------------OIL MAPS 2019---------------------------------------------

setwd(oil_f)

oil <- readOGR(dsn="raw", layer="Tierras_SEPTIEMBRE_170919")
oil<-clgeo_Clean(oil)
oil <- oil[grepl(c('EXPLORACION|PRODUCCION|TEA'),oil$ESTAD_AREA),]
oil<-spTransform(oil, crs(mpios)) 
writeOGR(oil, dsn="harm", layer="oil_clean_2019", driver ="ESRI Shapefile", overwrite_layer = T)
oil <- readOGR(dsn="harm", layer="oil_clean_2019") 

#-------------------------BASIC CONVERTIONS--------------------------------------

oil<-clgeo_Clean(oil)
mpios<-clgeo_Clean(mpios)

oil_st<-st_as_sf(oil)
mpios_st<-st_as_sf(mpios)

# set the folder where I want everything to be saved. 

setwd(paste(oil_f,'/harm',sep="")) 

#------------------------INTERSECCIONES----------------------------------

mpios_oil<-raster::intersect(oil,mpios)
mpios_oil<-as.data.frame(mpios_oil)


mpios_oil %>% mutate_if(is.factor, as.character) -> mpios_oil
save.dta13(mpios_oil, "int_mpios_oil_19.dta")

#------------------------CENTROIDES----------------------------------

c_oil<-SpatialPointsDataFrame(gCentroid(oil, byid=TRUE), oil@data, match.ID = FALSE)
c_oil_st<-st_as_sf(c_oil)
mpios_oil_st<-st_intersection(mpios_st,c_oil_st)
mpios_oil<-as(mpios_oil_st,'Spatial')
mpios_oil_dta<- as.data.frame(mpios_oil, xy=TRUE, na.rm=TRUE)

mpios_oil_dta %>% mutate_if(is.factor, as.character) -> mpios_oil_dta
save.dta13(mpios_oil_dta, "cent_mpios_oil_19.dta")

#------------------------AREA----------------------------------

mx<-gIntersects(oil, byid=TRUE)
# create a list for the results
results.list<-as.list(vector(length=ncol(mx)))
# group
for(i in 1:ncol(mx)) {
  tmp <- which(mx[,i]) # get TRUE FALSE values for the i-th column
  ifelse(length(tmp)>1, # if there is more than 1 TRUE value,
         tmp.expand<-which(apply(mx[,tmp],1,any)), # get the row-number of the other TRUE Values and create a vector called expand
         tmp.expand<-tmp) # otherwise define tmp as expand
  while(length(tmp.expand)>length(tmp)){ # while tmp.expand has more items than tmp
    tmp<-tmp.expand # reset tmp to tmp.expand
    tmp.expand<-as.vector(which(apply(mx[,tmp],1,any))) # get all new row-numbers of new TRUE values
  }
  results.list[[i]]<-tmp.expand # store results in the list
  print(paste("nr", i, "out of", ncol(mx),"done", sep=" "))
}
# create unique ids from the results
results.list<-
  llply(.data = results.list,
        .fun = function(x)paste(x,collapse=""))
#join everything and convert to usual data type. It is to remark that we lose the attributes and I havent figuresd out how to keep them. This implies that we are not going to have a date to work with.
join<-unionSpatialPolygons(oil,IDs=results.list)
join <- as(join, "SpatialPolygonsDataFrame")
join<-clgeo_Clean(join)
join_st <-st_as_sf(join)
join_st$ID_j<- seq.int(nrow(join_st))
# intersect - note that sf is intelligent with attribute data!
pi <- st_intersection(mpios_st, join_st)
as.data.frame(pi)
# add in areas in m2
attArea <- pi %>%
  mutate(area = st_area(.) %>% as.numeric())
# for each field get area per title
attArea %>%
  as_tibble() %>%
  group_by(admin2Pcod, ID_j) %>%
  summarize(area = sum(area))
pi<-attArea
pi$a_inter_pc<-(pi$area/1000000)/pi$a_m_km2
pi<-as(pi,'Spatial')
pi<-as.data.frame(pi)

pi %>% mutate_if(is.factor, as.character) -> pi
save.dta13(data = pi , file = "area_mpios_oil_19.dta")


#-------------------------OIL MAPS 2020---------------------------------------------

setwd(oil_f)

oil <- readOGR(dsn="raw", layer="Tierras_SEPTIEMBRE_170919")
oil<-clgeo_Clean(oil)
oil <- oil[grepl(c('EXPLORACION|PRODUCCION|TEA'),oil$ESTAD_AREA),]
oil<-spTransform(oil, crs(mpios)) 
writeOGR(oil, dsn="harm", layer="oil_clean_2020", driver ="ESRI Shapefile", overwrite_layer = T)
oil <- readOGR(dsn="harm", layer="oil_clean_2020") 

#-------------------------BASIC CONVERTIONS--------------------------------------

oil<-clgeo_Clean(oil)
mpios<-clgeo_Clean(mpios)

oil_st<-st_as_sf(oil)
mpios_st<-st_as_sf(mpios)

# set the folder where I want everything to be saved. 

setwd(paste(oil_f,'/harm',sep="")) 

#------------------------INTERSECCIONES----------------------------------

mpios_oil<-raster::intersect(oil,mpios)
mpios_oil<-as.data.frame(mpios_oil)

mpios_oil %>% mutate_if(is.factor, as.character) -> mpios_oil
save.dta13(mpios_oil, "int_mpios_oil_20.dta")

#------------------------CENTROIDES----------------------------------

c_oil<-SpatialPointsDataFrame(gCentroid(oil, byid=TRUE), oil@data, match.ID = FALSE)
c_oil_st<-st_as_sf(c_oil)
mpios_oil_st<-st_intersection(mpios_st,c_oil_st)
mpios_oil<-as(mpios_oil_st,'Spatial')
mpios_oil_dta<- as.data.frame(mpios_oil, xy=TRUE, na.rm=TRUE)

mpios_oil_dta %>% mutate_if(is.factor, as.character) -> mpios_oil_dta
save.dta13(mpios_oil_dta, "cent_mpios_oil_20.dta")

#------------------------AREA----------------------------------

mx<-gIntersects(oil, byid=TRUE)
# create a list for the results
results.list<-as.list(vector(length=ncol(mx)))
# group
for(i in 1:ncol(mx)) {
  tmp <- which(mx[,i]) # get TRUE FALSE values for the i-th column
  ifelse(length(tmp)>1, # if there is more than 1 TRUE value,
         tmp.expand<-which(apply(mx[,tmp],1,any)), # get the row-number of the other TRUE Values and create a vector called expand
         tmp.expand<-tmp) # otherwise define tmp as expand
  while(length(tmp.expand)>length(tmp)){ # while tmp.expand has more items than tmp
    tmp<-tmp.expand # reset tmp to tmp.expand
    tmp.expand<-as.vector(which(apply(mx[,tmp],1,any))) # get all new row-numbers of new TRUE values
  }
  results.list[[i]]<-tmp.expand # store results in the list
  print(paste("nr", i, "out of", ncol(mx),"done", sep=" "))
}
# create unique ids from the results
results.list<-
  llply(.data = results.list,
        .fun = function(x)paste(x,collapse=""))
#join everything and convert to usual data type. It is to remark that we lose the attributes and I havent figuresd out how to keep them. This implies that we are not going to have a date to work with.
join<-unionSpatialPolygons(oil,IDs=results.list)
join <- as(join, "SpatialPolygonsDataFrame")
join<-clgeo_Clean(join)
join_st <-st_as_sf(join)
join_st$ID_j<- seq.int(nrow(join_st))
# intersect - note that sf is intelligent with attribute data!
pi <- st_intersection(mpios_st, join_st)
as.data.frame(pi)
# add in areas in m2
attArea <- pi %>%
  mutate(area = st_area(.) %>% as.numeric())
# for each field get area per title
attArea %>%
  as_tibble() %>%
  group_by(admin2Pcod, ID_j) %>%
  summarize(area = sum(area))
pi<-attArea
pi$a_inter_pc<-(pi$area/1000000)/pi$a_m_km2
pi<-as(pi,'Spatial')
pi<-as.data.frame(pi)

pi %>% mutate_if(is.factor, as.character) -> pi
save.dta13(data = pi , file = "area_mpios_oil_20.dta")

#-------------------------GEO MAPS---------------------------------------------
setwd(geo_f)
# Import and clean 

geo<- readOGR(dsn="raw", layer="Zonas_Potenciales_Integradas_Recursos_Minerales_Grupo1_Metales_y__Minerales_Preciosos")
keep_geo <- c("ELEM_PRINC","POTENCIAL","RESTRICCIO")
geo <- geo[,(names(geo) %in% keep_geo)]
geo$ID<- seq.int(nrow(geo))
geo <- geo[grepl('Au',geo$ELEM_PRINC),]
geo$a_geo_km2<-area(geo)/1000000
geo<-spTransform(geo, crs(mpios))
writeOGR(geo, dsn="harm", layer="geo_clean", driver ="ESRI Shapefile", overwrite_layer = T)
geo <- readOGR(dsn="harm", layer="geo_clean")

#-------------------------BASIC CONVERTIONS---------------------------------------------

geo<-clgeo_Clean(geo)
geo_st<-st_as_sf(geo)

#------INTERSECTION------
setwd(paste(geo_f,'/harm',sep="")) 

mpios_geo<-raster::intersect(geo,mpios)
mpios_geo<-as.data.frame(mpios_geo)

mpios_geo %>% mutate_if(is.factor, as.character) -> mpios_geo
save.dta13(mpios_geo, "int_mpios_geo.dta")

#------------------------CENTROIDES----------------------------------

c_geo<-SpatialPointsDataFrame(gCentroid(geo, byid=TRUE), geo@data, match.ID = FALSE)
c_geo_st<-st_as_sf(c_geo)
mpios_geo_st<-st_intersection(mpios_st,c_geo_st)
mpios_geo<-as(mpios_geo_st,'Spatial')
mpios_geo_dta<- as.data.frame(mpios_geo, xy=TRUE, na.rm=TRUE)

mpios_geo_dta %>% mutate_if(is.factor, as.character) -> mpios_geo_dta
save.dta13(mpios_geo_dta, "cent_mpios_geo.dta")

#------------------------AREA----------------------------------

mx<-gIntersects(geo, byid=TRUE)
# create a list for the results
results.list<-as.list(vector(length=ncol(mx)))
# group
for(i in 1:ncol(mx)) {
  tmp <- which(mx[,i]) # get TRUE FALSE values for the i-th column
  ifelse(length(tmp)>1, # if there is more than 1 TRUE value,
         tmp.expand<-which(apply(mx[,tmp],1,any)), # get the row-number of the other TRUE Values and create a vector called expand
         tmp.expand<-tmp) # otherwise define tmp as expand
  while(length(tmp.expand)>length(tmp)){ # while tmp.expand has more items than tmp
    tmp<-tmp.expand # reset tmp to tmp.expand
    tmp.expand<-as.vector(which(apply(mx[,tmp],1,any))) # get all new row-numbers of new TRUE values
  }
  results.list[[i]]<-tmp.expand # store results in the list
  print(paste("nr", i, "out of", ncol(mx),"done", sep=" "))
}
# create unique ids from the results
results.list<-
  llply(.data = results.list,
        .fun = function(x)paste(x,collapse=""))
#join everything and convert to usual data type. It is to remark that we lose the attributes and I havent figuresd out how to keep them. This implies that we are not going to have a date to work with.
join<-unionSpatialPolygons(geo,IDs=results.list)
join <- as(join, "SpatialPolygonsDataFrame")
join<-clgeo_Clean(join)
join_st <-st_as_sf(join)
join_st$ID_j<- seq.int(nrow(join_st))
# intersect - note that sf is intelligent with attribute data!
pi <- st_intersection(mpios_st, join_st)
as.data.frame(pi)
# add in areas in m2
attArea <- pi %>%
  mutate(area = st_area(.) %>% as.numeric())
# for each field get area per title
attArea %>%
  as_tibble() %>%
  group_by(admin2Pcod, ID_j) %>%
  summarize(area = sum(area))
pi<-attArea
pi$a_inter_pc<-(pi$area/1000000)/pi$a_m_km2
pi<-as(pi,'Spatial')
pi<-as.data.frame(pi)
pi %>% mutate_if(is.factor, as.character) -> pi
save.dta13(data = pi , file = "area_mpios_geo.dta")


#---------------------POZOS--------------------------------
setwd(oil_f)

pozos<-readOGR(dsn="raw", layer="POZOS_EPIS_SGC_2020_04_30")
pozos<-clgeo_Clean(pozos)
pozos<-spTransform(pozos,crs(mpios))

mpio_pozos_all<-raster::intersect(pozos,mpios)
mpio_pozos_all<-as.data.frame(mpio_pozos_all)
mpio_pozos_all %>% mutate_if(is.factor, as.character) -> mpio_pozos_all
mpio_pozos_all <-mpio_pozos_all[,!(names(mpio_pozos_all) %in% c("coords.x1","coords.x2","coords.x3"))]
save.dta13(data=mpio_pozos_all,file="harm/mpio_pozos_all.dta")

oil <- readOGR(dsn="harm", layer="oil_clean_2020") 
pozos_prod<-raster::intersect(pozos,oil )

mpio_pozos_prod<-raster::intersect(pozos_prod,mpios)
mpio_pozos_prod<-as.data.frame(mpio_pozos_prod)
mpio_pozos_prod<-as.data.frame(mpio_pozos_prod)
mpio_pozos_prod %>% mutate_if(is.factor, as.character) -> mpio_pozos_prod
mpio_pozos_prod <-mpio_pozos_prod[,!(names(mpio_pozos_prod) %in% c("coords.x1","coords.x2","coords.x3"))]
save.dta13(data = mpio_pozos_prod , file = "harm/mpio_pozos_prod.dta")





