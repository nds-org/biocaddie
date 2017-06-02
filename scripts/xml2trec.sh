#!/bin/bash
if [ -z "$1" ]; then
   echo "./xml2trec.sh <year>"
   exit 1;
fi
year=$1

mkdir -p /shared/treccds/data/$year/trecText
rm -f /shared/treccds/data/$year/trecText/treccds${year}_all.txt

find /shared/treccds/data/$year -type f -name '*xml' | while read file
do
    shortName=`basename $file | cut -d '.' -f 1`
    echo -e "<DOC>\n<DOCNO>$shortName</DOCNO>\n<TEXT>" >> /shared/treccds/data/$year/trecText/treccds${year}_all.txt
    sed -e 's/<[^>]*>/ /g' $file >> /shared/treccds/data/$year/trecText/treccds${year}_all.txt
    echo -e "\n</TEXT>\n</DOC>" >> /shared/treccds/data/$year/trecText/treccds${year}_all.txt
    echo -e "$file converted into trec format" >>  /shared/treccds/data/$year/trecText/treccds${year}_log.txt
done
