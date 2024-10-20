% Signal Visualization App
% Description:
% This MATLAB app allows users to load an audio or signal file, apply
% denoising techniques, and visualize the signal in both the time and frequency
% domains. The app is equipped with user-friendly controls and visualizations, 
% making it a useful tool for signal processing tasks such as noise reduction 
% and spectral analysis. The app accepts signals in both .wav and .mat formats.

% Features:
% - Load Signal: The user can load audio files (.wav) or signal data from .mat files.
% - Apply Denoising: The app applies a denoising filter to the loaded signal.
% - Time Domain Visualization: The app displays the signal waveform in the time domain.
% - Frequency Domain Visualization: The app shows the magnitude spectrum of the signal in the frequency domain.
% - Interactive Controls: The user can toggle between viewing the time and frequency domains.

% How to Use:
% 1. Press the "Load Signal" button to load an audio or signal file.
% 2. Use the checkboxes to select whether to display the time domain, frequency domain, or both.
% 3. Press the "Apply Denoising" button to apply noise reduction to the loaded signal.
% 4. The app will update the plots accordingly in the Time Domain and Frequency Domain panels.

% Notes:
% - The signal must be in a valid format: either .wav or .mat with 'signal' and 'fs' fields.
% - The sampling frequency (fs) is automatically detected from the file.
% - Plots are updated automatically after loading a signal or applying denoising.

% Class SignalVisualizationApp < matlab.apps.AppBase
% This class contains all the components and functionality of the app.

classdef SignalVisualizationApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        LeftPanel               matlab.ui.container.Panel
        RightPanel              matlab.ui.container.Panel
        
        % Left Panel Components
        LoadSignalButton        matlab.ui.control.Button
        ApplyDenoisingButton    matlab.ui.control.Button
        FrequencyDomainCheckBox matlab.ui.control.CheckBox
        TimeDomainCheckBox      matlab.ui.control.CheckBox
        
        % Right Panel Components
        UIAxes1                 matlab.ui.control.UIAxes
        UIAxes2                 matlab.ui.control.UIAxes
    end
    
    properties (Access = private)
        input_signal            % User-loaded or generated signal
        fs                      % Sampling frequency
        denoised_signal         % Denoised signal
        outputDir               % Output directory for data
        frequency_axis          % Frequency axis for plotting
    end
    
    methods (Access = private)
        
        function startupFcn(app)
            app.fs = 44100;
            app.outputDir = 'Output/Data1';
            app.TimeDomainCheckBox.Value = true;
            app.FrequencyDomainCheckBox.Value = true;
        end
        
        function LoadSignalButtonPushed(app, ~)
            [file, path] = uigetfile({'*.wav;*.mat'}, 'Select an Audio or MAT File');
            if isequal(file, 0)
                return;
            end
            [~, ~, ext] = fileparts(file);
            if strcmp(ext, '.mat')
                data = load(fullfile(path, file));
                if isfield(data, 'signal') && isfield(data, 'fs')
                    app.input_signal = data.signal;
                    app.fs = data.fs;
                else
                    uialert(app.UIFigure, 'MAT file must contain variables "signal" and "fs".', 'Invalid File');
                    return;
                end
            else
                [app.input_signal, app.fs] = audioread(fullfile(path, file));
            end
            app.input_signal = app.input_signal(:)';

            plotSignal(app, app.input_signal, 'Proccessed Signal');
        end
        
        function ApplyDenoisingButtonPushed(app, ~)
            % Apply denoising to the input signal
            if isempty(app.input_signal)
                uialert(app.UIFigure, 'No input signal loaded.', 'Error');
                return;
            end
            
            % Perform denoising (using the inverse filter from main script)
            data = load(fullfile(app.outputDir, 'processed_data.mat'));
            inverse_response = data.system_frequency_response;
            inverse_filter_coeffs = ifft([inverse_response; flipud(inverse_response)], 'symmetric');
            numCoeffs = 500;
            window = hamming(numCoeffs);
            inverse_filter_coeffs = inverse_filter_coeffs(1:numCoeffs) .* window;
            
            app.denoised_signal = filter(inverse_filter_coeffs, 1, app.input_signal);
            
            plotSignal(app, app.denoised_signal, 'Denoised Signal');
        end
        
        function plotSignal(app, signal, titleStr)
            t = (0:length(signal)-1)/app.fs;
            n = length(signal);
            Y = fft(signal);
            f = (0:n/2-1)*(app.fs/n);
            magnitude_spectrum = abs(Y(1:n/2));
            
            if app.TimeDomainCheckBox.Value
                plot(app.UIAxes1, t, signal);
                xlabel(app.UIAxes1, 'Time (s)');
                ylabel(app.UIAxes1, 'Amplitude');
                title(app.UIAxes1, [titleStr ' - Time Domain']);
            else
                cla(app.UIAxes1);
            end
            
            if app.FrequencyDomainCheckBox.Value
                plot(app.UIAxes2, f, magnitude_spectrum);
                xlabel(app.UIAxes2, 'Frequency (Hz)');
                ylabel(app.UIAxes2, 'Magnitude');
                title(app.UIAxes2, [titleStr ' - Frequency Domain']);
            else
                cla(app.UIAxes2);
            end
        end
    end
    
    methods (Access = private)
        function createComponents(app)
            % Create UIFigure and components
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1000 600];
            app.UIFigure.Name = 'Signal Visualization App';
            
            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure, [1, 2]);
            app.GridLayout.ColumnWidth = {'1x', '2x'};
            
            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Title = 'Controls';
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            
            % Create components inside LeftPanel
            leftGrid = uigridlayout(app.LeftPanel, [5, 1]);
            leftGrid.RowHeight = repmat({'fit'}, 1, 5);
            leftGrid.Padding = [10 10 10 10];
            leftGrid.RowSpacing = 5;
            
            % LoadSignalButton
            app.LoadSignalButton = uibutton(leftGrid, 'push');
            app.LoadSignalButton.ButtonPushedFcn = createCallbackFcn(app, @LoadSignalButtonPushed, true);
            app.LoadSignalButton.Text = 'Load Signal';
            app.LoadSignalButton.Layout.Row = 1;
            app.LoadSignalButton.Layout.Column = 1;
            
            % TimeDomainCheckBox
            app.TimeDomainCheckBox = uicheckbox(leftGrid);
            app.TimeDomainCheckBox.Text = 'Show Time Domain';
            app.TimeDomainCheckBox.Value = true;
            app.TimeDomainCheckBox.Layout.Row = 2;
            app.TimeDomainCheckBox.Layout.Column = 1;
            
            % FrequencyDomainCheckBox
            app.FrequencyDomainCheckBox = uicheckbox(leftGrid);
            app.FrequencyDomainCheckBox.Text = 'Show Frequency Domain';
            app.FrequencyDomainCheckBox.Value = true;
            app.FrequencyDomainCheckBox.Layout.Row = 3;
            app.FrequencyDomainCheckBox.Layout.Column = 1;
            
            % ApplyDenoisingButton
            app.ApplyDenoisingButton = uibutton(leftGrid, 'push');
            app.ApplyDenoisingButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyDenoisingButtonPushed, true);
            app.ApplyDenoisingButton.Text = 'Apply Denoising';
            app.ApplyDenoisingButton.Layout.Row = 4;
            app.ApplyDenoisingButton.Layout.Column = 1;
            
            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Title = 'Signal Plots';
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            
            % Create UIAxes1 and UIAxes2 in RightPanel
            rightGrid = uigridlayout(app.RightPanel, [2, 1]);
            rightGrid.RowHeight = {'1x', '1x'};
            rightGrid.Padding = [10 10 10 10];
            rightGrid.RowSpacing = 10;
            
            % UIAxes1
            app.UIAxes1 = uiaxes(rightGrid);
            app.UIAxes1.Layout.Row = 1;
            app.UIAxes1.Layout.Column = 1;
            xlabel(app.UIAxes1, 'Time (s)');
            ylabel(app.UIAxes1, 'Amplitude');
            title(app.UIAxes1, 'Time Domain');
            
            % UIAxes2
            app.UIAxes2 = uiaxes(rightGrid);
            app.UIAxes2.Layout.Row = 2;
            app.UIAxes2.Layout.Column = 1;
            xlabel(app.UIAxes2, 'Frequency (Hz)');
            ylabel(app.UIAxes2, 'Magnitude');
            title(app.UIAxes2, 'Frequency Domain');
            
            app.UIFigure.Visible = 'on';
        end
    end
    
    methods (Access = public)
        % App startup
        function app = SignalVisualizationApp
            createComponents(app)
            registerApp(app, app.UIFigure)
            runStartupFcn(app, @startupFcn)
        end
        
        % App teardown
        function delete(app)
            delete(app.UIFigure)
        end
    end
end
