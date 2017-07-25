## Practice with AFD analysis
## TODO: adapt to real data.

##---------------------##
## Study case 1 : Wine ##
##---------------------##

## Load data & packages
library(car)
library(MASS)
#install.packages('rattle')
data(wine, package='rattle')
attach(wine)
head(wine)

## Scatter plot -> overview of the data
scatterplotMatrix(wine[2:6])
scatterplotMatrix(wine[2:14])

## LDA analysis
wine.lda <- lda(Type ~ ., data=wine)
wine.lda

## Plot LDA results
wine.lda.values <- predict(wine.lda)
ldahist(data = wine.lda.values$x[,1], g=Type)
ldahist(data = wine.lda.values$x[,2], g=Type)

## Scatterplots of the Discriminant Functions
## We can obtain a scatterplot of the best two discriminant functions, with the data points labelled by cultivar, by typing:
plot(wine.lda.values$x[,1],wine.lda.values$x[,2]) # make a scatterplot
text(wine.lda.values$x[,1],wine.lda.values$x[,2],Type,cex=0.7,pos=4,col="red") # add labels



##-----------------------------------##
## Study case 2 : MBA admission data ##
##-----------------------------------##

## install packages
library(klaR)

## Load data
url <- 'http://www.biz.uiowa.edu/faculty/jledolter/DataMining/admission.csv'
admit <- read.csv(url)
head(admit)

adm=data.frame(admit)
plot(adm$GPA,adm$GMAT,col=adm$De)

## linear discriminant analysis
m1=lda(De~.,adm)
m1
predict(m1,newdata=data.frame(GPA=3.21,GMAT=497))

## The quadratic discriminant analysis:
m2=qda(De~.,adm)
m2
predict(m2,newdata=data.frame(GPA=3.21,GMAT=497))

## Which model is best? In order to answer this question, 
## we evaluate the linear discriminant analysis by randomly
## selecting 60 of 85 students, estimating the parameters
## on the training data, and classifying the remaining 25
## students of the holdout sample. We repeat this 100 times.

n=85
nt=60
neval=n-nt
rep=100

### LDA
set.seed(123456789)
errlin=dim(rep)
for (k in 1:rep) {
  train=sample(1:n,nt)
  ## linear discriminant analysis
  m1=lda(De~.,adm[train,])
  predict(m1,adm[-train,])$class
  tablin=table(adm$De[-train],predict(m1,adm[-train,])$class)
  errlin[k]=(neval-sum(diag(tablin)))/neval
}
merrlin=mean(errlin)
merrlin

### QDA
set.seed(123456789)
errqda=dim(rep)
for (k in 1:rep) {
  train=sample(1:n,nt)
  ## quadratic discriminant analysis
  m1=qda(De~.,adm[train,])
  predict(m1,adm[-train,])$class
  tablin=table(adm$De[-train],predict(m1,adm[-train,])$class)
  errqda[k]=(neval-sum(diag(tablin)))/neval
}
merrqda=mean(errlin)
merrqda

## We achieve a 10.2% misclassification rate in both cases. 
## R also give us some visualization tools. For example library klaR:
partimat(De~.,data=adm,method="lda")



##-------------------------------------------------------##
## Study case 3 :  Credit Scoring on German Bank Dataset ##
##-------------------------------------------------------##

## read data 
attach(cred1)
credit <- read.csv("http://www.biz.uiowa.edu/faculty/jledolter/DataMining/germancredit.csv")
head(credit,2) # See details about codification in the attached documentation.

cred1=credit[, c("Default","duration","amount","installment","age")]
head(cred1)
summary(cred1)

## Are the selected variables in cred1 normally distributed? 
## Lets try to check this assumption by simple histograms:
hist(cred1$duration)
hist(cred1$amount)
hist(cred1$installment)
hist(cred1$age)

## Transform selected data into a data.frame to make LDA
cred1=data.frame(cred1)


## The data do not fit the normality assumption and this will be a problem
## with the use of LDA or QDA analysis, but in any case we can try to see
## what happens if we try to predict the defaults by using discriminant functions.

## LDA: class proportions of the training set used as prior probabilities
zlin=lda(Default~.,cred1)

## Confusion Matrix:
table(predict(zlin)$class, Default)

## LDA predictions for two new observations:
predict(zlin,newdata=data.frame(duration=6,amount=1100,installment=4,age=67))
predict(zlin,newdata=data.frame(duration=6,amount=1100, installment=4,age=67))$class


## QDA: class proportions of the training set used as prior probabilities
zqua=qda(Default~.,cred1)
## Confusion Matrix:
table(predict(zqua)$class, Default)
## QDA predictions for two new observations:
predict(zqua,newdata=data.frame(duration=6,amount=1100,installment=4,age=67))
predict(zqua,newdata=data.frame(duration=6,amount=1100, installment=4,age=67))$class
