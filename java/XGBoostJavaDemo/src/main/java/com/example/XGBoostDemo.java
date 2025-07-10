package com.example;

import ml.dmlc.xgboost4j.java.*;
import java.util.HashMap;
import java.io.IOException;

public class XGBoostDemo {
    static {
        System.load("/usr/local/lib/libxgboost4j.so");
    }

    public static void main(String[] args) {
        try {
            float[] data = new float[] {1, 2, 3, 4};
            DMatrix trainMat = new DMatrix(data, 2, 2);
            trainMat.setLabel(new float[] {0, 1});

            HashMap<String, Object> params = new HashMap<>();
            params.put("objective", "binary:logistic");
            params.put("eval_metric", "logloss");

            Booster booster = XGBoost.train(trainMat, params, 2, new HashMap<>(), null, null);
            System.out.println("Booster created successfully: " + booster);

            System.out.println("Press Enter key to exit...");
            System.in.read();

        } catch (XGBoostError | IOException e) {
            e.printStackTrace();
        }
    }
}