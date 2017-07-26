for file in `find /data/biocaddie/data/update_json_folder/ -type f`; 
do 
   name=`basename $file`; 
   id=`echo $name | cut -f1 -d.`; 
   curl -XPUT "localhost:9200/biocaddie/dataset/$id?pretty"  -H 'Content-Type: application/json' -d "@$file"; 
done
