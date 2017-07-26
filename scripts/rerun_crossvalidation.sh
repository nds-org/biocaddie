#!/bin/bash

# filter eval results for test queries only and copy them to ./eval/<model>/test/short folder
for dir in `find /shared/biocaddie/eval -maxdepth 1 -type d | grep -v "./eval$"`
do
    dirname=`basename $dir`
    if [ ! -d "$dir/test/short" ]
    then
	mkdir -p $dir/test/short
	for file in `find ${dir}/combined/short -type f -name "*.eval"`
	do
	     filename=`basename $file`
	     egrep -v "\sEA[1-6]\s|\sall\s" $file > $dir/test/short/$filename
	done
    fi
    if [ -z "$(ls -A $dir/test/short)" ]
    then
	echo "$dir/test/short is empty"
    else
	# Leave on query out cross-validation
        mkdir -p /shared/biocaddie/loocv
	echo "Process cross-validation for $dir/test/short"
        for metric in map ndcg ndcg_cut_5 ndcg_cut_10 ndcg_cut_20 ndcg_cut_100 ndcg_cut_500 P_5 P_10 P_20 P_100 P_500
        do
             scripts/run.sh edu.gslis.biocaddie.util.CrossValidation -input $dir/test/short -metric $metric -output /shared/biocaddie/loocv/$dirname.test.short.$metric.out
        done
    fi
done
