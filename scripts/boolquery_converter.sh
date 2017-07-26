#!/bin/bash

rm -f ~/biocaddie/queries/boolqueries.combined.short
cat ~/biocaddie/queries/queries.combined.short | while read line
do
	#check if the line include <text> tag, create combination of 2 query terms from short query
	if echo $line | grep -q "<text>"
	then
	    echo -e "\t<text>\n\t#or(" >> ~/biocaddie/queries/boolqueries.combined.short
	    text_str=`echo "$line" | sed -e 's/<[^>]*>//g'`
	    #echo "$text_str"
	    text_arr=($text_str)
	    for i in `seq 0 $((${#text_arr[@]}-1))`
	    do
		for j in `seq $((i+1)) $((${#text_arr[@]}-1))`
		do
		     echo -e "\t\t#band( ${text_arr[$i]} ${text_arr[$j]} )" >> ~/biocaddie/queries/boolqueries.combined.short
		done
	    done
 	    echo -e "\t)\n\t</text>" >> ~/biocaddie/queries/boolqueries.combined.short
	#check if the line include <number> tag, just add it to boolean query with indent for easy viewing
	elif echo $line | grep -q "<number>"
	then
	    echo -e "\t$line" >> ~/biocaddie/queries/boolqueries.combined.short
	#for all other lines, add it directly to boolean query
	else
	    echo "$line" >> ~/biocaddie/queries/boolqueries.combined.short
	fi 
done
