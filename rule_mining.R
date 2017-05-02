library(arules)
library(arulesViz)


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



# variable to keep
variable_to_keep <- scan("C:\\Users\\PC_immuno\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\feature_selection_diag_SjS_formated.txt", what="", sep="\n")
variable_to_keep <- c(variable_to_keep, "X.Clinical.Diagnosis.DISEASE")
data = data[ , (names(data) %in% variable_to_keep)]

# Deal with NA
# use only patient without NA ( drop control in the process ...)
data = data[complete.cases(data),]
data <- data.frame(lapply(data, as.factor))


# mining
rules <- apriori(data)
rules <- apriori(data,
                 parameter = list(minlen=2, supp=0.005, conf=0.8),
                 appearance = list(rhs=c("X.Clinical.Diagnosis.DISEASE=SjS"),
                                   default="lhs"),
                 control = list(verbose=F))
rules.sorted <- sort(rules, by="lift")
inspect(rules)

# plot stuff
plot(rules)
