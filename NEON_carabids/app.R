#install.packages(c("shiny","devtools","rsconnect"))
library(shiny)

data<-read.csv("carabid_data.csv")
tags$h1("NEON Carabid collection Index")

ui<- fluidPage(
  fluidRow(
  column(6, offset = 3, tags$h1("NEON Carabid Lookup", align="center"),
               tags$p("This tool combines data from",
               tags$a(href="https://data.neonscience.org/taxonomic-lists","NEON taxonomy tables"),
               ",", tags$a(href="https://biorepo.neonscience.org/portal/collections/misc/collprofiles.php?collid=39", "specimen records"),
               ", and storage maps for the physical pinned collection.")
         ,align="center")
    ),
  fluidRow(  
    column(4, offset = 4,
           tags$p(tags$a(href="https://mandrewj.shinyapps.io/neonmos/","NEON Mosquito Lookup"))
           ,align="center")
  ),
  fluidRow(
    column(4, offset = 4,
                             
               textInput(inputId = "taxon", label = "Input taxon name:", value ="", width = '400px', placeholder = "Carabidae"),
               radioButtons(inputId = "searchType", label = "Search by:", choices = c("scientific name" = "sciname","NEON taxon code" = "taxonid"),selected = "sciname", inline=TRUE),
               
    )
  ,align="center"),
  fluidRow(
    column(10, offset=1,
               
               #dataTableOutput("tableOut") #interactive datatable
               #verbatimTextOutput("outText"),
               tableOutput("tableOut")
               )
  ,align="center")
  )
server<- function(input, output) {

#filteredData<-eventReactive(input$go, {
#  data[grep(input$taxon, data$sciname, ignore.case=TRUE), ][[1:10]]
#})

  
  
  output$tableOut <- renderTable({ 

        if (input$taxon != "") {
      if (input$searchType =="sciname") {
        
        data[grep(input$taxon, data$scientificName, ignore.case=TRUE),1:6]
        
      } else if (input$searchType =="taxonid") {
        data[grep(input$taxon, data$taxonID, ignore.case=TRUE),1:6]
        }
      }
    }, striped = TRUE, hover=TRUE, spacing = "s")
  
}

shinyApp(ui = ui, server = server)
