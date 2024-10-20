% Image Filter App
% Description:
% The Image Filter App allows users to apply different filtering techniques to enhance
% the visibility of images received from a spacecraft. It supports the selection of
% various filters, adjusting filter parameters, and comparing original and processed images.
% The app emphasizes noise reduction, contrast enhancement, and edge sharpening.

% Features:
% - **Image Selection:** Users can load and select images received from the spacecraft.
% - **Filter Application:** Apply Butterworth low-pass filters with customizable orders and cutoff frequencies.
% - **Contrast Enhancement:** Utilize adaptive histogram equalization to enhance image contrast.
% - **Edge Sharpening:** Apply a sharpening filter to enhance image edges and detail.
% - **Side-by-Side Comparison:** Display original and processed images side by side for direct comparison.
% - **Save Functionality:** Ability to save the enhanced images for further analysis or reporting.

% How to Use:
% 1. **Load Images:** Start the app which automatically loads the images from a pre-defined location.
% 2. **Select Image:** Use the navigation controls to select different images for processing.
% 3. **Adjust Filter Settings:** Modify the filter order and cutoff frequency to suit the specific needs of the image.
% 4. **Apply Filters:** Click the "Apply Filter" button to process the selected image.
% 5. **View Comparison:** Observe the side-by-side comparison of the original and filtered images.
% 6. **Save Image:** Save the processed images by clicking the "Save Image" button.

% Notes:
% - The app is designed to handle images in a matrix format where each pixel's intensity is represented as a double-precision float.
% - Filters are applied in the frequency domain using the Fourier Transform to enhance performance and effectiveness.
% - Edge sharpening is performed after histogram equalization to ensure that contrast enhancements do not interfere with edge detection.

% Class ImageFilterApp < matlab.apps.AppBase
% This class implements the UI and functionality for the Image Filter App, including image loading,
% filtering, enhancement, and saving processed images for different types of analysis.

function ImageFilterApp

    hFig = uifigure('Name', 'Image Filter App', 'Position', [100, 100, 1200, 600]);
    
    % Create Grid Layout
    mainGrid = uigridlayout(hFig, [1, 2]);
    mainGrid.ColumnWidth = {'1x', '2x'};
    
    % Create Left Panel for Controls
    controlPanel = uipanel(mainGrid);
    controlPanel.Title = 'Controls';
    controlPanel.Layout.Row = 1;
    controlPanel.Layout.Column = 1;
    
    % Create Right Panel for Plots
    plotPanel = uipanel(mainGrid);
    plotPanel.Title = 'Plots';
    plotPanel.Layout.Row = 1;
    plotPanel.Layout.Column = 2;
    
    % Controls Grid
    controlGrid = uigridlayout(controlPanel, [15, 2]);
    controlGrid.RowHeight = repmat({'fit'}, 1, 15);
    controlGrid.ColumnWidth = {'fit', '1x'};
    controlGrid.Padding = [10 10 10 10];
    controlGrid.RowSpacing = 5;
    
    % Load Image Button
    loadImageButton = uibutton(controlGrid, 'push', 'Text', 'Load Image', 'ButtonPushedFcn', @loadImage);
    loadImageButton.Layout.Row = 1;
    loadImageButton.Layout.Column = [1, 2];
    
    % Filter Type Dropdown
    filterTypeLabel = uilabel(controlGrid, 'Text', 'Filter Type:');
    filterTypeLabel.Layout.Row = 2;
    filterTypeLabel.Layout.Column = 1;
    
    filterTypeDropdown = uidropdown(controlGrid, 'Items', {'Passive Filter 1', 'Passive Filter 2', 'Active Filter 1', 'Active Filter 2'});
    filterTypeDropdown.Layout.Row = 2;
    filterTypeDropdown.Layout.Column = 2;
    filterTypeDropdown.ValueChangedFcn = @onFilterTypeChanged;
    
    % Filter Order Slider
    filterOrderLabel = uilabel(controlGrid, 'Text', 'Filter Order:');
    filterOrderLabel.Layout.Row = 3;
    filterOrderLabel.Layout.Column = 1;
    
    filterOrderSlider = uislider(controlGrid, 'Limits', [1, 10], 'Value', 1);
    filterOrderSlider.Layout.Row = 3;
    filterOrderSlider.Layout.Column = 2;
    filterOrderSlider.ValueChangedFcn = @onParameterChanged;
    
    % Cutoff Frequency Slider
    cutoffFreqLabel = uilabel(controlGrid, 'Text', 'Cutoff Frequency (0.01 - 0.5):');
    cutoffFreqLabel.Layout.Row = 4;
    cutoffFreqLabel.Layout.Column = 1;
    
    cutoffFreqSlider = uislider(controlGrid, 'Limits', [0.01, 0.5], 'Value', 0.3);
    cutoffFreqSlider.Layout.Row = 4;
    cutoffFreqSlider.Layout.Column = 2;
    cutoffFreqSlider.ValueChangedFcn = @onParameterChanged;
    
    % Component Values for Active Filters
    RLabel = uilabel(controlGrid, 'Text', 'Resistance R (Ohms):');
    RLabel.Layout.Row = 5;
    RLabel.Layout.Column = 1;
    
    RField = uieditfield(controlGrid, 'numeric', 'Value', 820);
    RField.Layout.Row = 5;
    RField.Layout.Column = 2;
    RField.ValueChangedFcn = @onParameterChanged;
    
    CLabel = uilabel(controlGrid, 'Text', 'Capacitance C (Farads):');
    CLabel.Layout.Row = 6;
    CLabel.Layout.Column = 1;
    
    CField = uieditfield(controlGrid, 'numeric', 'Value', 1e-6);
    CField.Layout.Row = 6;
    CField.Layout.Column = 2;
    CField.ValueChangedFcn = @onParameterChanged;
    
    % Applied Filter Button
    applyButton = uibutton(controlGrid, 'Text', 'Apply Filter', 'ButtonPushedFcn', @applyFilter);
    applyButton.Layout.Row = 7;
    applyButton.Layout.Column = [1, 2];
    
    % Axes for Original and Filtered Images
    axesGrid = uigridlayout(plotPanel, [2, 2]);
    axesGrid.RowHeight = {'1x', '1x'};
    axesGrid.ColumnWidth = {'1x', '1x'};
    axesGrid.Padding = [10 10 10 10];
    axesGrid.RowSpacing = 10;
    
    % Original Image Axes
    originalAxes = uiaxes(axesGrid);
    originalAxes.Layout.Row = 1;
    originalAxes.Layout.Column = 1;
    title(originalAxes, 'Original Image');
    
    % Filtered Image Axes
    filteredAxes = uiaxes(axesGrid);
    filteredAxes.Layout.Row = 1;
    filteredAxes.Layout.Column = 2;
    title(filteredAxes, 'Filtered Image');
    
    % Original Frequency Domain Axes
    originalFreqAxes = uiaxes(axesGrid);
    originalFreqAxes.Layout.Row = 2;
    originalFreqAxes.Layout.Column = 1;
    title(originalFreqAxes, 'Original Frequency Domain');
    
    % Filtered Frequency Domain Axes
    filteredFreqAxes = uiaxes(axesGrid);
    filteredFreqAxes.Layout.Row = 2;
    filteredFreqAxes.Layout.Column = 2;
    title(filteredFreqAxes, 'Filtered Frequency Domain');
    
    % Disabled component fields for passive filters initially
    RLabel.Enable = 'off';
    RField.Enable = 'off';
    CLabel.Enable = 'off';
    CField.Enable = 'off';
    
    % Initialized image variables
    firstImage2D = [];
    imageLoaded = false;
    
    
    function loadImage(src, event)
        [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Image Files'}, 'Select an Image');
        if isequal(file, 0)
            return; 
        end
        imagePath = fullfile(path, file);
        img = imread(imagePath);
        if size(img, 3) == 3
            img = rgb2gray(img);
        end
        firstImage2D = double(img);
        
        % Normalize image data to [0, 1]
        firstImage2D = firstImage2D - min(firstImage2D(:));
        firstImage2D = firstImage2D / max(firstImage2D(:));
        
        % Displayed the original image
        figure;
        imshow(firstImage2D);
        title('Original Image');
        
        % Displayed the image in the app
        imshow(firstImage2D, 'Parent', originalAxes);
        title(originalAxes, 'Original Image');
        
        % Plotted the original frequency domain
        imageFFT = fftshift(fft2(firstImage2D));
        magnitude = log(abs(imageFFT) + 1);
        imshow(magnitude, [], 'Parent', originalFreqAxes);
        colormap(originalFreqAxes, jet); colorbar(originalFreqAxes);
        
        % Clear the filtered image axes
        cla(filteredAxes);
        cla(filteredFreqAxes);
        
        imageLoaded = true;
    end
    
    function onFilterTypeChanged(src, event)
        selectedFilter = filterTypeDropdown.Value;
        if strcmp(selectedFilter, 'Active Filter 1') || strcmp(selectedFilter, 'Active Filter 2')
            % Enable component fields
            RLabel.Enable = 'on';
            RField.Enable = 'on';
            CLabel.Enable = 'on';
            CField.Enable = 'on';
        else
            % Disable component fields
            RLabel.Enable = 'off';
            RField.Enable = 'off';
            CLabel.Enable = 'off';
            CField.Enable = 'off';
        end
    end
    
    function applyFilter(src, event)
        if ~imageLoaded
            uialert(hFig, 'Please load an image first.', 'No Image Loaded');
            return;
        end
        
        % Get current parameter values
        filterOrderValue = round(filterOrderSlider.Value);
        cutoffFreqValue = cutoffFreqSlider.Value;
        RValue = RField.Value;
        CValue = CField.Value;
        selectedFilter = filterTypeDropdown.Value;

        switch selectedFilter
            case 'Passive Filter 1'
                % Implemented Passive Filter 1
                filteredImage = applyPassiveFilter1(firstImage2D, filterOrderValue, cutoffFreqValue);
            case 'Passive Filter 2'
                % Implemented Passive Filter 2
                filteredImage = applyPassiveFilter2(firstImage2D, filterOrderValue, cutoffFreqValue);
            case 'Active Filter 1'
                % Implemented Active Filter 1 (High-pass filter)
                filteredImage = applyActiveFilter1(firstImage2D, RValue, CValue);
            case 'Active Filter 2'
                % Implemented Active Filter 2 (Low-pass filter)
                filteredImage = applyActiveFilter2(firstImage2D, RValue, CValue, filterOrderValue, cutoffFreqValue);
            otherwise
                errordlg('Unknown filter type selected.', 'Error');
                return;
        end
        
        % Displayed the filtered image
        figure;
        imshow(filteredImage);
        title(['Filtered Image using ', selectedFilter]);
        
        % Displayed the image in the app
        imshow(filteredImage, 'Parent', filteredAxes);
        title(filteredAxes, ['Filtered Image using ', selectedFilter]);
        
        % Plotted the filtered frequency domain
        filteredFFT = fftshift(fft2(filteredImage));
        magnitude = log(abs(filteredFFT) + 1);
        imshow(magnitude, [], 'Parent', filteredFreqAxes);
        colormap(filteredFreqAxes, jet); colorbar(filteredFreqAxes);
        title(filteredFreqAxes, 'Filtered Frequency Domain');
    end
    
    function onParameterChanged(src, event)
        % Parameters are applied when 'Apply Filter' is clicked
    end
    
    % Filter Implementation Functions
    
    function filteredImage = applyPassiveFilter1(imageData, order, cutoffFreq)
        
        [M, N] = size(imageData);
        D0_low = cutoffFreq * (min(M, N)/2) * 0.8;
        D0_high = cutoffFreq * (min(M, N)/2) * 1.2;
        [U, V] = meshgrid(-floor(N/2):floor(N/2)-1, -floor(M/2):floor(M/2)-1);
        D = sqrt(U.^2 + V.^2);
        
        H_low = 1 ./ (1 + (D ./ D0_low).^(2 * order));
        H_high = 1 ./ (1 + (D0_high ./ (D + eps)).^(2 * order));
        H = H_low .* H_high;
        
        imageFFT = fftshift(fft2(imageData));
        filteredFFT = imageFFT .* H;
        filteredImage = real(ifft2(ifftshift(filteredFFT)));
        
        % Normalized the image to [0, 1]
        filteredImage = filteredImage - min(filteredImage(:));
        filteredImage = filteredImage / max(filteredImage(:));
    end
    
    function filteredImage = applyPassiveFilter2(imageData, order, cutoffFreq)

        [M, N] = size(imageData);
        D0_low = cutoffFreq * (min(M, N)/2) * 0.8;
        D0_high = cutoffFreq * (min(M, N)/2) * 1.2;
        [U, V] = meshgrid(-floor(N/2):floor(N/2)-1, -floor(M/2):floor(M/2)-1);
        D = sqrt(U.^2 + V.^2);
        
        H_low = 1 ./ (1 + (D ./ D0_low).^(2 * order));
        H_high = 1 ./ (1 + (D0_high ./ (D + eps)).^(2 * order));
        H = 1 - (H_low .* H_high);
        
        imageFFT = fftshift(fft2(imageData));
        filteredFFT = imageFFT .* H;
        filteredImage = real(ifft2(ifftshift(filteredFFT)));
        
        % Normalized the image to [0, 1]
        filteredImage = filteredImage - min(filteredImage(:));
        filteredImage = filteredImage / max(filteredImage(:));
    end
    
    function filteredImage = applyActiveFilter1(imageData, R, C)
        
        % Computed the cutoff frequency
        fc = 1 / (2 * pi * R * C);
        
        % Converted cutoff frequency to normalized frequency
        cutoffFreq = fc / (1 / (2 * min(size(imageData))));
        
        % Designed the Butterworth high-pass filter
        [M, N] = size(imageData);
        [U, V] = meshgrid(-floor(N/2):floor(N/2)-1, -floor(M/2):floor(M/2)-1);
        D = sqrt(U.^2 + V.^2);
        D0 = cutoffFreq * (min(M, N)/2);
        
        H = 1 ./ (1 + (D0 ./ (D + eps)).^(2));
        
        imageFFT = fftshift(fft2(imageData));
        filteredFFT = imageFFT .* H;
        filteredImage = real(ifft2(ifftshift(filteredFFT)));
        
        % Normalized the image to [0, 1]
        filteredImage = filteredImage - min(filteredImage(:));
        filteredImage = filteredImage / max(filteredImage(:));
    end
    
    function filteredImage = applyActiveFilter2(imageData, R, C, order, cutoffFreq)
        
        % Computed the cutoff frequency
        fc = 1 / (2 * pi * R * C);
        
        % Converted cutoff frequency to normalized frequency
        cutoffFreq = fc / (1 / (2 * min(size(imageData))));
        
        % Designed the Butterworth low-pass filter
        [M, N] = size(imageData);
        [U, V] = meshgrid(-floor(N/2):floor(N/2)-1, -floor(M/2):floor(M/2)-1);
        D = sqrt(U.^2 + V.^2);
        D0 = cutoffFreq * (min(M, N)/2);
        
        H = 1 ./ (1 + (D ./ D0).^(2 * order));
        
        imageFFT = fftshift(fft2(imageData));
        filteredFFT = imageFFT .* H;
        filteredImage = real(ifft2(ifftshift(filteredFFT)));
        
        % Normalized the image to [0, 1]
        filteredImage = filteredImage - min(filteredImage(:));
        filteredImage = filteredImage / max(filteredImage(:));
    end
end


