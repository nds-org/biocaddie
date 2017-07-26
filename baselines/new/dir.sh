#!/bin/bash

if [ -z "$1" ]; then
   echo "./dir.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./dir.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
subset=$2

if [ -z "$3" ]; then
   echo "./dir.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
col=$3

base=/data/$col

if [ -z "$4" ]; then
   mkdir -p $base/output/dir/$subset/$topics
   for mu in 50 250 500 1000 2500 5000 10000
   do
        echo "IndriRunQuery -index=$base/indexes/${col}_all/ -trecFormat=true -rule=method:dir,mu:$mu $base/queries/queries.$subset.$topics > $base/output/dir/$subset/$topics/$mu.out"
   done
else
   year=$4
   mkdir -p $base/output/$year/dir/$subset/$topics
   for mu in 50 250 500 1000 2500 5000 10000
   do
   	echo "IndriRunQuery -index=$base/indexes/${col}${year}_all/ -trecFormat=true -rule=method:dir,mu:$mu $base/queries/queries.$subset.$topics.$year > $base/output/$year/dir/$subset/$topics/$mu.out"
   done
fi
