#!/bin/bash

if [ -z "$1" ]; then
   echo "./runqueries-lucene.sh <topics> <collection>"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./runqueries-lucene.sh <topics> <collection>"
   exit 1;
fi
col=$2

base=/data/biocaddie

mkdir -p lucene-output/pubmed-rocchio/$col/$topics
find queries/pubmed-rocchio/$col/$topics -type f | while read file
do
   for b in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
   do
      for k1 in 0.2 0.4 0.6 0.8 1.0 1.2 1.5 1.7 2.0
      do
           fileName=`basename $file`

           echo "scripts/run.sh edu.gslis.lucene.main.LuceneRunQuery -index /data/biocaddie/lucene/biocaddie_all/shard0/ -queryfile $file -format json -field text -similarity method:bm25,k1:$k1,b:$b  > lucene-output/pubmed-rocchio/$col/$topics/$fileName,k1:$k1,b:$b"
       done
   done
done


# pubmed/runqueries.sh short combined | parallel -j 10 bash -c "{}"
