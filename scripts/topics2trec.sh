#!/bin/bash

if [ -z "$1" ]; then
   echo "./topics2trec.sh <year>"
   exit 1;
fi
year=$1

mkdir -p /shared/treccds/queries/$year
rm -f /shared/treccds/queries/$year/queries$year.combined.orig

topic_number=1

#create queries file in trec format
grep "<summary>" /shared/treccds/topics/$year/topics$year.xml | sed -e 's/summary>/text>/g'| while read text
do
    echo -e "<query>\n\t<number>$topic_number</number>" >> /shared/treccds/queries/$year/queries$year.combined.orig
    echo -e "\t$text\n</query>" >> /shared/treccds/queries/$year/queries$year.combined.orig
    topic_number=`expr $topic_number + 1`
done
