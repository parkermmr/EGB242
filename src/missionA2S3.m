%%%% EGB242 Assignment 2, Section 3 %%

%% Initialise workspace
clear all; close all;
load DataA2 imagesReceived;

%% 1.1 Initial Image Analysis

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

%% 3.2

% Image dimensions and parameters
numPixels = 307200; % Number of pixels in an image (640x480)
sampleRate = 1000;  % Pixels per second

% Time vector for the entire duration of one image
t = linspace(0, numPixels / sampleRate, numPixels);

% Frequency vector calculation
f = linspace(-sampleRate/2, sampleRate/2, numPixels);

% Reshape the 1D image data to a 2D matrix
imageData = imagesReceived(1, :); % Assuming the first row for the first image
image2D = reshape(imageData, [480, 640]);

% Visualizing the image in the time domain
figure;
plot(t, imageData);
title('Time Domain Representation of Received Image Data');
xlabel('Time (seconds)');
ylabel('Pixel Intensity');

% Visualizing the image in the frequency domain
% Perform Fourier Transform
imageDataFFT = fft(imageData);
imageDataFFT = fftshift(imageDataFFT); % Centering zero frequency component

figure;
plot(f, abs(imageDataFFT));
title('Frequency Domain Representation of Received Image Data');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

%% Save the time and frequency data
save('time_and_frequency_vectors.mat', 't', 'f');