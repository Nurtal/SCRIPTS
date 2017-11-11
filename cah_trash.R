
library(fastcluster)


## Load data
input_data_file = "C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\Spellcraft\\TRASH\\cavale\\clean_data\\all_gated_data_absolute.csv"
input_data = read.csv(input_data_file, stringsAsFactors=TRUE, sep=",", header = TRUE)
attach(input_data)

## Prepare data
myDF <- input_data[complete.cases(input_data), ]
rownames(myDF) <- myDF$ID
myDF$ID <- NULL

AFC <- dudi.coa(df=myDF, scannf=FALSE, nf=ncol(myDF))
plot.dudi(AFC)

## CAH 

## calcul de la matrice des distances
md <- dist.dudi(AFC)
#distMat <- dist.dudi(AFC, amongrow=TRUE)

arbre <- hclust(md, method = "ward.D2")

plot(arbre, labels = FALSE, main = "Dendrogramme")

inertie <- sort(arbre$height, decreasing = TRUE)
plot(inertie[1:20], type = "s", xlab = "Nombre de classes", 
     ylab = "Inertie")



## decoupage de l'arbre

library(devtools)
install_github("larmarange/JLutils")
library(JLutils)
best.cutree(arbre)
best.cutree(arbre, graph = TRUE, xlab = "Nombre de classes", 
            ylab = "Inertie relative")

typo <- cutree(arbre, 3)

write.csv(typo, "C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\Spellcraft\\CBFD\\data4\\cah_patient_to_cluster_dataset2.csv")


par(mfrow = c(1, 2))
library(RColorBrewer)
s.class(AFC$li, as.factor(typo), col = brewer.pal(5, 
                                                  "Set1"), sub = "Axes 1 et 2")
s.class(AFC$li, as.factor(typo), 3, 4, col = brewer.pal(5, 
                                                        "Set1"), sub = "Axes 3 et 4")
