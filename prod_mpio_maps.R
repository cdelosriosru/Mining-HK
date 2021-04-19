#load packages
z<-c("base","ggpubr","cleangeo","ggplot2","rgdal","haven","dplyr","broom","sf","plyr")
#ggplot2 or tidyverse
#z<-c("cleangeo'","ggplot2","ggmap","dplyr", "sf", "sp","rgdal","maptools","rgeos","raster","sf","raster","stars","maps","geosphere","foreign","tidyverse","xlsx","plyr","cleangeo","hablar","haven","dplyr","maps","viridis","cartogram","tidyverse","broom")
lapply(z, library, character.only = TRUE) 



#PATHS 
main = "C:/Users/cdelo/Dropbox/HK_Extractives_2020"
prod = paste(main,"/DATA/Produccion_campos/harm", sep="") 
wells = paste(main,"/DATA/Petroleo/raw", sep="") 
politic = paste(main, "/DATA/PoliticalBoundaries", sep="") 
violencia = paste(main, "/DATA/Violencia/harm", sep="") 

loc_fig = ("C:/Users/cdelo/Dropbox/Apps/Overleaf/Oil - HK - Colombia/graphs")
# I like this projection better
wgs.84    <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" # ASUM? QUE ESTA ERA LA PROYECCI?N DE LOS COLEGIOS


#--------------IMPORTING FILES----------------------------------------

setwd(politic)

#load and prepare the map 

mpios<- readOGR(dsn=".", layer="land_mpios") 
mpios<-clgeo_Clean(mpios)

mpios$codmpio<-substr(mpios$admin2Pcod, 3, 7)
mpios$codmpio<-as.numeric(mpios$codmpio)

# load the data. I created the vars in stata (its easier as I had the code ready)

setwd(prod)

dta<-read_dta("prod_oil_mpio.dta")

dta<-dta%>%
  filter(year == 2011)
# Merge data 

prod_mpio<-merge(mpios,dta, by = "codmpio")
prod_mpio$prom_prod_mpio_trans<-prod_mpio$prom_prod_mpio2/1000000

#loc_data_st<-fortify(loc_data, region="NOMBRE")
#names(loc_data_st)[names(loc_data_st) == "id"] <- "NOMBRE"
#loc_data_st<-merge(loc_data_st,dta, by= "NOMBRE")

sf_poly <- as(prod_mpio, "sf")

setwd(loc_fig)

# First only the mean socioeconomic stratum



ggplot(sf_poly) +
  geom_sf(aes(fill = prom_prod_mpio_trans), size = 0.00001, color = "black") +  
  coord_sf(crs = wgs.84)  +
  scale_fill_continuous(low='thistle2', high='darkred', 
                        guide='colourbar', ,na.value="white", name="")+
  theme_void()+
  theme(legend.justification = "center",
        legend.key.size = unit(0.6, "cm"),
        legend.position="right",
        legend.box="vertical"
        )
#+
# theme(plot.title = element_text(hjust = 0.5))+

#  theme(plot.title=element_text(size=10, hjust=0.5, face="bold", colour="black",vjust=-1)) +
# theme(plot.subtitle=element_text(size=7, hjust=0.5, face="italic", color="black")) +
#labs(title="Mean Socioeconomic Stratum",
#    subtitle="by Population")

ggsave("prom_prod_million.pdf")
ggsave("prom_prod_million.png")

#Vargas Conflict-----------------
setwd(violencia)


map<- readOGR(dsn=".", layer="map") 
map<-clgeo_Clean(map)
farc<-read_dta("farc.dta")

farc_mpio<-merge(mpios,farc, by = "codmpio")
farc_mpio$FARC1[is.na(farc_mpio$FARC1)] <- 0

sf_poly2 <- as(farc_mpio, "sf")
sf_poly3 <- as(map, "sf")
sf3<-as.data.frame(map)
sf3$Landmines<-"Landmines"


setwd(loc_fig)


ggplot(sf_poly2) +
  geom_sf(aes(fill = FARC1), size = 0.00001, color = "black") +  
  coord_sf(crs = wgs.84)  +
  scale_fill_gradient(low='grey90', high='orangered1', 
                       guide = "legend", breaks= c(0,1), labels = c("No FARC", "FARC"), name = "")+
  
  theme_void()+
  theme(legend.justification = "center",
        legend.key.size = unit(0.6, "cm"),
        legend.position="right",
        legend.box="vertical"
  )+
  geom_point(data=sf3, aes(longitud_c, latitud_ca, colour = factor(Landmines), shape=factor(Landmines)), alpha = 0.6, size = .8, color = "black") + 
  coord_sf(crs = wgs.84)+
  labs(colour = "",
       shape= "")+
  scale_color_manual(name = "", values = "black")

ggsave("LandminesVIO.pdf")
ggsave("LandminesVIO.png")


sf32<-sf3%>%
  filter(a_o > 2010)

ggplot(sf_poly2) +
  geom_sf(aes(fill = FARC1), size = 0.00001, color = "black") +  
  coord_sf(crs = wgs.84)  +
  scale_fill_gradient(low='grey90', high='orangered1', 
                      guide = "legend", breaks= c(0,1), labels = c("No FARC", "FARC"), name = "")+
  
  theme_void()+
  theme(legend.justification = "center",
        legend.key.size = unit(0.6, "cm"),
        legend.position="right",
        legend.box="vertical"
  )+
  geom_point(data=sf32, aes(longitud_c, latitud_ca, colour = factor(Landmines), shape=factor(Landmines)), alpha = 0.6, size = .8, color = "black") + 
  coord_sf(crs = wgs.84)+
  labs(colour = "",
       shape= "")+
  scale_color_manual(name = "", values = "black")

ggsave("LandminesVIO_f.pdf")
ggsave("LandminesVIO_f.png")




#----Wells and Prod-----

setwd(wells)


wells<- readOGR(dsn=".", layer="graph_pozos") 
wells<-clgeo_Clean(wells)
sfwells<-as.data.frame(wells)
sfwells$Wells<-"Oil Wells"

setwd(loc_fig)

ggplot(sf_poly) +
  geom_sf(aes(fill = prom_prod_mpio_trans), size = 0.00001, color = "black") +  
  coord_sf(crs = wgs.84)  +
  scale_fill_continuous(low='thistle2', high='darkred', 
                        guide='colourbar', ,na.value="white", name="")+
  theme_void()+
  theme(legend.justification = "center",
        legend.key.size = unit(0.6, "cm"),
        legend.position="right",
        legend.box="vertical"
  )+
  geom_point(data=sfwells, aes(WELL_LONGI, WELL_LATIT, colour = factor(Wells), shape=factor(Wells)), alpha = 0.5, size = .5, color = "black") + 
  coord_sf(crs = wgs.84)+
  labs(colour = "",
       shape= "")+
  scale_color_manual(name = "", values = "black")

ggsave("prod_wells_mpio.pdf")
ggsave("prod_wells_mpio.png")

