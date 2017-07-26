#!/bin/bash

if [ -z "$1" ]; then
   echo "./rocchio.sh <topics> <collection>"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./rocchio.sh <topics> <collection>"
   exit 1;
fi
col=$2

base=/data/biocaddie
mkdir -p lucene-output/rocchio/$col/$topics

for b in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
do
   for k1 in 1.0 1.2 1.5 1.7 2.0
   do
      for fbTerms in 5 10 20 50 
      do 
         for fbDocs in 5 10 20 50
         do
            for beta in  0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
            do
                echo "scripts/run.sh edu.gslis.lucene.main.LuceneRunQuery -index $base/lucene/biocaddie_all/shard0/ -queryfile queries/queries.$col.$topics  -format indri -field text -similarity method:bm25,k1:$k1,b:$b -fbDocs=$fbDocs -fbTerms=$fbTerms -alpha=1 -beta=$beta > lucene-output/rocchio/$col/$topics/k1=$k1:b=$b:fbTerms=$fbTerms:fbDocs=$fbDocs:beta=$beta.out"
            done
         done
      done
   done
done
