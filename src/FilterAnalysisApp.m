% Filter Analysis App
% Description:
% The Filter Analysis App allows users to select and analyze different types of filters 
% (passive and active) based on their circuit configurations. The app generates the 
% transfer function for each filter, computes its frequency response, and visualizes 
% the results in terms of a Bode plot. The app also outputs the filter coefficients 
% (numerator and denominator) for each selected filter.

% Features:
% - **Filter Selection:** Choose between four filter types: Passive Filter 1, Passive Filter 2, Active Filter 1, and Active Filter 2.
% - **Filter Analysis:** The app computes and displays the transfer function of the selected filter and visualizes the Bode plot (magnitude and phase).
% - **Coefficient Display:** The app calculates and displays the filter's numerator (b) and denominator (a) coefficients.
% - **Frequency-Domain Visualization:** The Bode plot shows both the magnitude (in dB) and phase (in degrees) of the filter's frequency response.

% How to Use:
% 1. **Select Filter Type:** From the drop-down menu, choose a filter type (e.g., Passive Filter 1, Active Filter 1).
% 2. **Analyze Filter:** Click the "Analyze Filter" button to compute the transfer function and visualize the filter's frequency response.
% 3. **View Results:** The magnitude (in dB) and phase (in degrees) are plotted against frequency in the Bode plot. The coefficients of the filter are displayed in the text area.

% Notes:
% - The app uses pre-defined resistor and capacitor values for each filter to compute the transfer function.
% - Filter coefficients are displayed in the output text area for further analysis or usage.
% - Bode plots are generated for the selected filter, showing how the filter behaves in both the magnitude and phase domains.

% Class FilterAnalysisApp < matlab.apps.AppBase
% This class implements the UI and functionality for the Filter Analysis App, including
% transfer function generation, frequency response visualization, and filter coefficient
% calculation for four different types of filters (two passive and two active).

classdef FilterAnalysisApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        LeftPanel                  matlab.ui.container.Panel
        FilterTypeDropDownLabel    matlab.ui.control.Label
        FilterTypeDropDown         matlab.ui.control.DropDown
        AnalyzeFilterButton        matlab.ui.control.Button
        OutputTextAreaLabel        matlab.ui.control.Label
        OutputTextArea             matlab.ui.control.TextArea
        RightPanel                 matlab.ui.container.Panel
        FrequencyResponseAxes      matlab.ui.control.UIAxes
    end

    methods (Access = private)

        function startupFcn(app)
            app.FilterTypeDropDown.Items = {'Passive Filter 1', 'Passive Filter 2', 'Active Filter 1', 'Active Filter 2'};
            app.FilterTypeDropDown.Value = 'Passive Filter 1';
        end

        function AnalyzeFilterButtonPushed(app, ~)
            try
                % Get the selected filter type
                filterType = app.FilterTypeDropDown.Value;
        
                % Get the filter coefficients based on the selected filter type
                [b, a] = app.getFilterCoefficients(filterType);
        
                % Create the transfer function system
                sys = tf(b, a);
        
                % Compute the Bode response
                [mag, phase, w] = bode(sys); % mag and phase are 3D arrays
        
                % Squeeze mag and phase arrays to get 2D arrays
                mag = squeeze(mag);
                phase = squeeze(phase);
        
                % Clear the previous plot
                cla(app.FrequencyResponseAxes);
        
                % Plot Magnitude on the top half of the axes
                yyaxis(app.FrequencyResponseAxes, 'left');
                plot(app.FrequencyResponseAxes, w, 20*log10(mag), 'b-', 'LineWidth', 2);
                ylabel(app.FrequencyResponseAxes, 'Magnitude (dB)');
                set(app.FrequencyResponseAxes, 'YColor', 'b');
        
                % Plot Phase on the bottom half of the axes
                yyaxis(app.FrequencyResponseAxes, 'right');
                plot(app.FrequencyResponseAxes, w, phase, 'r--', 'LineWidth', 2);
                ylabel(app.FrequencyResponseAxes, 'Phase (degrees)');
                set(app.FrequencyResponseAxes, 'YColor', 'r');
        
                % Set plot properties
                xlabel(app.FrequencyResponseAxes, 'Frequency (rad/s)');
                title(app.FrequencyResponseAxes, ['Bode Plot of ', filterType]);
                grid(app.FrequencyResponseAxes, 'on');
        
                % Display the filter coefficients in the output text area
                app.OutputTextArea.Value = ['Filter coefficients (b): ', mat2str(b), newline, ...
                                            'Filter coefficients (a): ', mat2str(a)];
            catch ME
                app.OutputTextArea.Value = ['Error: ', ME.message];
            end
        end


        function [b, a] = getFilterCoefficients(app, filterType)
            switch filterType
                case 'Passive Filter 1'
                    % Passive Filter 1: RC High-pass and Low-pass combination
                    R1 = 1.2e3; C1 = 10e-6; R2 = 1e3; C2 = 4.7e-6;
                    a = [R1*C1*R2*C2, (R1*C1 + R2*C2), 1];
                    b = [0, 0, 1];
                case 'Passive Filter 2'
                    % Passive Filter 2: Two-stage RC Low-pass filter
                    R1 = 1.2e3; C1 = 10e-6; R2 = 1e3; C2 = 4.7e-6;
                    a = [R1*C1*R2*C2, (R1*C1 + R2*C2), 1];
                    b = [0, 1, 0];
                case 'Active Filter 1'
                    % Active Filter 1: Band-pass filter
                    R = 820; C = 1e-6;
                    b = [1, 0, 0];
                    a = [1, 2/(R*C), 1/(R*C)^2];
                case 'Active Filter 2'
                    % Active Filter 2: Low-pass filter
                    R = 820; C = 1e-6;
                    b = [1/(R*C)^2];
                    a = [1, 2/(R*C), 1/(R*C)^2];
            end
        end
    end

    methods (Access = private)

        function createComponents(app)
            % Create UIFigure and components
            app.UIFigure = uifigure('Position', [100 100 700 500], 'Name', 'Filter Analysis App');
            app.GridLayout = uigridlayout(app.UIFigure, [1 2]);

            % Left Panel for Controls
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Title = 'Controls';
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % FilterType DropDown
            app.FilterTypeDropDownLabel = uilabel(app.LeftPanel, 'Text', 'Select Filter Type:');
            app.FilterTypeDropDownLabel.Position = [20 400 100 22];
            app.FilterTypeDropDown = uidropdown(app.LeftPanel);
            app.FilterTypeDropDown.Position = [130 400 150 22];

            % Analyze Button
            app.AnalyzeFilterButton = uibutton(app.LeftPanel, 'push', 'Text', 'Analyze Filter');
            app.AnalyzeFilterButton.Position = [50 350 200 30];
            app.AnalyzeFilterButton.ButtonPushedFcn = createCallbackFcn(app, @AnalyzeFilterButtonPushed, true);

            % Output Text Area
            app.OutputTextAreaLabel = uilabel(app.LeftPanel, 'Text', 'Filter Coefficients:');
            app.OutputTextAreaLabel.Position = [20 300 150 22];
            app.OutputTextArea = uitextarea(app.LeftPanel);
            app.OutputTextArea.Position = [20 100 260 200];

            % Right Panel for Frequency Response Plot
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Title = 'Frequency Response';
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            app.FrequencyResponseAxes = uiaxes(app.RightPanel);
            app.FrequencyResponseAxes.Position = [10 10 330 420];

            startupFcn(app)
        end
    end

    % App startup
    methods (Access = public)
        function app = FilterAnalysisApp
            createComponents(app);
            registerApp(app, app.UIFigure);
            if nargout == 0
                clear app
            end
        end

        % App teardown
        function delete(app)
            delete(app.UIFigure);
        end
    end
end

