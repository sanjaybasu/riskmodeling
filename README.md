# Creating multivariable risk models from clinical trial data

Many clinical trials now release individual participant data, which enables researchers to create personalized medicine decision-making tools for clinicians: multivariable models of heterogeneous treatment effects (HTEs), which use the data from trials to predict which people are more likely to experience benefit, no effect, or harm from therapy.

Here, we provide code for a Shiny app in R that enables rapid generation of multivariable benefit/risk prediction models, using elastic net regularization to minimize the risk of overfitting and maximize generalizability.

The code:
1. Reads in user-supplied data (.csv with named columns)
2. Allows the user to identify the outcome, treatment, and covariates, as named in the data headers
3. Fits a logistic model with elastic-net regularization, allows the user to enter values for each covariate, and displays the absolute risk reduction for the patient given the supplied values

The implementation can be applied by users to clinical trial data, at:
https://sanjaybasu.shinyapps.io/rctmodeling/

Thanks to Jonas Kemp, jbkemp7@stanford.edu

Sanjay Basu
Department of Medicine, Stanford University
*basus@stanford.edu
