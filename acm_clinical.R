library(FactoMineR)
library(factoextra)
library(corrplot)




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
  flow_data_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\data_discretized.txt", sep="")
}else{
  #-Linux
  data <- read.csv("/home/foulquier/Bureau/SpellCraft/WorkSpace/SCRIPTS/data/clinical_data_phase_1.csv", stringsAsFactors=TRUE)
}
data <- read.csv(data_file_name, stringsAsFactors=TRUE)

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


# get only the control (a dataframe full of NA ...)
control_data = data[data$X.Clinical.Diagnosis.DISEASE == "Control", ] 

# use only patient without NA ( drop control in the process ...)
data = data[complete.cases(data),]
data <- data.frame(lapply(data, as.factor))

# Create sub data
lung_data = data[,grep("Lung", names(data), value=TRUE)]
lung_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
lung_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
lung_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)

kidney_data = data[,grep("Kidney", names(data), value=TRUE)]
kidney_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
kidney_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
kidney_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)

nerveSystem_data = data[,grep("NerveSystem", names(data), value=TRUE)]
nerveSystem_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
nerveSystem_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
nerveSystem_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)

skin_data = data[,grep("Skin", names(data), value=TRUE)]
skin_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
skin_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
skin_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)

muscleAndSkeletal_data = data[,grep("MuscleandSkeletal", names(data), value=TRUE)]
muscleAndSkeletal_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
muscleAndSkeletal_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
muscleAndSkeletal_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)

comorbidity_data = data[,grep("Comorbirdity", names(data), value=TRUE)]
comorbidity_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
comorbidity_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
comorbidity_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)

vascular_data = data[,grep("Vascular", names(data), value=TRUE)]
vascular_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
vascular_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
vascular_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)

gastro_data = data[,grep("Gastro", names(data), value=TRUE)]
gastro_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
gastro_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
gastro_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)

heart_data = data[,grep("Heart", names(data), value=TRUE)]
heart_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
heart_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
heart_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)

diagnosis_data = data[,grep("Diagnosis", names(data), value=TRUE)]
diagnosis_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
diagnosis_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
diagnosis_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)

autoantibody_data = data[,grep("Autoantibody", names(data), value=TRUE)]
autoantibody_data = data[,grep("CALL", names(autoantibody_data), value=TRUE)]
autoantibody_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
autoantibody_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
autoantibody_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)

symptom_data = data[,grep("Symptom", names(data), value=TRUE)]
symptom_data$X.Clinical.Diagnosis.DISEASE = as.factor(data$X.Clinical.Diagnosis.DISEASE)
symptom_data$X.Clinical.Demography.SEX = as.factor(data$X.Clinical.Demography.SEX)
symptom_data$X.Clinical.Sampling.CENTER = as.factor(data$X.Clinical.Sampling.CENTER)

sub_data_list = list(lung_data, kidney_data, nerveSystem_data, skin_data, muscleAndSkeletal_data, comorbidity_data, vascular_data, gastro_data, heart_data, diagnosis_data, autoantibody_data, symptom_data)
sub_data_name = list("lung", "kidney", "nerveSystem", "skin", "muscleAndSkeletal", "comorbidity", "vascular", "gastro", "heart", "diagnosis", "autoantibody", "symptom")


for(val in 1:length(sub_data_list)){
  
  # Get data
  data = sub_data_list[[val]]
  
  
  # Perfrom ACM
  mca1 = MCA(data, graph = FALSE)
  
  # Extract variable and individuals
  var <- get_mca_var(mca1)
  ind <- get_mca_ind(mca1)
  
  # Extract "labels" for future coloration
  sick <- as.factor(data$X.Clinical.Diagnosis.DISEASE)
  sex <- as.factor(data$X.Clinical.Demography.SEX)
  center <- as.factor(data$X.Clinical.Sampling.CENTER)
  
  #--------------#
  # PLot Section #
  #--------------#
  
  # Plot explain variance
  image_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\images\\", "explain_variance_", sub_data_name[val], ".png", sep="")
  #image_file_name = paste("C:\\Users\\PC_immuno\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\images\\", "explain_variance_", sub_data_name[val], ".png", sep="")
  png(filename=image_file_name)
  plot(fviz_screeplot(mca1))
  dev.off()
  
  # Plot most contributing variables for each dimension
  image_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\images\\", "variable_contribution_", sub_data_name[val], ".png", sep="")
  #image_file_name = paste("C:\\Users\\PC_immuno\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\images\\", "variable_contribution_", sub_data_name[val], ".png", sep="")
  png(filename=image_file_name)
  var <- get_mca_var(mca1)
  corrplot(var$contrib, is.corr = FALSE)
  dev.off()
  
  # Plot individual, colored by sickness, add ellipse
  image_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\images\\", "individuals_disease_", sub_data_name[val], ".png", sep="")
  #image_file_name = paste("C:\\Users\\PC_immuno\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\images\\", "individuals_disease_", sub_data_name[val], ".png", sep="")
  png(filename=image_file_name)
  plot(fviz_mca_ind(mca1, label="none", habillage = sick,
               addEllipses = TRUE, ellipse.level = 0.95))
  dev.off()
  
  # Plot individual, colored by sex, add ellipse
  image_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\images\\", "individuals_sex_", sub_data_name[val], ".png", sep="")
  #image_file_name = paste("C:\\Users\\PC_immuno\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\images\\", "individuals_sex_", sub_data_name[val], ".png", sep="")
  png(filename=image_file_name)
  plot(fviz_mca_ind(mca1, label="none", habillage = sex,
               addEllipses = TRUE, ellipse.level = 0.95))
  dev.off()
  
  # Plot individual, colored by center, add ellipse
  image_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\images\\", "individuals_center_", sub_data_name[val], ".png", sep="")
  #image_file_name = paste("C:\\Users\\PC_immuno\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\images\\", "individuals_center_", sub_data_name[val], ".png", sep="")
  png(filename=image_file_name)
  plot(fviz_mca_ind(mca1, label="none", habillage = center,
               addEllipses = TRUE, ellipse.level = 0.95))
  dev.off()
  
  
}


#------------#
# TEST SPACE #
#------------#

# Get data
data = merge(autoantibody_data, symptom_data)

# Perfrom ACM
mca1 = MCA(data, graph = FALSE)

# Extract variable and individuals
var <- get_mca_var(mca1)
ind <- get_mca_ind(mca1)

# Extract "labels" for future coloration
sick <- as.factor(data$X.Clinical.Diagnosis.DISEASE)
sex <- as.factor(data$X.Clinical.Demography.SEX)
center <- as.factor(data$X.Clinical.Sampling.CENTER)


# Plot explain variance
fviz_screeplot(mca1)

# Plot most contributing variables for each dimension
var <- get_mca_var(mca1)
corrplot(var$contrib, is.corr = FALSE)

# Plot individual, colored by sickness, add ellipse
fviz_mca_ind(mca1, label="none", habillage = sick,
                  addEllipses = TRUE, ellipse.level = 0.95)

# Plot individual, colored by sex, add ellipse
fviz_mca_ind(mca1, label="none", habillage = sex,
                  addEllipses = TRUE, ellipse.level = 0.95)

# Plot individual, colored by center, add ellipse
fviz_mca_ind(mca1, label="none", habillage = center,
                  addEllipses = TRUE, ellipse.level = 0.95)


#-------------#
## FLOW DATA ##
#-------------#


flow_data_name ="C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\panel_6_filtered.txt_discrete"
data <- read.csv(flow_data_name, stringsAsFactors=TRUE, sep=";")


# use only patient without NA ( drop control in the process ...)
data = data[complete.cases(data),]
data <- data.frame(lapply(data, as.factor))


# Split into Panel
flow_data_panel_1 <- data[,grep("P1|DISEASE|OMICID", colnames(data))]
flow_data_panel_2 <- data[,grep("P2|DISEASE|OMICID", colnames(data))]
flow_data_panel_3 <- data[,grep("P3|DISEASE|OMICID", colnames(data))]
flow_data_panel_4 <- data[,grep("P4|DISEASE|OMICID", colnames(data))]
flow_data_panel_5 <- data[,grep("P5|DISEASE|OMICID", colnames(data))]
flow_data_panel_6 <- data[,grep("P6|DISEASE|OMICID", colnames(data))]

data <- flow_data_panel_6
panel = "panel_6"

# Perfrom ACM
mca1 = MCA(data, graph = FALSE)

# Extract variable and individuals
var <- get_mca_var(mca1)
ind <- get_mca_ind(mca1)

# Extract "labels" for future coloration
sick <- as.factor(data$X.Clinical.Diagnosis.DISEASE)
sex <- as.factor(data$X.Clinical.Demography.SEX)
center <- as.factor(data$X.Clinical.Sampling.CENTER)


# Plot explain variance
fviz_screeplot(mca1)

# Plot most contributing variables for each dimension
image_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\images\\", "graphe_1_", panel, ".png", sep="")
png(filename=image_file_name)
var <- get_mca_var(mca1)
corrplot(var$contrib, is.corr = FALSE)
dev.off()

# Plot individual, colored by sickness, add ellipse
image_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\images\\", "graphe_2_", panel, ".png", sep="")
png(filename=image_file_name)
fviz_mca_ind(mca1, label="none", habillage = sick,
             addEllipses = TRUE, ellipse.level = 0.95)
dev.off()

