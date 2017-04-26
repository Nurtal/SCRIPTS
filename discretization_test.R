
# Gestion des packages

if(!require(discretization)){
  install.packages("discretization")
}

library(discretization)
library(datasets)

data(iris)
summary(iris)


# load data
# where am i 
info = Sys.info()
os = info[["sysname"]]
data_file_name = "undef"
login = info[["login"]]

#load data
if(identical(os, "Windows")){
  #-Windows
  data_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\panel_1_filtered.txt", sep="")
}else{
  #-Linux
  data_file_name = ("/home/foulquier/Bureau/SpellCraft/WorkSpace/SCRIPTS/data/clinical_data_phase_1.csv")
}
data <- read.csv(data_file_name, header = T, sep=";")

# Convert binary values to literal
df <- data
m <- as.matrix(df)
m[m=="0"] <- "Control"
m[m=="1"] <- "Case"
data <- as.data.frame(m)

## Move Disease column to the end of the data frame
names(data)
col_idx <- grep("DISEASE", names(data))
data <- data[, c((1:ncol(data))[-col_idx],col_idx)]
names(data)

## Set OMICID as row names and remove the column
#rownames(data) <- data$X.Clinical.Sampling.OMICID
data$X.Clinical.Sampling.OMICID <- NULL

write.table(data, "C:\\Users\\PC_immuno\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\data\\test.txt", sep=",")
data = read.csv("C:\\Users\\PC_immuno\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\data\\test_2.txt",header = T, sep=",")

play_data = read.csv("C:\\Users\\PC_immuno\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\data\\play.txt",header = T, sep=",")


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
machin = disc.Topdown(data, method=1)
truc = machin$Disc.data
