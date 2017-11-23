
require(xgboost)


## Load ecemple data
data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')
train <- agaricus.train
test <- agaricus.test


## REAL DATA TEST ##

## Load real data
input_data_file = "/home/perceval/Spellcraft/luminex/data_control_SjS.csv"
input_data = read.csv(input_data_file, stringsAsFactors=TRUE, sep=",", header = TRUE)
attach(input_data)

## Prepare data
myDF <- input_data[complete.cases(input_data), ]
df <- data.table(myDF, keep.rownames = F)
head(df)
sparse_matrix <- sparse.model.matrix(Disease~.-1, data = df)
head(sparse_matrix)

## Prepare Label
output_vector = df[,Disease] == "SjS"

## Train model
bst <- xgboost(data = sparse_matrix, label = output_vector, max.depth = 4,
               eta = 1, nthread = 2, nround = 10,objective = "binary:logistic")

## feature importance
importance <- xgb.importance(feature_names = sparse_matrix@Dimnames[[2]], model = bst)
head(importance)

importanceRaw <- xgb.importance(feature_names = sparse_matrix@Dimnames[[2]], model = bst, data = sparse_matrix, label = output_vector)
# Cleaning for better display
importanceClean <- importanceRaw[,`:=`(Cover=NULL, Frequency=NULL)]
head(importanceClean)

## plot feature importance
xgb.plot.importance(importance_matrix = importanceRaw)


###################

bst <- xgboost(data = train$data, label = train$label, max.depth = 2, eta = 1, nthread = 2, nround = 200, objective = "binary:logistic", verbose = 2)


pred <- predict(bst, test$data)
print(head(pred))

prediction <- as.numeric(pred > 0.5)
print(head(prediction))

err <- mean(as.numeric(pred > 0.5) != test$label)
print(paste("test-error=", err))

dtrain <- xgb.DMatrix(data = train$data, label=train$label)
dtest <- xgb.DMatrix(data = test$data, label=test$label)





## Another exemple ##
require(xgboost)
require(Matrix)
require(data.table)
require('vcd')

data(Arthritis)
df <- data.table(Arthritis, keep.rownames = F)

head(df)

str(df)

