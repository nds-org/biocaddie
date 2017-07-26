#!/bin/bash

if [ -z "$1" ]; then
   echo "./rm3-krovetz.sh <topics> <collection>"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./rm3-krovetz.sh <topics> <collection>"
   exit 1;
fi
col=$2

QUEUE_NAME="rm3-krovetz-$col-$topics"

# NOTE: These are paths internal to the container
base=/data/biocaddie
src_base=/root/biocaddie
for mu in 50 250 500 1000 2500 5000 10000
do
   for fbTerms in 5 10 20 50
   do
      for fbDocs in 5 10 20 50
      do
         for fbOrigWeight in  0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
         do
             redis-cli -h ${REDIS_SERVICE_HOST:-localhost} rpush "${QUEUE_NAME}" "IndriRunQuery -index=$base/indexes/biocaddie_all.krovetz/ -trecFormat=true -rule=method:dir,mu:$mu -fbDocs=$fbDocs -fbTerms=$fbTerms -fbOrigWeight=$fbOrigWeight $base/queries/queries.$col.$topics > output/rm3-krovetz/$col/$topics/mu=$mu:fbTerms=$fbTerms:fbDocs=$fbDocs:fbOrigWeight=$fbOrigWeight.out"
         done
      done
   done
done


# Then start a worker job to execute
cat kubernetes/worker.yaml \
          | sed -e "s#{{[ ]*name[ ]*}}#${QUEUE_NAME}#g" \
          | kubectl create -f -


echo 'Job started - to run multiple workers for this Job in parallel, use "kubectl scale"'
