%% EGB242 Assignment 2, Section 1 %%

clear all; close all; clc;

outputDir = 'Output/Data1';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Loaded the provided data
load DataA2 audioMultiplexNoisy fs sid;

% Defined the carrier frequencies
carrier_frequencies = [72080, 56100, 40260, 24240, 8260];

%% Characterized the Channel - 1.3

% 1-second duration for the sweep signal
t_sweep = 0:1/fs:1-1/fs;
% Sweep from 0 Hz to half the sampling rate
sweep = chirp(t_sweep, 0, 1, fs/2);  
output_sweep = channel(sid, sweep, fs);

% Computed the FFT of input and output sweeps
n_sweep = length(sweep);
fft_input_sweep = fft(sweep);
fft_output_sweep = fft(output_sweep);

% Frequency axis for one-sided FFT
frequency_axis_sweep = (0:n_sweep/2-1)*(fs/n_sweep); 

% Calculated the system frequency response
system_frequency_response = abs(fft_output_sweep(1:n_sweep/2)) ./ abs(fft_input_sweep(1:n_sweep/2));
inverse_response = 1 ./ system_frequency_response;
inverse_response(isinf(inverse_response) | isnan(inverse_response)) = 0;

%% Designed an Inverse Filter - 1.4
% Reasonable number of coefficients
numCoeffs = 500;
% Window to stabilize the filter
window = hamming(numCoeffs);  

inverse_response = inverse_response(:).';

% Created full symmetric frequency response for inverse FFT
full_inverse_response = [inverse_response, inverse_response(end-1:-1:2)];

% Computed the inverse FFT to obtain the impulse response of the inverse filter
inverse_filter_coeffs = ifft(full_inverse_response, 'symmetric');

% Took the first numCoeffs coefficients and apply the window
inverse_filter_coeffs = inverse_filter_coeffs(1:numCoeffs) .* window';

% Applied the inverse filter to the noisy multiplexed audio signal
denoised_signal = filter(inverse_filter_coeffs, 1, audioMultiplexNoisy);

% Analyzed the denoised signal to detect high-pitched noise frequencies
n_denoised = length(denoised_signal);
fft_denoised_signal = fft(denoised_signal);
magnitude_spectrum = abs(fft_denoised_signal(1:n_denoised/2));

% Frequency axis for denoised_signal
frequency_axis_denoised = (0:n_denoised/2-1)*(fs/n_denoised);

% Peak detection
[pks, locs] = findpeaks(magnitude_spectrum, ...
    'MinPeakProminence', max(magnitude_spectrum)/20, ...
    'MinPeakDistance', fs/1000);
noise_frequencies = frequency_axis_denoised(locs);

% Displayed detected noise frequencies
disp('Detected Noise Frequencies:');
disp(noise_frequencies);

% Initialized noise_frequencies if no peaks were detected
if isempty(noise_frequencies)
    noise_frequencies = []; 
end

%% Processed Each Carrier Frequency with Notch Filter - 1.5
processed_signals = cell(1, length(carrier_frequencies));

for i = 1:length(carrier_frequencies)
    fc = carrier_frequencies(i);

    % Designed a bandpass filter for each carrier frequency
    bpFilt = designfilt('bandpassfir', 'FilterOrder', 100, ...
                        'CutoffFrequency1', fc-1520, 'CutoffFrequency2', fc+1520, ...
                        'SampleRate', fs);

    % Applied the bandpass filter
    filtered_signal = filter(bpFilt, denoised_signal);
    filtered_signal = filtered_signal(:); 

    % Defined time vector as a column vector
    t = ((0:length(filtered_signal)-1)/fs)'; 

    % Demodulated the signal using Hilbert transform (envelope detection)
    analytic_signal = hilbert(filtered_signal);
    envelope = abs(analytic_signal);

    % Applied a low-pass filter to the envelope
    lpFilt = designfilt('lowpassfir', 'FilterOrder', 120, ...
                        'CutoffFrequency', 3000, ...
                        'SampleRate', fs);
    demodulated_signal = filter(lpFilt, envelope);

    % Applied notch filters to remove detected high-pitched noise
    for nf = noise_frequencies
        notchFilt = designfilt('bandstopiir', 'FilterOrder', 2, ...
                               'HalfPowerFrequency1', nf-50, 'HalfPowerFrequency2', nf+50, ...
                               'SampleRate', fs);
        demodulated_signal = filter(notchFilt, demodulated_signal);
    end

    % Dynamic Range Compression (Optional)
    % Threshold above which to compress
    threshold = 0.8;
    % Compression ratio
    ratio = 4;        
    compressed_signal = demodulated_signal;
    exceeds_threshold = abs(demodulated_signal) > threshold;
    compressed_signal(exceeds_threshold) = threshold + ...
        (abs(demodulated_signal(exceeds_threshold)) - threshold) / ratio .* sign(demodulated_signal(exceeds_threshold));

    %% Plotted and Save Results for each carrier frequency
    % Normalized and save the cleaned audio
    clean_signal_normalized = compressed_signal / max(abs(compressed_signal) + eps);
    processed_signals{i} = clean_signal_normalized;
    audiowrite(fullfile(outputDir, sprintf('ProcessedSignal_%dHz.wav', fc)), clean_signal_normalized, fs);

    % Plotted time-domain signal
    figure;
    plot((0:length(clean_signal_normalized)-1)/fs, clean_signal_normalized);
    title(sprintf('Compressed Cleaned Audio Signal at %d Hz', fc));
    xlabel('Time (s)');
    ylabel('Amplitude');
    saveas(gcf, fullfile(outputDir, sprintf('ProcessedSignal_%dHz_TimeDomain.png', fc)));

    % Plotted frequency-domain signal
    n_sig = length(clean_signal_normalized);
    Y_sig = fft(clean_signal_normalized);
    f_sig = (0:n_sig/2-1)*(fs/n_sig);
    magnitude_spectrum_sig = abs(Y_sig(1:n_sig/2));
    figure;
    plot(f_sig, magnitude_spectrum_sig);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title(sprintf('Processed Signal at %d Hz - Frequency Domain', fc));
    saveas(gcf, fullfile(outputDir, sprintf('ProcessedSignal_%dHz_FrequencyDomain.png', fc)));
end

%% PLAYBACK AND ANALYSIS APPLICATIONS 

% There are three applications built ground up for this analysis task:
% SignalVisualizationApp, ChannelAnalysisApp, and AudioPlaybackApp
% The Visualisation and Playback apps are Output dependant meaning you need
% to save the script output to be able to use these applications. Run this
% section of code to be prompted option to save the outputs. Also get the
% option to launch an application. 
%
% For more information on these applications please refer to there header
% portion of their independant src files.
%
% Hope you enjoy!

clc;
fprintf('\n');

disp('             $$\  $$\           $$$$$$\                                                 $$$$$$\   $$$$$$\           $$\  $$\                                  ');
disp('             \$$\ \$$\         $$  __$$\                                               $$  __$$\ $$  __$$\         $$  |$$  |                                 ');
disp('              \$$\ \$$\        $$ /  \__| $$$$$$\   $$$$$$\  $$\   $$\  $$$$$$\        $$ /  $$ |$$ /  $$ |       $$  /$$  /                                  ');
disp('               \$$\ \$$\       $$ |$$$$\ $$  __$$\ $$  __$$\ $$ |  $$ |$$  __$$\       \$$$$$$$ | $$$$$$  |      $$  /$$  /                                   ');
disp('                $$ | $$ |      $$ |\_$$ |$$ |  \__|$$ /  $$ |$$ |  $$ |$$ /  $$ |       \____$$ |$$  __$$        \$$< \$$<                                   ');
disp('               $$ / $$ /       $$ |  $$ |$$ |      $$ |  $$ |$$ |  $$ |$$ |  $$ |      $$\   $$ |$$ /  $$ |       \$$\ \$$\                                  ');
disp('              $$ / $$ /        \$$$$$$  |$$ |      \$$$$$$  |\$$$$$$  |$$$$$$$  |      \$$$$$$  |\$$$$$$  |        \$$\ \$$\                                 ');
disp('             \__/ \__/          \______/ \__|       \______/  \______/ $$  ____/        \______/  \______/          \__| \__|                                 ');
disp('                                                                       $$ |                                                                                  ');
disp('                                                                       $$ |                                                                                  ');
disp('                                                                       \__|                                                                                  ');
disp('                                                                                                                                                 ');
disp('                                                                                                                                                 ');
disp('                                                                                                                                                 ');
disp('$$$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\ $$$$$$\  ');
disp('\______|\______|\______|\______|\______|\______|\______|\______|\______|\______|\______|\______|\______|\______|\______|\______|\______|\______| ');
disp('                                                                                                                                                 ');
disp('                                                                                                                                                 ');
disp('                                                                                                                                                 ');
disp('                                                                                                                                                 ');
disp('                                                                                                                                                 ');
disp('                           $$$$$$$\  $$$$$$$\  $$$$$$$$\  $$$$$$\  $$$$$$$$\ $$\   $$\ $$$$$$$$\  $$$$$$\                                             ');
disp('                           $$  __$$\ $$  __$$\ $$  _____|$$  __$$\ $$  _____|$$$\  $$ |\__$$  __|$$  __$$\                                            ');
disp('                           $$ |  $$ |$$ |  $$ |$$ |      $$ /  \__|$$ |      $$$$\ $$ |   $$ |   $$ /  \__|                                           ');
disp('                           $$$$$$$  |$$$$$$$  |$$$$$\    \$$$$$$\  $$$$$\    $$ $$\$$ |   $$ |   \$$$$$$\                                             ');
disp('                           $$  ____/ $$  __$$< $$  __|    \____$$\ $$  __|   $$ \$$$$ |   $$ |    \____$$\                                            ');
disp('                           $$ |      $$ |  $$ |$$ |      $$\   $$ |$$ |      $$ |\$$$ |   $$ |   $$\   $$ |                                           ');
disp('                           $$ |      $$ |  $$ |$$$$$$$$\ \$$$$$$  |$$$$$$$$\ $$ | \$$ |   $$ |   \$$$$$$  |                                           ');
disp('                           \__|      \__|  \__|\________| \______/ \________|\__|  \__|   \__|    \______/                                            ');
disp('                                                                                                                                                 ');
disp('                                                                                                                                                 ');
disp('                              $$$$$$$\   $$$$$$\  $$$$$$$\ $$$$$$$$\        $$$$$$\  $$\   $$\ $$$$$$$$\                                          ');
disp('                              $$  __$$\ $$  __$$\ $$  __$$\\__$$  __|      $$  __$$\ $$$\  $$ |$$  _____|                                         ');
disp('                              $$ |  $$ |$$ /  $$ |$$ |  $$ |  $$ |         $$ /  $$ |$$$$\ $$ |$$ |                                               ');
disp('                $$$$$$\       $$$$$$$  |$$$$$$$$ |$$$$$$$  |  $$ |         $$ |  $$ |$$ $$\$$ |$$$$$\          $$$$$$\                            ');
disp('                \______|      $$  ____/ $$  __$$ |$$  __$$<   $$ |         $$ |  $$ |$$ \$$$$ |$$  __|         \______|                           ');
disp('                              $$ |      $$ |  $$ |$$ |  $$ |  $$ |         $$ |  $$ |$$ |\$$$ |$$ |                                               ');
disp('                              $$ |      $$ |  $$ |$$ |  $$ |  $$ |          $$$$$$  |$$ | \$$ |$$$$$$$$\                                          ');
disp('                              \__|      \__|  \__|\__|  \__|  \__|          \______/ \__|  \__|\________|                                         ');
disp('                                                                                                                                                 ');
disp('                                                                                                                                                 ');

userInput = input('Do you want to save the data? Y/N [Y]: ', 's');
if isempty(userInput)
    userInput = 'Y';
end

if upper(userInput) == 'Y'
    fprintf('Saving Data ...\n');

    outputDir = 'Output/Data1';
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    save(fullfile(outputDir, 'processed_data.mat'), 'processed_signals', 'fs', 'carrier_frequencies', 'frequency_axis_denoised', 'system_frequency_response', 'inverse_filter_coeffs');
    
    fprintf('Data saved successfully!\n');
end

fprintf('\n');
disp('Select an application to launch:');
disp('1: Signal Visualization App');
disp('2: Channel Analysis App');
disp('3: Audio Playback App');
disp('4: Exit');

choice = input('Enter your choice (1-4): ');

switch choice
    case 1
        SignalVisualizationApp;
    case 2
        ChannelAnalysisApp;
    case 3
        AudioPlaybackApp;
    case 4
        disp('Exiting...');
    otherwise
        disp('Invalid choice. Please restart the script and try again.');
end
