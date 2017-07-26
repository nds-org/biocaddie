#!/bin/bash
#
# Usage: ./run_all.sh [model] [topics] [collection]
#
MODELS="dir jm okapi rm3 tfidf two"
TOPICS="short orig stopped"
COLLECTIONS="combined train test"

# If no model specified, run all models
models=$1
if [ -z "$models" ]; then
   models="$MODELS"
elif [ "${MODELS/$models/ }" == "$MODELS" ]; then
   echo "./run_all.sh [model] [topics] [collection]"
   echo "model must be one of: $MODELS"
   exit 1
fi

# If no topics specified, run all topics
topics=$2
if [ -z "$topics" ]; then
   topics="$TOPICS"
elif [ "${TOPICS/$topics/ }" == "$TOPICS" ]; then
   echo "./run_all.sh [model] [topics] [collection]"
   echo "topics must be one of: $TOPICS"
   exit 1
fi

# If no collection specified, run all collections
collections=$3
if [ -z "$collections" ]; then
   collections="$COLLECTIONS"
elif [ "${COLLECTIONS/$collections/ }" == "$COLLECTIONS" ]; then
   echo "./run_all.sh [models] [topics] [collections]"
   echo "collection must be one of: $COLLECTIONS"
   exit 1
fi

# NOTE: These paths are external to the container
base=/data/biocaddie
for model in $models
do
   for col in $collections
   do
      for topic in $topics
      do
         kubernetes/$model.sh $topic $col 
      done
   done
done
