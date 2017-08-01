package edu.gslis.biocaddie.qpp.predictors;

import org.apache.commons.lang.ArrayUtils;
import org.rosuda.REngine.Rserve.RConnection;


public class Prediction {

	PredictorMatrix data;
	RConnection c = null;
	

	public Prediction(PredictorMatrix data) {
		this.data = data;
	}
		
	public void init() {
		try
		{
			c = new RConnection();
			c.voidEval("library(glmnet)");
			c.assign("headers", data.getHeaders());	
			c.assign("queries", data.getResponse().keySet().toArray(new String[0]));
			
			// y = target parameter
			c.assign("y", ArrayUtils.toPrimitive(data.getResponse().values().toArray(new Double[0])));
			
			//c.voidEval("y[y>=0.5] <- 1");
			//c.voidEval("y[y<0.5] <- 0");
			//c.voidEval("y <- as.factor(y)");

			// x = predictors
			c.voidEval("x <- data.frame()");	
			for (String key: data.getPredictors().keySet()) {				
				double[] d = ArrayUtils.toPrimitive(data.getPredictors().get(key));
				c.assign("tmp", d);
				c.eval("x <- rbind(x,tmp)");
			}
			c.voidEval("colnames(x) <- as.list(headers[-1])");
		} catch (Exception e) {
			e.printStackTrace();
		}		
	}
	
	public void close() {
		c.close();
	}
	
	/**
	 * Build cross-validated regression model
	 * @param query Held out query to be predicted
	 * @param alpha	Model type: 0=lasso, 1=ridge, otherwise elasticnet.
	 * @return predicted parameter value
	 */
	public double predict(String query, double alpha, boolean debug) 
	{
		double predicted = 0;

		try 
		{
			// Get the index of the specified query
			c.voidEval("q <- which(queries == \"" + query + "\")");
			
			// k-fold cross validation. alpha=1 lasso; alph=0 ridge
			// nfolds=length(queries)
			c.voidEval("cv.lasso <- cv.glmnet(as.matrix(x[-q,]), y[-q], alpha=" 
					+ String.format("%.2f", alpha) + ")");	

			//c.voidEval("cv.lasso <- cv.glmnet(as.matrix(x[-q,]), y[-q], family=c(\"binomial\"), alpha=" 
			//		+ String.format("%.2f", alpha) + ")");	
			
			// Predict the held-out value
			//c.voidEval("pred <- predict(cv.lasso, as.matrix(x[q,]), type=\"response\")");
			c.voidEval("pred <- predict(cv.lasso, as.matrix(x[q,]), s = \"lambda.min\")");
			
			// Get the coefficients
			c.voidEval("coef <- coef(cv.lasso)");
			String[] names = c.eval("row.names(coef)").asStrings();
			double[] coef = c.eval("as.matrix(coef)").asDoubles();			
			predicted = c.eval("pred").asDouble();
		
			if (predicted > 1) 
				predicted = 1;
			else if (predicted < 0) 
				predicted = 0;
			 
			if (debug) {
				String model = String.format(" + %s*%.4f", names[0], coef[0]);
				for (int i=1; i< coef.length; i++) {
					if (Math.abs(coef[i]) > 0.000001) 
						model += String.format(" + %s*%.4f", names[i], coef[i]);
				}
				System.out.println(query + "(" + predicted + "): " + model);				
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return predicted;
	}
}
