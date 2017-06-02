#!/bin/bash

# Generate PDF and PNG plots for visual comparison
Rscript plot.R short combined dir mu ndcg
Rscript plot.R short combined rm3 fbOrigWeight ndcg
Rscript plot.R short combined pubmed fbOrigWeight ndcg
Rscript plot.R short combined wikipedia fbOrigWeight ndcg

Rscript plot.R short combined dir mu ndcg_cut_20
Rscript plot.R short combined rm3 fbOrigWeight ndcg_cut_20
Rscript plot.R short combined pubmed fbOrigWeight ndcg_cut_20
Rscript plot.R short combined wikipedia fbOrigWeight ndcg_cut_20
