library(shiny)
library(ggplot2)
library(rjson)
suppressMessages(library(ggmap))
suppressPackageStartupMessages(library(googleVis))
Th = theme_grey(base_size=20)

shinyServer(function(input, output) {
  
  formulaText <- reactive({
    paste("Choice of categories: ", length(input$cate),
          "\nselected for date :", input$date, 
          "\nfor city of: ", input$city)
  })
  
#   Based on the city and date user selected, this method give proper url for API requesting
#   Major UK cities and their coordinations:
#   lat=51.513&lng=-0.0092 London
#   lat=52.481&lng=-1.9    Birmingham 
#   lat=55.865&lng=-4.258  Glasgow
#   lat=53.411&lng=-2.978  Liverpool
#   lat=53.796&lng=-1.548  Leeds
#   lat=53.383&lng=-1.466  Sheffield
  formulaRequest <- reactive({
    coords <- switch(input$city,
               "London"     = "lat=51.513&lng=-0.0092",
               "Birmingham" = "lat=52.481&lng=-1.9",
               "Glasgow"    = "lat=55.865&lng=-4.258",
               "Liverpool"  = "lat=53.411&lng=-2.978",
               "Leeds"      = "lat=53.796&lng=-1.548",
               "Sheffield"  = "lat=53.383&lng=-1.466")
    paste("http://data.police.uk/api/crimes-street/all-crime?",
          coords,
          "&date=",input$date, sep = "")
  })
  
# Here retrieve a JSON file from url, and convert into a data.frame if the file contains any information
# Else use the dataframe for showing the null result
  crimeTable <- reactive({
      fileDate <-formulaRequest()
      crime <- fromJSON(file = fileDate)
      
      crime.df <- data.frame()
      
      if(length(crime) < 1){
        crime.df
      }
        
      else{
        for(i in 1:length(crime)){
          record <- crime[[i]]
          crime.df[i,1] <- as.integer(record$id)
          crime.df[i,2] <- record$category
          crime.df[i,3] <- as.double(record$location$latitude)
          crime.df[i,4] <- as.double(record$location$longitude)
          crime.df[i,5] <- record$month
          crime.df[i,6] <- as.integer(record$location$street$id)
        }
        
        names(crime.df) <- c("id", "category","lat", "lon", "Date","Street id")
        crime.df <- crime.df[which(crime.df$category %in% input$cate),]

      }
    
    }
  )
  
  output$sum <- renderText(
    formulaText()
  )

  #Render the dynamic table output
  output$DataTable <- renderGvis({
    gvisTable(data = crimeTable(), 
              options = list(page='enable', width = 600, height = 350))
  })
  #Render the map output
  output$map <- renderPlot({
    tb <- crimeTable()
    if(nrow(tb) > 1){
      map <- get_map(location = c(lon = mean(range(tb$lon)), 
                                  lat = mean(range(tb$lat))), 
                     zoom = 14,
                     messaging = FALSE)
      p <- ggmap(map) + geom_point(data=tb, 
                                   aes(y=lat, x=lon, color=category),
                                   size=6,alpha = 0.7, position = "jitter") + 
        ggtitle("Map of crimes distribution\n") + Th
      print(p)
    } else {
      map <- get_map(input$city, 
                     zoom = 14,
                     messaging = FALSE)
      p <- ggmap(map) + ggtitle("No crime records match the requirement\n") + Th
      print(p)
    }
  })
  #Render the map output
  output$pie <- renderPlot({
    tb <- crimeTable()
    if(nrow(tb) > 1){
      p <- ggplot(tb, aes(x = factor(1), fill = factor(category))) +
        geom_bar(width = 1)
      pie <- p + coord_polar(theta = "y")  + 
        ggtitle("Pie chart of crimes in categories\n") + Th
      print(pie)
    } else {
      require(grid)
      p <- qplot(1:10, 1:10, geom="blank") + 
        labs(x = "", y = "", title = "No crimes selected\n") + Th
      print(p)
    }
  })
})