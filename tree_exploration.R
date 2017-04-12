library(FactoMineR)
library(factoextra)
library(corrplot)

# tree importation
library(rpart)
library(rpart.plot)

#-----------------#
# DATA PROCESSING #
#-----------------#

#load data
#data <- read.csv("/home/foulquier/Bureau/SpellCraft/WorkSpace/SCRIPTS/data/clinical_data_phase_1.csv", stringsAsFactors=TRUE)
#data <- read.csv("C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\data\\clinical_data_phase_1.csv", stringsAsFactors=TRUE)
data <- read.csv("C:\\Users\\PC_immuno\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\clinical_data_phase_1.csv", stringsAsFactors=TRUE)


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

sub_data_list = list(lung_data, kidney_data, nerveSystem_data, skin_data, muscleAndSkeletal_data, comorbidity_data, vascular_data, gastro_data, heart_data, diagnosis_data)
sub_data_name = list("lung", "kidney", "nerveSystem", "skin", "muscleAndSkeletal", "comorbidity", "vascular", "gastro", "heart", "diagnosis")

#-------------------#
# Tree Construction #
#-------------------#


# Step1: Begin with a small cp. 
tree <- rpart(X.Clinical.Diagnosis.DISEASE ~ ., data = data, control = rpart.control(cp = 0.0001))

# Step2: Pick the tree size that minimizes misclassification rate (i.e. prediction error).
# Prediction error rate in training data = Root node error * rel error * 100%
# Prediction error rate in cross-validation = Root node error * xerror * 100%
# Hence we want the cp value (with a simpler tree) that minimizes the xerror. 
printcp(tree)
bestcp <- tree$cptable[which.min(tree$cptable[,"xerror"]),"CP"]

# Step3: Prune the tree using the best cp.
tree.pruned <- prune(tree, cp = bestcp)

#--------------------#
# Tree Visualisation #
#--------------------#

# visu 1
plot(tree.pruned)
text(tree.pruned, cex = 0.8, use.n = TRUE, xpd = TRUE)

# visu 2
prp(tree.pruned, faclen = 0, cex = 0.8, extra = 1)

# visu 3
tot_count <- function(x, labs, digits, varlen)
{
  paste(labs, "\n\nn =", x$frame$n)
}

prp(tree.pruned, faclen = 0, cex = 0.8, node.fun=tot_count)