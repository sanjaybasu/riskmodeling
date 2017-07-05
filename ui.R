# Catalyst: treatment risk reduction modeling app (UI)
# ----------------------------------------------------
# Defines the user-facing portion of the application, where the
# user can upload a data file of choice, select a treatment variable
# and covariates for the risk model, and generate a risk calculator.

library(shiny)

shinyUI(
  navbarPage("Modeling Treatment Benefit/Risk from RCT Data",
    
    tabPanel("1. Upload data",
        fluidPage(fluidRow(
            column(3),
            column(6, fileInput("file", "Choose data file to upload (format: CSV with headers)...",
                      accept = c("text/csv",
                                 "text/comma-separated-values,text/plain",
                                 ".csv"),
                      width = '100%'
            )),
            column(3)
        ))
    ),
             
    tabPanel("2. Select variables",
        fluidPage(
            fluidRow(
                column(3),
                column(6, textInput("outcomeVar", "Enter name of outcome variable:", value = "", width = "100%", placeholder = NULL)),
                column(3)
            ),
            fluidRow(
              column(3),
              column(6, textInput("treatmentVar", "Enter name of treatment variable:", value = "", width = "100%", placeholder = NULL)),
              column(3)
            ),
            fluidRow(
              column(3),
              column(6, numericInput("numCovs", "Enter number of covariates:", 1, min = 1, max = NA, step = 1, width = "200px")),
              column(3)
            ),
            uiOutput("covariateInput")
        )
    ),
             
    tabPanel("3. Risk calculator",
        fluidPage(
            fluidRow(
                column(2),
                column(8, h3(textOutput("riskReduction"), align = "center")),
                column(2)
            ),
            uiOutput("calculator")
        )
    )
  
  )
)
