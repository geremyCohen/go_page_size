package com.example;

import ml.dmlc.xgboost4j.java.DMatrix;
import ml.dmlc.xgboost4j.java.XGBoost;
import ml.dmlc.xgboost4j.java.Booster;

public class XGBoostDemo {
    public static void main(String[] args) {
        try {
            // Simple example using dummy data
            DMatrix trainMat = new DMatrix(new float[]{1,2,3,4}, 2, 2);
            Booster booster = XGBoost.train(trainMat, null, 1, new java.util.HashMap<>(), null, null);
            System.out.println("Booster created successfully: " + booster);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}