
# Gestion des packages

if(!require(discretization)){
  install.packages("discretization")
}

library(discretization)
library(datasets)

data(iris)
summary(iris)

#--Ameva criterion value
a=c(2,5,1,1,3,3)
m=matrix(a,ncol=3,byrow=TRUE)
test = ameva(m)


#----Calculating cacc value (Tsai, Lee, and Yang (2008))
a=c(3,0,3,0,6,0,0,3,0)
m=matrix(a,ncol=3,byrow=TRUE)
cacc(m)

##---- CAIM discretization ----
##----cut-potins
iris
cm=disc.Topdown(iris, method=1)
cm$cutp
##----discretized data matrix
cm$Disc.data

##---- CACC discretization----
disc.Topdown(iris, method=2)

##---- Ameva discretization ----
disc.Topdown(iris, method=3)
