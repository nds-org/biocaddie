#!/bin/bash

if [ -z "$1" ]; then
   echo "./jm-lucene-snowball.sh <topics> <subset> <collection> <year> --optional year parameter"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./jm-lucene-snowball.sh <topics> <subset> <collection> <year> --optional year parameter"
   exit 1;
fi
subset=$2

if [ -z "$3" ]; then
   echo "./jm-lucene-snowball.sh <topics> <subset> <collection> <year> --optional year parameter"
   exit 1;
fi
col=$3

base=/data/$col

if [ -z "$4" ]; then
   mkdir -p $base/lucene-output/jm-snowball/$subset/$topics
   for lambda in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
   do   
	echo "scripts/run.sh edu.gslis.lucene.main.LuceneRunQuery -index $base/lucene/${col}_all.snowball/shard0/ -queryfile $base/queries/queries.$subset.$topics  -format indri -field text -similarity method:jm,lambda:$lambda > $base/lucene-output/jm-snowball/$subset/$topics/lambda=$lambda.out"
   done
else
   year=$4
   mkdir -p $base/lucene-output/$year/jm-snowball/$col/$topics
   for lambda in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
   do
	echo "scripts/run.sh edu.gslis.lucene.main.LuceneRunQuery -index $base/lucene/${col}${year}_all.snowball/shard0/ -queryfile $base/queries/queries.$subset.$topics.$year  -format indri -field text -similarity method:jm,lambda:$lambda > $base/lucene-output/$year/jm-snowball/$subset/$topics/lambda=$lambda.out"
   done
fi
