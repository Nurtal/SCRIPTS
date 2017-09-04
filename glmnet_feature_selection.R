
##-------------------##
## FEATURE SELECTION ##
##-------------------##

## -> Lasso and Elastic-Net Regularized Generalized Linear Models
## -> Features Selection using the glmnet package
## -> Results display in the console are stored in txt file
## to be processed with a python function


## Import library
library(glmnet)


## Load data & define files names
input_data_file = "C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\Spellcraft\\Side Quest\\Bene\\newCytoData.csv"
output_file = "C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\Spellcraft\\Side Quest\\Bene\\test.txt"
input_data = na.omit(read.csv(input_data_file, stringsAsFactors=TRUE, sep=",", header = TRUE))
attach(input_data)

## Fit the model
cv.glmnet(x = as.matrix(input_data[, -1]),
          y = factor(input_data[, 1]),
          family = "multinomial", 
          type.measure = "class", 
          parallel = FALSE) -> cvfit


## Write console output in a txt file
results <- coef(cvfit, s = "lambda.min")
sink(log_file, append=TRUE)
results
sink()