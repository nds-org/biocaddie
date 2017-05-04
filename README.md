# NDS/uiucGSLIS BioCADDIE Challenge 

This repository contains the code used in the NDS/uiucGSLIS submission to the 2016 BioCADDIE challenge. The submission is based primarily on the Indri search engine and explores 1) feedback-based expansion models using PubMed as an external collection and 2) document priors based on dataset source repository.

## Prerequisites

* BioCADDIE Challenge benchmark data: https://biocaddie.org/benchmark-data assumed to be in ``/data/biocaddie/data``.
* Indri 5.11 with JNI support (liblemur.so, liblemur_jni.so, libindri.so, libindri_jni.so)
* Java 1.8
* R

This submission relies on the [ir-tools](https://github.com/uiucGSLIS/ir-tools) framework maintained by Miles Efron's lab at the University of Illinois at Urbana-Champaign.

You can either install prerequisites or use our provided Docker container.

## Install prerequisites
The following instructions assume an Ubuntu system running as root user:

``bash
apt-get update
apt-get install openjdk-8-jdk-headless maven
apt-get install r-base
apt-get install build-essential wget vim  zlibc zlib1g zlib1g-dev
``

Build and install Indri:
``bash
cd /usr/local/src
wget https://sourceforge.net/projects/lemur/files/lemur/indri-5.11/indri-5.11.tar.gz/download -O indri-5.11.tar.gz
tar xvfz indri-5.11.tar.gz
cd indri-5.11
./configure --enable-java --with-javahome=/usr/lib/jvm/java-8-openjdk-amd64
make 
make install
``

## Run Docker image
Instead of installing the prerequisites on your system, the provided Docker image contains all of the required dependencies. The following example assumes that you've downloaded the BioCADDIE benchmark data to /data/biocaddie.

``bash
docker run -it /data/biocaddie:/data/biocaddie ndslabs/indri bash
``

## Clone this repository and build artifacts

Download and install the ir-tools and indri libraries (Note: we're working to [add these to the Maven Central repository](https://opensource.ncsa.illinois.edu/jira/browse/NDS-849)):
``bash
wget https://github.com/nds-org/biocaddie/releases/download/v0.1/ir-utils-0.0.1-SNAPSHOT.jar
mvn install:install-file -Dfile=ir-utils-0.0.1-SNAPSHOT.jar -DgroupId=edu.gslis -DartifactId=ir-utils -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar
mvn install:install-file -Dfile=/usr/local/share/indri/indri.jar -DgroupId=indri -DartifactId=indri -Dversion=5.11 -Dpackaging=jar
``

``bash
git clone https://github.com/nds-org/biocaddie
cd biocaddie
mvn install
``


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
``bash
mkdir -p /data/biocaddie/data
wget https://biocaddie.org/sites/default/files/update_json_folder.zip
cd /data/biocaddie/data
unzip 
update_json_folder.zip
``

### Convert data to TREC-text format:
``bash
cd ~/biocaddie
scripts/dats2trec.sh
``

This converts the benchmark data to trectext format.  This produces a file ``/data/biocaddie/data/biocaddie_all.txt``. You can remove the original benchmark data, if desired.

### Create the biocaddie index

Use ``IndriBuildIndex`` to build the ``biocaddie_all`` index (customize paths as needed):

``bash
cd ~/biocaddie
IndriBuildIndex index/build_index.biocaddie.params
``


### Qrels and queries

The official BioCADDIE qrels and queries have been converted to Indri format in the ``qrels`` and ``queries`` directories.  We provide both the original training queries and final test queries and qrels, as well as combined sets for ongoing research.  We also provide the original official queries as well as stopped and manually shortened versions. We only use the original queries in our official submissions.

## Baseline models
We provide several bash scripts to sweep various Indri baseline model parameters. 
* ``dir.sh``: Query-likelihood with Dirichlet smoothing
* ``jm.sh``: Query-likelihood with Jelinek-Mercer smoothing
* ``okapi.sh``: Okapi-BM25
* ``rm3.sh``:  Relevance models with original query interpolation
* ``tfdf.sh``: Indri's default tfidf baseline
* ``two.sh``: Query-likelihood with two-stage smoothing

To run these scripts: 
``scripts/<model>.sh <topics> <collection>``

Where ``<topics>`` is one of ``short, stopped, orig`` and collection is one of ``train, test, combined``. For example:

``scripts/<model>.sh short combined``

This will produce an output directory ``output/model/combined/short`` containing one output file per parameter combination in TREC format.

## Cross-validation

The ``mkeval.sh`` script generates ``trec_eval`` output files for each parameter combination and then runs leave-one-query-out cross validation (loocv) on the results.

``scripts/mkeval.sh <model> <topics> <collection>``

The loocv process optimizes for the following metrics: map, ndcg, P_20, ndcg_cut_20.  This process generates on e output file per metric for the model/collection/topics.   

``loocv/model.collection.topics.metric.out``

The output file is formatted as:
``<query>	<parameter combination> 	<metric value>``

## Comparing model output 
To compare models, use the ``compare.R`` script:

``Rscript compare.R <collection> <from model> <to model> <topics>``

For example
``Rscript compare.R train dir two orig``

This will report the p-values of a paired, one-tailed t-test with the alternative hypothesis that <to model> is greater than <from model>.

The model comparisons can be used to select the best model from the training data.  Model parameter estimates must be determined from the LOOCV output.

## Converting PubMed data to trectext

Download the PubMed oa_bulk datasets to ``/data/pubmed/oa_bulk``:
* ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/non_comm_use.0-9A-B.txt.tar.gz
* ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/non_comm_use.C-H.txt.tar.gz
* ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/non_comm_use.I-N.txt.tar.gz
* ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/non_comm_use.O-Z.txt.tar.gz

Run the ``scripts/pmc2trec.sh``. This produces output in ``/data/pubmed/trecText/``

### Create the pubmed index

``IndriBuildIndex index/build_index.pubmed.params``

This will create an Indri index in ``/data/pubmed/indexes/pubmed``.

### Run the pubmed expansion models

The PubMed experiment requires two stages.  First, it uses ``edu.gslis.biocaddie.util.GetFeedbackQueries`` to generate the expansion queries from the ``pubmed`` index. Second, it uses ``edu.gslis.biocaddie.util.RunScorer`` to run the resulting queries against the ``biocaddie`` index.

This requires sweeping the RM3 model parameters (mu, fbDocs, fbTerms, lambda) for the pubmed collection as well as the Dirichlet mu parameter for the biocaddie collection.

The script ``pubmed/genrm3.sh`` will generate RM3 queries from the ``pubmed`` index in Gquery format.

``scripts/pubmed/genrm3.sh <topics> <collection>``

The script ``pubmed/runqueries.sh`` will run these queries against the ``biocaddie`` index:

``scripts/pubmed/runqueries.sh <topics> <collection>``

### Re-scoring using source priors

Coming soon.
