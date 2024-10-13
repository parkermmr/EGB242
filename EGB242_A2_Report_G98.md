# BASA National Space Program: Radio Frequency and Telecommunication Division

**Group Number:** 98  
**Group Members:** Parker Rennie (n11543043), Jack Bowen (n10765395), Deven Johnson (n12031615)  
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
Following the success of the communication system developed during our initial placement at BASA, our team has been given an important role in the primary engineering team for the next crewed Mars expedition. We have made a number of improvements to further improve performance, building on the results of Assignment 1, where the system successfully kept clear and dependable contact between mission control and the spacecraft.

This expedition plans to send a rover to investigate the proposed settlement location for humans on mars in order to create a permanent human habitat. The primary improvements include the use of Fourier Series in sophisticated noise reduction algorithms to get rid of the periodic noise and provide cleaner audio transmission. The method of converting analogue to digital has also been improved to lower latency and improve signal integrity. These improvements are essential as our team prepares for the MARS-242 mission.

Our work is divided into three main sections:
De-noising the Communication Channel: The spacecraft that is traveling towards Mars has been equipped with the communication system that was developed in Assignment 1. As the spacecraft leaves Earth's atmosphere, atmospheric distortions cause the audio to become inaudible even though the radio transmitter and receiver are operating as designed. A colleague has created a more realistic channel model that includes additive noise and distortions that vary with frequency. To guarantee clear communication, our objective is to describe and counteract these noise processes.

Rover Camera Control: Upon arrival the astronauts will send out a rover to explore prospective landing locations on Mars. The rover will send pictures of these locations back to the spaceship so the astronauts can decide on a secure landing spot. The rover's camera angle and axis is essential to this procedure since it has to spin on its yaw axis in order to properly photograph the Martian terrain.

Choosing a Landing Site: Once the rover has successfully taken images of possible landing locations, the photos will be sent to BASA Headquarters, where an appropriate landing spot will be selected. Our team will also have to filter the extra noise that the communication channel produces for the visual signals.

This report will highlight ...add to this once we have done reflection so we can highlight important learning experiences from this assignment

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
In this task, we aim to model the frequency-dependent distortion introduced by a communication channel. The channel is characterized as a Linear Time-Invariant (LTI) system, where the output signal \( y(t) \) is the convolution of the input signal \( x(t) \) with the channel's impulse response \( h(t) \):
\[ y(t) = x(t) * h(t) \]
The characteristics of the channel are obfuscated through the `channel.p` MATLAB library and can be called through the 'channel(sid, x, fs)' function. This task aims to test the channel via a test signal aiming to model the impulse and frequency response of the channel. 

#### Method
To determine the impulse response \( h(t) \) of the channel, we need to choose an appropriate test signal \( x(t) \) to transmit through the channel. The ideal choice is the **Dirac delta function** \( δ(t) \), which has the property:

\[ δ(t) * h(t) = h(t) \]

This property is because the convolution of \( h(t) \) with \( δ(t) \) yields \( h(t) \) itself, effectively "sampling" the impulse response directly. The Dirac delta function is defined such that:

\[ δ(t) =
\begin{cases}
\infty, & t = 0 \\
0, & t \neq 0
\end{cases}
\]

and satisfies the sifting property:

\[ \int_{-\infty}^{\infty} δ(t - τ) h(τ) \, dτ = h(t) \]

When \(x(t) = δ(t)\), the output \(y(t) \) becomes:

\[ y(t) = δ(t) * h(t) = h(t) \]

#### MATLAB Implementation
By transmitting this impulse signal through the channel using the provided channel function, we obtain \( h(t) \) :

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