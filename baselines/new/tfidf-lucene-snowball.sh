#!/bin/bash

if [ -z "$1" ]; then
   echo "./tfidf-lucene-snowball.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./tfidf-lucene-snowball.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
subset=$2

if [ -z "$3" ]; then
   echo "./tfidf-lucene-snowball.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
col=$3

base=/data/$col

if [ -z "$4" ]; then
    mkdir -p $base/lucene-output/tfidf-snowball/$subset/$topics
    echo "scripts/run.sh edu.gslis.lucene.main.LuceneRunQuery -index $base/lucene/${col}_all.snowball/shard0/ -queryfile $base/queries/queries.$subset.$topics  -format indri -field text -similarity method:tfidf > $base/lucene-output/tfidf-snowball/$subset/$topics/tfidf.out"
else
    year=$4
    mkdir -p $base/lucene-output/$year/tfidf-snowball/$subset/$topics
    echo "scripts/run.sh edu.gslis.lucene.main.LuceneRunQuery -index $base/lucene/${col}${year}_all.snowball/shard0/ -queryfile $base/queries/queries.$subset.$topics.$year  -format indri -field text -similarity method:tfidf > $base/lucene-output/$year/tfidf-snowball/$subset/$topics/tfidf.out"
fi
