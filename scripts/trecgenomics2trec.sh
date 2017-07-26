#!/bin/bash
mkdir -p /shared/trecgenomics/data/trecText
rm -f /shared/trecgenomics/data/trecText/trecgenomics_all.txt

find /shared/trecgenomics/data/ -type f -name '*html' | while read file
do
    shortName=`basename $file .html`
    echo -e "<DOC>\n<DOCNO>$shortName</DOCNO>\n<TEXT>" >> /shared/trecgenomics/data/trecText/trecgenomics_all.txt
    sed -e 's/<[^>]*>/ /g' $file >> /shared/trecgenomics/data/trecText/trecgenomics_all.txt
    echo -e "\n</TEXT>\n</DOC>" >> /shared/trecgenomics/data/trecText/trecgenomics_all.txt
    echo -e "$file converted into trec format" >>  /shared/trecgenomics/data/trecText/trecgenomic_log.txt
done
