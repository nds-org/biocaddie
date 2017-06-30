#!/bin/bash

if [ -z "$1" ]; then
   echo "./okapi.sh <topics> <collection>"
   exit 1;
fi
topics=$1

if [ -z "$2" ]; then
   echo "./okapi.sh <topics> <collection>"
   exit 1;
fi
col=$2

QUEUE_NAME="okapi-$col-$topics"

# NOTE: These are paths internal to the container
base=/data/biocaddie
src_base=/root/biocaddie
for b in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 
do
   for k1 in 1.0 1.2 1.5 1.7 2.0
   do 
      for k3 in 1.0 1.2 1.5 1.7 2.0
      do 
         redis-cli -h ${REDIS_SERVICE_HOST:-localhost} rpush "${QUEUE_NAME}" "IndriRunQuery -index=$base/indexes/biocaddie_all/ -trecFormat=true -baseline=okapi,k1:$k1,k3:$k3,b:$b queries/queries.$col.$topics > output/okapi/$col/$topics/k1=$k1:k3=$k3:b=$b.out"
      done
   done
done


# Then start a worker job to execute
cat kubernetes/worker.yaml \
          | sed -e "s#{{[ ]*name[ ]*}}#${QUEUE_NAME}#g" \
          | kubectl create -f -


echo 'Job started - to run multiple workers for this Job in parallel, use "kubectl scale"'
