#!/bin/bash

mkdir -p /shared/ohsumed/queries
rm -f /shared/ohsumed/queries/queries.combined.orig

echo -e "<parameters>" >> /shared/ohsumed/queries/queries.combined.orig

find /shared/ohsumed/queries/ -type f -name 'query.ohsu.*' | while read file
do
    egrep -A 1 "<num> Number:|<desc> Description:" $file | egrep -v "<desc> Description:|<title>" > tmp.txt
    cat tmp.txt | while read line
    do
	if  echo $line | grep -q "<num> Number:"
        then
            docno=`echo $line | cut -d ":" -f 2 | tr -d " "`
            echo -e "<query>\n\t<number>$docno</number>" >> /shared/ohsumed/queries/queries.combined.orig
        elif echo $line | grep -q "^--$"
        then
            #do nothing
	    :
	else
	    echo -e "\t<text>`echo $line|sed -e 's/[,!.;?:]//g'`</text>\n</query>" >> /shared/ohsumed/queries/queries.combined.orig
        fi  
    done
done    

echo -e "</parameters>" >> /shared/ohsumed/queries/queries.combined.orig
