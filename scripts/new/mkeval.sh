#!/bin/bash

if [ -z "$1" ]; then
   echo "./mkeval.sh <model> <topics> <subset> <collection> <year>  -- optional year parameter"
   exit 1;
fi
model=$1

if [ -z "$2" ]; then
   echo "./mkeval.sh <model> <topics> <subset> <collection> <year>  -- optional year parameter"
   exit 1;
fi
topics=$2

if [ -z "$3" ]; then
   echo "./mkeval.sh <model> <topics> <subset> <collection> <year>  -- optional year parameter"
   exit 1;
fi
subset=$3

if [ -z "$4" ]; then
   echo "./mkeval.sh <model> <topics> <collection> <year>  -- optional year parameter"
   exit 1;
fi
col=$4

if [ -z "$5" ]; then
    qrels=/data/$col/qrels/$col.qrels.$subset

    # Calculate metrics using trec_eval
    for file in `find /data/$col/output/$model/$subset/$topics -type f -size +0`;
    do
    	basename=`basename $file .out`;
    	mkdir -p /data/$col/eval/$model/$subset/$topics
    	trec_eval -c -q -m all_trec $qrels $file > /data/$col/eval/$model/$subset/$topics/$basename.eval;
    done

    # Leave on query out cross-validation
    mkdir -p /data/$col/loocv
    for metric in map ndcg ndcg_cut_5 ndcg_cut_10 ndcg_cut_20 ndcg_cut_100 P_5 P_10 P_20 P_100
    do
    	scripts/run.sh edu.gslis.biocaddie.util.CrossValidation -input /data/$col/eval/$model/$subset/$topics -metric $metric -output /data/$col/loocv/$model.$subset.$topics.$metric.indri.out
    done
else
    year=$5
    qrels=/data/$col/qrels/$col.qrels.$subset.$year

    # Calculate metrics using trec_eval
    for file in `find /data/$col/output/$year/$model/$subset/$topics -type f -size +0`;
    do
        basename=`basename $file .out`;
        mkdir -p /data/$col/eval/$year/$model/$subset/$topics
        trec_eval -c -q -m all_trec $qrels $file > /data/$col/eval/$year/$model/$subset/$topics/$basename.eval;
    done

    # Leave on query out cross-validation
    mkdir -p /data/$col/loocv/$year
    for metric in map ndcg ndcg_cut_5 ndcg_cut_10 ndcg_cut_20 ndcg_cut_100 P_5 P_10 P_20 P_100
    do
        scripts/run.sh edu.gslis.biocaddie.util.CrossValidation -input /data/$col/eval/$year/$model/$subset/$topics -metric $metric -output /data/$col/loocv/$year/$model.$subset.$topics.$metric.indri.out
    done
fi
