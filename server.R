# Catalyst: treatment risk reduction modeling app (server)
# --------------------------------------------------------
# Defines the server-side portion of the application, where the
# data is loaded into a dataframe, the risk model is generated
# using elastic-net logistic regression, and the results are 
# provided via a risk calculator interface. 

library(shiny)
library(caret)
library(glmnet)

shinyServer(function(input, output) {
      # Reads the user-supplied data into a data frame.
      # Currently just takes in a csv, but can add more sophisticated processing
      #   here to accept data in BioLINCC format.
      df = reactive({
          file = input$file
          if (is.null(file)) return(NULL)
          return(read.csv(file$datapath))
      })
      
      # Dynamically generates the fields where covariate information can be entered.
      # Currently only takes the variable name.
      # Could conceivably be extended to accept additional information (e.g. is variable
      #   categorical or continuous, in numeric or text format, etc.).
      output$covariateInput = renderUI({
          output = vector("list", input$numCovs)
          for (i in 1:input$numCovs) {
              output[[i]] = fluidRow(
                column(3),
                column(6, textInput(paste("covariate", i, sep=""), "Enter name of covariate:", value = "", width = "100%", placeholder = NULL)),
                column(3)
              )
          }
          return(output)
      })
      
      # Builds a list of covariates for use in creating the model formula.
      covs = reactive({
          ls = vector("list", input$numCovs)
          for (i in 1:input$numCovs) {
              ls[[i]] = input[[paste("covariate", i, sep="")]]
          }
          return(ls)
      })
      
      # Creates the risk model.
      # Model is logistic(outcome) = treatment*beta + covariates*beta + treatment*covariates*beta.
      # Variables are selected via elastic-net regularization; hyperparameters are chosen via
      #   10-fold cross-validation.
      # See caret docs to adjust model or training options in train and trainControl methods.
      model = reactive({
          data = df()
          data[,input$outcomeVar] = as.factor(data[,input$outcomeVar])
          covs = covs()
          formula = as.formula(paste(input$outcomeVar, paste(
                                     paste(c(input$treatmentVar, covs), collapse = "+"),
                                     paste(input$treatmentVar, covs, sep = "*", collapse = "+"), sep = "+"), 
                                     sep = " ~ "))
          ctrl = trainControl(method = "cv",
                              number = 10)
          model = train(formula,
                        data = data,
                        method = "glmnet",
                        family = "binomial",
                        trControl = ctrl)
          return(model)
      })
      
      # Generates the risk calculator interface.
      # Current calculator interface is very basic: it accepts (numeric) input for each covariate
      #   and outputs the absolute risk reduction.
      output$calculator = renderUI({
          covs = covs()
          output = vector("list", input$numCovs)
          for (i in 1:input$numCovs) {
              output[[i]] = fluidRow(
                  column(3),
                  column(6, numericInput(paste("covVal", i, sep=""), paste("Enter value for ", covs[[i]], ":", sep = ""), 0, min = NA, max = NA, step = 1, width = "100%")),
                  column(3)
              )
          }
          return(output)
      })
      
      # Computes the absolute risk reduction for the given covariate values.
      # Assumes probs gives a 2x2 df, with:
      #   rows: 1 = not treated, 2 = treated
      #   cols: 1 = outcome 0,   2 = outcome 1
      absRiskRed = reactive({
          model = model()
          covs = covs()
          preds_df = data.frame(matrix(nrow = 2, ncol = 0))
          preds_df[input$treatmentVar] = c(0, 1)
          for (i in 1:input$numCovs) {
              preds_df[covs[[i]]] = rep(input[[paste("covVal", i, sep="")]], 2)
          }
          probs = predict(model, preds_df, type = "prob")
          return(probs[1, 2] - probs[2, 2])
      })
      
      output$riskReduction = renderText({ paste("Absolute risk reduction:", absRiskRed()) })
  }
)
