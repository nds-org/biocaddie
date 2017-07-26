#!/bin/bash

rm -f /shared/ohsumed/data/trecText/ohsumed_all.txt
cat /shared/ohsumed/data/ohsumed.* | while read line

do

	#check if the line include document number, add to <DOCNO> tag
        if echo $line | grep -q "^.U$"
	then
	    echo -e "<DOC>" >> /shared/ohsumed/data/trecText/ohsumed_all.txt
	elif echo $line | grep -q "^[0-9][0-9]*$"
	then
	    echo -e "<DOCNO>$line</DOCNO>\n<TEXT>" >> /shared/ohsumed/data/trecText/ohsumed_all.txt
	#check if the line include .I, close the text tag
	elif echo $line | grep -q "^.I [0-9]*$"
	then
	    echo -e "</TEXT>\n</DOC>" >> /shared/ohsumed/data/trecText/ohsumed_all.txt
	#for all other lines, add it directly to text tag
	else
	    echo "$line" >> /shared/ohsumed/data/trecText/ohsumed_all.txt
	fi 
done
#remove the first and incorrect </TEXT> and </DOC> tags
sed -i -e '1,2d' /shared/ohsumed/data/trecText/ohsumed_all.txt
#add closing tag </TEXT> and </DOC> for the last document.
echo -e "</TEXT>\n</DOC>" >> /shared/ohsumed/data/trecText/ohsumed_all.txt
#remove .M, .T, .P, .W, .A, .S
sed -i -e 's/.[MTPWAS]$//g'  /shared/ohsumed/data/trecText/ohsumed_all.txt 
