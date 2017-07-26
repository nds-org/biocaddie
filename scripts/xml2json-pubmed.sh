#!/bin/bash
rm -rf /shared/pubmed/json_test/pubmeddata.json /shared/pubmed/json_test/pubmeddata.log
find /shared/pubmed/test -type f -name '*nxml' | while read file
do
    basename=`basename $file '.nxml'`
    #extract pmcid for each document, it will be used for index id and pmcid tag in json.
    id=`awk '{if(match (\$0, /<article-id pub-id-type="pmc">.*<\/article-id>/)) {print substr (\$0,RSTART,RLENGTH)}}' "$file" | cut -d "<" -f2 | cut -d ">" -f2`
    
    #create json file for pubmed data
    echo -e "{\"index\":{\"_id\":\"$id\"}}">> /shared/pubmed/json_test/pubmeddata.json
    echo -ne "{\"name\":\"$basename.nxml\",\"pmcid\":$id,\"text\":\"" >> /shared/pubmed/json_test/pubmeddata.json
    #strip off all the xml tag, remove all special characters (such as non-alphanumeric except white space, space) Also remove new line.
    sed -e 's/<[^>]*>/ /g' -e 's/[^a-zA-Z \d\s:]//g'  $file| tr '\n' ' '  >> /shared/pubmed/json_test/pubmeddata.json
    echo -e "\"}" >> /shared/pubmed/json_test/pubmeddata.json
    echo -e "$file converted into json format" >> /shared/pubmed/json_test/pubmeddata.log
done
