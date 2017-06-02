#for row in `cat fbOrigWeight.predicted`; do  query=`echo $row | cut -f1 -d,`; fbOrigWeight=`echo $row | cut -f2 -d,`; grep "^ndcg .*$query\s" "/data/willis8/biocaddie/eval/rm3/combined/short/mu=1000:fbTerms=50:fbDocs=10:fbOrigWeight=$fbOrigWeight.eval"; done

for row in `cat rm3.fbOrigWeight.ndcg_cut_20.predicted`; do  query=`echo $row | cut -f1 -d,`; fbOrigWeight=`echo $row | cut -f2 -d,`; grep "^ndcg_cut_20 .*$query\s" "/data/willis8/biocaddie/eval/rm3/combined/short/mu=500:fbTerms=50:fbDocs=10:fbOrigWeight=$fbOrigWeight.eval"; done
