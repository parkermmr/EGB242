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