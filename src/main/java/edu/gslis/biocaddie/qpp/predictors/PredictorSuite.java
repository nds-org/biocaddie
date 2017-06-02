package edu.gslis.biocaddie.qpp.predictors;

import java.util.Map;

import edu.gslis.indexes.IndexWrapper;
import edu.gslis.queries.GQuery;
import edu.gslis.searchhits.SearchHits;
import edu.gslis.utils.Stopper;

/**
 * A predictor suite implements one or more query performance predictor calculations.
 * Predictors can be pre-retrieval, requiring only the index and query, or
 * post-retrieval, query, and set of initial results.
 */
public abstract class PredictorSuite {

	IndexWrapper index;
	GQuery query;
	SearchHits hits;
	Stopper stopper;
	int k;
	
	public void setIndex(IndexWrapper index) {
		this.index = index;
	}
	
	public void setQuery(GQuery query) {
		this.query = query;
	}
	
	public void setHits(SearchHits hits) {
		this.hits = hits;
	}
		
	public void setStopper(Stopper stopper) {
		this.stopper = stopper;
	}
	
	public void setK(int k) {
		this.k = k;
	}
	
	public abstract Map<String, Double> calculatePredictors();

}
