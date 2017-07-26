#!/bin/bash

#
# Generate Rocchio queries in JSON format using Lucene
#

if [ -z "$1" ]; then
   echo "./genrocchio.sh <topics> <collection>"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./genrocchio.sh <topics> <collection>"
   exit 1;
fi
col=$2

mkdir -p queries/pubmed-rocchio/$col/$topics

# Set k1 and b to reasonable defaults. We may eventually want to sweep these parameters.
k1=1.2
b=0.75
#for b in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
#for k1 in 1.0 1.2 1.5 1.7 2.0
for fbTerms in 75 100
do
#   for fbDocs in 5 10 20 50 100
   for fbDocs in 75 100
   do
      for beta in  0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
      do
          echo "scripts/run.sh edu.gslis.biocaddie.util.GetFeedbackQueriesRocchio -input queries/queries.$col.$topics -output queries/pubmed-rocchio/$col/$topics/queries.k1:$k1,b:$b,fbTerms:$fbTerms,fbDocs:$fbDocs,beta:$beta.json -index /data/pubmed/lucene/pubmed_all/shard0 -fbDocs $fbDocs -fbTerms $fbTerms -alpha 1 -beta $beta -stoplist data/stoplist.all -k1 $k1 -b $b"
      done
   done
done
