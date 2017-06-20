package edu.gslis.biocaddie.qpp.predictors;

import java.util.Map;
import java.util.TreeMap;

import org.apache.commons.lang.ArrayUtils;
import org.rosuda.REngine.Rserve.RConnection;

import com.google.common.base.Strings;
import com.uwyn.jhighlight.tools.StringUtils;

public class PredictorMatrix {

	String[] headers = new String[0];
	Map<String, Double[]> predictors = new TreeMap<String, Double[]>();
	
	Map<String, Double> paramMap = new TreeMap<String, Double>();
	
	RConnection c = null;

	public void setHeaders(String[] headers) {
		this.headers = headers;
	}
	
	public String[] getHeaders() {
		return headers;
	}
	
	public void addPredictor(String key, Double[] values) {
		predictors.put(key,  values);
	}
	
	public Map<String, Double[]> getPredictors() {
		return predictors;
	}
	
	
	public void setParameterValues(Map<String, Double> paramMap) {
		this.paramMap = paramMap;
	}
	
	public void prepare() {
		try
		{
				c = new RConnection();
				c.voidEval("library(glmnet)");
				c.assign("headers", headers);			
				c.assign("queries", paramMap.keySet().toArray(new String[0]));
				
				// y = target parameter
				c.assign("y", ArrayUtils.toPrimitive(paramMap.values().toArray(new Double[0])));
				
				// x = predictors
				c.voidEval("x <- data.frame()");	
				for (String key: predictors.keySet()) {				
					double[] d = ArrayUtils.toPrimitive(predictors.get(key));
					c.assign("tmp", d);
					c.eval("x <- rbind(x,tmp)");
				}
				//c.voidEval("print(dim(x))");
				//c.voidEval("print(dim(headers[-1]))");
				//c.voidEval("print(class(x))");
				//c.voidEval("print(class(y))");
				c.voidEval("colnames(x) <- as.list(headers[-1])");
		} catch (Exception e) {
			e.printStackTrace();
		}		
	}
	public void close() {
		c.close();
	}
	public double predict(String query, boolean verbose) {
		// Build the penalized regression model using qpp[-query]
		// Predict parameter 
		
		double predicted = 0;

		try {
			c.voidEval("q <- which(queries == \"" + query + "\")");
			//c.voidEval("print(q)");
			//c.voidEval("print(dim(x))");
			//c.voidEval("print(length(y))");
			c.voidEval("cv.lasso <- cv.glmnet(as.matrix(x[-q,]), y[-q], alpha=1)");		
			c.voidEval("pred <- predict(cv.lasso, as.matrix(x[q,]))");
			//c.voidEval("print(pred)");
			c.voidEval("coef <- coef(cv.lasso)");
			String[] names = c.eval("row.names(coef)").asStrings();
			double[] coef = c.eval("as.matrix(coef)").asDoubles();
			String model = String.format(" + %s*%.4f", names[0], coef[0]);
			for (int i=1; i< coef.length; i++) {
				if (coef[i] != 0) 
					model += String.format(" + %s*%.4f", names[i], coef[i]);
			}
			predicted = c.eval("pred").asDouble();
			System.out.println(query + "(" + predicted + "): " + model);
			if (predicted > 1) 
				predicted = 1;
			else if (predicted < 0) 
				predicted = 0;
			//c.voidEval("mse <- sqrt(apply((y[-q]-pred)^2,2,mean))");
			//c.voidEval("lam.best <- cv.lasso$lambda[order(mse)[1]]");
			//c.voidEval("min(mse)");
		} catch (Exception e) {
			e.printStackTrace();
		}
		return predicted;
	}

}
