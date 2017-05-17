library(ade4)
library(FactoClass)

# load data
# where am i 
info = Sys.info()
os = info[["sysname"]]
data_file_name = "undef"
login = info[["login"]]

#load data
if(identical(os, "Windows")){
  #-Windows
  data_file_name = paste("C:\\Users\\", login, "\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\data_discretized.txt", sep="")
  
  
}else{
  #-Linux
  data_file_name = ("/home/foulquier/Bureau/SpellCraft/WorkSpace/SCRIPTS/data/clinical_data_phase_1.csv")
}


## Load data
data <- read.csv(data_file_name, header = T, sep=",")

str(data)

myDF <- subset(iris, select= -X.Clinical.Diagnosis.DISEASE)

myDF <- data

myDF$X.Clinical.Diagnosis.DISEASE <- NULL

str(iris)
myDF <- subset(iris, select= -Species)
str(myDF)



AFC <- dudi.coa(df=myDF, scannf=FALSE, nf=ncol(myDF))
plot.dudi(AFC)



#-----------#
# CAH STUFF #
#-----------#

distMat <- dist.dudi(AFC, amongrow=TRUE)
CAH <- ward.cluster(distMat, peso = apply(X=myDF, MARGIN=1, FUN=sum) , plots = TRUE, h.clust = 1)

par(mfrow=c(1,2))
barplot(sort(CAH$height / sum(CAH$height), decreasing = TRUE)[1:15] * 100,
        xlab = "Noeuds", ylab = "Part de l'inertie totale (%)",
        names.arg=1:15, main="Inertie selon le partitionnement")

barplot(cumsum(sort(CAH$height / sum(CAH$height), decreasing = TRUE))[1:15] * 100,
        xlab = "Nombre de classes", ylab = "Part de l'inertie totale (%)",
        names.arg=1:15, main="Inertie expliquée")

par(mfrow=c(1,1))
plot(as.dendrogram(CAH), leaflab = "none")

myDF$clusters <- cutree(tree = CAH, k = 7)
s.class(cstar=1,addaxes=TRUE, grid=TRUE, axesell=TRUE,
        dfxy=AFC$li, fac=as.factor(myDF$clusters), col=1:7,
        label=c(1:7), csub=1.2, possub="bottomright")



plot.dudi(AFC, Tcol = TRUE, Trow = FALSE)

s.class(cstar=1,addaxes=TRUE, grid=FALSE, axesell=TRUE,
        dfxy=AFC$li, fac=as.factor(myDF$clusters), col=1:3,
        label=c(1:3), csub=1.2, possub="bottomright", add=TRUE)


# OTHER STUFF
library(colorspace) # get nice colors



#True data
data_file_name = "C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\SpellCraft\\SCRIPTS\\data\\panel_1_filtered.txt_discrete"
data <- read.csv(data_file_name, header = T, sep=";")
data2 <- data[,-which( colnames(data)=="X.Clinical.Diagnosis.DISEASE" )]
disease_labels <- data[,which( colnames(data)=="X.Clinical.Diagnosis.DISEASE" )]
disease_col <- rev(rainbow_hcl(7))[as.numeric(disease_labels)]


# Plot a SPLOM:
pairs(data2, col = disease_col)

# Add a legend
par(xpd = TRUE)
legend(x = 0.05, y = 0.4, cex = 2,
       legend = as.character(levels(disease_labels)),
       fill = unique(disease_col))
par(xpd = NA)

par(las = 2, mar = c(4.5, 3, 3, 2) + 0.1, cex = .8)
MASS::parcoord(data2, col = disease_col, var.label = TRUE, lwd = 2)

# Add Title
title("Parallel coordinates plot of the Iris data")
# Add a legend
par(xpd = TRUE)
legend(x = 1.75, y = -.25, cex = 1,
       legend = as.character(levels(disease_labels)),
       fill = unique(disease_col), horiz = TRUE)
par(xpd = NA)


d_data <- dist(data2) # method="man" # is a bit better
hc_data <- hclust(d_data, method = "complete")
disease <- rev(levels(data[,which( colnames(data)=="X.Clinical.Diagnosis.DISEASE" )]))


library(dendextend)
dend <- as.dendrogram(hc_data)
# order it the closest we can to the order of the observations:
#dend <- rotate(dend, 1:150)

# Color the branches based on the clusters:
dend <- color_branches(dend, k=8) #, groupLabels=iris_species)

# Manually match the labels, as much as possible, to the real classification of the flowers:
labels_colors(dend) <-
  rainbow_hcl(8)[sort_levels_values(
    as.numeric(data[,8])[order.dendrogram(dend)]
  )]

# We shall add the flower type to the labels:
labels(dend) <- paste(as.character(data[,which( colnames(data)=="X.Clinical.Diagnosis.DISEASE" )])[order.dendrogram(dend)],
                      "(",labels(dend),")", 
                      sep = "")
# We hang the dendrogram a bit:
dend <- hang.dendrogram(dend,hang_height=0.1)
# reduce the size of the labels:
# dend <- assign_values_to_leaves_nodePar(dend, 0.5, "lab.cex")
dend <- set(dend, "labels_cex", 0.5)
# And plot:
par(mar = c(3,3,3,7))
plot(dend, 
     main = "Clustered Iris data set
     (the labels give the true flower species)", 
     horiz =  TRUE,  nodePar = list(cex = .007))
legend("bottom", legend = disease, fill = rainbow_hcl(8))

par(mar = rep(0,4))
circlize_dendrogram(dend)




