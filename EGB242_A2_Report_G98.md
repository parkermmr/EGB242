# BASA National Space Program: Radio Frequency and Telecommunication Division

**Group Number:** 98  
**Group Members:** Parker Rennie (n11543043), Name2 (Student ID), Name3 (Student ID)  
**Unit Name:** Signal Analysis
**Unit Code:** EGB242

## Table of Contents

0. [Introduction](#introduction)
1. [Section 1: De-noising the Communication Channel](#section-1-de-noising-the-communication-channel)
   - [1.1 Audio Signal Analysis](#11-audio-signal-analysis)
   - [1.2 Demodulation of Audio Signals](#12-demodulation-of-audio-signals)
   - [1.3 Modeling Frequency-Dependent Distortion](#13-modeling-frequency-dependent-distortion)
   - [1.4 Noise Reduction Application](#14-noise-reduction-application)
   - [1.5 Single-Tone Noise Removal](#15-single-tone-noise-removal)
2. [Section 2: Rover Camera Control](#section-2-rover-camera-control)
   - [2.1 DC Motor Modeling](#21-dc-motor-modeling)
   - [2.2 Feedback System Integration](#22-feedback-system-integration)
   - [2.3 System Dynamics Analysis](#23-system-dynamics-analysis)
   - [2.4 Gain Adjustment Analysis](#24-gain-adjustment-analysis)
   - [2.5 Control System for Panoramic Views](#25-control-system-for-panoramic-views)
   - [2.6 Panorama Capture Task](#26-panorama-capture-task)
3. [Section 3: Choosing a Landing Site](#section-3-choosing-a-landing-site)
   - [3.1 Initial Image Analysis](#31-initial-image-analysis)
   - [3.2 Signal Analysis](#32-signal-analysis)
   - [3.3 Filter Selection](#33-filter-selection)
   - [3.4 Noise Removal and Image Cleanup](#34-noise-removal-and-image-cleanup)
   - [3.5 Full Image Set Processing](#35-full-image-set-processing)
4. [Conclusion](#conclusion)
5. [Reflection](#reflection)
   - [Learning & Understanding](#learning--understanding)
   - [Challenges & Limitations](#challenges--limitations)
   - [Future Improvements](#future-improvements)
   - [Teamwork & Collaboration](#teamwork--collaboration)
6. [References](#references)
7. [Appendices](#appendices)
   - [Appendix A: MATLAB Source Code](#appendix-a-matlab-source-code)
   - [Appendix B: Additional Material](#appendix-b-additional-material)

---

## Introduction

*Provide a brief overview of the assignment, including its purpose and the main challenges faced in the communication and control systems described.*

---

## Section 1: De-noising the Communication Channel

### 1.1 Audio Signal Analysis

#### Objective
Analyze the noisy multiplexed audio signal.

#### Method
Plot the signal in both time and frequency domains.

#### Results
Include plots and discuss the observable characteristics.

### 1.2 Demodulation of Audio Signals

#### Objective
Demodulate the multiplexed audio signals.

#### Method
Apply the demultiplexing system developed previously.

#### Results
Discuss the audio quality and plot signals in both domains.

### 1.3 Modeling Frequency-Dependent Distortion

#### Objective
Model the channel's impulse response.

#### Method
Transmit test signals and analyze the channel's frequency response.

#### Results
Plot and compare the frequency responses.

### 1.4 Noise Reduction Application

#### Objective
Apply the modeled channel distortion for noise reduction.

#### Method
Reverse the channel distortion and demodulate.

#### Results
Analyze and plot the de-noised audio signals.

### 1.5 Single-Tone Noise Removal

#### Objective
Remove single-frequency noise.

#### Method
Identify and filter out the single-tone noise.

#### Results
Listen to the cleaned audio and provide time and frequency domain plots.

---

## Section 2: Rover Camera Control

### 2.1 DC Motor Modeling

#### Objective
Model the camera's yaw control motor.

#### Method
Apply Laplace transforms to find the step response.

#### Results
Plot and compare the step response with the step input.

### 2.2 Feedback System Integration

#### Objective
Enhance control with a feedback system.

#### Method
Model and simulate the feedback system.

#### Results
Discuss changes in control and plot the step response.

### 2.3 System Dynamics Analysis

#### Objective
Analyze the feedback system dynamics.

#### Method
Determine natural frequency, damping ratio, and other dynamics.

#### Results
Discuss the suitability of the feedback system for the camera control.

### 2.4 Gain Adjustment Analysis

#### Objective
Adjust system gains to refine control.

#### Method
Simulate different gain values and analyze their effects.

#### Results
Plot responses for varying gains and determine optimal settings.

### 2.5 Control System for Panoramic Views

#### Objective
Configure the control system for panoramic sweeps.

#### Method
Adjust gain settings to meet specific motion requirements.

#### Results
Store and discuss the final transfer function settings.

### 2.6 Panorama Capture Task

#### Objective
Capture a panoramic sweep on Mars.

#### Method
Implement the control system with the designed settings.

#### Results
Describe the panorama capture process and outcomes.

---

## Section 3: Choosing a Landing Site

### 3.1 Initial Image Analysis

#### Objective
Analyze the first received image for noise characteristics.

#### Method
Display and assess the image quality.

#### Results
Discuss the quality and any noticeable noise patterns.

### 3.2 Signal Analysis

#### Objective
Analyze the image signal in time and frequency domains.

#### Method
Construct and plot the necessary vectors.

#### Results
Identify noise components and their characteristics.

### 3.3 Filter Selection

#### Objective
Choose the appropriate filter for noise removal.

#### Method
Analyze different filters based on provided schematics.

#### Results
Justify the selection of a specific filter type.

### 3.4 Noise Removal and Image Cleanup

#### Objective
Apply the selected filter to clean the image signal.

#### Method
Implement the filtering process.

#### Results
Display the cleaned image and assess the removal of noise.

### 3.5 Full Image Set Processing

#### Objective
Repeat the noise removal process for all images.

#### Method
Factorize and implement the de-noising process.

#### Results
Display cleaned images and provide landing site recommendations.

---

## Conclusion

*Summarize the key findings, the effectiveness of the noise removal and control systems, and any conclusions drawn from the project.*

---

## Reflection

### Learning & Understanding
*Summarize key learnings from the project.*

### Challenges & Limitations
*Discuss the main challenges and limitations faced.*

### Future Improvements
*Propose potential improvements for future projects.*

### Teamwork & Collaboration
*Reflect on teamwork and collaboration during the project.*

---

## References
*A list of havard style references relevant to the project.*

---

## Appendices

### Appendix A: MATLAB Source Code

*Include raw source code relevant to the tasks completed.*

### Appendix B: Additional Material

*Any additional diagrams, data, or notes used in the report.*