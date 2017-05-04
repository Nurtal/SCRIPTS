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



## variable to keep
variable_to_keep <- scan("C:\\Users\\PC_immuno\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\feature_selection_diag_RA_formated.txt", what="", sep="\n")
variable_to_keep <- scan("C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\feature_selection_diag_SjS_formated.txt", what="", sep="\n")
variable_to_keep <- c(variable_to_keep, "X.Clinical.Diagnosis.DISEASE")
data = data[ , (names(data) %in% variable_to_keep)]

# drop MHTERM
drops_variable = c("X.Clinical.Diagnosis.MHTERM")
data = data[ , !(names(data) %in% drops_variable)]

# Deal with NA
# use only patient without NA ( drop control in the process ...)
data = data[complete.cases(data),]
data <- data.frame(lapply(data, as.factor))


# mining
rules <- apriori(data)
rules <- apriori(data,
                 parameter = list(minlen=2, supp=0.05, conf=0.8),
                 appearance = list(rhs=c("X.Clinical.Diagnosis.DISEASE=SjS"),
                                   default="lhs"),
                 control = list(verbose=T))
rules.sorted <- sort(rules, by="lift")
inspect(rules)


# write rules into file
rules_df = as(rules, "data.frame");
write.table(rules_df, "C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rules_SjS.txt", sep=";")
write.table(rules_df, "C:\\Users\\PC_immuno\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rules_RA.txt", sep=";")


# find redundant rules
## for better comparison we sort the rules by confidence and add Bayado's improvement
rules <- sort(rules, by = "confidence")
quality(rules)$improvement <- interestMeasure(rules, measure = "improvement")
inspect(rules)
is.redundant(rules)

# remove redundant rules
rules_filtered <- rules[!is.redundant(rules)]
inspect(rules_filtered)

# plot stuff
plot(rules_filtered)
plot(rules, method="graph", control=list(type="items"))
plot(rules, method="paracoord", control=list(reorder=TRUE))
plot(rules, method="graph", control=list(type="itemsets"))

# write rules into file
rules_df = as(rules, "data.frame");
write.table(rules_df, "C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rules_non_redundant_SjS.txt", sep=";")
write.table(rules_df, "C:\\Users\\PC_immuno\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rules_non_redundant_RA.txt", sep=";")
