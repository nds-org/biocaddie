#!/bin/bash

mkdir -p /shared/trecgenomics/queries
rm -f /shared/trecgenomics/queries/queries.combined.orig

topic_number=200

echo -e "<parameters>" >> /shared/trecgenomics/queries/queries.combined.orig

#create queries file in trec format
grep "<[0-9]*>" /shared/trecgenomics/queries/2007topics.txt | sed -e 's/\[//g' -e 's/\]//g' -e "s/[?.']//g" -e 's/<[0-9]*>//g'| while read text
do
    echo -e "<query>\n\t<number>$topic_number</number>" >> /shared/trecgenomics/queries/queries.combined.orig
    echo -e "\t<text>$text</text>\n</query>" >> /shared/trecgenomics/queries/queries.combined.orig
    topic_number=`expr $topic_number + 1`
done

echo -e "</parameters>" >> /shared/trecgenomics/queries/queries.combined.orig
