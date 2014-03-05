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
  headerPanel("Crime in UK cities"),
  
  
  sidebarPanel(

    img(src = "http://resources.woodlands-junior.kent.sch.uk/customs/images/uk.jpg", height = 200, width = 400),
    #for select a specified date
    selectInput("date", "Date:",dates),
    br(),
    #for select city of interest
    radioButtons("city", "City:",
                 c("London"     = "London",
                   "Birmingham" = "Birmingham",
                   "Glasgow"    = "Glasgow",
                   "Liverpool"  = "Liverpool",
                   "Leeds"      = "Leeds",
                   "Sheffield"  = "Sheffield")),
    br(),
    #for select categories to study
    checkboxGroupInput("cate", "Categories: (select at least one)", 
                       cate.df[-1], select = cate.df[2])
    ),
  
  mainPanel(
    tabsetPanel(
      
      tabPanel("Summary",h3(verbatimTextOutput("sum"))),
      tabPanel("Plot", plotOutput("pie")),
      tabPanel("Map", plotOutput("map",width= 800, height=800)),
      tabPanel("Table", htmlOutput("DataTable")) 
    )
   
    )
))