package edu.gslis.biocaddie.util;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.io.FileUtils;

import edu.gslis.biocaddie.qpp.predictors.PredictorMatrix;

/** 
 * Leave-one-out cross validation with query performance predictor support.
 * 
 */
public class CrossValidationQPP 
{	

    public static void main(String[] args) throws Exception 
    {
        Options options = createOptions();
        CommandLineParser parser = new GnuParser();
        CommandLine cl = parser.parse( options, args);
        if (cl.hasOption("help")) {
            HelpFormatter formatter = new HelpFormatter();
            formatter.printHelp( CrossValidationQPP.class.getCanonicalName(), options );
            return;
        }
        String outputPath = cl.getOptionValue("output");
        String inputPath = cl.getOptionValue("input");
        String metric = cl.getOptionValue("metric");
        String predictorsPath = cl.getOptionValue("predictors");
        String predictionParam = cl.getOptionValue("param");
        boolean verbose = cl.hasOption("verbose");
        
        // Per-query cross-validated output
        FileWriter output  = new FileWriter(outputPath);
        
        // Read trec_eval output 
        Set<String> topics = new TreeSet<String>();
        Map<String, Map<String, Double>> trecEval = new TreeMap<String, Map<String, Double>>();
        
        
        // Read the trec eval output
        readTrecEvalOutput(inputPath, topics, trecEval, metric);
        
        // Read the predictors 
        PredictorMatrix predictors = readPredictors(predictorsPath);        
        
               
        // Get the 
        Map<String, String> cvNoQppMap = new TreeMap<String, String>();
        
        Map<String, String> topicMaxParamMap = new TreeMap<String, String>();
        Map<String, Double> topicParamMap = new TreeMap<String, Double>();
        for (String topic: topics) {
        	 String maxParam = getMaxParam(topic, trecEval, verbose);
        	 cvNoQppMap.put(topic, maxParam);
        	 
        	 Map<String, Double> paramMap = getParamMap(maxParam);
         	 //mu=1000:fbTerms=10:fbDocs=50:fbOrigWeight=0.2.out
        	 double tmpMax = 0;
        	 String tmpParams = "";
        	 double maxLambda = 0;
        	 for (double lambda=0.0; lambda < 1.0; lambda +=0.1) {

        		 /*
        		 String params = "";
        		 int i=0;
        		 for (String key: paramMap.keySet()) {
        			 if (i > 0)
        				 params+= ",";
        			 if (key.equals(predictionParam))
        				 params += String.format("%s:%.1f", key, lambda);
        			 else 
        				 params += String.format("%s:%.1f", key, paramMap.get(key));
        			 i++;
        		 }
        		 */
        		 String params = getParamKey(paramMap, predictionParam, lambda);
        		 //String params = String.format("mu=%d:fbTerms=%d:fbDocs=%d:fbOrigWeight=%.1f.eval",
        		//		 paramMap.get("mu").intValue(), paramMap.get("fbTerms").intValue(), paramMap.get("fbDocs").intValue(), lambda);
        		 if (trecEval.get(params) != null) {
        			 if (trecEval.get(params).get(topic) == null)
        				 System.err.println("No topic " + topic + " for " + params);
        			 else {
	        			 double tmp = trecEval.get(params).get(topic);
		        		 if (tmp > tmpMax) {
		            		 //System.out.println(params);
		        			 tmpParams = params;
		        			 tmpMax = tmp;
		        			 maxLambda = lambda;
		        		 }
        			 }
        		 }
        	 }
        	         	 
        	 topicMaxParamMap.put(topic, tmpParams);  
        	 topicParamMap.put(topic, maxLambda);
        }
        
        
        /*
        Map<String, Double> topicMetricMap = new TreeMap<String, Double>();
        Map<String, Double> topicParamMap = new TreeMap<String, Double>();
		for (String paramSet: trecEval.keySet()) {
			
			Map<String, Double> paramMap = getParamMap(paramSet);
			
			Map<String, Double> topicMap = trecEval.get(paramSet);
			for (String topic: topicMap.keySet()) {
				double metricValue = topicMap.get(topic);
				double paramValue = paramMap.get(predictionParam);
				if (topicMetricMap.containsKey(topic)) {
					if (metricValue > topicMetricMap.get(topic)) {
						topicMetricMap.put(topic, metricValue);
						topicParamMap.put(topic, paramValue);
					}
				} else {
					topicMetricMap.put(topic, metricValue);
					topicParamMap.put(topic, paramValue);
				}
			}
		}
		*/

		// Train the model and predict lambda		
		predictors.setParameterValues(topicParamMap);
		predictors.prepare();
		Map<String, Double> topicPredictedMap = new TreeMap<String, Double>();
		for (String topic: topicParamMap.keySet()) {
			double predicted = predictors.predict(topic, false);
			topicPredictedMap.put(topic, predicted);
			
			String maxParam = cvNoQppMap.get(topic);
       	 	double noQpp = trecEval.get(maxParam).get(topic);
       	 	
       	 	Map<String, Double> paramMap = getParamMap(maxParam);
       	 	String paramKey = getParamKey(paramMap, predictionParam, predicted);
			//String params = String.format("mu=%d:fbTerms=%d:fbDocs=%d:fbOrigWeight=%.1f.eval",
			//	 paramMap.get("mu").intValue(), paramMap.get("fbTerms").intValue(), paramMap.get("fbDocs").intValue(), predicted);
			double withQpp = trecEval.get(paramKey).get(topic);
			System.out.println(topic + "\t" + noQpp + "\t" + withQpp);
		}
		predictors.close();

		output.close();

    }
    
    public static Map<String, Double> getParamMap(String params) {
    	Map<String, Double> paramMap = new TreeMap<String, Double>(); 
    	//  mu=2000.0:lambda=0.1:fbDocs=10.0:fbTerms=100.0.eval
    	params = params.replaceAll(".eval", "");
    	String[] fields = new String[0];
    	if (params.indexOf(",") > 0)
    		fields = params.split(",");
    	else if (params.indexOf(":") > 0)
    		fields = params.split(":");
    	for (String field: fields) {
    		String[] nvpair  = new String[0];
    		if (params.indexOf(",") > 0)
    			nvpair = field.split(":");
    		else 
    			nvpair = field.split("=");
    		paramMap.put(nvpair[0], Double.parseDouble(nvpair[1]));
    	}
    	return paramMap;
    }
    
    public static String getParamKey(Map<String, Double> paramMap) {
    	String paramKey = "";
    	int i=0;
    	for (String k: paramMap.keySet()) {
    		Double v = paramMap.get(k);
    		if (i > 0) 
    			paramKey += ",";
    		paramKey += String.format("%s:%.1f", k, v);
    		i++;
    	}
    	return paramKey;
    }
    
    public static String getParamKey(Map<String, Double> paramMap, String param, double value) {
		 String params = "";
		 int i=0;
		 for (String key: paramMap.keySet()) {
			 if (i > 0)
				 params+= ",";
			 if (key.equals(param))
				 params += String.format("%s:%.1f", key, value);
			 else 
				 params += String.format("%s:%.1f", key, paramMap.get(key));
			 i++;
		 }
		 return params;
    }
    
    public static String getMaxParam(String heldOut, Map<String, Map<String, Double>> trecEval, boolean verbose) {
		double max = 0;
		String maxParam = "";
		for (String paramSet: trecEval.keySet()) {
			Map<String, Double> topicMap = trecEval.get(paramSet);
		
			// Get the topic/values for this parameter set
			double score = 0;
			for (String topic: topicMap.keySet()) {
				// Ignore held-out topic
				if (topic.equals(heldOut))
					continue;
				// Get the average score for the training set
				score += topicMap.get(topic);						
			}				
			// Divide by topics less held-out topic
			score /= (topicMap.size() - 1);
							
			if (score > max) {
				max = score;
				maxParam = paramSet;					
			}
			if (verbose)
				System.err.println(heldOut + ", " + paramSet + ", "  + score);
		}

		if (verbose)
			System.err.println(heldOut + ", " + maxParam + ", "  + max + ",max");
		
		return maxParam;
    }
    
    public static PredictorMatrix readPredictors(String path) 
    		throws IOException {
    	 
    	PredictorMatrix predictors = new PredictorMatrix();
    	
    	 List<String> lines = FileUtils.readLines(new File(path));
    	 int i=0;
    	 for (String line: lines) {
    		 String[] fields = line.split(",");
    		 if (i==0) {
    			 predictors.setHeaders(fields);
    		 }
    		 else
    		 {
	    		 
	    		 String key = fields[0];
	    		 List<Double> values = new ArrayList<Double>();
	    		 for (int j=1; j < fields.length; j++) {
	    			 values.add(Double.parseDouble(fields[j]));
	    		 }
	    		 predictors.addPredictor(key, values.toArray(new Double[0]));
    		 }
    		 i++;    			 	
    	 }
    	 
    	 return predictors;
    }
    
    /**
     * Read the trec_eval output into a set of topics and map of maps.
     * @param inputPath
     * @param topics
     * @param trecEval
     */
    public static void readTrecEvalOutput(String inputPath, Set<String> topics, 
    		Map<String, Map<String, Double>> trecEval, String metric) throws IOException{
        // Read trec_eval output 
        File inputDir = new File(inputPath);
        if (inputDir.isDirectory()) {
        	
        	//Read each input file (parameter output)
        	for (File file: inputDir.listFiles()) {
        		if (file.isDirectory())
        			continue;
        		
        		String paramSet = file.getName();
        		
        		List<String> lines = FileUtils.readLines(file);
        		for (String line: lines) {
        			String[] fields = line.split("\\t");
        			String measure = fields[0].trim();
        			String topic = fields[1];

        			if (measure.equals("runid") || topic.equals("all") || measure.equals("relstring"))
        				continue;
        		
        			double value =0;
        			try {
        				 value = Double.parseDouble(fields[2]); 
        			} catch (Exception e) {
        				System.err.println(e.getMessage());
        				continue;
        			}
        			
        			topics.add(topic);
        			
        			if (measure.equals(metric)) {
        				Map<String, Double> paramMap = getParamMap(paramSet);
        				String paramKey = getParamKey(paramMap);

        				
        				// Store the topic=value pair for each parameter set for this metric
        				Map<String, Double> topicMap = trecEval.get(paramKey);
        				if (topicMap == null) 
        					topicMap = new TreeMap<String, Double>();
        				
        				topicMap.put(topic, value);
        				trecEval.put(paramKey, topicMap);
        			}
        		}
        	}
        }
    }
    
    public static Options createOptions()
    {
        Options options = new Options();
        options.addOption("input", true, "Path to directory trec_eval output files");
        options.addOption("metric", true, "Cross validation target metric");
        options.addOption("predictors", true, "Path to predictors");
        options.addOption("param", true, "QPP target parameter");
        options.addOption("output", true, "Output path");
        options.addOption("verbose", false, "Verbose output");
        return options;
    }
      
}
