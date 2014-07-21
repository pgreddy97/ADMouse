get.file.parts <- function(file.fullpath) {
  # ===================================
  # Function will take a file name with path and split the file name into 
  # path, fullname, name and ext
  # ===================================  
  if (! is.character(file.fullpath)) {
    stop('File name must be a string')
  }
  
  file.parts <- strsplit(as.character(file.fullpath), .Platform$file.sep, fixed=TRUE)[[1]] # split on file separator
  
  if (length(file.parts) == 0) { # if empty file name
    return(list(path='',
                fullname='',
                name='',
                ext='')
    )
  } else {
    if (length(file.parts) == 1) { # if no path then just the file name itself
      file.path <- '.'
      file.fullname <- file.parts
    } else {
      file.path <- paste(file.parts[1:(length(file.parts)-1)], collapse=.Platform$file.sep) # 1:last-1 token is path
      file.fullname <- file.parts[length(file.parts)] # last token is filename
    }        
    file.fullname.parts <- strsplit(file.fullname,'.',fixed=TRUE)[[1]] # split on .
    if (length(file.fullname.parts) == 1) { # if no extension
      file.ext <- ''
      file.name <- file.fullname.parts
    } else {
      file.ext <- paste('.', file.fullname.parts[length(file.fullname.parts)], sep="") # add the . to the last token
      file.name <- paste(file.fullname.parts[1:(length(file.fullname.parts)-1)], collapse=".")
    }
    return(list(path=file.path,
                fullname=file.fullname,
                name=file.name,
                ext=file.ext))
  }         	
} # end: get.file.parts()

plot.heatmap <- function(data, # data: any data frame (Rows: are binding sites, Cols: partner TFs)
                         use.as.dist=F, # use.as.dist: use data directly as a similarity matrix (data must be symmetric matrix/data frame)
                         to.file=NULL, # to.file: png/pdf file that you want to save the figure to (default: no saving)
                         row.title="rows", # row.title: axis title for rows
                         col.title="cols", # col.title: axis title for columns
                         title.name=NULL, # title.name: plot title
                         filt.thresh=1e-7, # filt.thresh: used to remove rows and cols with all values < filt.thresh
                         subtract.filt.thresh=F, # subtract filt.thresh from all values and set values < filt.thresh = 0
                         pseudo.count=1e-30, # pseudo.count: uniform random numbers scaled by pseudo.count are added to the matrix to avoid 0 std for constant columns
                         logval=F, # logval: T/F . If set to T, then the matrix is log transformed before clustering. (filt.thresh, break.lowerbound and break.upperbound will also be log transformed)
                         replace.diag=T, # replace.diag: If set to T, then matrix diagonal values are replaced by maximum value in the matrix
                         replace.na=T, # replace.na: If set of T, then NA values are replaced by minimum value in the matrix
                         num.breaks=255, # num.breaks: number of breaks in colors (The breaks correspond to uniformly sampled quantiles from the distribution of values in the matrix, excluding all values below filt.thresh)
                         break.type="quantile", # break.type: type of color breaks, quantile: means the colors are adjusted to uniformly spaced quantiles, linear: colors are placed on the linear scale
                         break.lowerbound=filt.thresh, # break.lowerbound: For values below break.lowerbound are ignored and set to the lowest color
                         break.upperbound=NA, # break.upperbound: For values above break.upperbound are ignored and set to the highest color
                         clust.method=c("average","average"), # clust.method: linkage method e.g. "complete/average/ward/single" . Either a single value or a pair of values c(row,col) will apply to clustering rows and columns
                         dist.metric=c("euclidean","euclidean"), # dist.metric="euclidean/pearson/spearman/binary/manhattan". Either a single value or a pair of values c(row,col) will apply to clustering rows and columns
                         scale="none", # scale: "row", "col", "none" whether to standardize rows/columns or none
                         row.cluster=T, # row.cluster=T : T or F to cluster rows OR a numeric vector with the desired row order OR a dendrogram object
                         col.cluster=T, # col.cluster=T : T or F to cluster columns OR a numeric vector with the desired row order OR a dendrogram object
                         row.optimal.order=F, # row.optimal.order=F : T or F to arrange row dendrogram in optimal order
                         col.optimal.order=F, # col.optimal.order=F : T or F to arrange col dendrogram in optimal order
                         symm.cluster=F, # symm.cluster=F : if set to T then column clustering is set equal to row clustering
                         show.dendro="both", # show.dendro="both"  : which dendrograms to show "row", "column", "both" or "none"
                         row.lab=FALSE,
                         col.lab=FALSE
) {
  # ===================================
  # Plot clustered heatmap of associations
  # NOTE: This is currently horrendously slow for large number of rows
  # ===================================
  if (!require("gplots")) {
    install.packages("gplots", dependencies = TRUE)
    library(gplots)
  }
  if (!require("fastcluster")) {
      install.packages("fastcluster", dependencies = TRUE)
      library(fastcluster)
  }
  if (!require("fBasics")) {
      install.packages("fBasics", dependencies = TRUE)
      library(fBasics) 
  }
  if (!require("cba")) {
      install.packages("cba", dependencies = TRUE)
      library(cba)
  }
  
  library(fastcluster) # fast hclust
  library(gplots) # heatmap2
  library(fBasics) # color scales
  library(cba) # adds optimal ordering functionality
  
  # Remove columns with all NAs
  na.idx <- apply( data , 2 , function(x) all(is.na(x)) )
  data <- data[ , !na.idx]
  if (symm.cluster) {
    data <- data[!na.idx,]
  }
  # Remove rows with all NAs
  na.idx <- apply( data , 1 , function(x) all(is.na(x)) )
  data <- data[!na.idx, ]  
  if (symm.cluster) {
    data <- data[,!na.idx]
  }
  
  if (! is.na(filt.thresh) ) {
    # Remove columns with all very small values
    na.idx <- apply( data , 2 , function(x) all((x<filt.thresh),na.rm=T) )
    data <- data[ , !na.idx]
    if (symm.cluster) {
      data <- data[!na.idx,]
    }    
    # Remove rows with all very small values
    na.idx <- apply( data , 1 , function(x) all((x<filt.thresh),na.rm=T) )
    data <- data[!na.idx, ]
    if (symm.cluster) {
      data <- data[,!na.idx]
    }    
  }
  
  data.size <- dim(data)
  if (data.size[[1]] < 1) {return()}
  
  # Add a small random number to each value to avoid problems with clustering
  clean.data <- as.matrix(data) + (pseudo.count * matrix( data=runif(prod(data.size)), data.size[1], data.size[2]) )
  
  # If logval log transform relevant parameters
  if (logval) {
    clean.data <- log10(clean.data)
    clean.data[is.infinite(clean.data)] <- NA
    filt.thresh <- log10(filt.thresh)
    break.lowerbound <- log10(break.lowerbound)
    break.upperbound <- log10(break.upperbound)
  }
  
  # subtract filt.thresh if required
  if (subtract.filt.thresh & !is.na(filt.thresh)) {
    clean.data <- clean.data - filt.thresh
    clean.data[which(clean.data < 0)] <- 0
  }
  
  breaks.data <- as.vector(clean.data)
  min.val <- min(breaks.data,na.rm=T)
  max.val <- max(breaks.data,na.rm=T)  
  
  # Replace diagonal values with max if required
  if (replace.diag) { 
    for (r in rownames(clean.data)) {
      if (r %in% colnames(clean.data)) {
        if (is.na(clean.data[r,r])) { clean.data[r,r] <- max.val }
      }
    }
  }
  
  # Replace NAs with minimum value
  if (replace.na) { clean.data[is.na(clean.data)] <- min.val } # set NAs to minimum value
  
  # Generate color breaks
  # number of parts to split the color map into (max 3 parts min.val:break.lowerbound , lowerbound:upperbound, upperbound:max.val)
  if (!is.na(break.lowerbound)) {
    if (break.lowerbound < min.val) {break.lowerbound <- NA}
  }
  if (!is.na(break.upperbound)) {
    if (break.upperbound > max.val) {break.upperbound <- NA}
  }
  
  n.breaks <- num.breaks
  
  if (is.na(break.lowerbound) && is.na(break.upperbound)) { # Full scale
    
    if (break.type == "quantile") {
      breaks.vals <- quantile(breaks.data,prob=seq(0,1,length.out=n.breaks),na.rm=T)
      breaks.vals <- c(min.val,breaks.vals,max.val)
    } else if (break.type == "linear") {
      breaks.vals <- seq(min.val,max.val,length.out=n.breaks)
    }
    
  } else if (is.na(break.lowerbound) && !is.na(break.upperbound)) {  # min:upper , upper:max    
    
    n.1.2 <- round(2*n.breaks/3) # number of break values
    n.3 <- round(n.breaks/3)
    if (break.type == "quantile") {
      # min:upper
      breaks.vals.1.2 <- quantile( breaks.data[breaks.data<break.upperbound], prob=seq(0,1,length.out=n.1.2), na.rm=T)
      breaks.vals.1.2 <- c(min.val, breaks.vals.1.2, break.upperbound)
      #upper:max      
      breaks.vals.3 <- quantile( breaks.data[breaks.data>=break.upperbound], prob=seq(0,1,length.out=n.3), na.rm=T)
      breaks.vals.3 <- c(breaks.vals.3, max.val)      
      breaks.vals <- c(breaks.vals.1.2, breaks.vals.3)
    } else if (break.type == "linear") {
      breaks.vals <- c( seq(min.val, break.upperbound, length.out=n.1.2),
                        seq(break.upperbound, max.val, length.out=n.3))
    }
    
  } else if (!is.na(break.lowerbound) && is.na(break.upperbound)) {
    
    n.1 <- round(n.breaks/3) # number of break values
    n.2.3 <- round(2*n.breaks/3)
    if (break.type == "quantile") {
      # min:lower
      breaks.vals.1 <- quantile( breaks.data[breaks.data<break.lowerbound], prob=seq(0,1,length.out=n.1), na.rm=T)
      breaks.vals.1 <- c(min.val, breaks.vals.1, break.lowerbound)
      #lower:max      
      breaks.vals.2.3 <- quantile( breaks.data[breaks.data>=break.lowerbound], prob=seq(0,1,length.out=n.2.3), na.rm=T)
      breaks.vals.2.3 <- c(breaks.vals.2.3, max.val)      
      breaks.vals <- c(breaks.vals.1, breaks.vals.2.3)
    } else if (break.type == "linear") {
      breaks.vals <- c( seq(min.val, break.lowerbound, length.out=n.1),
                        seq(break.lowerbound, max.val, length.out=n.2.3))
    }    
    
  } else {
    
    n.1 <- round(n.breaks/3) # number of break values
    n.2 <- round(n.breaks/3) 
    n.3 <- round(n.breaks/3) 
    if (break.type == "quantile") {
      # min:lower
      breaks.vals.1 <- quantile( breaks.data[breaks.data<break.lowerbound], prob=seq(0,1,length.out=n.1), na.rm=T)
      breaks.vals.1 <- c(min.val, breaks.vals.1, break.lowerbound)
      # lower:upper
      breaks.vals.2 <- quantile( breaks.data[ (breaks.data>=break.lowerbound) & (breaks.data<break.upperbound)], 
                                 prob=seq(0,1,length.out=n.2), na.rm=T)
      breaks.vals.1 <- c(breaks.vals.2, break.upperbound)      
      # upper:max      
      breaks.vals.3 <- quantile( breaks.data[breaks.data>=break.upperbound], prob=seq(0,1,length.out=n.3), na.rm=T)
      breaks.vals.3 <- c(breaks.vals.3, max.val)      
      breaks.vals <- c(breaks.vals.1, breaks.vals.2, breaks.vals.3)
    } else if (break.type == "linear") {
      breaks.vals <- c( seq(min.val, break.lowerbound, length.out=n.1),
                        seq(break.lowerbound, break.upperbound, length.out=n.2),
                        seq(break.upperbound, max.val, length.out=n.3))
    }    
    
  }
  
  all.colors <- seqPalette( (length(breaks.vals)-1) , "YlOrRd" )
  
  # Old code  
  #   temp.min.val <- min.val
  #   temp.max.val <- max.val
  #   if (! is.na(break.lowerbound)) {  
  #     breaks.data <- breaks.data[breaks.data>break.lowerbound] # Remove low values
  #     temp.min.val <- break.lowerbound
  #   }
  #   if (! is.na(break.upperbound)) {  
  #     breaks.data <- breaks.data[breaks.data<break.upperbound] # Remove low values
  #     temp.max.val <- break.upperbound
  #   }   
  #     
  #   n.breaks <- num.breaks
  #   if (break.type == "quantile") {
  #     breaks.vals <- quantile(breaks.data,prob=seq(0,1,length.out=n.breaks),na.rm=T)
  #     breaks.vals <- c(temp.min.val,breaks.vals,temp.max.val)
  #   } else if (break.type == "linear") {
  #     breaks.vals <- seq(temp.min.val,temp.max.val,length.out=n.breaks)
  #   }
  #   
  #   #all.colors <- heat.colors(length(breaks.vals)-3)
  #   #all.colors <- heatPalette(length(breaks.vals)-3)
  #   #all.colors <- rev( divPalette( (length(breaks.vals)-3) , "RdBu" ) )  
  #   #all.colors <- rev(focusPalette( (length(breaks.vals)-3) , "redfocus" ))
  #   #all.colors <- rampPalette( (length(breaks.vals)-3) , "blue2red" )
  #   #all.colors <- rev( redgreen((length(breaks.vals)-3)) )
  #   all.colors <- seqPalette( (length(breaks.vals)-3) , "YlOrRd" )
  #   all.colors <- ( c(all.colors[1], all.colors, all.colors[length(all.colors)]) )
  
  # Select image size
  if ( !is.null(to.file) ) {
    if (max(data.size) > 150) {
      plot.width <- 15
      plot.height <- 15      
    } else {
      plot.width <- 11
      plot.height <- 11      
    }
    file.ext <- get.file.parts(to.file)$ext
    if (tolower(file.ext) == '.png') {
      png(filename=to.file, width=plot.width, height=plot.height, units="in", res=600)      
    } else {
      pdf(file=to.file,width=plot.width,height=plot.height)
    }    
  }
  
  # Ajust font sizes
  #cex.val <- 1
  cex.val <- 0.9
  if (max(data.size) > 50) {
    cex.val <- 0.7
  }
  if (max(data.size) > 70) {
    cex.val <- 0.6
  }
  if (max(data.size) < 20) {
    cex.val <- 1
  }
  
  # Decide whether to show row or column names
  lab.row <- NULL
  row.sep <- c(1:nrow(clean.data))     
  lab.col <- NULL
  col.sep <- c(1:ncol(clean.data))
  
  if (nrow(clean.data) > 200) {
    lab.row <- NA
    row.sep <- NULL
    col.sep <- NULL
  }
  if (ncol(clean.data) > 200) {
    lab.col <- NA
    row.sep <- NULL
    col.sep <- NULL
  }
  
  lab.row <- row.lab
  lab.col <- col.lab
  
  # Compute clustering
  #   orig.clean.data <- clean.data
  #   clean.data[clean.data >= filt.thresh] <- 0.5
  #   clean.data[clean.data >= 2*filt.thresh] <- 1
  #   clean.data[clean.data < filt.thresh] <- 0
  #   clean.data <- clean.data + (pseudo.count * matrix( data=runif(prod(clean.data)), nrow(clean.data), ncol(clean.data) ) )
  
  if (length(dist.metric)==1) {
    dist.metric <- c(dist.metric,dist.metric)
  }
  if (length(clust.method)==1) {
    clust.method <- c(clust.method,clust.method)
  }
  
  row.cluster.results <- T
  col.cluster.results <- T
  
  # Cluster rows
  if (grepl(pattern="pearson|spearman",x=dist.metric[1])) { # If pearson or spearman, precompute distance matrix
    if (is.logical(row.cluster)) {
      if (row.cluster) {
        if (use.as.dist) { # Use data as distance measures directly
          row.cluster.results <- hclust( as.dist( -clean.data ), method=clust.method[1] )
          # Compute optimal ordering if required
          if (row.optimal.order) {            
            new.order <- order.optimal( as.dist( -clean.data ), row.cluster.results$merge)
            row.cluster.results$merge <- new.order$merge
            row.cluster.results$order <- new.order$order
          }          
        } else { # Use data as feature matrices and compute distance measure
          temp.dist <- as.dist( 1 - cor( t(clean.data),method=dist.metric[1],use="na.or.complete" )^2)
          row.cluster.results <- hclust( temp.dist ,method=clust.method[1] )
          # Compute optimal ordering if required
          if (row.optimal.order) {            
            new.order <- order.optimal( temp.dist, row.cluster.results$merge)            
            row.cluster.results$merge <- new.order$merge
            row.cluster.results$order <- new.order$order
          }
          rm(temp.dist)
        }
        row.cluster <- as.dendrogram(row.cluster.results)
      }  
    }
  } else { # if NOT pearson or spearman
    if (is.logical(row.cluster)) {
      if (row.cluster) {        
        if (use.as.dist) {
          row.cluster.results <- hclust( as.dist( -clean.data ), method=clust.method[1] )  
          # Compute optimal ordering if required
          if (row.optimal.order) {            
            new.order <- order.optimal( as.dist( -clean.data ), row.cluster.results$merge)
            row.cluster.results$merge <- new.order$merge
            row.cluster.results$order <- new.order$order
          }                    
        } else {
          temp.dist <- dist( clean.data, method=dist.metric[1] )
          row.cluster.results <- hclust( temp.dist, method=clust.method[1] )  
          if (row.optimal.order) {            
            new.order <- order.optimal( temp.dist, row.cluster.results$merge)            
            row.cluster.results$merge <- new.order$merge
            row.cluster.results$order <- new.order$order
          }
          rm(temp.dist)          
        }        
        row.cluster <- as.dendrogram(row.cluster.results)
      }  
    }
  }
  
  # Cluster columns
  if (grepl(pattern="pearson|spearman",x=dist.metric[2])) {    
    if (is.logical(col.cluster)) {
      if (col.cluster) {
        if (use.as.dist) {          
          col.cluster.results <- hclust( as.dist( -t(clean.data)), method=clust.method[2] )
          # Compute optimal ordering if required
          if (col.optimal.order) {            
            new.order <- order.optimal( as.dist( -t(clean.data) ), col.cluster.results$merge)
            col.cluster.results$merge <- new.order$merge
            col.cluster.results$order <- new.order$order
          }                    
        } else {
          temp.dist <- as.dist( 1 - cor( clean.data,method=dist.metric[2],use="na.or.complete" )^2)
          col.cluster.results <- hclust( temp.dist ,method=clust.method[2] )
          # Compute optimal ordering if required
          if (col.optimal.order) {            
            new.order <- order.optimal( temp.dist, col.cluster.results$merge)            
            col.cluster.results$merge <- new.order$merge
            col.cluster.results$order <- new.order$order
          }
          rm(temp.dist)                    
        }
        col.cluster <- as.dendrogram(col.cluster.results)        
      }  
    }
  } else {
    if (is.logical(col.cluster)) {
      if (col.cluster) {
        if (use.as.dist) {
          col.cluster.results <- hclust( as.dist( -t(clean.data)), method=clust.method[2] )
          # Compute optimal ordering if required
          if (col.optimal.order) {            
            new.order <- order.optimal( as.dist( -t(clean.data) ), col.cluster.results$merge)
            col.cluster.results$merge <- new.order$merge
            col.cluster.results$order <- new.order$order
          }                          
        } else {
          temp.dist <- dist( t(clean.data), method=dist.metric[2] )
          col.cluster.results <- hclust( temp.dist, method=clust.method[2] ) 
          # Compute optimal ordering if required
          if (col.optimal.order) {            
            new.order <- order.optimal( temp.dist, col.cluster.results$merge)            
            col.cluster.results$merge <- new.order$merge
            col.cluster.results$order <- new.order$order
          }
          rm(temp.dist)                              
        }        
        col.cluster <- as.dendrogram(col.cluster.results)        
      }  
    }    
  }
  
  #   clean.data <- orig.clean.data
  # Check if user wants to cluster rows and columns symmetrically
  if ( symm.cluster && (nrow(clean.data) == ncol(clean.data)) ) {
    if (all(rownames(clean.data) %in% colnames(clean.data))) {
      m.idx <- match(rownames(clean.data),colnames(clean.data))
      clean.data <- clean.data[,m.idx]
      col.cluster <- row.cluster
      col.cluster.results <- row.cluster.results      
    }
  }
  
  # Plot heat map
  if (scale == "none") {
    heatmap.2( clean.data,
               Rowv = row.cluster, 
               Colv = col.cluster,
               dendrogram=show.dendro,
               hclustfun = function(x) hclust(x,method=clust.method[1]),
               cexRow = 0.25,
               cexCol = 0.8,
               scale=scale,
               margins = c(9,9),
               #col = cm.colors(256),
               #col = gray( seq(0,1,length.out=(length(breaks.vals)-1)) ),
               #col = heat.colors(length(breaks.vals)-1),
               col = all.colors,
               breaks = breaks.vals,
               density.info="none",
               trace="none",
               keysize=0.8,
               colsep=col.sep,
               rowsep=row.sep,
               sepcolor="grey",
               sepwidth=c(0.01,0.01),
               na.color="white",
               xlab=col.title,
               ylab=row.title,
               labRow=lab.row,
               labCol=lab.col,   
               main=title.name,
               las = 2)
  } else {
    heatmap.2( clean.data,
               Rowv = row.cluster, 
               Colv = col.cluster,
               dendrogram=show.dendro,   
               hclustfun = function(x) hclust(x,method=clust.method[1]),
               cexRow = cex.val,
               cexCol = cex.val,
               scale=scale,
               margins = c(9,9),
               #col = cm.colors(256),
               #col = gray( seq(0,1,length.out=(length(breaks.vals)-1)) ),
               #col = heat.colors(length(breaks.vals)-1),
               col = all.colors,             
               density.info="none",
               trace="none",
               keysize=0.8,
               colsep=col.sep,
               rowsep=row.sep,
               sepcolor="grey",
               sepwidth=c(0.01,0.01),
               na.color="white",
               xlab=col.title,
               ylab=row.title,
               labRow=lab.row,
               labCol=lab.col,   
               main=title.name,
               las = 2)
    
  }
  
  if (!is.null(to.file)) { dev.off() }
  
  invisible(list(row.cluster=row.cluster.results,
                 col.cluster=col.cluster.results,
                 clustered.data=clean.data))
}

args <- commandArgs(trailingOnly=TRUE)
directory = args[1]
ordNumDirectory = paste(directory,"/orderedMatricesNumbers",sep="")
setwd(ordNumDirectory)
files <- list.files(path=ordNumDirectory, full.names = FALSE)

for (fileName in files) {
    setwd(ordNumDirectory)
    
    title = ""
    name=""
    if (fileName=="H3K27ac_all_numbers.txt"){title="H3K27ac All Sites"
                                             name ="H3K27ac_all.pdf"}
    else if (fileName=="H3K4me1_all_numbers.txt"){title="H3K4me1 All Sites"
                                                  name="H3K4me1_all.pdf"}
    else if (fileName=="H3K4me3_all_numbers.txt"){title="H3K4me3 All Sites"
                                                  name="H3K4me3_all.pdf"}
    else if (fileName=="HDAC2_all_numbers.txt"){title="HDAC2 All Sites"
                                                name="HDAC2_all.pdf"}
    else if (fileName=="H3K27ac_dhs_numbers.txt"){title="H3K27ac DHS Sites"
                                                  name="H3K27ac_dhs.pdf"}
    else if (fileName=="H3K4me1_dhs_numbers.txt"){title="H3K4me1 DHS Sites"
                                                  name="H3K4me1_dhs.pdf"}
    else if (fileName=="H3K4me3_dhs_numbers.txt"){title="H3K4me3 DHS Sites"
                                                  name="H3K4me3_dhs.pdf"}
    else if (fileName=="HDAC2_dhs_numbers.txt"){title="HDAC2 DHS Sites"
                                                name="HDAC2_dhs.pdf"}

    tempFrame <- read.table(fileName, header=FALSE, sep="\t")
    temp <-data.matrix(tempFrame, rownames.force = NA)
  
    motifDirectory = paste(directory,"/labels","/motif",sep="")
    runDirectory = paste(directory,"/labels","/run",sep="")
    heatmapDirectory = paste(directory,"/heatmaps",sep="")
    
    setwd(motifDirectory)
    motifLabel<- read.table(fileName, header=TRUE, sep="\t")
    
    setwd(runDirectory)
    runLabel<-read.table(fileName,header=TRUE, sep="\t")
    
    setwd(heatmapDirectory)
    plot.heatmap(temp, 
                 to.file=name, 
                 row.title="Motifs",
                 col.title="Run",
                 filt.thresh=1,
                 pseudo.count=0,
                 replace.diag=F,
                 clust.method=c("ward","ward"),
                 row.optimal.order=T,
                 col.optimal.order=T, 
                 row.lab=motifLabel$names,
                 col.lab=runLabel$names)

}