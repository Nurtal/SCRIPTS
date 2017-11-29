

## Load data
input_data_file = "C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\Spellcraft\\TRASH\\Luminex\\Luminex_SjS_Ctrl.csv"
input_data = read.csv(input_data_file, stringsAsFactors=FALSE, sep=",", header = TRUE)
attach(input_data)
myDF <- input_data[complete.cases(input_data), ]


## create output vector
output_vector = myDF$Disease

## format data for exploration
sparse_matrix <- sparse.model.matrix(Disease~.-1, data = myDF)

## Build the model
bst <- xgboost(data = sparse_matrix, label = output_vector, max.depth = 4,
               eta = 1, nthread = 2, nround = 10,objective = "binary:logistic")

## Load library
require(Matrix)
require(data.table)
require(vcd)
require(xgboost)

## Feature importance
importance <- xgb.importance(feature_names = sparse_matrix@Dimnames[[2]], model = bst)
head(importance)

importanceRaw <- xgb.importance(feature_names = sparse_matrix@Dimnames[[2]], model = bst, data = sparse_matrix, label = output_vector)
importanceClean <- importanceRaw[,`:=`(Cover=NULL, Frequency=NULL)]
head(importanceClean)

## Plot feature importance
xgb.plot.importance(importance_matrix = importanceRaw)
