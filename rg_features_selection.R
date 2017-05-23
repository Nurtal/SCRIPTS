# Features extractions
library(Boruta)

# load data
# where am i 
info = Sys.info()
os = info[["sysname"]]
data_file_name = "undef"
login = info[["login"]]

#load data
if(identical(os, "Windows")){
  
  #-Windows
  data_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rg_data_to_filter.txt", sep="")
  feature_save_file = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\data\\rg_feature_selected.txt", sep="")
  data_filtered_file = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\data\\rg_data_filtered.txt", sep="")
  
}else{
  
  #-Linux
  data <- read.csv("/home/foulquier/Bureau/SpellCraft/WorkSpace/SCRIPTS/data/clinical_data_phase_1.csv", stringsAsFactors=TRUE)
}

data <- read.csv(data_file_name, header = T, stringsAsFactors = T, sep=",")

# drop medication (lots of NA)
medication_col_names = grep("Medication", names(data), value=TRUE)
drops <- medication_col_names
data = data[ , !(names(data) %in% drops)]

# drop a few  variable
drops_2 = c("X.Clinical.Diagnosis.ONSETDTC", "X.Clinical.Sampling.LBDTC", "X.Clinical.Sampling.USUBJID", "X.Clinical.Sampling.OMICID", "X.Clinical.Demography.BRTHYR", "X.Clinical.Sampling.DURATIONYR")
data = data[ , !(names(data) %in% drops_2)]

# drop a few other variables
drops_3 = c("X.Clinical.Symptom.PEGLOBAL", "X.Clinical.Demography.AGE", "X.Clinical.Consent.CSPHASE", "X.Clinical.Demography.RACE")
data = data[ , !(names(data) %in% drops_3)]

# use only patient without NA ( drop control in the process ...)
data = data[complete.cases(data),]
data <- data.frame(lapply(data, as.factor))


# Run Boruta
boruta.train <- Boruta(X.Clinical.Diagnosis.DISEASE~., data = data, doTrace = 2)


# Supplemental Results
final.boruta <- TentativeRoughFix(boruta.train)


# Final steps
getSelectedAttributes(final.boruta, withTentative = F)
boruta.df <- attStats(final.boruta)
write.table(boruta.df, feature_save_file, sep=";")
  
# Write new tables
selected_variables <- getSelectedAttributes(final.boruta, withTentative = F)
f <- paste(selected_variables, collapse='|')
f <- paste(c(f, "X.Clinical.Diagnosis.DISEASE|X.Clinical.Sampling.OMICID"), collapse = '|')
data <- data[,grep(f, colnames(data))]
write.table(data, data_filtered_file, sep=";")
