# -----------------------------------------------------------
# RAGE: Regression After Gene Expression
#
# Shint app to inspect the training data 
#
# Date: 20 March 2023
#
library(shiny)
library(tidyverse)
library(fs)

# --- Read the data
cache <- "C:/Projects/RCourse/Masterclass/RAGE/data/cache"

patientDF <- readRDS(path(cache, "patients.rds") )
trainDF   <- readRDS(path(cache, "training.rds"))
nTrainDF  <- readRDS(path(cache, "norm_training.rds"))

# --- names of the 1000 genes
genes <- names(trainDF)[-1]

# --- join expression with patient data
trainDF %>%
  left_join(patientDF, by = "id")  -> trainDF

nTrainDF %>%
  left_join(patientDF, by = "id")  -> nTrainDF



# Define UI: 
ui <- fluidPage(

    # Application title
    titlePanel("RAGE: training data on 1000 genes and 200 patients"),

    # Sidebar  
    sidebarLayout(
        sidebarPanel(
          # select the gene
          selectInput("select", h3("gene"), 
                        choices = genes, 
                        selected = genes[1]),
          # select the smoother
          radioButtons("smooth", label = h3("Smoother"),
                         choices = list("linear" = 1, "lowess" = 2),
                         selected = 1)
        ),

        # Show a plots
        mainPanel(
           plotOutput("rawPlot"),
           plotOutput("normPlot")
        )
    )
)

# Define server logic
server <- function(input, output) {

    output$rawPlot <- renderPlot({
      if( input$smooth == 1 ) {
        tibble( BMI = trainDF$BMI,
                gene     = trainDF[[input$select]] ) %>%
          ggplot( aes(x=gene, y=BMI)) +
          geom_point( size = 1.5 , colour = "steelblue") +
          geom_smooth( method = "lm") +
          labs( x = "Expression", y = "BMI",
                title = "Without Normalisation")
      } else {
        tibble( BMI = trainDF$BMI,
                gene     = trainDF[[input$select]] ) %>%
          ggplot( aes(x=gene, y=BMI)) +
          geom_point( size = 1.5 , colour = "steelblue") +
          geom_smooth() +
          labs( x = "Expression", y = "BMI",
                title = "Without Normalisation")
      }
    })
    
    output$normPlot <- renderPlot({
      if( input$smooth == 1 ) {
        tibble( BMI = nTrainDF$BMI,
                gene     = nTrainDF[[input$select]] ) %>%
          ggplot( aes(x=gene, y=BMI)) +
          geom_point( size = 1.5 , colour = "steelblue") +
          geom_smooth( method = "lm") +
          labs( x = "Expression", y = "BMI",
                title = "Normalised")
      } else {
        tibble( BMI = nTrainDF$BMI,
                gene     = nTrainDF[[input$select]] ) %>%
          ggplot( aes(x=gene, y=BMI)) +
          geom_point( size = 1.5 , colour = "steelblue") +
          geom_smooth() +
          labs( x = "Expression", y = "BMI",
                title = "Normalised")
      }
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
