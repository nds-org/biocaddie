#!/bin/bash

if [ -z "$1" ]; then
   echo "./two.sh <topics> <collection>"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./two.sh <topics> <collection>"
   exit 1;
fi
col=$2

QUEUE_NAME="two-$col-$topics"

# NOTE: These are paths internal to the container
base=/data/biocaddie
src_base=/rot/biocaddie
for mu in 50 250 500 1000 2500 5000 10000
do
   for lambda in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
   do
    redis-cli -h ${REDIS_SERVICE_HOST:-localhost} rpush "${QUEUE_NAME}" "IndriRunQuery -index=$base/indexes/biocaddie_all/ -trecFormat=true -rule=method:two,mu:$mu,lambda:$lambda queries/queries.$col.$topics > output/two/$col/$topics/mu=$mu:lambda=$lambda.out"
   done
done


# Then start a worker job to execute
cat kubernetes/worker.yaml \
          | sed -e "s#{{[ ]*name[ ]*}}#${QUEUE_NAME}#g" \
          | kubectl create -f -


echo 'Job started - to run multiple workers for this Job in parallel, use "kubectl scale"'
