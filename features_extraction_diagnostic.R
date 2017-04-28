# Features extractions
library(Boruta)

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


# convert disease to 1, control to 0
df <- data
m <- as.matrix(df)
m[m=="Control"] <- 0
m[m=="SLE"] <- 0
m[m=="RA"] <- 1
m[m=="UCTD"] <- 0
m[m=="undef"] <- 0
m[m=="SSc"] <- 0
m[m=="SjS"] <- 0
m[m=="PAPs"] <- 0
m[m=="MCTD"] <- 0
data <- as.data.frame(m)


# use only patient without NA ( drop control in the process ...)
data = data[complete.cases(data),]
data <- data.frame(lapply(data, as.factor))




# Delete some variables
data$Row.names <- NULL



# Panel to Process:
panel_to_process <- data

# Run Boruta
boruta.train <- Boruta(X.Clinical.Diagnosis.DISEASE~., data = panel_to_process, doTrace = 2)

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

## Display supplemental results
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
getSelectedAttributes(final.boruta, withTentative = F)
boruta.df <- attStats(final.boruta)
#write.table(boruta.df, "/home/foulquier/Bureau/SpellCraft/WorkSpace/FeatureSelection/feature_selection_panel_1.txt", sep=";")
write.table(boruta.df, "C:\\Users\\Beckman-Coulter\\Desktop\\Nathan\\SCRIPTS\\data\\feature_selection_panel_6.txt", sep=";")

# Write new tables
selected_variables <- getSelectedAttributes(final.boruta, withTentative = F)
f <- paste(selected_variables, collapse='|')
f <- paste(c(f, "X.Clinical.Diagnosis.DISEASE|X.Clinical.Sampling.OMICID"), collapse = '|')
panel_to_process <- panel_to_process[,grep(f, colnames(panel_to_process))]

#write.table(panel_to_process, "/home/foulquier/Bureau/SpellCraft/WorkSpace/FeatureSelection/panel_6_filtered.txt", sep=";")
write.table(panel_to_process, "C:\\Users\\Beckman-Coulter\\Desktop\\Nathan\\SCRIPTS\\data\\panel_6_filtered.txt", sep=";")
