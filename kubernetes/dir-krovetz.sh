#!/bin/bash

if [ -z "$1" ]; then
   echo "./dir.sh <topics> <collection>"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./dir.sh <topics> <collection>"
   exit 1;
fi
col=$2

QUEUE_NAME="dir-krovetz-$col-$topics"

# NOTE: These are paths internal to the container
base=/data/biocaddie
for mu in 50 250 500 1000 2500 5000 10000
do
   redis-cli -h ${REDIS_SERVICE_HOST:-localhost} rpush "${QUEUE_NAME}" "IndriRunQuery -index=$base/indexes/biocaddie_all.krovetz/ -trecFormat=true -rule=method:dir,mu:$mu queries/queries.$col.$topics > output/dir-krovetz/$col/$topics/$mu.out"
done



# Then start a worker job to execute
cat kubernetes/worker.yaml \
          | sed -e "s#{{[ ]*name[ ]*}}#${QUEUE_NAME}#g" \
          | kubectl create -f -


echo 'Job started - to run multiple workers for this Job in parallel, use "kubectl scale"'
