#!/bin/bash

if [ -z "$1" ]; then
   echo "./okapi.sh <topics> <collection> <year>"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./okapi.sh <topics> <collection> <year>"
   exit 1;
fi
col=$2

if [ -z "$3" ]; then
   echo "./okapi.sh <topics> <collection> <year>"
   exit 1;
fi
year=$3


base=/data/treccds
mkdir -p $base/output/$year/okapi/$col/$topics
for b in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 
do
   for k1 in 1.0 1.2 1.5 1.7 2.0
   do 
      for k3 in 1.0 1.2 1.5 1.7 2.0
      do 
         echo "IndriRunQuery -index=$base/indexes/treccds${year}_all/ -trecFormat=true -baseline=okapi,k1:$k1,k3:$k3,b:$b $base/queries/$year/queries.$col.$topics > $base/output/$year/okapi/$col/$topics/k1=$k1:k3=$k3:b=$b.out"
      done
   done
done

