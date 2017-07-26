#!/bin/bash

if [ -z "$1" ]; then
   echo "./dir-lucene-snowball.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./dir-lucene-snowball.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
subset=$2

if [ -z "$3" ]; then
   echo "./dir-lucene-snowball.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
col=$3

base=/data/$col

if [ -z "$4" ]; then
   mkdir -p $base/lucene-output/dir-snowball/$subset/$topics
   for mu in 50 250 500 1000 2500 5000 10000
   do
	echo "scripts/run.sh edu.gslis.lucene.main.LuceneRunQuery -index $base/lucene/${col}_all.snowball/shard0/ -queryfile $base/queries/queries.$subset.$topics  -format indri -field text -similarity method:dir,mu:$mu > $base/lucene-output/dir-snowball/$subset/$topics/$mu.out"
   done
else
   year=$4
   mkdir -p $base/lucene-output/$year/dir-snowball/$subset/$topics
   for mu in 50 250 500 1000 2500 5000 10000
   do
	echo "scripts/run.sh edu.gslis.lucene.main.LuceneRunQuery -index $base/lucene/${col}${year}_all.snowball/shard0/ -queryfile $base/queries/queries.$subset.$topics.$year  -format indri -field text -similarity method:dir,mu:$mu > $base/lucene-output/$year/dir-snowball/$subset/$topics/$mu.out"
   done
fi
