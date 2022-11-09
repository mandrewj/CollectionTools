library("shiny")
library("jsonlite")
library("rvest")
library("ggplot2")
library("ggmap")

#hard code these variables to start with
collid<-4
gbifdataset<-"59728459-7b42-4942-8e38-00eb56f2331e"

#portal= use installation API to find portal and collection?
#GBIF - eventually get from Symbiota API?





# UI output ----
ui<- fluidPage(
  fluidRow(
    column(8, offset = 2,
           tags$p("Collection details are hard-coded for this example, but could be made reactive with inputs."),
           tags$p(paste("Collid=",collid,sep=" ")),
           tags$p(paste("GBIF dataset:",gbifdataset,sep=" ")),
           #numericInput(inputId = "collid", label = "Input collid:", value =4, min=1, max=1000, width = '400px'),
           #textInput(inputId = "gbifdataset", label = "Input GBIF dataset key:", value ="59728459-7b42-4942-8e38-00eb56f2331e", width = '400px'),
           
           #actionButton(inputId="set", label="set"),
           tags$p("click refresh to generate page - each element can be automated to periodically update"),
           actionButton(inputId = "refresh data", label = "refresh")
           #actionButton(inputId = "refresh map", label = "refreshmap")
           
    )
    ,align="center"),
  
  
  fluidRow(
    column(8, offset = 2, tags$h1(textOutput("title")))
  ,align="center"),
  fluidRow(
    column(2, offset = 4, htmlOutput("collicon")),
    column(2,offset = 6, tags$p(textOutput("collcodes")))
           
           ),

  fluidRow(
    column(10, offset=1,
           tags$h3("Ecdysis specimen records:"),
           tags$p("Total specimens:"),
           textOutput("ecdysisOut"),
           ""
    )
    ,align="center"),
  fluidRow(
    column(10, offset = 1,
        tags$p(" This currently displays the last record for the portal and not yet the last record for this collid - pending API developments"),
        #htmlOutput("ecdysisRecord"))
        tableOutput("ecdysisRecord"))
      ,align="center"),
  fluidRow(
    column(10, offset=1,
           
           plotOutput("ecdysisRecordMap")
    )
    ,align="center"),

  fluidRow(
    column(10, offset=1,
           tags$h3("GBIF literature citations:"),
           textOutput("gbifOut"),
           ""
    )
    ,align="center"),
  fluidRow(
    column(10, offset=1,
           tags$h3("Bionomia specimens-to-people links:"),
           textOutput("bionomiaOut"),
           "",
           ""
    )
    ,align="center"),
  fluidRow(
    column(10, offset=1,
           tags$h3("Heat map of specimens from the collection:"),
           plotOutput("recordMap")
    )
    ,align="center")
)

# Server code ----

server<- function(input, output, session) {
  # timer setup ####
  #reactive timers: https://shiny.rstudio.com/reference/shiny/0.14/reactiveTimer.html
  autoDaily<-reactiveTimer(86400000)
  autoMinute<-reactiveTimer(6000)
  refresh<-eventReactive(input$refresh,{})
  #refreshmap<-eventReactive(input$refreshmap,{})
   observeEvent(input$set,{
              collid<-input$collid
              print(collid)
              gbifdataset<-input$gbifdataset
              print(gbifdataset)
 }
              
              )
  
  
    # minute updates ####
  
  output$title<-renderText({
    refresh()
    fromJSON(paste("https://serv.biokic.asu.edu/ecdysis/api/v2/collection/",collid, sep=""))$collectionName
  })
  
  output$collcodes<-renderText({
    refresh()
    paste("Institution code:",{fromJSON(paste("https://serv.biokic.asu.edu/ecdysis/api/v2/collection/",collid, sep=""))$institutionCode},
          "Collection code:",{fromJSON(paste("https://serv.biokic.asu.edu/ecdysis/api/v2/collection/",collid, sep=""))$collectionCode},sep=" ")
  })
  
  output$collicon<-renderText({
    refresh()
    paste('<img src="',{fromJSON(paste("https://serv.biokic.asu.edu/ecdysis/api/v2/collection/",collid, sep=""))$icon},'" style="height:70px;align:center;valign:center;">')
  })
  
  output$ecdysisOut<-renderText({
  refresh()

  #update with stats API calls eventually    
  collpage<- read_html(paste("https://serv.biokic.asu.edu/ecdysis/collections/misc/collprofiles.php?collid=",collid,sep=""))
  
  stats<- collpage %>%
    html_nodes("li") %>%
    html_text()
  
  strsplit(stats[grep(" specimen records",stats)], split =" ")[[1]][1]
  })

  
  output$ecdysisRecord<-renderTable({
  refresh()
  x<- fromJSON(paste("https://serv.biokic.asu.edu/ecdysis/api/v2/occurrence?limit=1&offset=0&collid=",collid,sep=""))
  offset<-x$count - 1
  y<- fromJSON(paste("https://serv.biokic.asu.edu/ecdysis/api/v2/occurrence?offset=",offset,"&limit=1&collid=",collid, sep=""))
  
  
  data.frame(catalogNumber=y$results$catalogNumber, family=y$results$family, scientificName=y$results$sciname,
             collectedBy=y$results$recordedBy, identifiedBy=y$results$identifiedBy, digitizedBy=y$results$recordEnteredBy, dateEntered=y$results$dateEntered)
  
  
  #paste('<iframe src="',{paste("https://serv.biokic.asu.edu/ecdysis/collections/individual/index.php?occid=",y$results$occid,sep="")},'" width="800px" height="600px" style="overflow:auto;border:5px ridge blue"></iframe>',sep="")

  })
  
  
  output$ecdysisRecordMap<-renderPlot({
    refresh()
    x<- fromJSON(paste("https://serv.biokic.asu.edu/ecdysis/api/v2/occurrence?limit=1&offset=0&collid=",collid,sep=""))
    offset<-x$count - 1
    y<- fromJSON(paste("https://serv.biokic.asu.edu/ecdysis/api/v2/occurrence?offset=",offset,"&limit=1&collid=",collid, sep=""))
    
    
    if (!is.na(y$results$decimalLatitude)) {
      bbox<-c(left={y$results$decimalLongitude-10}, bottom={y$results$decimalLatitude-10}, right= {y$results$decimalLongitude+10}, top={y$results$decimalLatitude+10})
      mymap<-get_stamenmap(bbox, zoom = 4, maptype="toner-lite", crop = FALSE)
      ggmap(mymap) +
        geom_point(aes(x = decimalLongitude, y = decimalLatitude),data=y$results, size=4, color="blue") +
        ggtitle("Specimen collection locality") +
        theme(plot.title = element_text(hjust = 0.5),
              legend.position = "none",
              axis.ticks.x = element_blank(),
              axis.ticks.y = element_blank(),
              axis.text.x = element_blank(),
              axis.text.y = element_blank(),
        ) +
        labs(x='', y='')
    
    }
  
  })
  
  
  output$gbifOut<-renderText({
    refresh()
    fromJSON(paste("https://api.gbif.org/v1/literature/search?gbifDatasetKey=",gbifdataset,"&limit=1",sep=''))$count
  })
  
  
  output$bionomiaOut<-renderText({
    #invalidateLater(2000)
    refresh()
    print("scraping bionomia")
    bpage<-read_html(paste("https://bionomia.net/dataset/",gbifdataset,sep=""))
    
    strsplit({bpage %>%
        html_nodes(".alert-info") %>%
        html_text()},split="\n")[[1]][3]
    
    
  })
  
  
  
  # daily updates ####
  #observe({
    #https://www.geeksforgeeks.org/append-row-to-csv-using-r/
    #Create stats string and append to file
    
   # })

  output$recordMap <- renderPlot({
    refresh()
    #autoDaily()
    #get occurrence data
    temp <- tempfile()
    download.file(paste("https://serv.biokic.asu.edu/ecdysis/webservices/dwc/dwcapubhandler.php?collid=",collid,sep=""),temp)
    data <- read.csv(unzip(temp, files="occurrences.csv"))
    unlink(temp)
    
    #data<-read.csv("occurrences.csv")
    
    #create map
    
    bbox<-c(left=-179, bottom = -65, right = 179, top = 70)
    mymap<- get_stamenmap(bbox, zoom=3, maptype="toner-lite", crop=TRUE)
    ggmap(mymap)+
      #stat_density2d(aes(x = decimalLongitude, y = decimalLatitude, fill = ..level.., alpha =.5), data = data, geom="polygon", contour_var = "density", bins=100, size=5) +
      #scale_fill_distiller(palette = "RdYlBu")+
      geom_point(aes(x = decimalLongitude, y = decimalLatitude, alpha = .1),data=data, size=1.5, color="blue") +
      ggtitle("Georeferenced specimen records") +
      theme(plot.title = element_text(hjust = 0.5),
            legend.position = "none",
            axis.ticks.x = element_blank(),
            axis.ticks.y = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_blank(),
      ) +
      labs(x='', y='')
    
  })
  
  }

# Call app ----

shinyApp(ui = ui, server = server)
