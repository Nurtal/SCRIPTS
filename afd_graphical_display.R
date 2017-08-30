## Perform Linear Discriminant Analysis
## and display graphical results

## Library importation
library(car)
library(MASS)

## Init the different path needed
input_data_file = "/home/foulquier/Bureau/SpellCraft/WorkSpace/Side_quest/Benedicte/data_extented.csv" # csv file where the first row correspond to the disease (and is labeled Disease)
png_path_overview = "/home/foulquier/Bureau/SpellCraft/WorkSpace/Side_quest/Benedicte/" # must be a folder

## import the data
input_data = read.csv(input_data_file, stringsAsFactors=TRUE, sep=",", header = TRUE)
attach(input_data)

## Perform LDA
r <- lda(formula = Disease ~ ., data = input_data[,2:ncol(input_data)])
data.lda.values <- predict(r)

## plot the Stacked Histogram of the LDA Values
comp = 1
while(comp <= ncol(r$scaling)){
  png_save_file = paste(png_path_overview, "LDA_comp_", comp, "_histogram.png" , sep="")
  png(filename=png_save_file)
  ldahist(data = data.lda.values$x[,comp], g=Disease)
  dev.off()
  comp = comp + 1
}

## Simple 2D scatterplot
plot(data.lda.values$x[,1],data.lda.values$x[,2]) # make a scatterplot
text(data.lda.values$x[,1],data.lda.values$x[,2],Disease,cex=0.7,pos=4,col="red") # add labels

## Alternative plot (test each comination of 2 LDA)
plot(r)

## 3D display
x <- LDA1 <- data.lda.values$x[,1]
y <- LDA2 <- data.lda.values$x[,2]
z <- LDA3 <- data.lda.values$x[,3]
scatter3d(x = LDA1, y = LDA2, z =LDA3, groups = input_data$Disease, grid = FALSE, surface = FALSE, ellipsoid = TRUE)
