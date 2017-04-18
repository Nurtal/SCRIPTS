library(FactoMineR)
library(factoextra)
library(corrplot)

# tree importation
library(rpart)
library(rpart.plot)

#-----------------#
# DATA PROCESSING #
#-----------------#

# where am i 
info = Sys.info()
os = info[["sysname"]]
data_file_name = "undef"
login = info[["login"]]

#load data
if(identical(os, "Windows")){
  #-Windows
  data_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\clinical_data_phase_2.csv", sep="")
}else{
  #-Linux
  data_file_name = ("/home/foulquier/Bureau/SpellCraft/WorkSpace/SCRIPTS/data/clinical_data_phase_1.csv")
}
data <- read.csv(data_file_name, stringsAsFactors=TRUE)

# drop medication (lots of NA)
medication_col_names = grep("Medication", names(data), value=TRUE)
drops <- medication_col_names
data = data[ , !(names(data) %in% drops)]

# drop a few  variable
drops_2 = c("X.Clinical.Diagnosis.ONSETDTC", "X.Clinical.Sampling.LBDTC", "X.Clinical.Sampling.USUBJID", "X.Clinical.Demography.BRTHYR", "X.Clinical.Sampling.DURATIONYR")
data = data[ , !(names(data) %in% drops_2)]

# drop a few other variables
drops_3 = c("X.Clinical.Symptom.PEGLOBAL", "X.Clinical.Demography.AGE", "X.Clinical.Consent.CSPHASE", "X.Clinical.Demography.RACE")
data = data[ , !(names(data) %in% drops_3)]

# drop auto-antibody (non-CALL variables)
drops_autoantibody = c("X.Autoantibody.SSA60", "X.Autoantibody.U1RNP", "X.Autoantibody.RF","X.Autoantibody.DNA", "X.Autoantibody.SSB", "X.Autoantibody.CENTB", "X.Autoantibody.ENA", "X.Autoantibody.SCL70", "X.Autoantibody.C4", "X.Autoantibody.CLG", "X.Autoantibody.SSA52", "X.Autoantibody.CCP2", "X.Autoantibody.B2M", "X.Autoantibody.CENTB", "X.Autoantibody.C3C", "X.Autoantibody.SSA", "X.Clinical.Lab.LBC3", "X.Autoantibody.CLM", "X.Autoantibody.PR3", "X.Autoantibody.JO1", "X.Autoantibody.SM", "X.Autoantibody.B2G", "X.Autoantibody.PFLC")
data = data[ , !(names(data) %in% drops_autoantibody)]

# set NA to negative in autoantibody CALL variables
data$X.Autoantibody.NENACALL[is.na(data$X.Autoantibody.NENACALL)] <- "negative"
data$X.Autoantibody.ANAPOSNEGCALL[is.na(data$X.Autoantibody.ANAPOSNEGCALL)] <- "negative"
data$X.Autoantibody.ANCAPOSNEGCALL[is.na(data$X.Autoantibody.ANCAPOSNEGCALL)] <- "negative"
data$X.Autoantibody.B2GCALL[is.na(data$X.Autoantibody.B2GCALL)] <- "negative"
data$X.Autoantibody.U1RNPCALL[is.na(data$X.Autoantibody.U1RNPCALL)] <- "negative"
data$X.Autoantibody.B2MCALL[is.na(data$X.Autoantibody.B2MCALL)] <- "negative"
data$X.Autoantibody.C3CCALL[is.na(data$X.Autoantibody.C3CCALL)] <- "negative"
data$X.Autoantibody.C4CALL[is.na(data$X.Autoantibody.C4CALL)] <- "negative"
data$X.Autoantibody.CCP2CALL[is.na(data$X.Autoantibody.CCP2CALL)] <- "negative"
data$X.Autoantibody.CENTBCALL[is.na(data$X.Autoantibody.CENTBCALL)] <- "negative"
data$X.Autoantibody.CLGCALL[is.na(data$X.Autoantibody.CLGCALL)] <- "negative"
data$X.Autoantibody.CLMCALL[is.na(data$X.Autoantibody.CLMCALL)] <- "negative"
data$X.Autoantibody.DNACALL[is.na(data$X.Autoantibody.DNACALL)] <- "negative"
data$X.Autoantibody.ENACALL[is.na(data$X.Autoantibody.ENACALL)] <- "negative"
data$X.Autoantibody.JO1CALL[is.na(data$X.Autoantibody.JO1CALL)] <- "negative"
data$X.Autoantibody.MPOCALL[is.na(data$X.Autoantibody.MPOCALL)] <- "negative"
data$X.Autoantibody.SCL70CALL[is.na(data$X.Autoantibody.SCL70CALL)] <- "negative"
data$X.Autoantibody.RFCALL[is.na(data$X.Autoantibody.RFCALL)] <- "negative"
data$X.Autoantibody.PFLCCALL[is.na(data$X.Autoantibody.PFLCCALL)] <- "negative"
data$X.Autoantibody.PR3CALL[is.na(data$X.Autoantibody.PR3CALL)] <- "negative"
data$X.Autoantibody.SMCALL[is.na(data$X.Autoantibody.SMCALL)] <- "negative"
data$X.Autoantibody.SSA52CALL[is.na(data$X.Autoantibody.SSA52CALL)] <- "negative"
data$X.Autoantibody.SSACALL[is.na(data$X.Autoantibody.SSACALL)] <- "negative"
data$X.Autoantibody.SSBCALL[is.na(data$X.Autoantibody.SSBCALL)] <- "negative"
data$X.Autoantibody.SSA60CALL[is.na(data$X.Autoantibody.SSA60CALL)] <- "negative"
data$X.Autoantibody.U1RNPCALL[is.na(data$X.Autoantibody.U1RNPCALL)] <- "negative"









# get only the control (a dataframe full of NA ...)
control_data = data[data$X.Clinical.Diagnosis.DISEASE == "Control", ] 

# use only patient without NA ( drop control in the process ...)
data = data[complete.cases(data),]
data <- data.frame(lapply(data, as.factor))



autoantibody_data = data[,grep("Autoantibody", names(data), value=TRUE)]
autoantibody_data = data[,grep("CALL", names(autoantibody_data), value=TRUE)]
#autoantibody_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#autoantibody_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#autoantibody_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
autoantibody_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)



#-------------------#
# Feature Selection #
#-------------------#
library(Boruta)
drops_3 = c("X.Clinical.Diagnosis.MHTERM")
data = data[ , !(names(data) %in% drops_3)]

# Run Boruta
boruta.train <- Boruta(data$X.Clinical.Diagnosis.DISEASE~.-data$X.Clinical.Sampling.OMICID, data = data, doTrace = 2)

# Display results
plot(boruta.train, xlab = "", xaxt = "n")
lz<-lapply(1:ncol(boruta.train$ImpHistory),function(i)
  boruta.train$ImpHistory[is.finite(boruta.train$ImpHistory[,i]),i])

names(lz) <- colnames(boruta.train$ImpHistory)
Labels <- sort(sapply(lz,median))
axis(side = 1,las=2,labels = names(Labels),
     at = 1:ncol(boruta.train$ImpHistory), cex.axis = 0.7)

# Supplemental Results
final.boruta <- TentativeRoughFix(boruta.train)

# Display supplemental results
#png("/home/foulquier/Bureau/SpellCraft/WorkSpace/FeatureSelection/feature_selection_panel_1.png", width=4, height=4, units="in", res=300)
plot(final.boruta, xlab = "", xaxt = "n")
lz<-lapply(1:ncol(boruta.train$ImpHistory),function(i)
  boruta.train$ImpHistory[is.finite(boruta.train$ImpHistory[,i]),i])

names(lz) <- colnames(boruta.train$ImpHistory)
Labels <- sort(sapply(lz,median))
axis(side = 1,las=2,labels = names(Labels),
     at = 1:ncol(boruta.train$ImpHistory), cex.axis = 0.7)
#dev.off()

# Final steps
selected_variables = getSelectedAttributes(final.boruta, withTentative = F)
boruta.df <- attStats(final.boruta)
selected_data = data[,selected_variables]


#----------------------#
# Random Forest - Test #
#----------------------#
require(randomForest)

# create labels
labels = data$X.Clinical.Diagnosis.DISEASE



# Get data
# "X.Clinical.Sampling.OMICID"

#data = merge(autoantibody_data, symptom_data, by = "X.Clinical.Sampling.OMICID")
#data = merge(data, lung_data, by = "X.Clinical.Sampling.OMICID")
#data = merge(data, kidney_data, by = "X.Clinical.Sampling.OMICID")
#data = merge(data, heart_data, by = "X.Clinical.Sampling.OMICID")
#data = merge(symptom_data, skin_data, by = "X.Clinical.Sampling.OMICID")


# drop a few  variable
drops_3 = c("X.Clinical.Sampling.OMICID", "X.Clinical.Diagnosis.DISEASE", "X.Clinical.Sampling.CENTER")
drops_autoantibody = c("X.Autoantibody.SSA60", "X.Autoantibody.U1RNP", "X.Autoantibody.RF","X.Autoantibody.DNA", "X.Autoantibody.SSB", "X.Autoantibody.CENTB", "X.Autoantibody.ENA", "X.Autoantibody.SCL70", "X.Autoantibody.C4", "X.Autoantibody.CLG", "X.Autoantibody.SSA52", "X.Autoantibody.CCP2", "X.Autoantibody.B2M", "X.Autoantibody.CENTB", "X.Autoantibody.C3C", "X.Autoantibody.SSA", "X.Clinical.Lab.LBC3")
selected_data = selected_data[ , !(names(selected_data) %in% drops_3)]
selected_data = selected_data[ , !(names(selected_data) %in% drops_autoantibody)]



# run random forest
data.rf <- randomForest(selected_data, labels)
print(data.rf)

# plot score vs number of tree
data.rf=randomForest(selected_data, labels, ntree=20000) 
plot(data.rf$err.rate[,1], type="l")
