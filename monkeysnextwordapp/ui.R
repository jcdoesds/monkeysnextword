#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


shinyUI(
  fluidPage(
    
    title = "Monkeys Guess Your Next Word",
    
    fluidRow(
      column(5, offset = 4,
             h1("Monkeys Guess The Next Word")
      )
    ),
    
    plotOutput("distPlot"),
    
    hr(),
    
    fluidRow(
      column(4,
             h4("Diamonds Explorer")
      ),
      column(4,
             sliderInput("bins",
                         "Number of bins:",
                         min = 1,
                         max = 50,
                         value = 30)
      ),
      column(4,
             h4("right")
      )
    )
  )
)

