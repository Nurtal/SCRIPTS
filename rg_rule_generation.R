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
  data_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rg_data_filtered.txt", sep="")
  features_saved_file = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rg_feature_selected.txt", sep="")
  save_rules_file = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rg_all_rules.txt", sep="")
  save_rules_file_2 = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\rg_all_rules_filtered.txt", sep= "")
  
}else{
  #-Linux
  data <- read.csv("/home/foulquier/Bureau/SpellCraft/WorkSpace/SCRIPTS/data/clinical_data_phase_1.csv", stringsAsFactors=TRUE)
}
data <- read.csv(data_file_name, stringsAsFactors=TRUE, sep=";")


# Deal with NA
# use only patient without NA ( drop control in the process ...)
data = data[complete.cases(data),]
data <- data.frame(lapply(data, as.factor))


# mining
rules <- apriori(data)
rules.sorted <- sort(rules, by="lift")

# write rules into file
rules_df = as(rules, "data.frame");
write.table(rules_df, save_rules_file, sep=";")

# find redundant rules
## for better comparison we sort the rules by confidence and add Bayado's improvement
rules <- sort(rules, by = "confidence")
quality(rules)$improvement <- interestMeasure(rules, measure = "improvement")
is.redundant(rules)

# remove redundant rules
rules_filtered <- rules[!is.redundant(rules)]


# write non redundant rules into file
rules_df = as(rules_filtered, "data.frame");
write.table(rules_df, save_rules_file_2 , sep=";")