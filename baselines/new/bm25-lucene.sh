#!/bin/bash

if [ -z "$1" ]; then
   echo "./bm25-lucene.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./bm25-lucene.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
subset=$2

if [ -z "$3" ]; then
   echo "./bm25-lucene.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
col=$3

base=/data/$col

if [ -z "$4" ]; then
    mkdir -p $base/lucene-output/bm25/$subset/$topics
    for b in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
    do
        for k1 in 0 0.2 0.5 0.7 1.0 1.2 1.5 1.7 2.0
        do
	     echo "scripts/run.sh edu.gslis.lucene.main.LuceneRunQuery -index $base/lucene/${col}_all/shard0/ -queryfile $base/queries/queries.$subset.$topics  -format indri -field text -similarity method:bm25,k1:$k1,b:$b > $base/lucene-output/bm25/$subset/$topics/k1=$k1:b=$b.out"
   	done
    done
else
    year=$4
    mkdir -p $base/lucene-output/$year/bm25/$subset/$topics
    for b in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
    do
        for k1 in 0 0.2 0.5 0.7 1.0 1.2 1.5 1.7 2.0
        do
             echo "scripts/run.sh edu.gslis.lucene.main.LuceneRunQuery -index $base/lucene/${col}${year}_all/shard0/ -queryfile $base/queries/queries.$subset.$topics.$year  -format indri -field text -similarity method:bm25,k1:$k1,b:$b > $base/lucene-output/$year/bm25/$subset/$topics/k1=$k1:b=$b.out"
        done
    done
fi
