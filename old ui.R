library(shiny)
library(rjson)
cate <- fromJSON(file = "http://data.police.uk/api/crime-categories?date=2013-08")
dates <- fromJSON(file = "http://data.police.uk/api/crimes-street-dates")
dates <- as.character(unlist(dates))
names(dates) <- dates

cate.df <- as.character()
for(i in 1:length(cate)){
  cate.df[i] <- cate[[i]][1]
}

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Category of crime"),
  
  sidebarPanel(
    
    #Location
    sliderInput("lat", 
                "Select latitude:", 
                min = 49,
                max = 61, 
                value = 52.629729,
                step= 0.000001
    ),
    sliderInput("lon", 
                "Select Longitude :", 
                min = -2.000,
                max = 2.000, 
                value = -1.131592,
                step= 0.000001
    ),
    br(),
    #for select categories to study
    checkboxGroupInput("variable", "Variable:", cate.df[-1]),
    #for select a specified date
    selectInput("date", "Date:",dates)
  ),
  
  mainPanel(
    tabsetPanel(
      tabPanel("Summary", h3(verbatimTextOutput("num"))), 
      tabPanel("Category", tableOutput("list")), 
      tabPanel("Table", htmlOutput("DataTable")),
      tabPanel("Mapgg", plotOutput("map",width= 800, height=800)) 
    )
    
  )
))