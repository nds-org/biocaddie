library(ggplot2)
library(gtools)

args = commandArgs(trailingOnly=TRUE)
#model="rm3"
#topics="short"
#col="combined"
#metric="ndcg"
#param="fbOrigWeight"


topics <- args[1]
col <- args[2]
model <- args[3]
param <- args[4]
metric <- args[5]

#rm3.combined.short.map.out

loocv.file = paste("../../loocv/", model, ".", col, ".", topics, ".",  metric, ".out", sep="")
dir.file = paste("../../loocv/dir.", col, ".", topics, ".",  metric, ".out", sep="")
print(loocv.file)
print(dir.file)
loocv.model <- read.table(loocv.file, header=F)
loocv.dir <- read.table(dir.file, header=F)
colnames(loocv.model) <- c("query", "params", "metric.model")
colnames(loocv.dir) <- c("query", "params", "metric.dir")

loocv <- merge(loocv.model, loocv.dir, by=c("query"))
loocv$metric <- loocv.model$metric - loocv.dir$metric
loocv.model$metric.diff <- loocv.model$metric - loocv.dir$metric

# Read file containing NDCG for each level of alpha
data <- read.csv(paste(model, ".", param, ".", metric, ".out", sep=""), header=F)
colnames(data) <- c("param", "query", "metric")


# Setup barplot
tmp <- merge(data, loocv.dir, by=c("query"))
#head(tmp)
tmp$metric.diff <- tmp$metric - tmp$metric.dir
#tmp <- tmp[order(tmp$query),]

#pdf(paste(model, "-", param, ".pdf", sep=""))
#boxplot(metric.diff ~ query, data=tmp, xlab="Topics", ylab=paste("NDCG(Dir) - Mean(NDCG(", model, "))", sep=""))
#abline(h = 0)
#dev.off()
pdf(paste(model, "-", param, "-", metric,  ".pdf", sep=""))
ggplot(tmp, aes(x = factor(query), y = metric.diff))  + geom_boxplot(outlier.shape=NA) + geom_point(aes(colour = param), size=0.5)  + scale_colour_gradient(low = "darkblue", high = "red", name = param) + geom_hline(yintercept=0) + geom_point(data = loocv.model, size=0.2, colour = "green") + ylim(-1, 1) + labs(title = metric, x="Query")
#+ theme(axis.title.x=element_blank(), axis.text.x=element_blank(),  axis.ticks.x=element_blank())
#scale_colour_hue(h = c(270, 360)) 
dev.off()


png(paste(model, "-", param, "-", metric,  ".png", sep=""))
ggplot(tmp, aes(x = factor(query), y = metric.diff))  + geom_boxplot(outlier.shape=NA) + geom_point(aes(colour = param), size=0.5)  + scale_colour_gradient(low = "darkblue", high = "red", name = param) + geom_hline(yintercept=0) + geom_point(data = loocv.model, size=0.2, colour = "green") + ylim(-1, 1) + labs(title = metric, x="Query")
#+ theme(axis.title.x=element_blank(), axis.text.x=element_blank(),  axis.ticks.x=element_blank())
#scale_colour_hue(h = c(270, 360)) 
dev.off()

#ggplot(tmp, aes(x = factor(query), y = metric.diff)) + geom_boxplot(outlier.shape=NA) + geom_point(aes(colour = param), size=0.5)  + scale_colour_gradient(low = "red", high = "darkblue") + geom_hline(yintercept=0) + theme(axis.title.x=element_blank(), axis.text.x=element_blank(),  axis.ticks.x=element_blank())

