%%%% EGB242 Assignment 2, Section 3 %%

%% Initialise workspace
clear all; close all;
load DataA2 imagesReceived;

%% 3.1 Initial Image Analysis

% Dimensions of the image
numRows = 480;
numCols = 640;  

% Extracted the first image data from the received signals
firstImageData = imagesReceived(1, :);

% Reshaped the 1D image data into a 2D matrix
firstImage2D = reshape(firstImageData, [numRows, numCols]);

% Displayed the first image
figure;
imshow(firstImage2D);
title('First Received Image of Landing Site');

imwrite(firstImage2D, 'FirstLandingSiteImage.png');

%% 3.2 Signal Analysis

% Image dimensions and parameters
numPixels = 307200; 
sampleRate = 1000;  

% Time vector for the entire duration of one image
t = linspace(0, numPixels / sampleRate, numPixels);

% Frequency vector calculation
f = linspace(-sampleRate/2, sampleRate/2, numPixels);

% Reshaped the 1D image data to a 2D matrix
imageData = imagesReceived(1, :);
firstImage2D = reshape(firstImageData, [480, 640]);

figure;
plot(t, firstImageData);
title('Time Domain Representation of Received Image Data');
xlabel('Time (seconds)');
ylabel('Pixel Intensity');

% Perform Fourier Transform
imageDataFFT = fft(firstImageData);
imageDataFFT = fftshift(imageDataFFT);

figure;
plot(f, abs(imageDataFFT));
title('Frequency Domain Representation of Received Image Data');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

%% 3.3 Filter Selection

% ----------------------> APPLICATION BUILT FOR THE PURPOSES OF THIS TASK <---------------------- %

% For more information on the application please refer to
% FilterAnalysisApp.m
FilterAnalysisApp

%% 3.4 Noise Removal using the Chosen Filter



