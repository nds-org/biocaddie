#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
setwd("./qrels")

options(digits=1)
col <- args[1]

qrelsFile <- paste("biocaddie.qrels", col, sep=".")
qrelsData <- read.table(qrelsFile, header=F,col.names=c("Query", "ID", "Docno", "RelNo"),sep="\t")
qrelsData$Rel=rep("No",length(qrelsData$RelNo))
qrelsData$Rel[qrelsData$RelNo>0]="Yes"

qrels_stats <- aggregate(Docno ~ Rel*Query , data = qrelsData, length)
colnames(qrels_stats) <- c("Rel","Query","Doccount")
qrels_stats 

