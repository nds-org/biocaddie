#!/bin/bash
# 
# This script will bootstrap your cluster's GLFS volume with
# the necessary BioCADDIE and PubMed indexes needed by indri 
# 
# Usage: ./kubernetes/setup-index.sh [index_name]
# 
# NOTE: If no index is speficied, all will be set up
#

# Exit if error is encountered
set -e

index_name=$1

if [ "$index_name" == "biocaddie" -o "$index_name" == "" ]; then 
        echo 'Reindexing biocaddie: Starting...'

        # Clear out any old data for this index
	rm -rf /data/biocaddie

	# Download BioCADDIE benchmark data
	echo 'Reindexing biocaddie: Downloading...'
	mkdir -p /data/biocaddie/data
	cd /data/biocaddie/data
	wget https://biocaddie.org/sites/default/files/update_json_folder.zip

	# Convert BioCADDIE data to TREC format
	echo 'Reindexing biocaddie: Converting...'
	cd ~/biocaddie
	scripts/dats2trec.sh

	# Create the biocaddie index
	echo "Reindexing biocaddie: Indexing..."
	mkdir -p /data/biocaddie/indexes
	cd ~/biocaddie
	IndriBuildIndex index/build_index.biocaddie.params

	echo 'Reindexing biocaddie: Complete!'
fi

if [ "$index_name" == "pubmed" -o "$index_name" == "" ]; then
        echo 'Reindexing pubmed: Started...'

	# Clear out any old data for this index
	rm -rf /data/pubmed

	# Download PubMed Open Access data
        echo 'Reindexing pubmed: Downloading...'
	mkdir -p /data/pubmed/oa_bulk
	cd /data/pubmed/oa_bulk
	wget ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/non_comm_use.0-9A-B.txt.tar.gz
	wget ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/non_comm_use.C-H.txt.tar.gz
	wget ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/non_comm_use.I-N.txt.tar.gz
	wget ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/non_comm_use.O-Z.txt.tar.gz

	# Convert PubMed data to TREC format
        echo 'Reindexing pubmed: Converting...'
	cd ~/biocaddie
	scripts/pmc2trec.sh

	# Create the PubMed index
        echo 'Reindexing pubmed: Indexing...'
	mkdir -p /data/pubmed/indexes
	cd ~/biocaddie
	IndriBuildIndex index/build_index.pubmed.params

	echo 'Reindexing pubmed: Complete!'
fi

