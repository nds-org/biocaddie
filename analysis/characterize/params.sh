#!/bin/bash


#
# This ugly, fragile, but working script parses per-query metric values from the trec_eval output
# This should be pretty straightforward to move to a better language than bash and sed.
#
# Creates model.parameter.metric.out files
#
#

if [ -z "$1" ]; then
   echo "./params.sh <metric>"
   exit 1;
fi
metric=$1

zgrep "^$metric\s" ../../eval/dir/combined/short/* | grep -v all | sed 's/^.*short\///' | sed "s/.eval:$metric//g" | sed 's/\s\s*/,/g' > dir.mu.$metric.out


# mu=1000:fbTerms=50:fbDocs=10:fbOrigWeight=0.5.eval

zgrep "^$metric\s" ../../eval/rm3/combined/short/* | grep -v all | grep "mu=1000:fbTerms=[^:]*:fbDocs=10:fbOrigWeight=0.5" |  sed 's/^.*short\///' | sed "s/.eval:$metric//g" | sed 's/\s\s*/,/g' | sed 's/mu=1000:fbTerms=//g' | sed 's/:fbDocs=10:fbOrigWeight=0.5//g' > rm3.fbTerms.$metric.out
zgrep "^$metric\s" ../../eval/rm3/combined/short/* | grep -v all | grep "mu=1000:fbTerms=50:fbDocs=[^:]*:fbOrigWeight=0.5" |  sed 's/^.*short\///' | sed "s/.eval:$metric//g" | sed 's/\s\s*/,/g' | sed 's/mu=1000:fbTerms=50:fbDocs=//g' | sed 's/:fbOrigWeight=0.5//g' > rm3.fbDocs.$metric.out
zgrep "^$metric\s" ../../eval/rm3/combined/short/* | grep -v all | grep "mu=1000:fbTerms=50:fbDocs=10:fbOrigWeight=.*\.eval" |  sed 's/^.*short\///' | sed "s/.eval:$metric//g" | sed 's/\s\s*/,/g' | sed 's/mu=1000:fbTerms=50:fbDocs=10:fbOrigWeight=//g' > rm3.fbOrigWeight.$metric.out


# PubMed
zgrep "^$metric\s" ../../eval/pubmed/combined/short/* | grep -v all | grep "mu:2500,fbTerms:[^,]*,fbDocs:50,fbOrigWeight:0.7,dir-mu:1000\." |  sed 's/^.*short\/queries\.//' | sed "s/.eval:$metric//g" | sed 's/\s\s*/,/g' | sed 's/mu:2500,fbTerms://g' | sed 's/,fbDocs:50,fbOrigWeight:0.7,dir-mu:1000//g' > pubmed.fbTerms.$metric.out

zgrep "^$metric\s" ../../eval/pubmed/combined/short/* | grep -v all | grep "mu:2500,fbTerms:20,fbDocs:[^,]*,fbOrigWeight:0.7,dir-mu:1000\." |  sed 's/^.*short\/queries\.//' | sed "s/.eval:$metric//g" | sed 's/\s\s*/,/g' | sed 's/mu:2500,fbTerms:20,fbDocs://g' | sed 's/,fbOrigWeight:0.7,dir-mu:1000//g' > pubmed.fbDocs.$metric.out

zgrep "^$metric\s" ../../eval/pubmed/combined/short/* | grep -v all | grep "mu:2500,fbTerms:20,fbDocs:50,fbOrigWeight:[^,]*,dir-mu:1000\." |  sed 's/^.*short\/queries\.//' | sed "s/.eval:$metric//g" | sed 's/\s\s*/,/g' | sed 's/mu:2500,fbTerms:20,fbDocs:50,fbOrigWeight://g' | sed 's/,dir-mu:1000//g' > pubmed.fbOrigWeight.$metric.out

# Wikipedia
zgrep "^$metric\s" ../../eval/wikipedia/combined/short/* | grep -v all | grep "mu:2500,fbTerms:[^,]*,fbDocs:50,fbOrigWeight:0.7,dir-mu:1000\." |  sed 's/^.*short\/queries\.//' | sed "s/.eval:$metric//g" | sed 's/\s\s*/,/g' | sed 's/mu:2500,fbTerms://g' | sed 's/,fbDocs:50,fbOrigWeight:0.7,dir-mu:1000//g' > wikipedia.fbTerms.$metric.out

zgrep "^$metric\s" ../../eval/wikipedia/combined/short/* | grep -v all | grep "mu:2500,fbTerms:20,fbDocs:[^,]*,fbOrigWeight:0.7,dir-mu:1000\." |  sed 's/^.*short\/queries\.//' | sed "s/.eval:$metric//g" | sed 's/\s\s*/,/g' | sed 's/mu:2500,fbTerms:20,fbDocs://g' | sed 's/,fbOrigWeight:0.7,dir-mu:1000//g' > wikipedia.fbDocs.$metric.out

zgrep "^$metric\s" ../../eval/wikipedia/combined/short/* | grep -v all | grep "mu:2500,fbTerms:20,fbDocs:50,fbOrigWeight:[^,]*,dir-mu:1000\." |  sed 's/^.*short\/queries\.//' | sed "s/.eval:$metric//g" | sed 's/\s\s*/,/g' | sed 's/mu:2500,fbTerms:20,fbDocs:50,fbOrigWeight://g' | sed 's/,dir-mu:1000//g' > wikipedia.fbOrigWeight.$metric.out
