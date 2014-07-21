data <- read.csv("merged.bed", header=FALSE, sep = "\t")
difference = numeric(length=length(data[,1]))

for (i in 0:length(data[,1])) {
	difference[i]=data[i,3]-data[i,2]
}

print (length(data[,1]))