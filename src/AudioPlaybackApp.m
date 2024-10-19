% Audio Playback App
% Description:
% The Audio Playback App is designed to allow users to select, combine, and 
% play back audio signals with control over playback and filtering options. 
% It supports playback of multiple signals simultaneously and provides basic 
% audio manipulation features, such as adjusting volume, applying notch 
% filters to remove noise, and exporting the processed audio.

% Features:
% - **Signal Selection:** Choose one or more processed signals for playback.
% - **Combine Signals:** Combine selected signals for simultaneous playback.
% - **Volume Control:** Adjust the volume of the playback using a slider.
% - **Noise Filtering:** Apply a notch filter to remove specific noise frequencies.
% - **Playback Controls:** Play, pause, stop, rewind, and fast-forward the audio.
% - **Export Processed Audio:** Save the processed audio signal to a .wav file.
% - **Signal Visualization:** View the time-domain representation of the current audio signal.

% How to Use:
% 1. **Select Signal(s):** Choose one or more signals from the list for playback.
%    Check the "Combine Signals" option to play multiple signals together.
% 2. **Adjust Volume:** Use the volume slider to control the playback volume.
% 3. **Apply Filter (Optional):** Set the noise frequency and filter bandwidth,
%    then press "Apply Filter" to remove unwanted noise from the signal.
% 4. **Playback Controls:**
%    - Press "Play" to start playing the selected signals.
%    - Use "Pause/Resume", "Stop", "Rewind", or "Fast Forward" to control playback.
% 5. **Export Audio:** After processing, press "Export Audio" to save the result as a .wav file.
% 6. **Signal Visualization:** The selected signal is displayed in the right panel for analysis.

% Notes:
% - Signals are loaded from a pre-processed file, and carrier frequencies 
%   are automatically displayed for selection.
% - Noise filtering applies a notch filter centered at the specified frequency, 
%   with a user-defined bandwidth.

% Class AudioPlaybackApp < matlab.apps.AppBase
% This class contains the implementation of the audio playback and signal manipulation functionalities.

classdef AudioPlaybackApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        LeftPanel               matlab.ui.container.Panel
        RightPanel              matlab.ui.container.Panel
        
        % Left Panel Components
        SignalListBoxLabel      matlab.ui.control.Label
        SignalListBox           matlab.ui.control.ListBox
        CombineSignalsCheckBox  matlab.ui.control.CheckBox
        VolumeSliderLabel       matlab.ui.control.Label
        VolumeSlider            matlab.ui.control.Slider
        NoiseFreqEditFieldLabel matlab.ui.control.Label
        NoiseFreqEditField      matlab.ui.control.NumericEditField
        BandwidthEditFieldLabel matlab.ui.control.Label
        BandwidthEditField      matlab.ui.control.NumericEditField
        ApplyFilterButton       matlab.ui.control.Button
        ExportButton            matlab.ui.control.Button
        
        % Playback Controls
        PlayButton              matlab.ui.control.Button
        PauseButton             matlab.ui.control.Button
        StopButton              matlab.ui.control.Button
        RewindButton            matlab.ui.control.Button
        FastForwardButton       matlab.ui.control.Button
        
        % Right Panel Components
        UIAxes                  matlab.ui.control.UIAxes
    end
    
    properties (Access = private)
        processed_signals       % Cell array of processed signals
        fs                      % Sampling frequency
        player                  % audioplayer object
        combined_signal         % Combined signal for playback
        current_signal          % Current signal selected
        outputDir               % Output directory for data
        carrier_frequencies     % Carrier frequencies
        noise_frequency         % Noise frequency for filtering
        filter_bandwidth        % Bandwidth of the notch filter
    end
    
    methods (Access = private)
        
        function startupFcn(app)
            % Load processed data
            app.outputDir = 'Output/Data1';
            data = load(fullfile(app.outputDir, 'processed_data.mat'));
            app.processed_signals = data.processed_signals;
            app.fs = data.fs;
            app.carrier_frequencies = data.carrier_frequencies;
            
            signal_names = cellfun(@(fc) sprintf('Signal at %d Hz', fc), num2cell(app.carrier_frequencies), 'UniformOutput', false);
            app.SignalListBox.Items = signal_names;

            app.current_signal = app.processed_signals{1};
            app.VolumeSlider.Value = 1;
            app.noise_frequency = [];
            app.filter_bandwidth = [];
        end
        
        function PlayButtonPushed(app, ~)
            if isempty(app.player) || ~isplaying(app.player)
                
                selected_indices = find(ismember(app.SignalListBox.Items, app.SignalListBox.Value));
                if isempty(selected_indices)
                    uialert(app.UIFigure, 'Please select at least one signal.', 'No Signal Selected');
                    return;
                end
                if app.CombineSignalsCheckBox.Value
                    % Combine selected signals
                    selected_signals = cellfun(@(x) x(:)', app.processed_signals(selected_indices), 'UniformOutput', false);
                    min_length = min(cellfun(@length, selected_signals));
                    selected_signals = cellfun(@(x) x(1:min_length), selected_signals, 'UniformOutput', false);
                    app.combined_signal = sum(cell2mat(selected_signals'), 1);
                else
                    % Play the first selected signal
                    app.combined_signal = app.processed_signals{selected_indices(1)};
                end
                
                % Apply volume
                app.combined_signal = app.combined_signal * app.VolumeSlider.Value;
                
                % Apply noise filtering if specified
                if ~isempty(app.noise_frequency) && ~isempty(app.filter_bandwidth)
                    notchFilt = designfilt('bandstopiir', 'FilterOrder', 2, ...
                                           'HalfPowerFrequency1', app.noise_frequency - app.filter_bandwidth/2, ...
                                           'HalfPowerFrequency2', app.noise_frequency + app.filter_bandwidth/2, ...
                                           'SampleRate', app.fs);
                    app.combined_signal = filter(notchFilt, app.combined_signal);
                end
                
                % Create audioplayer object
                app.player = audioplayer(app.combined_signal, app.fs);
                play(app.player);
                
                % Plot the signal
                plot(app.UIAxes, (1:length(app.combined_signal))/app.fs, app.combined_signal);
                xlabel(app.UIAxes, 'Time (s)');
                ylabel(app.UIAxes, 'Amplitude');
                title(app.UIAxes, 'Playback Signal');
            end
        end
        
        function PauseButtonPushed(app, ~)
            if ~isempty(app.player)
                if isplaying(app.player)
                    pause(app.player);
                else
                    resume(app.player);
                end
            end
        end
        
        function StopButtonPushed(app, ~)
            if ~isempty(app.player)
                stop(app.player);
            end
        end
        
        function RewindButtonPushed(app, ~)
            if ~isempty(app.player)
                current_sample = get(app.player, 'CurrentSample');
                new_sample = max(1, current_sample - 5 * app.fs);
                stop(app.player);
                play(app.player, [new_sample, length(app.combined_signal)]);
            end
        end
        
        function FastForwardButtonPushed(app, ~)
            if ~isempty(app.player)
                current_sample = get(app.player, 'CurrentSample');
                new_sample = min(length(app.combined_signal), current_sample + 5 * app.fs);
                stop(app.player);
                play(app.player, [new_sample, length(app.combined_signal)]);
            end
        end
        
        function VolumeSliderValueChanged(app, ~)
            % Volume adjustment will take effect on next play
        end
        
        function ApplyFilterButtonPushed(app, ~)
            % Get noise frequency and bandwidth
            app.noise_frequency = app.NoiseFreqEditField.Value;
            app.filter_bandwidth = app.BandwidthEditField.Value;
            
            % Update the combined signal with the new filter
            if ~isempty(app.combined_signal)
                notchFilt = designfilt('bandstopiir', 'FilterOrder', 2, ...
                                       'HalfPowerFrequency1', app.noise_frequency - app.filter_bandwidth/2, ...
                                       'HalfPowerFrequency2', app.noise_frequency + app.filter_bandwidth/2, ...
                                       'SampleRate', app.fs);
                app.combined_signal = filter(notchFilt, app.combined_signal);
                
                plot(app.UIAxes, (1:length(app.combined_signal))/app.fs, app.combined_signal);
                xlabel(app.UIAxes, 'Time (s)');
                ylabel(app.UIAxes, 'Amplitude');
                title(app.UIAxes, 'Filtered Signal');
            end
        end
        
        function ExportButtonPushed(app, ~)
            [file, path] = uiputfile('*.wav', 'Save Audio File');
            if isequal(file, 0)
                return;
            end
            audiowrite(fullfile(path, file), app.combined_signal, app.fs);
            uialert(app.UIFigure, 'Audio file saved successfully.', 'Export Complete');
        end
    end
    
    methods (Access = private)
        function createComponents(app)
            % Create UIFigure and components
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 800 600];
            app.UIFigure.Name = 'Audio Playback App';
            
            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure, [1, 2]);
            app.GridLayout.ColumnWidth = {'1x', '2x'};
            
            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Title = 'Controls';
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            
            % Create components inside LeftPanel
            leftGrid = uigridlayout(app.LeftPanel, [14, 2]);
            leftGrid.RowHeight = repmat({'fit'}, 1, 14);
            leftGrid.ColumnWidth = {'fit', '1x'};
            leftGrid.RowSpacing = 5;
            leftGrid.Padding = [10 10 10 10];
            
            % SignalListBoxLabel
            app.SignalListBoxLabel = uilabel(leftGrid);
            app.SignalListBoxLabel.Text = 'Select Signal(s):';
            app.SignalListBoxLabel.Layout.Row = 1;
            app.SignalListBoxLabel.Layout.Column = 1;
            
            % SignalListBox
            app.SignalListBox = uilistbox(leftGrid);
            app.SignalListBox.Multiselect = 'on';
            app.SignalListBox.Layout.Row = [2 4];
            app.SignalListBox.Layout.Column = [1 2];
            
            % CombineSignalsCheckBox
            app.CombineSignalsCheckBox = uicheckbox(leftGrid);
            app.CombineSignalsCheckBox.Text = 'Combine Signals';
            app.CombineSignalsCheckBox.Layout.Row = 5;
            app.CombineSignalsCheckBox.Layout.Column = [1 2];
            
            % VolumeSliderLabel
            app.VolumeSliderLabel = uilabel(leftGrid);
            app.VolumeSliderLabel.Text = 'Volume:';
            app.VolumeSliderLabel.Layout.Row = 6;
            app.VolumeSliderLabel.Layout.Column = 1;
            
            % VolumeSlider
            app.VolumeSlider = uislider(leftGrid);
            app.VolumeSlider.Limits = [0 2];
            app.VolumeSlider.Value = 1;
            app.VolumeSlider.ValueChangedFcn = createCallbackFcn(app, @VolumeSliderValueChanged, true);
            app.VolumeSlider.Layout.Row = 7;
            app.VolumeSlider.Layout.Column = [1 2];
            
            % NoiseFreqEditFieldLabel
            app.NoiseFreqEditFieldLabel = uilabel(leftGrid);
            app.NoiseFreqEditFieldLabel.Text = 'Noise Frequency (Hz):';
            app.NoiseFreqEditFieldLabel.Layout.Row = 8;
            app.NoiseFreqEditFieldLabel.Layout.Column = 1;
            
            % NoiseFreqEditField
            app.NoiseFreqEditField = uieditfield(leftGrid, 'numeric');
            app.NoiseFreqEditField.Layout.Row = 8;
            app.NoiseFreqEditField.Layout.Column = 2;
            
            % BandwidthEditFieldLabel
            app.BandwidthEditFieldLabel = uilabel(leftGrid);
            app.BandwidthEditFieldLabel.Text = 'Filter Bandwidth (Hz):';
            app.BandwidthEditFieldLabel.Layout.Row = 9;
            app.BandwidthEditFieldLabel.Layout.Column = 1;
            
            % BandwidthEditField
            app.BandwidthEditField = uieditfield(leftGrid, 'numeric');
            app.BandwidthEditField.Layout.Row = 9;
            app.BandwidthEditField.Layout.Column = 2;
            
            % ApplyFilterButton
            app.ApplyFilterButton = uibutton(leftGrid, 'push');
            app.ApplyFilterButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyFilterButtonPushed, true);
            app.ApplyFilterButton.Text = 'Apply Filter';
            app.ApplyFilterButton.Layout.Row = 10;
            app.ApplyFilterButton.Layout.Column = [1 2];
            
            % ExportButton
            app.ExportButton = uibutton(leftGrid, 'push');
            app.ExportButton.ButtonPushedFcn = createCallbackFcn(app, @ExportButtonPushed, true);
            app.ExportButton.Text = 'Export Audio';
            app.ExportButton.Layout.Row = 11;
            app.ExportButton.Layout.Column = [1 2];
            
            % Playback Controls
            % PlayButton
            app.PlayButton = uibutton(leftGrid, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Text = 'Play';
            app.PlayButton.Layout.Row = 12;
            app.PlayButton.Layout.Column = 1;
            
            % PauseButton
            app.PauseButton = uibutton(leftGrid, 'push');
            app.PauseButton.ButtonPushedFcn = createCallbackFcn(app, @PauseButtonPushed, true);
            app.PauseButton.Text = 'Pause/Resume';
            app.PauseButton.Layout.Row = 12;
            app.PauseButton.Layout.Column = 2;
            
            % StopButton
            app.StopButton = uibutton(leftGrid, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Text = 'Stop';
            app.StopButton.Layout.Row = 13;
            app.StopButton.Layout.Column = 1;
            
            % RewindButton
            app.RewindButton = uibutton(leftGrid, 'push');
            app.RewindButton.ButtonPushedFcn = createCallbackFcn(app, @RewindButtonPushed, true);
            app.RewindButton.Text = 'Rewind';
            app.RewindButton.Layout.Row = 13;
            app.RewindButton.Layout.Column = 2;
            
            % FastForwardButton
            app.FastForwardButton = uibutton(leftGrid, 'push');
            app.FastForwardButton.ButtonPushedFcn = createCallbackFcn(app, @FastForwardButtonPushed, true);
            app.FastForwardButton.Text = 'Fast Forward';
            app.FastForwardButton.Layout.Row = 14;
            app.FastForwardButton.Layout.Column = [1 2];
            
            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Title = 'Signal Visualization';
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            
            % Create UIAxes in RightPanel
            app.UIAxes = uiaxes(app.RightPanel);
            app.UIAxes.Position = [20 20 540 520];
            xlabel(app.UIAxes, 'Time (s)');
            ylabel(app.UIAxes, 'Amplitude');
            title(app.UIAxes, 'Signal');
            
            app.UIFigure.Visible = 'on';
        end
    end
    
    methods (Access = public)
        % App startup
        function app = AudioPlaybackApp
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



