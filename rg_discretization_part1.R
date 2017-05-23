# Gestion des packages
library(discretization)
library(datasets)


# load data
# where am i 
info = Sys.info()
os = info[["sysname"]]
data_file_name = "undef"
login = info[["login"]]

## Init Path
if(identical(os, "Windows")){
  #-Windows
  data_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rg_data_to_discretize.txt", sep="")
  tmp_file = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rg_data_to_discretize_tmp.txt", sep="")
  
}else{
  #-Linux
  data_file_name = ("/home/foulquier/Bureau/SpellCraft/WorkSpace/SCRIPTS/data/clinical_data_phase_1.csv")
}

## Load data
data <- read.csv(data_file_name, header = T, sep=",")

# replace NA in disease by Control
#data[c("X.Clinical.Diagnosis.DISEASE")][is.na(data[c("X.Clinical.Diagnosis.DISEASE")])] <- 0

## Use only patient without NA ( could drop control in the process ...)
data = data[complete.cases(data),]
data <- data.frame(lapply(data, as.factor))

## Move Disease column to the end of the data frame
col_idx <- grep("DISEASE", names(data))
data <- data[, c((1:ncol(data))[-col_idx],col_idx)]

## Remove the column
data$X.Clinical.Sampling.OMICID <- NULL

## Write data in a file to be reformat by a python script
write.table(data, tmp_file, sep=",")