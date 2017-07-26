#!/bin/bash

if [ -z "$1" ]; then
   echo "./jm.sh <topics> <collection>"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./jm.sh <topics> <collection>"
   exit 1;
fi
col=$2

base=/data/biocaddie
mkdir -p output-lucene/jm/$col/$topics
for lambda in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 
do
   echo "scripts/run.sh edu.gslis.lucene.main.LuceneRunQuery -index $base/lucene/biocaddie_all.6.6.0/shard0/ -queryfile queries/queries.$col.$topics  -format indri -field text -similarity method:jm,lambda:$lambda > output-lucene/jm/$col/$topics/lambda=$lambda.out"
done
