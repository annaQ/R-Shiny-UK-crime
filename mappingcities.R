#install.packages("rjson")
#install.packages("ggmap")
#install.packages("ggmap")
library(rjson)
library(ggplot2)
library(ggmap)
library(rJava)

###############Build maps

cate <- fromJSON(paste(readLines("category.json"), collapse=""))

cate.df <- as.character()
for(i in 1:15){
  cate.df[i] <- cate[[i]][1]
}

uk <- fromJSON(paste(readLines("uk crime.json"), collapse=""))
crime.df <- data.frame()

for(i in 1:length(uk)){
  record <- uk[[i]]
  crime.df[i,1] <- record$id
  crime.df[i,2] <- record$category
  crime.df[i,3] <- as.numeric(record$location$latitude)
  crime.df[i,4] <- as.numeric(record$location$longitude)
  crime.df[i,5] <- as.Date(paste(record$month,"-01",sep = ""))
  crime.df[i,6] <- record$location$street$id
}
names(crime.df) <- c("id", "category","lat", "lon", "Date","street_id")
northmap<- get_map("Northampton", zoom = 10)
ukmap <- get_map("uk", zoom = 8)
map <- get_map(location = c(lon = mean(crime.df$lon), lat = mean(crime.df$lat)), zoom = 14)
ggmap(map) 
ggmap(map)+geom_point(data=crime.df, aes(y=lat, x=lon, color=category), 
                      size=3, alpha=0.5)
#zoom = 14, lon wide = 0.06, lat = 0.04
map1 <- get_map("London", zoom = 14)
#zoom = 15, lon wide = 0.03, lat = 0.016
map2 <- get_map("London", zoom = 15)
#zoom = 15, lon wide = 0.15, lat = 0.008
map3 <- get_map("London", zoom = 16)

#zoom = 15, lon wide = 0.15, lat = 0.008
map4 <- get_map(location = c(lon = -0.125, lat = 51.509), zoom = 15)

ggmap(map4)
