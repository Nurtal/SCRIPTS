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
  data_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\flow_data_phase_1.txt", sep="")
  data_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SCRIPTS\\data\\flow_data_phase_1.txt", sep="")
  data_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\data\\data_discretized.txt", sep="")
  
  
}else{
  #-Linux
  data <- read.csv("/home/foulquier/Bureau/SpellCraft/WorkSpace/SCRIPTS/data/clinical_data_phase_1.csv", stringsAsFactors=TRUE)
}

flow_data <- read.csv(data_file_name, header = T, stringsAsFactors = T, sep=",")


# convert disease to 1, control to 0
flow_data$X.Clinical.Diagnosis.DISEASE[is.na(flow_data$X.Clinical.Diagnosis.DISEASE)] <- "Control"
df <- flow_data
m <- as.matrix(df)
m[m=="Control"] <- 0
m[m=="SLE"] <- 0
m[m=="RA"] <- 0
m[m=="UCTD"] <- 0
m[m=="undef"] <- 0
m[m=="SSc"] <- 0
m[m=="SjS"] <- 1
m[m=="PAPs"] <- 0
m[m=="MCTD"] <- 0
flow_data <- as.data.frame(m)

# Delete some variables
flow_data$Row.names <- NULL

# Remove patient
flow_data<-flow_data[!(flow_data$X.Clinical.Sampling.OMICID=="N32151646"),]
flow_data<-flow_data[!(flow_data$X.Clinical.Sampling.OMICID=="N32151888"),]

# Split into Panel
flow_data_panel_1 <- flow_data[,grep("P1|DISEASE|OMICID", colnames(flow_data))]
flow_data_panel_2 <- flow_data[,grep("P2|DISEASE|OMICID", colnames(flow_data))]
flow_data_panel_3 <- flow_data[,grep("P3|DISEASE|OMICID", colnames(flow_data))]
flow_data_panel_4 <- flow_data[,grep("P4|DISEASE|OMICID", colnames(flow_data))]
flow_data_panel_5 <- flow_data[,grep("P5|DISEASE|OMICID", colnames(flow_data))]
flow_data_panel_6 <- flow_data[,grep("P6|DISEASE|OMICID", colnames(flow_data))]
flow_data_all <- flow_data

# Remove NA or perform Imputation
flow_data_panel_1 <- flow_data_panel_1[complete.cases(flow_data_panel_1),]
flow_data_panel_2 <- flow_data_panel_2[complete.cases(flow_data_panel_2),]
flow_data_panel_3 <- flow_data_panel_3[complete.cases(flow_data_panel_3),]
flow_data_panel_4 <- flow_data_panel_4[complete.cases(flow_data_panel_4),]
flow_data_panel_5 <- flow_data_panel_5[complete.cases(flow_data_panel_5),]
flow_data_panel_6 <- flow_data_panel_6[complete.cases(flow_data_panel_6),]

flow_data_all <-flow_data_all[complete.cases(flow_data_all),]


# Panel to Process:
panel_to_process <- flow_data_all

# Run Boruta
#boruta.train <- Boruta(X.Clinical.Diagnosis.DISEASE~.-X.Clinical.Sampling.OMICID, data = panel_to_process, doTrace = 2)
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
write.table(boruta.df, "C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\data\\feature_selection_panel_all_discrete.txt", sep=";")

# Write new tables
selected_variables <- getSelectedAttributes(final.boruta, withTentative = F)
f <- paste(selected_variables, collapse='|')
f <- paste(c(f, "X.Clinical.Diagnosis.DISEASE|X.Clinical.Sampling.OMICID"), collapse = '|')
panel_to_process <- panel_to_process[,grep(f, colnames(panel_to_process))]

#write.table(panel_to_process, "/home/foulquier/Bureau/SpellCraft/WorkSpace/FeatureSelection/panel_6_filtered.txt", sep=";")
write.table(panel_to_process, "C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\data\\panel_all_filtered.txt_discrete", sep=";")
