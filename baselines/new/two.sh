#!/bin/bash

if [ -z "$1" ]; then
   echo "./two.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./two.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
subset=$2

if [ -z "$3" ]; then
   echo "./two.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
col=$3


base=/data/$col
if [ -z "$4" ]; then
    mkdir -p $base/output/two/$subset/$topics
    for mu in 50 250 500 1000 2500 5000 10000
    do
   	for lambda in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
   	do
       	    echo "IndriRunQuery -index=$base/indexes/${col}_all/ -trecFormat=true -rule=method:two,mu:$mu,lambda:$lambda $base/queries/queries.$subset.$topics > $base/output/two/$subset/$topics/mu=$mu:lambda=$lambda.out"
   	done
    done
else
    year=$4
    mkdir -p $base/output/$year/two/$subset/$topics
    for mu in 50 250 500 1000 2500 5000 10000
    do
        for lambda in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
        do
            echo "IndriRunQuery -index=$base/indexes/${col}${year}_all/ -trecFormat=true -rule=method:two,mu:$mu,lambda:$lambda $base/queries/queries.$subset.$topics.$year > $base/output/$year/two/$subset/$topics/mu=$mu:lambda=$lambda.out"
        done
    done
fi
