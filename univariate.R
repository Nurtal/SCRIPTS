##
## R stuff to run univariate 
## analysis on specific metabolites
## befor ELISA
##

## load data
input_data_file = "/home/tyrosine/Spellcraft/XGBTL/data/data_control_SjS_PENTRAXIN3_vs_GDF15.csv"
input_data = read.csv(input_data_file, stringsAsFactors=TRUE, sep=",", header = TRUE)
attach(input_data)
myDF <- input_data[complete.cases(input_data), ]

## run analysis

## tutorial
# Convertir la colonne dose en facteur
ToothGrowth$dose <- as.factor(ToothGrowth$dose)
head(ToothGrowth)

myDF$Disease <- as.factor(myDF$Disease)



library(ggplot2)
# Violin plot basic
p <- ggplot(ToothGrowth, aes(x=dose, y=len)) + 
  geom_violin()
p

p <- ggplot(myDF, aes(x=Disease, y=PENTRAXIN3)) + 
  geom_violin()
p


# Tourner le violin plot
p + coord_flip()
# Utiliser l'argument trim = FALSE
ggplot(ToothGrowth, aes(x=dose, y=len)) + 
  geom_violin(trim=FALSE)



# violin plot avec un dot plot
p + geom_dotplot(binaxis='y', stackdir='center', dotsize=1)
# Violin plot avec des points dispersés (jitter)
# 0.2 : dégré de dispersion sur l'axe des x
p + geom_jitter(shape=16, position=position_jitter(0.2))






### test
hsb2 <- within(read.csv("https://stats.idre.ucla.edu/stat/data/hsb2.csv"), {
  race <- as.factor(race)
  schtyp <- as.factor(schtyp)
  prog <- as.factor(prog)
})

attach(hsb2)

machin = read.csv(input_data_file, stringsAsFactors=FALSE, sep=",", header = TRUE)
attach(machin)
machin <- machin[complete.cases(machin), ]
machin[machin=="control"]<-0
machin[machin=="SjS"]<-1

t.test(GDF15 ~ Disease)
#t.test(as.numeric(machin$PENTRAXIN3), as.numeric(machin$Disease), paired = TRUE)
t.test(write, read, paired = TRUE)

















## Test on diseases
input_data_file ="/home/tyrosine/Spellcraft/XGBTL/data/SjS_data_with_medication.csv"
machin = read.csv(input_data_file, stringsAsFactors=TRUE, sep=",", header = TRUE)
attach(machin)
machin <- machin[complete.cases(machin), ]
machin[machin=="Control"]<-0
machin[machin=="SjS"]<-1
machin[machin=="No"]<-0
machin[machin=="Yes"]<-1


##--------------##
## PLOT SECTION ##
##--------------##
## AMALARIA
p <- ggplot(machin, aes(x=STEROID, y=GDF15)) + 
  geom_violin()
p
# violin plot avec un dot plot
p + geom_dotplot(binaxis='y', stackdir='center', dotsize=1)
# Violin plot avec des points dispersés (jitter)
# 0.2 : dégré de dispersion sur l'axe des x
p + geom_jitter(shape=16, position=position_jitter(0.2))



