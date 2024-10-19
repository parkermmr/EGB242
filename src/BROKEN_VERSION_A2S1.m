%% EGB242 Assignment 2, Section 1 %%

clear all; close all; clc;

outputDir = 'Output/Data1';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Loaded the provided data
load DataA2 audioMultiplexNoisy fs sid;

%% 1.1 Time and Frequency Domain Representations

audioMultiplexNoisy = audioMultiplexNoisy(:);  

% Time vector
t = (0:length(audioMultiplexNoisy) - 1) / fs;

% Plotted time domain signal
figure;
plot(t, audioMultiplexNoisy);
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Recorded Audio Waveform in Time Domain');
grid on;

% Applied Hamming window to reduce spectral leakage
windowed_signal = audioMultiplexNoisy .* hamming(length(audioMultiplexNoisy));

% Computed FFT of windowed signal
fftaudioMultiplexNoisy = fft(windowed_signal);

% Frequency vector adjusted for fftshift
n = length(windowed_signal);
f = (-n/2:n/2-1)*(fs/n);

% Shifted zero frequency component to center of spectrum
fft_shifted = fftshift(fftaudioMultiplexNoisy);

% Plotted frequency domain
figure;
plot(f, abs(fft_shifted));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Frequency Domain Plot of Multiplexed Audio Signal');
grid on;

% Defined the carrier frequencies
carrier_frequencies = [72080, 56100, 40260, 24240, 8260];

%% 1.2
% Used absolute value of shifted FFT to find peaks
system = abs(fft_shifted);

% Adjusted parameters for peak detection
minPeakProminence = max(system) * 0.1;
minPeakDistance = 10000;

% Found peaks in positive frequencies only (since spectrum is symmetric)
positive_freqs = f(f >= 0);
system_positive = system(f >= 0);

% Found peaks in the magnitude spectrum to detect carrier frequencies
[pkz, locz] = findpeaks(system_positive, 'MinPeakProminence', minPeakProminence, 'MinPeakDistance', minPeakDistance);
detected_carrier_frequencies = positive_freqs(locz);

% Printed detected carrier frequencies
fprintf('Detected Carrier Frequencies:\n');
for i = 1:length(detected_carrier_frequencies)
    fprintf('%.2f Hz\n', detected_carrier_frequencies(i));
end

% Plotted detected peaks on the magnitude spectrum
figure;
plot(positive_freqs, system_positive);
hold on;
plot(carrier_frequencies, pkz, 'ro');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Detected Carrier Frequencies in the Positive Frequency Range');
grid on;
hold off;

% Pre-allocated cell array for demodulated signals
demodulated_signals = cell(1, length(carrier_frequencies));

for i = 1:length(carrier_frequencies)
    % Extracted carrier frequency
    fc = carrier_frequencies(i);

    % Created analytic signal using Hilbert transform
    analytic_signal = hilbert(audioMultiplexNoisy);

    t = (0:length(audioMultiplexNoisy) - 1)' / fs;

    % Demodulated using complex exponential
    demodulated_complex = analytic_signal .* exp(-1j * 2 * pi * fc * t);

    % Low-pass filter to extract baseband signal
    audio_bandwidth = 8000;
    cutoff_freq = audio_bandwidth / (fs / 2);

    [b, a] = butter(6, cutoff_freq);
    demodulated_signal = filter(b, a, real(demodulated_complex));

    demodulated_signals{i} = demodulated_signal;

    % Plotted time domain and frequency domain representations
    figure;
    subplot(2,1,1);
    plot(t, demodulated_signal);
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    title(sprintf('Demodulated Audio Signal %d in Time Domain (Carrier: %.2f Hz)', i, fc));
    grid on;

    % Computed FFT of demodulated signal
    fft_demodulated_signal = fft(demodulated_signal);
    n_demod = length(demodulated_signal);
    f_demod = (-n_demod/2:n_demod/2-1)*(fs/n_demod);
    fft_demod_shifted = fftshift(fft_demodulated_signal);

    subplot(2,1,2);
    plot(f_demod, abs(fft_demod_shifted));
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title(sprintf('Demodulated Audio Signal %d in Frequency Domain (Carrier: %.2f Hz)', i, fc));
    grid on;
end

%% PLAYBACK

num_signals = length(demodulated_signals);
fprintf('There are %d demodulated signals available.\n', num_signals);
fprintf('To play a specific signal, enter a number between 1 and %d.\n', num_signals);
fprintf('=================================================================\n\n');

while true
    signal_index = input(sprintf('Enter a number between 1 and %d to play a signal, or 0 to quit: ', num_signals));

    if signal_index == 0
        fprintf('Exiting.\n');
        break;
    end

    if signal_index >= 1 && signal_index <= num_signals
        fprintf('Playing demodulated audio for signal %d (Carrier Frequency: %.2f Hz)\n', signal_index, carrier_frequencies(signal_index));

        % Normalized the demodulated signal for playback
        playback_signal = demodulated_signals{signal_index};
        playback_signal = playback_signal / max(abs(playback_signal));

        player = audioplayer(playback_signal, fs); %#ok<*TNMLP> 
        play(player);

        pause(length(playback_signal) / fs + 0.5);

        fprintf('Finished playing signal %d.\n\n', signal_index);
        fprintf('=================================================================\n\n');
    else
        fprintf('Invalid input. Please enter a number between 1 and %d.\n', num_signals);
    end
end


%% Characterized the Channel

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

%% Designed an Inverse Filter
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

% Peak detection for de-noising
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

%% Processed Each Carrier Frequency with Notch Filter
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
    hFig = figure;
    plot((0:length(clean_signal_normalized)-1)/fs, clean_signal_normalized);
    title(sprintf('Compressed Cleaned Audio Signal at %d Hz', fc));
    xlabel('Time (s)');
    ylabel('Amplitude');
    saveas(hFig, fullfile(outputDir, sprintf('ProcessedSignal_%dHz_TimeDomain.png', fc)));

    % Plotted frequency-domain signal
    n_sig = length(clean_signal_normalized);
    Y_sig = fft(clean_signal_normalized);
    f_sig = (0:n_sig/2-1)*(fs/n_sig);
    magnitude_spectrum_sig = abs(Y_sig(1:n_sig/2));
    hFig = figure;
    plot(f_sig, magnitude_spectrum_sig);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title(sprintf('Processed Signal at %d Hz - Frequency Domain', fc));
    saveas(hFig, fullfile(outputDir, sprintf('ProcessedSignal_%dHz_FrequencyDomain.png', fc)));
end

%% PLAYBACK AND ANALYSIS APPLICATIONS 

% There are three applications built ground up for this analysis task:
% SignalVisualizationApp, ChannelAnalysisApp, and AudioPlaybackApp
% The Visualisation and Playback apps are Output dependant meaning you need
% to save the script output to be able to use these applications. Run this
% section of code to be prompted option to save the outputs. Also get the
% option to launch an application. 
%
% For more information on these applications please refer to their header
% portion of their independent src files.
%
% Hope you enjoy!

clc;
fprintf('\n');

disp('$$\  $$\           $$$$$$\                                                 $$$$$$\   $$$$$$\           $$\  $$\                                  ');
disp('\$$\ \$$\         $$  __$$\                                               $$  __$$\ $$  __$$\         $$  |$$  |                                 ');
disp(' \$$\ \$$\        $$ /  \__| $$$$$$\   $$$$$$\  $$\   $$\  $$$$$$\        $$ /  $$ |$$ /  $$ |       $$  /$$  /                                  ');
disp('  \$$\ \$$\       $$ |$$$$\ $$  __$$\ $$  __$$\ $$ |  $$ |$$  __$$\       \$$$$$$$ | $$$$$$  |      $$  /$$  /                                   ');
disp('   $$  |$$  |      $$ |\_$$ |$$ |  \__|$$ /  $$ |$$ |  $$ |$$ /  $$ |       \____$$ |$$  __$$<       \$$< \$$<                                   ');
disp('  $$  /$$  /       $$ |  $$ |$$ |      $$ |  $$ |$$ |  $$ |$$ |  $$ |      $$\   $$ |$$ /  $$ |       \$$\ \$$\                                  ');
disp(' $$  /$$  /        \$$$$$$  |$$ |      \$$$$$$  |\$$$$$$  |$$$$$$$  |      \$$$$$$  |\$$$$$$  |        \$$\ \$$\                                 ');
disp(' \__/ \__/          \______/ \__|       \______/  \______/ $$  ____/        \______/  \______/          \__| \__|                                 ');
disp('                                                           $$ |                                                                                  ');
disp('                                                           $$ |                                                                                  ');
disp('                                                           \__|                                                                                  ');
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
disp('                      $$$$$$$\  $$$$$$$\  $$$$$$$$\  $$$$$$\  $$$$$$$$\ $$\   $$\ $$$$$$$$\  $$$$$$\                                             ');
disp('                      $$  __$$\ $$  __$$\ $$  _____|$$  __$$\ $$  _____|$$$\  $$ |\__$$  __|$$  __$$\                                            ');
disp('                      $$ |  $$ |$$ |  $$ |$$ |      $$ /  \__|$$ |      $$$$\ $$ |   $$ |   $$ /  \__|                                           ');
disp('                      $$$$$$$  |$$$$$$$  |$$$$$\    \$$$$$$\  $$$$$\    $$ $$\$$ |   $$ |   \$$$$$$\                                             ');
disp('                      $$  ____/ $$  __$$< $$  __|    \____$$\ $$  __|   $$ \$$$$ |   $$ |    \____$$\                                            ');
disp('                      $$ |      $$ |  $$ |$$ |      $$\   $$ |$$ |      $$ |\$$$ |   $$ |   $$\   $$ |                                           ');
disp('                      $$ |      $$ |  $$ |$$$$$$$$\ \$$$$$$  |$$$$$$$$\ $$ | \$$ |   $$ |   \$$$$$$  |                                           ');
disp('                      \__|      \__|  \__|\________| \______/ \________|\__|  \__|   \__|    \______/                                            ');
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
