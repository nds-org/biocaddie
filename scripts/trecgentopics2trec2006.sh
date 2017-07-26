#!/bin/bash

mkdir -p /shared/trecgenomics/queries
rm -f /shared/trecgenomics/queries/queries.combined.orig.2006

topic_number=160

echo -e "<parameters>" >> /shared/trecgenomics/queries/queries.combined.orig.2006

#create queries file in trec format
cat /shared/trecgenomics/queries/2006topics.txt | sed -e 's/\[//g' -e 's/\]//g' -e "s/[?.'()-]//g" -e 's/<[0-9]*>//g'| while read text
do
    echo -e "<query>\n\t<number>$topic_number</number>" >> /shared/trecgenomics/queries/queries.combined.orig.2006
    echo -e "\t<text>$text</text>\n</query>" >> /shared/trecgenomics/queries/queries.combined.orig.2006
    topic_number=`expr $topic_number + 1`
done

echo -e "</parameters>" >> /shared/trecgenomics/queries/queries.combined.orig.2006
