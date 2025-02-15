# 🫀 FPGA Implementation of ECG Signal Processing Using Fast Fourier Transform (FFT)

> 📢 **Coming Soon**: Full academic paper on FPGA-based real-time ECG signal processing implementation


**Author:** Marcu-Cristian Petric  
**Affiliation:** Technical University of Cluj-Napoca  
**Date:** January 2025

## ⚠️ Important Notice

**Please refer to the comprehensive documentation in `documentation.pdf` for complete technical details, implementation specifics, and results.**

## Project Overview

The electrocardiogram (ECG or EKG) is a crucial diagnostic tool for verifying heart electrical activity. Traditional software-based processing systems often suffer from latency and high power consumption, limiting their real-time applications. This project addresses these challenges through FPGA implementation.

### Abstract

This paper presents the design and implementation of an FPGA-based system for real-time ECG signal processing. The system filters ECG data through Fast Fourier Transform (FFT) and Inverse Fast Fourier Transform (IFFT) to reconstruct the filtered signal. It then computes R-R intervals and the heart rate, displayed on a 7-segment display, while detecting cardiac conditions such as bradycardia and tachycardia. The efficient real-time data monitoring and low power consumption demonstrate the FPGA's suitability for resource-constrained medical applications.

### Key Features
- Real-time ECG signal processing
- FFT-based noise filtering
- R-peak detection and heart rate calculation
- Cardiac anomaly detection (bradycardia, tachycardia)
- Low latency and power consumption

## 📚 Documentation

**The complete technical documentation (`documentation.pdf`) includes:**
- Detailed theoretical background
- System architecture and design decisions
- Implementation specifics and VHDL entity descriptions
- Comprehensive test results and analysis
- Resource utilization reports
- References and citations

> 📖 **Strongly Recommended**: Please read the full documentation before working with or modifying the implementation. The PDF contains crucial information about the system's design, constraints, and performance characteristics.

## Keywords
*ECG signal processing, FPGA, Fast Fourier Transform (FFT), R-peak detection, Bradycardia, Tachycardia, Real-time monitoring, Medical signal processing, Low power consumption*

## Table of Contents

1. [Introduction](#introduction)
2. [Theoretical Considerations](#theoretical-considerations)
   - [ECG Interpretation](#ecg-interpretation)
   - [Discrete and Fast Fourier Transform (DFT and FFT)](#discrete-and-fast-fourier-transform-dft-and-fft)
   - [AXI4-Stream Protocol](#axi4-stream-protocol)
   - [Cardiac Anomaly](#cardiac-anomaly)
3. [Design](#design)
   - [Data Processing Pipeline](#data-processing-pipeline)
   - [Undesired frequencies](#undesired-frequencies)
   - [R-Peak Detection algorithm](#r-peak-detection-algorithm)
4. [Implementation](#implementation)
   - [Implementation details](#implementation-details)
   - [FFT IP Core Configuration](#fft-ip-core-configuration)
   - [Elaborated Design](#elaborated-design)
   - [Entities](#entities)
5. [Results](#results)
   - [Artificial Data Filtering Tests](#artificial-data-filtering-tests)
   - [Real ECG Data Filtering Tests](#real-ecg-data-filtering-tests)
   - [Implementation obtained parameters](#implementation-obtained-parameters)
6. [Summary and Conclusions](#summary-and-conclusions)
7. [References](#references) 
