package com.example.jni;

public class CPUInfo {
    static {
        System.loadLibrary("cpuinfo");
    }

    // Native method declaration
    public native int getPageSize();
    public native int getCPUCores();
    public native String getCPUModel();

    // Test method
    public static void main(String[] args) {
        CPUInfo info = new CPUInfo();
        System.out.println("Page Size: " + info.getPageSize() + " bytes");
        System.out.println("CPU Cores: " + info.getCPUCores());
        System.out.println("CPU Model: " + info.getCPUModel());
    }
}
