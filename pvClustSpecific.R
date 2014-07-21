args <- commandArgs(trailingOnly=TRUE)
directory = args[1]
fileName = args[2]
setwd(directory)

setwd("numbers")

  
title = ""
name=""
if (fileName=="H3K27ac_all_numbers.txt"){title="H3K27ac All Sites" 
                                           name ="H3K27ac_all"}
else if (fileName=="H3K4me1_all_numbers.txt"){title="H3K4me1 All Sites"
                                                name="H3K4me1_all"}
else if (fileName=="H3K4me3_all_numbers.txt"){title="H3K4me3 All Sites"
                                                name="H3K4me3_all"}
else if (fileName=="HDAC2_all_numbers.txt"){title="HDAC2 All Sites"
                                              name="HDAC2_all"}
else if (fileName=="H3K27ac_dhs_numbers.txt"){title="H3K27ac DHS Sites"
                                                name="H3K27ac_dhs"}
else if (fileName=="H3K4me1_dhs_numbers.txt"){title="H3K4me1 DHS Sites"
                                                name="H3K4me1_dhs"}
else if (fileName=="H3K4me3_dhs_numbers.txt"){title="H3K4me3 DHS Sites"
                                                name="H3K4me3_dhs"}
else if (fileName=="HDAC2_dhs_numbers.txt"){title="HDAC2 DHS Sites"
                                              name="HDAC2_dhs"}
  
numbersDir = paste(directory,"/numbers",sep="")
dendogramsDir = paste(directory,"/pvDendograms",sep="")
  
setwd(numbersDir)
dataTable <-read.table(fileName , header = FALSE, sep = "\t")
motifTitle = paste(dendogramsDir,"/",name,"_run.pdf",sep="")
pdf(motifTitle)
motifPlotTitle = paste(title,"PV Run Clustering")
result <- pvclust(dataTable, method.dist="euclidean", method.hclust="ward",nboot=1000)
plot(result)
dev.off()
  
auRunDir = paste(directory,"/pvValues/run/au",sep="")
mergeRunDir = paste (directory,"/pvValues/run/merge",sep="")
auMotifDir = paste(directory,"/pvValues/motif/au",sep="")
mergeMotifDir = paste(directory,"/pvValues/motif/merge",sep="")
  
setwd(auRunDir)
write(result$edges$au, file=fileName, sep = " ")

setwd(mergeRunDir)
write.table(result$hclust$merge, file = fileName, sep = " ")
  
setwd(numbersDir)
dataTableTranspose <- t(dataTable)
runTitle = paste(dendogramsDir,"/",name,"_motif.pdf",sep="")
pdf(runTitle)
runPlotTitle=paste(title, "PV Motif Clustering")
result <- pvclust(dataTableTranspose, method.dist="euclidean", method.hclust="ward",nboot=1000)
plot(result)
dev.off()
  
setwd(auMotifDir)
write(result$edges$au, file=fileName, sep = " ")
  
setwd(mergeMotifDir)
write.table(result$hclust$merge, file = fileName, sep = " ")