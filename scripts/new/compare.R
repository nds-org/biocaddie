#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

options(digits=4)
subset <- args[1]
from <- args[2]
to <- args[3]
topics <- args[4]
col <- args[5]

filePath <- paste("/data",col,"loocv",sep="/")

#if year argument is available, update path for loocv
if(length(args)==6){
    year=args[6]
    filePath <- paste(filePath,year,sep="/")
}

setwd(filePath)

cat("Please enter run methods for comparison:\n\t0: both are Indri\n\t1: both are Lucene\n\t2: from is Indri, to is Lucene\n\t3: from is Lucene, to is Indri\n")
run <- readLines("stdin",n=1);
run <- as.integer(run)

for (metric in c("map", "ndcg",  "P_20", "ndcg_cut_20", "P_100", "ndcg_cut_100")) {
    fromFile <- paste(from, subset, topics, metric, "indri.out", sep=".")
    toFile <- paste(to, subset, topics, metric, "indri.out", sep=".")
    if (as.integer(run)==1 | as.integer(run)==3){
    	fromFile <- paste(from, subset, topics, metric, "lucene.out", sep=".")
    }
    if (as.integer(run)==1 | as.integer(run)==2){
        toFile <- paste(to, subset, topics, metric, "lucene.out", sep=".")
    }
    fromData <- read.table(fromFile, header=F)
    toData <- read.table(toFile, header=F)
    fromData <- fromData[order(fromData$V1),]
    toData <- toData[order(toData$V1),]
    t <- t.test(fromData$V3, toData$V3, paired=T, alternative="less")
    print(paste(metric, round(mean(fromData$V3), 4), round(mean(toData$V3), 4), "p=", round(t$p.value, 4)))
}
