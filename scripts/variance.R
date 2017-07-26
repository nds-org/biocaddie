#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

options(digits=4)
file <- args[1]

metricData <- read.table(file, header=T,sep="\t")
var_calculation <- function(row) var(row)
metricData$variance <- apply(metricData[,-1],1,var_calculation)
metricData
