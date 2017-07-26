#!/bin/bash

if [ -z "$1" ]; then
   echo "./rm3.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./rm3.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
subset=$2

if [ -z "$3" ]; then
   echo "./rm3.sh <topics> <subset> <collection> <year>  --optional year parameter"
   exit 1;
fi
col=$3

base=/data/$col

if [ -z "$4" ]; then
    mkdir -p $base/output/rm3/$subset/$topics
    for mu in 50 250 500 1000 2500 5000 10000
    do
   	for fbTerms in 5 10 20 50 
   	do 
      	    for fbDocs in 5 10 20 50
      	    do
         	for fbOrigWeight in  0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
         	do
             	    echo "IndriRunQuery -index=$base/indexes/${col}_all/ -trecFormat=true -rule=method:dir,mu:$mu -fbDocs=$fbDocs -fbTerms=$fbTerms -fbOrigWeight=$fbOrigWeight $base/queries/queries.$subset.$topics > $base/output/rm3/$subset/$topics/mu=$mu:fbTerms=$fbTerms:fbDocs=$fbDocs:fbOrigWeight=$fbOrigWeight.out"
         	done
      	    done
   	done
    done
else
    year=$4
    mkdir -p $base/output/$year/rm3/$subset/$topics
    for mu in 50 250 500 1000 2500 5000 10000
    do
        for fbTerms in 5 10 20 50
        do
            for fbDocs in 5 10 20 50
            do
                for fbOrigWeight in  0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
                do
                    echo "IndriRunQuery -index=$base/indexes/${col}${year}_all/ -trecFormat=true -rule=method:dir,mu:$mu -fbDocs=$fbDocs -fbTerms=$fbTerms -fbOrigWeight=$fbOrigWeight $base/queries/queries.$subset.$topics.$year > $base/output/$year/rm3/$subset/$topics/mu=$mu:fbTerms=$fbTerms:fbDocs=$fbDocs:fbOrigWeight=$fbOrigWeight.out"
                done
            done
        done
    done
fi
