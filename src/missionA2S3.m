%%%% EGB242 Assignment 2, Section 3 %%%%

%% Initialize workspace
clear all; close all; clc;

load('DataA2.mat'); 

if ~exist('imagesReceived', 'var')
    error('Variable ''imagesReceived'' not found in the data file.');
end

%% 3.1 Initial Image Analysis

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

% Saved the first image
imwrite(firstImage2D, 'FirstLandingSiteImage.png');

%% 3.2 Signal Analysis

% Image dimensions and parameters
numPixels = numRows * numCols; 
sampleRate = 1000;

% Time vector for the entire duration of one image
t = linspace(0, numPixels / sampleRate, numPixels);

% Frequency vector calculation
f = linspace(-sampleRate/2, sampleRate/2, numPixels);

% Plotted time-domain representation of received image data
figure;
plot(t, firstImageData);
title('Time Domain Representation of Received Image Data');
xlabel('Time (seconds)');
ylabel('Pixel Intensity');

% Performed Fourier Transform
imageDataFFT = fftshift(fft(firstImageData));

% Plotted frequency-domain representation
figure;
plot(f, abs(imageDataFFT));
title('Frequency Domain Representation of Received Image Data');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

%% 3.3 Filter Selection



%% 3.4 Noise Removal using the Chosen Filter

% Converted image to double precision for processing
firstImage2D_double = double(firstImage2D);

% Defined filter parameters
filterOrder = 1; % Lower order to reduce blurring
cutoffFrequency = 0.2; % Adjusted cutoff to preserve more details

% Generated frequency grid for filtering
[M, N] = size(firstImage2D_double);
[U, V] = meshgrid(-floor(N/2):floor(N/2)-1, -floor(M/2):floor(M/2)-1);
D = sqrt(U.^2 + V.^2); 
D0 = cutoffFrequency * (min(M, N)/2);

% Designed Butterworth low-pass filter
H = 1 ./ (1 + (D ./ D0).^(2 * filterOrder));

% Applied the filter in the frequency domain
imageFFT = fftshift(fft2(firstImage2D_double)); 
filteredFFT = imageFFT .* H; 
filteredImage2D = real(ifft2(ifftshift(filteredFFT))); 

% Normalized the filtered image to [0, 1]
filteredImage2D = filteredImage2D - min(filteredImage2D(:));
filteredImage2D = filteredImage2D / max(filteredImage2D(:));

% Applied adaptive histogram equalization to enhance contrast
filteredImage2D = adapthisteq(filteredImage2D, 'ClipLimit', 0.015, 'Distribution', 'rayleigh');

% Sharpened the image to enhance edges
sharpenedImage = imsharpen(filteredImage2D, 'Radius', 1, 'Amount', 1);

% Displayed the original and processed images side by side
figure;
subplot(1,2,1);
imshow(firstImage2D);
title('Original Image');

subplot(1,2,2);
imshow(sharpenedImage);
title('Filtered, Equalized, and Sharpened Image');

% Saved the processed image
imwrite(sharpenedImage, 'Filtered_Image.png');

%% EXTRA

% Launch the Image Filter App
% For more information on the application please refer to ImageFilterApp.m
ImageFilterApp;

%% 3.5 Process All Images and Display Side by Side

numImages = size(imagesReceived, 1); 

for idx = 1:numImages
    % Extracted the image data from the received signals
    imageData = imagesReceived(idx, :);
    
    % Reshaped the 1D image data into a 2D matrix
    image2D = reshape(imageData, [numRows, numCols]);
    
    % Converted image to double precision for processing
    image2D_double = double(image2D);
    
    % Defined filter parameters
    filterOrder = 1; 
    cutoffFrequency = 0.2;
    
    % Generated frequency grid for filtering
    [M, N] = size(image2D_double);
    [U, V] = meshgrid(-floor(N/2):floor(N/2)-1, -floor(M/2):floor(M/2)-1);
    D = sqrt(U.^2 + V.^2); 
    D0 = cutoffFrequency * (min(M, N)/2); 
    
    % Designed Butterworth low-pass filter
    H = 1 ./ (1 + (D ./ D0).^(2 * filterOrder));
    
    % Applied the filter in the frequency domain
    imageFFT = fftshift(fft2(image2D_double)); 
    filteredFFT = imageFFT .* H; 
    filteredImage2D = real(ifft2(ifftshift(filteredFFT))); 
    
    % Normalized the filtered image to [0, 1]
    filteredImage2D = filteredImage2D - min(filteredImage2D(:));
    filteredImage2D = filteredImage2D / max(filteredImage2D(:));
    
    % Applied adaptive histogram equalization to enhance contrast
    filteredImage2D = adapthisteq(filteredImage2D, 'ClipLimit', 0.015, 'Distribution', 'rayleigh');
    
    % Sharpened the image to enhance edges
    sharpenedImage = imsharpen(filteredImage2D, 'Radius', 1, 'Amount', 1);
    
    figure('Visible', 'off'); 
    subplot(1,2,1);
    imshow(image2D);
    title(['Original Image ' num2str(idx)]);
    
    subplot(1,2,2);
    imshow(sharpenedImage);
    title(['Filtered and Sharpened Image ' num2str(idx)]);
    
    saveas(gcf, ['Comparison_Image_' num2str(idx) '.png']);
    close(gcf); 
end



