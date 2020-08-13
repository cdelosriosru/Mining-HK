
# PROJECT :     		Mining and Human Capital
# AUTHOR :				Camilo De Los Rios Rueda
# PURPOSE :				merge mining titles with municipalities in Colombia. This creates the data bases necessary to 
#                 perform the econometric analysis. I have three ways of measuring gold
# DATE WRITTEN :   		21.02.2020
# LAST REVISION DATE: 	29.04.2020
# LAST REVISED BY :   	Camilo De Los Rios  Rueda


##==============================================================================
## INITIALIZE
##==============================================================================

z<-c("ggplot2","ggmap","dplyr", "sf", "sp","rgdal","maptools","rgeos","raster","sf","raster","stars","maps","geosphere","foreign","tidyverse","plyr","cleangeo","hablar","haven","dplyr","maps","viridis","cartogram","tidyverse","broom","readstata13")
lapply(z, library, character.only = TRUE) 

##==============================================================================
## PATHS
##==============================================================================
#data = "C:/Users/camilodel/Desktop/IDB/MINING-HK/DATA"
data = "Z:/IDB/MINING-HK/DATA" # si está en dropx
mineria = paste(data,"/Mineria/titulos_colombia", sep="") #poner si esta en el hard drive
municipios = paste(data,"/PoliticalBoundaries/Colombia", sep="")
#-----------------------------------IMPORTING FILES----------------------------------------

setwd(municipios)

mpios<- readOGR(dsn="municipios", layer="municipios") # EPSG:4326
mpios$a_m_km2<-area(mpios)/1000000 # create the area of each municipality; it might be useful. 


#-------------------------MINING TITLES----------------------------

setwd(mineria) 

loop <- c("08","10","17")

for (x in loop) {
  
  nam <- paste("t_", x, sep = "")
  dsn <- paste("raw/20", x, sep = "")
  layer <- paste("t_", x, sep = "")
  
  assign(nam, readOGR(dsn=dsn, layer= layer) )
  
}

keep_t <- c("MINERALES","FECHA_INSC")


t_08 <- t_08[,(names(t_08) %in% keep_t)]
t_08$ID<- seq.int(nrow(t_08))

t_10 <- t_10[,(names(t_10) %in% keep_t)]
t_10$ID<- seq.int(nrow(t_10))

t_17 <- t_17[,(names(t_17) %in% keep_t)]
t_17$ID<- seq.int(nrow(t_17))


t_08 <- t_08[grepl('ORO',t_08$MINERALES),] # extract only the relevant info. 
writeOGR(t_08, dsn="harm/2008", layer="t_08", driver ="ESRI Shapefile", overwrite_layer = T)
t_08 <- readOGR(dsn="harm/2008", layer="t_08") 
t_08$a_t_km2<-area(t_08)/1000000 
t_08<-spTransform(t_08, crs(mpios)) 

t_10 <- t_10[grepl('ORO',t_10$MINERALES),] # extract only the relevant info. 
writeOGR(t_10, dsn="harm/2010", layer="t_10", driver ="ESRI Shapefile", overwrite_layer = T)
t_10 <- readOGR(dsn="harm/2010", layer="t_10") 
t_10$a_t_km2<-area(t_10)/1000000 
t_10<-spTransform(t_10, crs(mpios)) 

t_17 <- t_17[grepl('ORO',t_17$MINERALES),] # extract only the relevant info. 
writeOGR(t_17, dsn="harm/2017", layer="t_17", driver ="ESRI Shapefile", overwrite_layer = T)
t_17 <- readOGR(dsn="harm/2017", layer="t_17") 
t_17$a_t_km2<-area(t_17)/1000000 
t_17<-spTransform(t_17, crs(mpios)) 




#-------------------------MINING SOLICITUDES----------------------------

setwd(mineria) 

loop <- c("08","10","17")

for (x in loop) {
  
  nam <- paste("s_", x, sep = "")
  dsn <- paste("raw/20", x, sep = "")
  layer <- paste("s_", x, sep = "")
  
  assign(nam, readOGR(dsn=dsn, layer= layer) )
  
}

keep_s <- c("MINERALES","FECHA_RADI") 


s_08 <- s_08[,(names(s_08) %in% keep_s)]
s_08$ID<- seq.int(nrow(s_08))

s_10 <- s_10[,(names(s_10) %in% keep_s)]
s_10$ID<- seq.int(nrow(s_10))

s_17 <- s_17[,(names(s_17) %in% keep_s)]
s_17$ID<- seq.int(nrow(s_17))


s_08 <- s_08[grepl('ORO',s_08$MINERALES),] # extract only the relevant info. 
writeOGR(s_08, dsn="harm/2008", layer="s_08", driver ="ESRI Shapefile", overwrite_layer = T)
s_08 <- readOGR(dsn="harm/2008", layer="s_08") 
s_08$a_s_km2<-area(s_08)/1000000 
s_08<-spTransform(s_08, crs(mpios)) 

s_10 <- s_10[grepl('ORO',s_10$MINERALES),] # extract only the relevant info. 
writeOGR(s_10, dsn="harm/2010", layer="s_10", driver ="ESRI Shapefile", overwrite_layer = T)
s_10 <- readOGR(dsn="harm/2010", layer="s_10") 
s_10$a_s_km2<-area(s_10)/1000000 
s_10<-spTransform(s_10, crs(mpios)) 

s_17 <- s_17[grepl('ORO',s_17$MINERALES),] # extract only the relevant info. 
writeOGR(s_17, dsn="harm/2017", layer="s_17", driver ="ESRI Shapefile", overwrite_layer = T)
s_17 <- readOGR(dsn="harm/2017", layer="s_17") 
s_17$a_s_km2<-area(s_17)/1000000 
s_17<-spTransform(s_17, crs(mpios)) 

#------BASICS--------- 
# Basic convertions that I need for more than one task. 
mpios<-clgeo_Clean(mpios)

s_08<-clgeo_Clean(s_08)
s_10<-clgeo_Clean(s_10)
s_17<-clgeo_Clean(s_17)

t_08<-clgeo_Clean(t_08)
t_10<-clgeo_Clean(t_10)
t_17<-clgeo_Clean(t_17)


mpios_st<-st_as_sf(mpios)

t_08_st<-st_as_sf(t_08)
t_10_st<-st_as_sf(t_10)
t_17_st<-st_as_sf(t_17)

s_08_st<-st_as_sf(s_08)
s_10_st<-st_as_sf(s_10)
s_17_st<-st_as_sf(s_17)

# set the folder where I want everything to be saved. 
setwd(paste(mineria,'/harm',sep="")) 

#------INTERSECTION------

mpios_oro_t_08<-raster::intersect(t_08,mpios)
mpios_oro_t_08<-as.data.frame(mpios_oro_t_08)

mpios_oro_t_08 %>% mutate_if(is.factor, as.character) -> mpios_oro_t_08
save.dta13(mpios_oro_t_08, "int_mpios_oro_t_08.dta")

mpios_oro_t_10<-raster::intersect(t_10,mpios)
mpios_oro_t_10<-as.data.frame(mpios_oro_t_10)

mpios_oro_t_10 %>% mutate_if(is.factor, as.character) -> mpios_oro_t_10
save.dta13(mpios_oro_t_10, "int_mpios_oro_t_10.dta")

mpios_oro_t_17<-raster::intersect(t_17,mpios)
mpios_oro_t_17<-as.data.frame(mpios_oro_t_17)

mpios_oro_t_17 %>% mutate_if(is.factor, as.character) -> mpios_oro_t_17
save.dta13(mpios_oro_t_17, "int_mpios_oro_t_17.dta")


mpios_oro_s_08<-raster::intersect(s_08,mpios)
mpios_oro_s_08<-as.data.frame(mpios_oro_s_08)

mpios_oro_s_08 %>% mutate_if(is.factor, as.character) -> mpios_oro_s_08
save.dta13(mpios_oro_s_08, "int_mpios_oro_s_08.dta")

mpios_oro_s_10<-raster::intersect(s_10,mpios)
mpios_oro_s_10<-as.data.frame(mpios_oro_s_10)

mpios_oro_s_10 %>% mutate_if(is.factor, as.character) -> mpios_oro_s_10
save.dta13(mpios_oro_s_10, "int_mpios_oro_s_10.dta")

mpios_oro_s_17<-raster::intersect(s_17,mpios)
mpios_oro_s_17<-as.data.frame(mpios_oro_s_17)

mpios_oro_s_17 %>% mutate_if(is.factor, as.character) -> mpios_oro_s_17
save.dta13(mpios_oro_s_17, "int_mpios_oro_s_17.dta")


#----CENTROIDS----

c_t_08<-SpatialPointsDataFrame(gCentroid(t_08, byid=TRUE), t_08@data, match.ID = FALSE) 
c_t_08_st<-st_as_sf(c_t_08)
mpios_oro_t_08_st<-st_intersection(mpios_st,c_t_08_st) 
mpios_oro_t_08<-as(mpios_oro_t_08_st,'Spatial')
mpios_oro_t_08_dta<- as.data.frame(mpios_oro_t_08, xy=TRUE, na.rm=TRUE)

mpios_oro_t_08_dta %>% mutate_if(is.factor, as.character) -> mpios_oro_t_08_dta
save.dta13(mpios_oro_t_08_dta, "cent_mpios_oro_t_08.dta") 

c_t_10<-SpatialPointsDataFrame(gCentroid(t_10, byid=TRUE), t_10@data, match.ID = FALSE) 
c_t_10_st<-st_as_sf(c_t_10)
mpios_oro_t_10_st<-st_intersection(mpios_st,c_t_10_st) 
mpios_oro_t_10<-as(mpios_oro_t_10_st,'Spatial')
mpios_oro_t_10_dta<- as.data.frame(mpios_oro_t_10, xy=TRUE, na.rm=TRUE)

mpios_oro_t_10_dta %>% mutate_if(is.factor, as.character) -> mpios_oro_t_10_dta
save.dta13(mpios_oro_t_10_dta, "cent_mpios_oro_t_10.dta") 

c_t_17<-SpatialPointsDataFrame(gCentroid(t_17, byid=TRUE), t_17@data, match.ID = FALSE) 
c_t_17_st<-st_as_sf(c_t_17)
mpios_oro_t_17_st<-st_intersection(mpios_st,c_t_17_st) 
mpios_oro_t_17<-as(mpios_oro_t_17_st,'Spatial')
mpios_oro_t_17_dta<- as.data.frame(mpios_oro_t_17, xy=TRUE, na.rm=TRUE)

mpios_oro_t_17_dta %>% mutate_if(is.factor, as.character) -> mpios_oro_t_17_dta
save.dta13(mpios_oro_t_17_dta, "cent_mpios_oro_t_17.dta") 


c_s_08<-SpatialPointsDataFrame(gCentroid(s_08, byid=TRUE), s_08@data, match.ID = FALSE) 
c_s_08_st<-st_as_sf(c_s_08)
mpios_oro_s_08_st<-st_intersection(mpios_st,c_s_08_st) 
mpios_oro_s_08<-as(mpios_oro_s_08_st,'Spatial')
mpios_oro_s_08_dta<- as.data.frame(mpios_oro_s_08, xy=TRUE, na.rm=TRUE)

mpios_oro_s_08_dta %>% mutate_if(is.factor, as.character) -> mpios_oro_s_08_dta
save.dta13(mpios_oro_s_08_dta, "cent_mpios_oro_s_08.dta") 

c_s_10<-SpatialPointsDataFrame(gCentroid(s_10, byid=TRUE), s_10@data, match.ID = FALSE) 
c_s_10_st<-st_as_sf(c_s_10)
mpios_oro_s_10_st<-st_intersection(mpios_st,c_s_10_st) 
mpios_oro_s_10<-as(mpios_oro_s_10_st,'Spatial')
mpios_oro_s_10_dta<- as.data.frame(mpios_oro_s_10, xy=TRUE, na.rm=TRUE)

mpios_oro_s_10_dta %>% mutate_if(is.factor, as.character) -> mpios_oro_s_10_dta
save.dta13(mpios_oro_s_10_dta, "cent_mpios_oro_s_10.dta") 

c_s_17<-SpatialPointsDataFrame(gCentroid(s_17, byid=TRUE), s_17@data, match.ID = FALSE) 
c_s_17_st<-st_as_sf(c_s_17)
mpios_oro_s_17_st<-st_intersection(mpios_st,c_s_17_st) 
mpios_oro_s_17<-as(mpios_oro_s_17_st,'Spatial')
mpios_oro_s_17_dta<- as.data.frame(mpios_oro_s_17, xy=TRUE, na.rm=TRUE)

mpios_oro_s_17_dta %>% mutate_if(is.factor, as.character) -> mpios_oro_s_17_dta
save.dta13(mpios_oro_s_17_dta, "cent_mpios_oro_s_17.dta") 

#-------AREAS--------

#Ok this turned out to be a real nightmare.... The best thing that I can do, for now, is to merge all the polygons regardless of the date. 

    mx<-gIntersects(t_08, byid=TRUE)
    
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
    
    join<-unionSpatialPolygons(t_08,IDs=results.list)
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
    save.dta13(data = pi , file = "area_mpios_oro_t_08.dta") 
    
    

    
    mx<-gIntersects(t_10, byid=TRUE)
    
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
    
    join<-unionSpatialPolygons(t_10,IDs=results.list)
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
    save.dta13(data = pi , file = "area_mpios_oro_t_10.dta") 
    
    
    
    mx<-gIntersects(t_17, byid=TRUE)
    
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
    
    join<-unionSpatialPolygons(t_17,IDs=results.list)
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
    save.dta13(data = pi , file = "area_mpios_oro_t_17.dta") 
    

    
    #Ok this turned out to be a real nightmare.... The best thing that I can do, for now, is to merge all the polygons regardless of the date. 
    
    mx<-gIntersects(s_08, byid=TRUE)
    
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
    
    join<-unionSpatialPolygons(s_08,IDs=results.list)
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
    save.dta13(data = pi , file = "area_mpios_oro_s_08.dta") 
    
    
    
    
    
    
    mx<-gIntersects(s_10, byid=TRUE)
    
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
    
    join<-unionSpatialPolygons(s_10,IDs=results.list)
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
    save.dta13(data = pi , file = "area_mpios_oro_s_10.dta") 
    
    
    
    mx<-gIntersects(s_17, byid=TRUE)
    
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
    
    join<-unionSpatialPolygons(s_17,IDs=results.list)
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
    save.dta13(data = pi , file = "area_mpios_oro_s_17.dta") # FINALLY!
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    