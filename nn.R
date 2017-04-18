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
  data_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\clinical_data_phase_1.csv", sep="")
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


# get only the control (a dataframe full of NA ...)
control_data = data[data$X.Clinical.Diagnosis.DISEASE == "Control", ] 

# use only patient without NA ( drop control in the process ...)
data = data[complete.cases(data),]
data <- data.frame(lapply(data, as.factor))

# Create sub data
lung_data = data[,grep("Lung", names(data), value=TRUE)]
#lung_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#lung_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#lung_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
lung_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)

kidney_data = data[,grep("Kidney", names(data), value=TRUE)]
#kidney_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#kidney_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#kidney_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
kidney_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)

nerveSystem_data = data[,grep("NerveSystem", names(data), value=TRUE)]
#nerveSystem_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#nerveSystem_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#nerveSystem_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
nerveSystem_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)

skin_data = data[,grep("Skin", names(data), value=TRUE)]
#skin_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#skin_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#skin_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
skin_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)

muscleAndSkeletal_data = data[,grep("MuscleandSkeletal", names(data), value=TRUE)]
#muscleAndSkeletal_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#muscleAndSkeletal_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#muscleAndSkeletal_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
muscleAndSkeletal_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)

comorbidity_data = data[,grep("Comorbirdity", names(data), value=TRUE)]
#comorbidity_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#comorbidity_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#comorbidity_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
comorbidity_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)

vascular_data = data[,grep("Vascular", names(data), value=TRUE)]
#vascular_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#vascular_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#vascular_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
vascular_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)

gastro_data = data[,grep("Gastro", names(data), value=TRUE)]
#gastro_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#gastro_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#gastro_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
gastro_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)

heart_data = data[,grep("Heart", names(data), value=TRUE)]
#heart_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#heart_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#heart_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
heart_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)

diagnosis_data = data[,grep("Diagnosis", names(data), value=TRUE)]
#diagnosis_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#diagnosis_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#diagnosis_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
diagnosis_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)

autoantibody_data = data[,grep("Autoantibody", names(data), value=TRUE)]
autoantibody_data = data[,grep("CALL", names(autoantibody_data), value=TRUE)]
#autoantibody_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#autoantibody_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#autoantibody_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
autoantibody_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)

symptom_data = data[,grep("Symptom", names(data), value=TRUE)]
#symptom_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
#symptom_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
#symptom_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)
symptom_data$X.Clinical.Sampling.OMICID = as.factor(data$X.Clinical.Sampling.OMICID)

sub_data_list = list(lung_data, kidney_data, nerveSystem_data, skin_data, muscleAndSkeletal_data, comorbidity_data, vascular_data, gastro_data, heart_data, diagnosis_data)
sub_data_name = list("lung", "kidney", "nerveSystem", "skin", "muscleAndSkeletal", "comorbidity", "vascular", "gastro", "heart", "diagnosis")


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


# drop a few  variable
drops_3 = c("X.Clinical.Sampling.OMICID", "X.Clinical.Diagnosis.DISEASE", "X.Clinical.Sampling.CENTER")
selected_data = selected_data[ , !(names(selected_data) %in% drops_3)]

# Convert to boolean data
nn_input = model.matrix(~ . + 0, data=selected_data, contrasts.arg = lapply(selected_data, contrasts, contrasts=FALSE))
