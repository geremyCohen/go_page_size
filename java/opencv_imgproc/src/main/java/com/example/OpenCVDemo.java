package com.example;

import org.opencv.core.*;
import org.opencv.imgproc.Imgproc;

public class OpenCVDemo {
    static {
        // Load the custom compiled OpenCV library from specific location
        System.load("/usr/local/lib/libopencv_java4130.so");
    }

    public static void main(String[] args) {
        try {
            System.out.println("OpenCV version: " + Core.VERSION);
            
            // Create a simple 3x3 matrix (image)
            Mat srcImage = new Mat(3, 3, CvType.CV_8UC3);
            srcImage.put(0, 0, 255, 0, 0);  // Red pixel
            srcImage.put(0, 1, 0, 255, 0);  // Green pixel  
            srcImage.put(0, 2, 0, 0, 255);  // Blue pixel
            
            // Create destination matrix for converted image
            Mat grayImage = new Mat();
            
            // Perform color conversion (this will trigger our custom printf)
            System.out.println("Performing color conversion...");
            Imgproc.cvtColor(srcImage, grayImage, Imgproc.COLOR_BGR2GRAY);
            
            System.out.println("Color conversion completed successfully!");
            System.out.println("Original image size: " + srcImage.rows() + "x" + srcImage.cols());
            System.out.println("Gray image size: " + grayImage.rows() + "x" + grayImage.cols());
            
            // Clean up
            srcImage.release();
            grayImage.release();
            
            System.out.println("OpenCV imgproc demo completed successfully!");
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}