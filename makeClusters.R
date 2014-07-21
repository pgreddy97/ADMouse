directory<-readline("Where is everything?!?!")
setwd(directory)

files <- list.files(path=directory, full.names = FALSE)

for (fileName in files){

  print(fileName)
  
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
  dendogramsDir = paste(directory,"/dendograms",sep="")
  completeDir = paste(directory,"/complete",sep="")
  print(name)
  
  setwd(numbersDir)
  dataTable <-read.table(fileName , header = FALSE, sep = "\t")
  dataDistance <- dist(dataTable, method="euclidean")
  dataCluster <- hclust(dataDistance, method="ward")
  motifTitle = paste(dendogramsDir,name,"_motif.pdf",sep="")
  pdf(motifTitle)
  motifPlotTitle = paste(title,"Motif Clustering")
  plot (dataCluster, main = motifPlotTitle, labels = FALSE)
  dev.off()
  
  motifTitle = paste(name,"_motifOrder.txt")
  setwd(completeDir)
  print(dataCluster$order)
  write(dataCluster$order, file=motifTitle)
  
  setwd(numbersDir)
  dataTableTranspose <- t(dataTable)
  dataDistanceTranspose <- dist(dataTableTranspose, method="euclidean")
  dataClusterTranspose <- hclust(dataDistanceTranspose, method="ward")
  runTitle = paste(dendogramsDir,name,"_run.pdf",sep="")
  pdf(runTitle)
  runPlotTitle=paste(title, "Run Clustering")
  plot(dataClusterTranspose, main = runPlotTitle, labels = FALSE)
  dev.off()
  
  runTitle = paste(name, "_runOrder.txt",sep="")
  setwd(completeDir)
  write = dataClusterTranspose$order
  write(write, file=runTitle)
}
