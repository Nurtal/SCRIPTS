library(discretization)
library(datasets)


# load data
# where am i 
info = Sys.info()
os = info[["sysname"]]
data_file_name = "undef"
login = info[["login"]]

#load data
if(identical(os, "Windows")){
  #-Windows
  reload_file = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rg_data_good_for_discretization.txt", sep="")
  save_file = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rg_data_discretized.txt", sep="")
  
}else{
  #-Linux
  data_file_name = ("/home/foulquier/Bureau/SpellCraft/WorkSpace/SCRIPTS/data/clinical_data_phase_1.csv")
}


## Reoload data
data = read.csv(reload_file,header = T, sep=",")

## Ameva discretization
discretization = disc.Topdown(data, method=1)
data_discrete = discretization$Disc.data

## Save in a file
write.table(data_discrete, save_file, sep=",")