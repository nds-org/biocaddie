package edu.gslis.biocaddie.qpp.predictors;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;

import edu.gslis.textrepresentation.FeatureVector;



/**
 * Work in progress.
 * 
 * Preliminary implementation of several standard post-retrieval predictors.
 */
public class PreRetrievalPredictorSuite extends PredictorSuite {
	
	
	public Map<String, Double> calculatePredictors() {		
		
		Map<String, Double> values = new HashMap<String, Double>();
		
		FeatureVector qv = query.getFeatureVector();
		
        DescriptiveStatistics idfstat = new DescriptiveStatistics();
        DescriptiveStatistics ictfstat = new DescriptiveStatistics();
        DescriptiveStatistics scqstat = new DescriptiveStatistics();

        double scs = 0;
        double entropy = 0;
        for (String term: qv.getFeatures()) {
            if (index.docFreq(term) == 0) // Skip OOV terms
                continue;

            // Inverse document frequency  (Kwok, 1996)          
            double idf = Math.log(index.docCount() / index.docFreq(term));
            
            // Inverse collection term frequency (
            double ictf = Math.log(index.termCount()/index.termFreq(term));
            
            // 	Collection query similarity (Zhao et al)
            double scq = (1 + Math.log(index.termFreq(term))) * idf;
            
    		
            // Simplified Clarity Score: KL-divergence of query model from collection model
			double pwq = qv.getFeatureWeight(term)/qv.getLength();
			double pwc = index.termFreq(term)/ index.termCount();			
			scs += pwq * Math.log(pwq/pwc);
            
			// Query entropy: looks wrong.
            entropy += pwc * Math.log(pwc);
			
            idfstat.addValue(idf);
            ictfstat.addValue(ictf);
            scqstat.addValue(scq);
        }
                        
        values.put("queryLen", qv.getLength());
        
        values.put("varIDF", idfstat.getVariance());
        values.put("avgIDF", idfstat.getMean());
        values.put("minIDF", idfstat.getMin());
        values.put("maxIDF", idfstat.getMax());

        values.put("varICTF", ictfstat.getVariance());
        values.put("avgICTF", ictfstat.getMean());
        values.put("minICTF", ictfstat.getMin());
        values.put("maxICTF", ictfstat.getMax());
        
        values.put("varSCQ", scqstat.getVariance());
        values.put("avgSCQ", scqstat.getMean());
        values.put("minSCQ", scqstat.getMin());
        values.put("maxSCQ", scqstat.getMax()); // Stable predictor (Hauff, 2010)
        values.put("sumSCQ", scqstat.getSum());
        
        values.put("scs", scs);
        values.put("entropy", entropy);
		return values;			
	}	
	
	
	// Not implemented yet
	// 	Coherency (He et al) -- required pre-computing
	//  PMI, avgPMI, maxPMI -- requires pre-computing
	// 	Term-weight variability (Hauff thesis, Zhao et al) -- requires pre-computing
		
}
