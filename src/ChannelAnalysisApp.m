classdef ChannelAnalysisApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        LeftPanel                  matlab.ui.container.Panel
        SignalTypeDropDownLabel    matlab.ui.control.Label
        SignalTypeDropDown         matlab.ui.control.DropDown
        IntegerParameterSliderLabel  matlab.ui.control.Label
        IntegerParameterSlider     matlab.ui.control.Slider
        IntegerParameterEditField  matlab.ui.control.NumericEditField
        DurationmsSliderLabel      matlab.ui.control.Label
        DurationmsSlider           matlab.ui.control.Slider
        DurationmsEditField        matlab.ui.control.NumericEditField
        AnalyzeChannelButton       matlab.ui.control.Button
        OutputTextAreaLabel        matlab.ui.control.Label
        OutputTextArea             matlab.ui.control.TextArea
        RightPanel                 matlab.ui.container.Panel
        TimeDomainAxes             matlab.ui.control.UIAxes
        FrequencyDomainAxes        matlab.ui.control.UIAxes
    end

    properties (Access = private)
        sid     
        fs      
        signal  
        y_signal  
    end

    methods (Access = private)

        function startupFcn(app)
            load('DataA2.mat', 'sid', 'fs');
            app.sid = sid;
            app.fs = fs;

            % Initialize defaults
            app.DurationmsEditField.Value = 1; 
            app.DurationmsSlider.Value = 1;

            app.IntegerParameterEditField.Value = 5;
            app.IntegerParameterSlider.Value = 5;
        end

        function SignalTypeDropDownValueChanged(app, ~)
            signalType = app.SignalTypeDropDown.Value;

            % Enable or disable integer parameter controls based on signal type
            if ismember(signalType, {'Sum of Sinusoids', 'PRBS Signal'})
                app.IntegerParameterSlider.Enable = 'on';
                app.IntegerParameterEditField.Enable = 'on';

                if strcmp(signalType, 'Sum of Sinusoids')
                    app.IntegerParameterSlider.Limits = [1 20];
                    app.IntegerParameterSlider.Value = 5;
                    app.IntegerParameterEditField.Value = 5;
                    % app.IntegerParameterSlider.MajorTicks = 1:1:20;
                    % app.IntegerParameterSlider.ValueDisplayFormat = '%.0f';
                    app.IntegerParameterSliderLabel.Text = 'Number of Sinusoids';
                else  % PRBS Signal
                    app.IntegerParameterSlider.Limits = [2 16];
                    app.IntegerParameterSlider.Value = 10;
                    app.IntegerParameterEditField.Value = 10;
                    % app.IntegerParameterSlider.MajorTicks = 2:1:16;
                    % app.IntegerParameterSlider.ValueDisplayFormat = '%.0f';
                    app.IntegerParameterSliderLabel.Text = 'PRBS Order';
                end
            else
                app.IntegerParameterSlider.Enable = 'off';
                app.IntegerParameterEditField.Enable = 'off';
            end
        end

        function AnalyzeChannelButtonPushed(app, ~)
            try
                % Get user inputs
                signalType = app.SignalTypeDropDown.Value;
                duration_ms = app.DurationmsEditField.Value;

                % Generate time vector
                t = 0:1/app.fs:(duration_ms/1000) - 1/app.fs;

                % Generate signal
                app.signal = generateSignal(app, signalType, t);

                % Transmit through channel
                app.y_signal = channel(app.sid, app.signal, app.fs);

                % Plot signals
                plotTimeDomain(app, t);
                plotFrequencyDomain(app);

                % Display results
                displayResults(app);

            catch ME
                uialert(app.UIFigure, ME.message, 'Error');
            end
        end

        function IntegerParameterSliderValueChanged(app, event)
            value = round(event.Value);
            app.IntegerParameterEditField.Value = value;
        end

        function IntegerParameterEditFieldValueChanged(app, event)
            value = round(event.Value);
            % Ensure value is within limits
            value = max(min(value, app.IntegerParameterSlider.Limits(2)), app.IntegerParameterSlider.Limits(1));
            app.IntegerParameterEditField.Value = value;
            app.IntegerParameterSlider.Value = value;
        end

        function DurationmsSliderValueChanged(app, event)
            value = event.Value;
            app.DurationmsEditField.Value = value;
        end

        function DurationmsEditFieldValueChanged(app, event)
            value = event.Value;
            % Ensure value is within limits
            value = max(min(value, app.DurationmsSlider.Limits(2)), app.DurationmsSlider.Limits(1));
            app.DurationmsEditField.Value = value;
            app.DurationmsSlider.Value = value;
        end

        function signal = generateSignal(app, signalType, t)
            switch signalType
                case 'Impulse Signal'
                    % Generate an impulse signal (Dirac delta approximation)
                    signal = zeros(size(t));
                    signal(1) = 1;

                case 'Narrow Pulse'
                    % Generate a narrow rectangular pulse
                    pulseWidth = round(0.001 * length(t));
                    signal = zeros(size(t));
                    signal(1:pulseWidth) = 1;

                case 'White Noise'
                    % Generate white Gaussian noise
                    signal = randn(size(t));

                case 'Chirp Signal'
                    % Generate a linear chirp from 20 Hz to fs/2 Hz
                    f0 = 20;
                    f1 = app.fs / 2 - 1000;
                    signal = chirp(t, f0, t(end), f1);

                case 'Sum of Sinusoids'
                    % Generate a sum of sinusoids at specific frequencies
                    numSinusoids = round(app.IntegerParameterEditField.Value);
                    baseFreq = 1000;
                    freqGap = (app.fs / 2 - baseFreq) / numSinusoids;
                    freqs = baseFreq:freqGap:(baseFreq + (numSinusoids - 1) * freqGap);
                    signal = sum(sin(2 * pi * freqs' * t), 1);

                case 'Square Wave'
                    % Generate a square wave at a given frequency
                    freq = 1000;
                    signal = square(2 * pi * freq * t);

                case 'Custom'
                    % Generate a custom signal
                    freq = 15000;
                    signal = sin(2 * pi * freq * t);

                case 'PRBS Signal'
                    % Generate a Pseudo-Random Binary Sequence (PRBS)
                    prbsOrder = round(app.IntegerParameterEditField.Value); 
                    nBits = 2^prbsOrder - 1;
                    % Create a simple PRBS using XOR feedback
                    reg = ones(1, prbsOrder);
                    prbs = zeros(1, nBits);
                    for i = 1:nBits
                        newBit = xor(reg(end), reg(end - 1));
                        prbs(i) = reg(end);
                        reg = [newBit, reg(1:end - 1)];
                    end
                    signal = repmat(prbs, 1, ceil(length(t)/length(prbs)));
                    signal = signal(1:length(t));
                    signal = 2 * signal - 1; 

                case 'Exponential Sweep'
                    % Generate an exponential sweep from 20 Hz to fs/2 Hz
                    f0 = 20;
                    f1 = app.fs / 2 - 1000;
                    signal = chirp(t, f0, t(end), f1, 'logarithmic');

                otherwise
                    error('Unknown signal type selected.');
            end

            % Normalize signal to prevent clipping
            signal = signal / max(abs(signal) + eps);
        end

        function plotTimeDomain(app, t)
            cla(app.TimeDomainAxes); 
            plot(app.TimeDomainAxes, t, app.signal, 'b', t, app.y_signal, 'r');
            legend(app.TimeDomainAxes, 'Input Signal', 'Output Signal');
            xlabel(app.TimeDomainAxes, 'Time (s)');
            ylabel(app.TimeDomainAxes, 'Amplitude');
            xlim(app.TimeDomainAxes, [0, t(end)]);
            title(app.TimeDomainAxes, 'Time-Domain Signals');
            drawnow;
        end

        function plotFrequencyDomain(app)
            n = length(app.signal);
            % Compute frequency vector
            f = (0:n-1)*(app.fs/n);

            fft_signal = fft(app.signal);
            fft_y_signal = fft(app.y_signal);

            % Avoid division by zero
            epsilon = 1e-12;
            fft_signal_abs = fft_signal;
            fft_signal_abs(abs(fft_signal_abs) < epsilon) = epsilon;

            % Compute frequency response H(f) = Y(f)/X(f)
            H_f = fft_y_signal ./ fft_signal_abs;

            % Plot magnitude spectrum
            cla(app.FrequencyDomainAxes); 
            plot(app.FrequencyDomainAxes, f(1:n/2), abs(H_f(1:n/2)));
            xlabel(app.FrequencyDomainAxes, 'Frequency (Hz)');
            ylabel(app.FrequencyDomainAxes, '|H(f)|');
            xlim(app.FrequencyDomainAxes, [0, app.fs/2]);
            title(app.FrequencyDomainAxes, 'Estimated Frequency Response |H(f)|');
            drawnow;
        end

        function displayResults(app)
            n = length(app.signal);
            f = (0:n-1)*(app.fs/n);
            fft_signal = fft(app.signal);
            fft_y_signal = fft(app.y_signal);
        
            % Avoid division by zero
            epsilon = 1e-12;
            fft_signal_abs = fft_signal;
            fft_signal_abs(abs(fft_signal_abs) < epsilon) = epsilon;
        
            H_f = fft_y_signal ./ fft_signal_abs;
        
            % Select frequencies up to Nyquist frequency
            num_points = 10; 
            max_freq = app.fs / 2; 
            selected_freqs = linspace(0, max_freq, num_points);
            results = '';
        
            for freq = selected_freqs
                [~, idx] = min(abs(f - freq));
                magnitude = abs(H_f(idx));
                phase = angle(H_f(idx)) * (180 / pi);
                results = sprintf('%sFrequency: %.2f Hz, |H(f)|: %.4f, Phase: %.2f degrees\n', ...
                                  results, freq, magnitude, phase);
            end
        
            app.OutputTextArea.Value = results;
        end

    end

    % Component initialization
    methods (Access = private)

        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1200 800];
            app.UIFigure.Name = 'Channel Analysis App';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure, [1, 2]);
            app.GridLayout.ColumnWidth = {'1x', '2x'};

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Title = 'Controls';
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Title = 'Plots';
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create components inside LeftPanel
            leftGrid = uigridlayout(app.LeftPanel, [8, 2]);
            leftGrid.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', '2x', 'fit'};
            leftGrid.ColumnWidth = {'fit', '1x'};
            leftGrid.Padding = [10 10 10 10];
            leftGrid.RowSpacing = 5;

            % SignalTypeDropDownLabel
            app.SignalTypeDropDownLabel = uilabel(leftGrid);
            app.SignalTypeDropDownLabel.Text = 'Signal Type';
            app.SignalTypeDropDownLabel.Layout.Row = 1;
            app.SignalTypeDropDownLabel.Layout.Column = 1;

            % SignalTypeDropDown
            app.SignalTypeDropDown = uidropdown(leftGrid);
            app.SignalTypeDropDown.Items = {'Impulse Signal', 'Narrow Pulse', 'White Noise', 'Chirp Signal', 'Sum of Sinusoids', 'Square Wave', 'Custom', 'PRBS Signal', 'Exponential Sweep'};
            app.SignalTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @SignalTypeDropDownValueChanged, true);
            app.SignalTypeDropDown.Layout.Row = 1;
            app.SignalTypeDropDown.Layout.Column = 2;
            app.SignalTypeDropDown.Value = 'Impulse Signal';

            % IntegerParameterSliderLabel
            app.IntegerParameterSliderLabel = uilabel(leftGrid);
            app.IntegerParameterSliderLabel.Text = 'Integer Parameter';
            app.IntegerParameterSliderLabel.Layout.Row = 2;
            app.IntegerParameterSliderLabel.Layout.Column = 1;

            % IntegerParameterSlider
            app.IntegerParameterSlider = uislider(leftGrid);
            app.IntegerParameterSlider.Limits = [1 20];
            app.IntegerParameterSlider.ValueChangedFcn = createCallbackFcn(app, @IntegerParameterSliderValueChanged, true);
            app.IntegerParameterSlider.Layout.Row = 3;
            app.IntegerParameterSlider.Layout.Column = [1 2];
            app.IntegerParameterSlider.Enable = 'off';

            % IntegerParameterEditField
            app.IntegerParameterEditField = uieditfield(leftGrid, 'numeric');
            app.IntegerParameterEditField.ValueChangedFcn = createCallbackFcn(app, @IntegerParameterEditFieldValueChanged, true);
            app.IntegerParameterEditField.Layout.Row = 2;
            app.IntegerParameterEditField.Layout.Column = 2;
            app.IntegerParameterEditField.Enable = 'off'; 

            % DurationmsSliderLabel
            app.DurationmsSliderLabel = uilabel(leftGrid);
            app.DurationmsSliderLabel.Text = 'Duration (ms)';
            app.DurationmsSliderLabel.Layout.Row = 4;
            app.DurationmsSliderLabel.Layout.Column = 1;

            % DurationmsSlider
            app.DurationmsSlider = uislider(leftGrid);
            app.DurationmsSlider.Limits = [1 5000]; 
            app.DurationmsSlider.ValueChangedFcn = createCallbackFcn(app, @DurationmsSliderValueChanged, true);
            app.DurationmsSlider.Layout.Row = 5;
            app.DurationmsSlider.Layout.Column = [1 2];
            app.DurationmsSlider.Value = 1000;

            % DurationmsEditField
            app.DurationmsEditField = uieditfield(leftGrid, 'numeric');
            app.DurationmsEditField.ValueChangedFcn = createCallbackFcn(app, @DurationmsEditFieldValueChanged, true);
            app.DurationmsEditField.Layout.Row = 4;
            app.DurationmsEditField.Layout.Column = 2;
            app.DurationmsEditField.Value = 1000;

            % AnalyzeChannelButton
            app.AnalyzeChannelButton = uibutton(leftGrid, 'push');
            app.AnalyzeChannelButton.ButtonPushedFcn = createCallbackFcn(app, @AnalyzeChannelButtonPushed, true);
            app.AnalyzeChannelButton.Text = 'Analyze Channel';
            app.AnalyzeChannelButton.Layout.Row = 6;
            app.AnalyzeChannelButton.Layout.Column = [1 2];
            app.AnalyzeChannelButton.FontSize = 14;

            % OutputTextAreaLabel
            app.OutputTextAreaLabel = uilabel(leftGrid);
            app.OutputTextAreaLabel.Text = 'Output';
            app.OutputTextAreaLabel.Layout.Row = 7;
            app.OutputTextAreaLabel.Layout.Column = 1;

            % OutputTextArea
            app.OutputTextArea = uitextarea(leftGrid);
            app.OutputTextArea.Layout.Row = [7 8];
            app.OutputTextArea.Layout.Column = [1 2];

            % Create components inside RightPanel
            rightGrid = uigridlayout(app.RightPanel, [2, 1]);
            rightGrid.RowHeight = {'1x', '1x'};
            rightGrid.ColumnWidth = {'1x'};
            rightGrid.Padding = [10 10 10 10];
            rightGrid.RowSpacing = 10;

            % TimeDomainAxes
            app.TimeDomainAxes = uiaxes(rightGrid);
            app.TimeDomainAxes.Layout.Row = 1;
            app.TimeDomainAxes.Layout.Column = 1;
            title(app.TimeDomainAxes, 'Time-Domain Signals');
            xlabel(app.TimeDomainAxes, 'Time (s)');
            ylabel(app.TimeDomainAxes, 'Amplitude');

            % FrequencyDomainAxes
            app.FrequencyDomainAxes = uiaxes(rightGrid);
            app.FrequencyDomainAxes.Layout.Row = 2;
            app.FrequencyDomainAxes.Layout.Column = 1;
            title(app.FrequencyDomainAxes, 'Estimated Frequency Response |H(f)|');
            xlabel(app.FrequencyDomainAxes, 'Frequency (Hz)');
            ylabel(app.FrequencyDomainAxes, '|H(f)|');

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        % Construct app
        function app = ChannelAnalysisApp

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






