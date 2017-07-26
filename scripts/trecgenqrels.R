#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

options(digits=4)

#the original qrel file of TREC Genomics contains duplicate judgements for a document for same query.
#read qrel file and load into dataframe - qrelsData
qrelsData <- read.table("/shared/trecgenomics/qrels/trecgenomics-qrels-2006.txt", header=F,col.names=c("query", "ID", "docno", "relno"),sep="\t")

#for each query and document, sum up the relno, if relno >=2, assign relno to 2.
nondup_qrelsData <- aggregate(relno~query*ID*docno,data=qrelsData,FUN=sum)
nondup_qrelsData$relno[nondup_qrelsData$relno>=2]=2
nondup_qrelsData=nondup_qrelsData[order(nondup_qrelsData$query,nondup_qrelsData$docno),]
write.table(nondup_qrelsData,"/shared/trecgenomics/qrels/trecgenomics-qrels-nondup-2006.txt",sep="\t",row.names=FALSE, col.names=FALSE) 
