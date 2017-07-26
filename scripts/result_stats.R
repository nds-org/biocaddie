#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

options(digits=4)
model <- args[1]
col <- args[2]
topic <- args[3]
k_value <- args[4]

#read qrel file and load into dataframe - qrelsData
qrelsFile <- paste("./qrels/biocaddie.qrels", col, sep=".")
qrelsData <- read.table(qrelsFile, header=F,col.names=c("query", "ID", "docno", "relno"),sep="\t")
qrelsData$rel=rep("no",length(qrelsData$relno))
qrelsData$rel[qrelsData$relno>0]="yes"

#read output files and load top k document data into data frame - output_df
outputPath <- paste("./output",model,col,topic, sep="/")
files <- list.files(path=outputPath,pattern="*.out",full.names=TRUE)
output_df=data.frame()
for (i in seq_along(files)){
	tmp_df <- read.table(files[i],header=F,col.names=c("query","ID","docno","topk","score","indri"),sep=" ")
	tmp_df$file=rep(files[i],length(tmp_df$query))
	tmp_df <- tmp_df[which(tmp_df$topk<=as.integer(k_value)),]
	output_df <- rbind(tmp_df,output_df)
}

topdocs=merge(output_df[c("query","docno","topk","file")], qrelsData[c("query","docno","rel")], by=c("docno","query"),all.x=TRUE)
topdocs$rel[is.na(topdocs$rel)]="unjudged"
topdocs_stats=aggregate(docno ~ file*query*rel , data = topdocs, length)
topdocs_stats=topdocs_stats[order(topdocs_stats$file,topdocs_stats$query,topdocs_stats$rel),]
outputFile <-  paste("./stats/stats",model,col,topic,k_value,"csv", sep=".")
write.csv(topdocs_stats, outputFile, row.names=FALSE)
