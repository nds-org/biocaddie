#!/usr/bin/env Rscript
#install.packages('ggplot2', repos="http://cran.rstudio.com/")

args = commandArgs(trailingOnly=TRUE)

options(digits=4)
model <- args[1]
col <- args[2]
topic <- args[3]

library(ggplot2)

filename=paste("stats",model,col,topic,"*.csv",sep=".")
files <- list.files(path="./stats",pattern=filename, full.names=TRUE)
stats_df=data.frame()
for (i in seq_along(files)){
	k_value=as.integer(unlist(strsplit(files[i], "[.]"))[[6]])
	tmp_df <- read.csv(files[i],header=T)
	#get average number of relevant docs, non relevant docs and unjudged docs for each query and add it to column tmp_stats$doc_query_avg
	tmp_stats <- aggregate(docno~query*rel,tmp_df,FUN=sum)
	tmp_stats$doc_query_avg <- tmp_stats$docno/length(unique(tmp_df$file))
	#add k_value into tmp_stats as column tmp_stats$k
        tmp_stats$k <- rep(k_value,length(tmp_stats$query))

	#plot graph to show the distribution of judged/non-judged docs in each query for each k for each model
	plot_filename=paste(model,col,topic,k_value,"png",sep=".")
	plot_filename_full=paste("./plot",plot_filename,sep="/")
	ggplot(tmp_stats, aes(query, doc_query_avg, fill = rel)) + geom_bar(stat="identity", position = "dodge") + ggtitle(plot_filename)
	ggsave(plot_filename_full)
	#print(tmp_stats[order(tmp_stats$query,tmp_stats$rel),])		
	stats_df <- rbind(tmp_stats,stats_df)
}

stats_final=aggregate(doc_query_avg~rel*k,stats_df,FUN=sum)
stats_final$avg=stats_final$doc_query_avg/length(unique(stats_df$query))
#plot graph to show distribution of judged/non-judged docs vs. k value for each model
plot_filename=paste(model,col,topic,"all","png",sep=".")
plot_filename_full=paste("./plot",plot_filename,sep="/")
ggplot(stats_final, aes(k, avg, fill = rel)) + geom_bar(stat="identity", position = "dodge") + ggtitle(plot_filename)
ggsave(plot_filename_full)
