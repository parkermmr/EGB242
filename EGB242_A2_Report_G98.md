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
Following the success of the communication system developed during our initial placement at BASA, our team has been given an important role in the primary engineering team for the next crewed Mars expedition. We have made several improvements to improve performance further, building on the results of Assignment 1, where the system successfully kept clear and dependable contact between mission control and the spacecraft.

This expedition plans to send a rover to investigate the proposed settlement location for humans on Mars to create a permanent human habitat. The primary improvements include the use of Fourier Series in sophisticated noise reduction algorithms to get rid of the periodic noise and provide cleaner audio transmission. The method of converting analogue to digital has also been improved to lower latency and improve signal integrity. These improvements are essential as our team prepares for the MARS-242 mission.

Our work is divided into three main sections:
De-noising the Communication Channel: The spacecraft that is travelling towards Mars has been equipped with the communication system that was developed in Assignment 1. As the spacecraft leaves Earth's atmosphere, atmospheric distortions cause the audio to become inaudible even though the radio transmitter and receiver operate as designed. A colleague has created a more realistic channel model that includes additive noise and distortions that vary with frequency. To guarantee clear communication, we aim to describe and counteract these noise processes.

Rover Camera Control: Upon arrival, the astronauts will send out a rover to explore prospective landing locations on Mars. The rover will send pictures of these locations back to the spaceship so the astronauts can decide on a secure landing spot. The rover's camera angle and axis are essential to this procedure since it has to spin on its yaw axis to properly photograph the Martian terrain.

Choosing a Landing Site: Once the rover has successfully taken images of possible landing locations, the photos will be sent to BASA Headquarters, where an appropriate landing spot will be selected. Our team will also have to filter the extra noise the communication channel produces for the visual signals.

**This report will highlight ...add to this once we have done reflection so we can highlight important learning experiences from this assignment**

---

## Section 1: De-noising the Communication Channel

### 1.1 Audio Signal Analysis
Time-Domain Plot of Multiplexed Audio Signal
Graph 1: The recorded audio waveform in the time domain over 20 seconds shows amplitude variations, indicating potential noise interference during transmission. These variations suggest the influence of multiple noise sources as the signal passes through Earth's atmosphere and space.

Frequency-Domain Plot of Multiplexed Audio Signal
Graph 2: This plot reveals distinct peaks at various frequencies. Each peak represents different components within the multiplexed audio signal, highlighting the carrier frequencies modulated with the original audio signals and potential noise frequencies introduced during transmission.

Carrier Frequencies
Graph 3: Significant peaks at approximately 10^4 Hz, 3 x 10^4 Hz, 5 x 10^4 Hz, and 7 x 10^4 Hz are marked with red circles. These peaks indicate the primary frequencies for de-multiplexing the audio signals and suggest potential noise interference.

Demodulated Audio Signal Analysis
Carrier Frequency: 8260.00 Hz

Graph 4 (Time Domain): The signal oscillates around zero amplitude with notable fluctuations, indicating the presence of noise and distortions likely from single-frequency tones introduced during transmission.

Graph 5 (Frequency Domain): A dominant peak at 0 Hz suggests the main frequency component of the signal, with additional smaller peaks indicating harmonics or noise.

Carrier Frequency: 24240.00 Hz

Graph 6 (Time Domain): Amplitude variations indicate that the audio signal retains its structure but is significantly influenced by noise and distortions from atmospheric and single-tone noise effects.

Graph 7 (Frequency Domain): A significant peak at 0 Hz with additional smaller peaks highlights the presence of noise components, emphasizing the need for de-noising techniques.

Carrier Frequency: 40260.00 Hz

Graph 8 (Time Domain): The signal shows significant fluctuations around zero amplitude, indicating the impact of noise and distortions during transmission.

Graph 9 (Frequency Domain): A dominant peak at 0 Hz and additional smaller peaks suggest the presence of noise or harmonics, emphasizing the necessity for cleaner signal processing.

Carrier Frequency: 56100.00 Hz

Graph 10 (Time Domain): Variations in amplitude indicate the audio signal is heavily influenced by noise and distortions from atmospheric distortions and single-tone noise effects.

Graph 11 (Frequency Domain): A significant peak at 0 Hz with smaller peaks suggests noise components, highlighting the need for de-noising techniques to enhance audio quality.

Carrier Frequency: 72080.00 Hz

Graph 12 (Time Domain): Fluctuations around zero amplitude indicate the presence of noise and distortions, affecting the signal’s structure.

Graph 13 (Frequency Domain): A strong low-frequency component with additional noise elements suggests the presence of single-tone noise effects, necessitating effective de-noising strategies.
#### Objective

In this section, we aim to visualize the noisy multiplexed audio signal received through the communication channel. This involves plotting the signal in both the time and frequency domains to better understand its structure and identify any noise components that may distort the audio.

#### Method

**Time-Domain Analysis:** The multiplexed audio signal, `audioMultiplexNoisy`, was plotted as a function of time to observe amplitude variations and identify distortions over time.

**Frequency-Domain Analysis:** Using the Fast Fourier Transform (FFT), the frequency content of the signal was analyzed. This helped identify any high-frequency noise or narrow-band interference that could be removed later.

**MATLAB Implementation**

** LEAVE FOR PARKER **

#### Results
Include plots and discuss the observable characteristics.

![Alt text](<Figures/1.1 Recorded Audio Waveform in Time Domain.png>){width=500}
![Alt text](<Figures/1.1 Frequency Domain Plot of Multiplexed Audio Signal.png>){width=500}
(detailed analysis will be included)

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
To determine the impulse response \( h(t) \) of the channel, we need to choose an appropriate test signal \( x(t) \) to transmit through the channel. The theoretical ideal choice is the **Dirac delta function** \( δ(t) \), which has the property:

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

** LEAVE FOR PARKER **

#### Results
Plot and compare the frequency responses.

#### Analysis
Provide a mathematical analysis, qualatative and quantative. Use logic and reasoning as a basis and pull on references if needed.

#### Limitations
Discuss the limitations of the Dirac Delta in practical applications and why signals like chirp can be better. Use logic and reasoning as a basis and pull on references if needed.

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
In this section, the aim was to develop and analyze the mathematical model of the servo motor controlling the yaw angle, \( \psi(t) \), of a camera mounted on our Mars rover. The model was based on the transfer function in the Laplace domain, given the motor's characteristics with parameters \( K_m = 1 \) and \( \alpha = 0.5 \). The feasibility of the system was evaluated by deriving the step response of the servo motor in the Laplace domain using the given transfer function and performing an inverse Laplace transform to obtain the time-domain representation of the motor's response to a unit step input in voltage. A time vector was generated over the interval \( t \in [0, 20) \) seconds with \( 10^4 \) samples, and both the step input and the corresponding step response were simulated and plotted to visualize how the yaw angle \( \psi(t) \) evolves over time.

#### Method

**Laplace Domain Analysis was conducted:**
The transfer function of the servo motor was defined as:
\[
G_m(s) = \frac{K_m}{s(s + \alpha)}
\]
where \( K_m = 1 \) and \( \alpha = 0.5 \). The Laplace transform of a unit step input voltage, \( U(s) = \frac{1}{s} \), was applied to determine the system's response in the Laplace domain.

**Inverse Laplace Transform was applied:**
The expression obtained from multiplying the motor's transfer function by the unit step input,
\[
\frac{K_m}{s^2(s + \alpha)}
\]
was simplified using partial fractions. The inverse Laplace transform of each term in the partial fraction decomposition was calculated to obtain the time-domain response, \( \psi_{out}(t) \). Resultantly, the system response can be modeled as such:
\[
\psi_{out} = -4 + 2t + 4e^{-0.5t};
\]

**A time vector and simulation were created:**
A time vector \( t \) was generated using `linspace` to produce \( 10^4 \) evenly spaced samples over the interval from 0 to 20 seconds. The step response \( \psi_{out}(t) \) was computed over this time vector using the derived time-domain formula.

**Plotting was performed:**
The step response \( \psi_{out}(t) \) was plotted alongside the step input to visually compare the system's output behavior to the constant input voltage. Plotting tools that supported annotations and grid lines were utilized to enhance the readability and interpretation of the plot.

This approach provided a systematic exploration of the servo motor's capability to effectively control the yaw angle of a Mars rover’s camera, highlighting areas requiring potential enhancements.

#### Results
![Comparison of Step Input and Step Response](Figures/2.1_Step_Response_of_System.png)
***Figure X:** This graph displays the comparison between the step input and the step response over a time interval of 0 to 20 seconds. The step input, represented as a dashed line, remains constant throughout the period, illustrating the constant voltage applied to the servo motor. The solid line depicts the step response, \( \psi_{out}(t) \), which shows the yaw angle of the camera as it evolves over time due to the applied input voltage. The response increases proportionally with time indicated by its linearity.*

#### Analysis
The response in *Figure X* clearly illustrates that under a constant input voltage, the camera's yaw angle \( \psi_{out}(t) \) does not converge to a constant value. Instead, it continues to increase linearly with time.The linear behavior of the response suggests that there is no damping or stabilizing mechanism inherent in the system that would cause the yaw angle to level off or stabilize at a certain point, which could be necessary for precise control and positioning of the camera. Given that the yaw angle does not stabilize, additional control mechanisms, such as feedback systems or damping components, might be required to achieve desired control objectives like reaching and maintaining a specific yaw angle. The system as modeled might be insufficient for tasks that require the camera to fix on a particular target or to perform sweeps and then hold at a specific view, indicating the potential need for revising the motor control strategy or incorporating other elements like sensors and feedback loops. 

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
