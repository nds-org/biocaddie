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

for (metric in c("map", "ndcg",  "P_20", "ndcg_cut_20", "P_100", "ndcg_cut_100")) {
    fromFile <- paste(from, subset, topics, metric, "out", sep=".")
    toFile <- paste(to, subset, topics, metric, "out", sep=".")

    fromData <- read.table(fromFile, header=F)
    toData <- read.table(toFile, header=F)
    fromData <- fromData[order(fromData$V1),]
    toData <- toData[order(toData$V1),]

    t <- t.test(fromData$V3, toData$V3, paired=T, alternative="less")
    print(paste(metric, round(mean(fromData$V3), 4), round(mean(toData$V3), 4), "p=", round(t$p.value, 4)))
}
