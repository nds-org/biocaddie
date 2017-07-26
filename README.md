# NDS BioCADDIE Prototype 

This repository contains the code used in the NDS/uiucGSLIS submission to the 2016 BioCADDIE challenge and subsequent prototype. The submission is based primarily on the Indri search engine and explores 1) feedback-based expansion models using PubMed as an external collection and 2) document priors based on dataset source repository.

## Prerequisites

* Indri 5.8 with JNI support (liblemur.so, liblemur_jni.so, libindri.so, libindri_jni.so)
* Java 1.8 (JDK) with Maven
* R

This submission relies on the [ir-tools](https://github.com/uiucGSLIS/ir-tools) framework maintained by Miles Efron's lab at the University of Illinois at Urbana-Champaign.

You can either install prerequisites or use our provided Docker container.

## Install prerequisites
The following instructions assume an Ubuntu system running as root user:

```bash
apt-get update
apt-get install openjdk-8-jdk-headless maven
apt-get install r-base
apt-get install build-essential git parallel vim wget zlibc zlib1g zlib1g-dev
```

Build and install Indri:
```bash
cd /usr/local/src
wget https://sourceforge.net/projects/lemur/files/lemur/indri-5.8/indri-5.8.tar.gz/download -O indri-5.8.tar.gz
tar xvfz indri-5.8.tar.gz
cd indri-5.8
./configure --enable-java --with-javahome=/usr/lib/jvm/java-8-openjdk-amd64
make 
make install
```

Build and install trec_eval:
```bash
cd /usr/local/src
wget http://trec.nist.gov/trec_eval/trec_eval_latest.tar.gz
tar xvfz trec_eval_latest.tar.gz
cd trec_eval.9.0/
make
make install
```

## Run Docker image
Instead of installing the prerequisites on your system, the provided Docker image contains all of the required dependencies. The following example assumes that you've downloaded the BioCADDIE benchmark data to /data/biocaddie.

```bash
docker run -it -v /data/biocaddie:/data/biocaddie -v /data/pubmed:/data/pubmed ndslabs/indri bash
```

## Clone this repository and build artifacts

Download and install the ir-tools and indri libraries (Note: we're working to [add these to the Maven Central repository](https://opensource.ncsa.illinois.edu/jira/browse/NDS-849)):
```bash
wget https://github.com/nds-org/biocaddie/releases/download/v0.1/ir-utils-0.0.1-SNAPSHOT.jar
mvn install:install-file -Dfile=ir-utils-0.0.1-SNAPSHOT.jar -DgroupId=edu.gslis -DartifactId=ir-utils -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar
mvn install:install-file -Dfile=/usr/local/share/indri/indri.jar -DgroupId=indri -DartifactId=indri -Dversion=5.8 -Dpackaging=jar
```

```bash
cd ~
git clone https://github.com/nds-org/biocaddie
cd biocaddie
mvn install
```


## Replication steps

This section describes the steps to repeat our 2016 BioCADDIE challenge submissions. The basic steps are:

* Convert benchmark json data to trectext format
* Build biocaddie Indri index
* Run baseline models using Indri (tfidf, okapi, dir, jm, rm1, rm3, sdm)
* Convert PubMed collection to trectext format
* Build pubmed Indri index
* Run PubMed expansion models
* Run models using repository priors


### Convert benchmark data to trectext format

Download the [BioCADDIE benchmark collection in JSON format](https://biocaddie.org/sites/default/files/update_json_folder.zip).
```bash
mkdir -p /data/biocaddie/data
cd /data/biocaddie/data
wget https://biocaddie.org/sites/default/files/update_json_folder.zip
```

### Convert data to TREC-text format:
```bash
cd ~/biocaddie
scripts/dats2trec.sh
```

Note: You may see the following error, which is expected:
```bash
java.lang.ClassCastException: com.google.gson.JsonNull cannot be cast to com.google.gson.JsonObject
	at edu.gslis.biocaddie.util.DATSToTrecText.main(DATSToTrecText.java:61)
```

This converts the benchmark data to trectext format.  This produces a file ``/data/biocaddie/data/biocaddie_all.txt``. You can remove the original benchmark data, if desired.

### Create the biocaddie index

Use ``IndriBuildIndex`` to build the ``biocaddie_all`` index (customize paths as needed):
```bash
mkdir -p /data/biocaddie/indexes
cd ~/biocaddie
IndriBuildIndex index/build_index.biocaddie.params
```

### Qrels and queries
The official BioCADDIE qrels and queries have been converted to Indri format in the ``qrels`` and ``queries`` directories.  We provide both the original training queries and final test queries and qrels, as well as combined sets for ongoing research.  We also provide the original official queries as well as stopped and manually shortened versions. We only use the original queries in our official submissions, but the shortened queries are currently used for our primarily evaluation.

## Baseline models
We provide several bash scripts to sweep various Indri baseline model parameters:
* ``dir.sh``: Query-likelihood with Dirichlet smoothing
* ``jm.sh``: Query-likelihood with Jelinek-Mercer smoothing
* ``okapi.sh``: Okapi-BM25
* ``rm3.sh``:  Relevance models with original query interpolation
* ``tfdf.sh``: Indri's default tfidf baseline
* ``tfdfexp.sh``: Indri's tfidf baseline with expansion 
* ``two.sh``: Query-likelihood with two-stage smoothing

To run these scripts using GNU Parallel: 
```bash
baselines/<model>.sh <topics> <collection> | parallel -j 20 bash -c "{}"
```

Where ``<topics>`` is one of ``short, stopped, orig`` and collection is one of ``train, test, combined``. For example:
```bash
baselines/dir.sh short combined | parallel -j 20 bash -c "{}"
```

This will produce an output directory ``output/dir/combined/short`` containing one output file per parameter combination in TREC format.


## Cross-validation

The ``mkeval.sh`` script generates ``trec_eval`` output files for each parameter combination and then runs leave-one-query-out cross validation (loocv) on the results, optimizing for specific metrics.

```bash
scripts/mkeval.sh <model> <topics> <collection>
```

The loocv process optimizes for the following metrics: map, ndcg, P_20, ndcg_cut_20.  This process generates one output file per metric for the model/collection/topics.  For example:

``loocv/model.collection.topics.metric.out``

The output file is formatted as:
``<query>	<parameter combination> 	<metric value>``

## Comparing model output 
To compare models, use the ``compare.R`` script. This runs a paired one-tailed t-test comparing two models and outputs the metrics averages and p-value: 

```bash
Rscript scripts/compare.R <collection> <from model> <to model> <topics>
```

For example:
```bash
Rscript scripts/compare.R combined tfidf dir short
```

This will report the p-values of a paired, one-tailed t-test with the alternative hypothesis that <to model> is greater than <from model>.

The model comparisons can be used to select the best model from the training data.  Model parameter estimates must be determined from the LOOCV output.


## PubMed Open Access data

This describes the process for building and running the PubMed expansion models.

### Converting PubMed data to trectext

Download the PubMed oa_bulk datasets to ``/data/pubmed/oa_bulk``:

```bash
mkdir -p /data/pubmed/oa_bulk
cd /data/pubmed/oa_bulk
wget ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/non_comm_use.0-9A-B.txt.tar.gz
wget ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/non_comm_use.C-H.txt.tar.gz
wget ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/non_comm_use.I-N.txt.tar.gz
wget ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/non_comm_use.O-Z.txt.tar.gz
```

```bash
cd ~/biocaddie
scripts/pmc2trec.sh
```

This produces output in ``/data/pubmed/trecText/`` containing the TREC-formatted documents.

### Create the pubmed index

```bash
mkdir -p /data/pubmed/indexes
cd ~/biocaddie
IndriBuildIndex index/build_index.pubmed.params
```

This will create an Indri index in ``/data/pubmed/indexes/pubmed``.

### Run the pubmed expansion models

The PubMed experiment requires two stages.  First, it uses ``edu.gslis.biocaddie.util.GetFeedbackQueries`` to generate the expansion queries from the ``pubmed`` index. Second, it uses ``edu.gslis.biocaddie.util.RunScorer`` to run the resulting queries against the ``biocaddie`` index.

This requires sweeping the RM3 model parameters (mu, fbDocs, fbTerms, lambda) for the pubmed collection as well as the Dirichlet mu parameter for the biocaddie collection.

This section assumes that you have an existing PubMed index under ``/data/pubmed/indexes/pubmed``:

Create the RM expanded queries:
```bash
pubmed/genrm3.sh short combined
```

This will generate a set of expanded queries (mu=2500) under ``queries/pubmed/``. Now run the queries against the BioCADDIE index:
```bash
pubmed/runqueries.sh short combined | parallel -j 20 bash -c "{}"
```


## Re-scoring using source priors

These scripts will re-score an initial retrieval using the priors described in the paper.

### Prior 1: Using training data

First, get the repository for each qrel:
```bash
cd ~/biocaddie
scripts/repo.sh > /data/biocaddie/data/biocaddie-doc-repo.out
```

Next, rescore an initial retrieval:
```bash
priors/rescore1.sh <input> <output>
```

For example
```bash
priors/rescore1.sh output/dir/combined/short output/dir-prior1/combined/short
```



### Prior 2: Pseudo-feedback
Rescore an initial retrieval:
```bash
priors/rescore2.sh <input> <output>
```

For example
```bash
priors/rescore2.sh output/dir/combined/short output/dir-prior2/combined/short
```

## Dependence model queries

We've also included as a baseline Metlzer's sequential dependence model (SDM) and full dependence model (FDM) runs.

Generate the SDM queries (uses ``dm.pl``). For example:
```bash
sdm/gensd.sh short combined
```

Run the queries, also sweeping the Dirichlet mu:
```bash
sdm/runsd.sh short combined | parallel -j 20 bash -c "{}"
```

You can also run the ``fd`` variants of these two scripts.

For more information, see:
Metzler, D. and Croft, W.B., [A Markov Random Field Model for Term Dependencies](http://dl.acm.org/citation.cfm?id=1076115), ACM SIGIR 2005.


## Using Lucene

Building the Lucene index:
```bash
scripts/run.sh edu.gslis.lucene.main.LuceneBuildIndex index/lucene_biocaddie.yaml
```

Running the QL baselines:
```bash
lucene/<model>.sh <topics> <collection> | parallel --eta bash -c "{}"
```
