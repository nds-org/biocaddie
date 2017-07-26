#!/bin/bash

if [ -z "$1" ]; then
   echo "./dir.sh <topics> <collection>"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./dir.sh <topics> <collection>"
   exit 1;
fi
col=$2

base=/data/biocaddie/
mkdir -p output-lucene/dir/$col/$topics
for mu in 50 250 500 1000 2500 5000 10000
do
   echo "scripts/run.sh edu.gslis.lucene.main.LuceneRunQuery -index $base/lucene/biocaddie_all.6.6.0/shard0/ -queryfile queries/queries.$col.$topics  -format indri -field text -similarity method:dir,mu:$mu > output-lucene/dir/$col/$topics/$mu.out"
done
