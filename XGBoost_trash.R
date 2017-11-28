

## Load data
input_data_file = "C:\\Users\\Nathan\\Desktop\\Prog\\WorkSpace\\LUMINEX\\Luminex_SjS_Ctrl.csv"
input_data = read.csv(input_data_file, stringsAsFactors=FALSE, sep=",", header = TRUE)
attach(input_data)

myDF <- input_data[complete.cases(input_data), ]

head(myDF)

output_vector = myDF[,Disease] == "SjS"

require(xgboost)


## Tuto stuff
require(Matrix)
require(data.table)
if (!require('vcd')) install.packages('vcd')

data(Arthritis)
df <- data.table(Arthritis, keep.rownames = F)
