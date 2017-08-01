library(ggplot2)
library(gtools)
library(dplyr)
library(MASS)

args = commandArgs(trailingOnly=TRUE)


topics <- args[1]
col <- args[2]
model <- args[3]
param <- args[4]
#metric <- "ndcg_cut_20"
metric <- args[5]

#rm3.combined.short.map.out

cat(paste(topics, col, model, param, metric))
loocv <- read.table(paste("../../loocv/", model, ".", col, ".", topics, ".",  metric, ".out", sep=""), header=F)
colnames(loocv) <- c("query", "params", "ndcg.model")

# Read file containing NDCG for each level of alpha
paramvals <- read.csv(paste("../characterize/",  model, ".", param, ".", metric, ".out", sep=""), header=F)
colnames(paramvals) <- c("param", "query", "ndcg")
#paramvals <- paramvals %>% group_by(query) %>% top_n(1, ndcg)
paramvals <- paramvals %>% group_by(query) %>% filter(ndcg == max(ndcg)) %>%  filter(1:n() == 1)

print(paramvals)

# Read qpp
qpp <- read.csv("../../qpp/predictors.csv", header=T)

# Merge predictors with response
qpp <- merge(paramvals, qpp, by=c("query"))

# Dump the correlation table
cat(sprintf("\n\nCorrelation table\n"))
cor(qpp[,-1])




#lm <- lm(param ~ drift + varSCQ + deviation, qpp)
#lm <- step(lm, direction="forward")
#summary(lm)


reg_analysis <- function(formula) {
    cat (sprintf("Regression analysis of %s\n", formula))
    mod <- lm(as.formula(formula), qpp)
    sum <-summary(mod)
#    bc <- boxcox(as.formula(formula), data=qpp,  plotit=F)
#    cat(sprintf("Coefficients:  %0.4f %0.4f p=%0.4f, R^2=%0.4f \n", lm$coefficients[1,1], lm$coefficients[2,1], lm$coefficients[2,4], lm$adj.r.squared))
#    cat(sprintf("\tBoxcox: %0.2f\n", bc$x[which(bc$y == max(bc$y))]))

    len <- length(residuals(mod))
    var <- summary(lm(abs(residuals(mod)) ~ fitted(mod)))
    cat(sprintf("\tConstant variance R^2: %0.4f\n", var$adj.r.squared))
    res <- summary(lm(residuals(mod)[-1] ~ residuals(mod)[-len]))
    cat(sprintf("\tResidual correlation R^2: %0.4f\n", res$adj.r.squared))
    f <- summary(mod)$fstatistic
    p <- pf(f[1],f[2],f[3],lower.tail=F)
    cat(sprintf("\tModel R^2: %0.4f\n", summary(mod)$r.squared))
    cat(sprintf("\tModel p-value %0.4f\n", p))
}

cat(sprintf("\n\nSingle-predictor models:\n\n"))
for (name in colnames(qpp)) {
    if ( name != "query" && name != "ndcg" && name != "param") {
      lm <- lm(paste("param ~ ", name), qpp)
      f <- summary(lm)$fstatistic
      # http://www.gettinggeneticsdone.com/2011/01/rstats-function-for-extracting-f-test-p.html
      p <- pf(f[1],f[2],f[3],lower.tail=F)
      if (p < 0.01) {
          reg_analysis(paste("param ~ ", name))
#         print (summary(lm))
      }
    }
}

cat("\n\nTwo-predictor models:\n\n")
reg_analysis("param^(1/2) ~ drift + varSCQ") 
reg_analysis("param^(1/2) ~ drift + deviation") 
reg_analysis("param^(1/2)  ~ varSCQ + deviation") 


cat("\n\nPredicting for held-out query:\n\n")
for (query in qpp$query) {
  lm <- lm(param ~ varSCQ + deviation, qpp[qpp$query != query,])
  new <- data.frame(qpp[qpp$query == query,])
  cat(sprintf("\t%s %0.1f\n", query, round(predict.lm(lm, new), 1)))
  #print (paste(query, "," , lm$coefficients))
}
