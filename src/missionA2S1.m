%% EGB242 Assignment 2, Section 1 %%

clear all; close all; clc;

outputDir = 'Output/Data1';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Loaded the provided data
load DataA2 audioMultiplexNoisy fs sid;

%% 1.1 Time Domain and Frequency Domain Analysis

audioMultiplexNoisyColumn = audioMultiplexNoisy(:);

t_vec = (0:length(audioMultiplexNoisyColumn) - 1) / fs;

% Plotted Time Domain
fig1 = figure;
plot(t_vec, audioMultiplexNoisyColumn);
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Recorded Audio Waveform in Time Domain');
grid on;
saveas(fig1, '1.1-TimeDomainPlot.png');

% Applied Hamming window to reduce spectral leakage
windowed_audio_signal = audioMultiplexNoisyColumn .* hamming(length(audioMultiplexNoisyColumn));

% Computed FFT of windowed signal
fftaudioMultiplexNoisyColumn = fft(windowed_audio_signal);

% Frequency vector adjusted for fftshift
nA = length(windowed_audio_signal);
fA = (-nA/2:nA/2-1)*(fs/nA);

% Shiftted zero frequency component to center of spectrum
fft_shifted_center = fftshift(fftaudioMultiplexNoisyColumn);

% Plotted frequency domain
fig2 = figure;
plot(fA, abs(fft_shifted_center));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Frequency Domain Plot of Multiplexed Audio Signal');
grid on;
saveas(fig2, '1.1-FrequencyDomainPlot.png');

%% 1.2 De-multiplexing System

% Found peaks in the frequency spectrum to detect carrier frequencies
systemA = abs(fft_shifted_center);
minPeakProminenceA = max(systemA) * 0.1;
minPeakDistanceA = 10000;
positive_freqsA = fA(fA >= 0);
system_positiveA = systemA(fA >= 0);
[pkzA, loczA] = findpeaks(system_positiveA, 'MinPeakProminence', minPeakProminenceA, 'MinPeakDistance', minPeakDistanceA);
detected_carrier_frequenciesA = positive_freqsA(loczA);

fprintf('Detected Carrier Frequencies:\n');
for i = 1:length(detected_carrier_frequenciesA)
    fprintf('%.2f Hz\n', detected_carrier_frequenciesA(i));
end

% Plotted detected peaks on the magnitude spectrum
fig3 = figure;
plot(positive_freqsA, system_positiveA);
hold on;
plot(detected_carrier_frequenciesA, pkzA, 'ro');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Detected Carrier Frequencies in the Positive Frequency Range');
grid on;
hold off;
saveas(fig3, '1.2-DetectedFrequenciesPlot.png');

% Demodulated signals using carrier frequencies
demodulated_signalsA = cell(1, length(detected_carrier_frequenciesA));
for i = 1:length(detected_carrier_frequenciesA)
    fcA = detected_carrier_frequenciesA(i);
    analytic_signalA = hilbert(audioMultiplexNoisyColumn);
    t_vec = (0:length(audioMultiplexNoisyColumn) - 1)' / fs;
    demodulated_complexA = analytic_signalA .* exp(-1j * 2 * pi * fcA * t_vec);
    audio_bandwidthA = 8000;
    cutoff_freqA = audio_bandwidthA / (fs / 2);
    [bA, aA] = butter(6, cutoff_freqA);
    demodulated_signalA = filter(bA, aA, real(demodulated_complexA));
    demodulated_signalsA{i} = demodulated_signalA;

    % Plotted time and frequency domain representations
    figTimeDomain = figure;
    subplot(2,1,1);
    plot(t_vec, demodulated_signalA);
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    title(sprintf('Demodulated Audio Signal %d in Time Domain (Carrier: %.2f Hz)', i, fcA));
    grid on;
    fft_demodulated_signalA = fft(demodulated_signalA);
    n_demodA = length(demodulated_signalA);
    f_demodA = (-n_demodA/2:n_demodA/2-1)*(fs/n_demodA);
    fft_demod_shiftedA = fftshift(fft_demodulated_signalA);
    subplot(2,1,2);
    plot(f_demodA, abs(fft_demod_shiftedA));
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title(sprintf('Demodulated Audio Signal %d in Frequency Domain (Carrier: %.2f Hz)', i, fcA));
    grid on;
    saveas(figTimeDomain, fullfile(outputDir, sprintf('DemodulatedSignal_%dHz.png', fcA)));
end


%% PLAYBACK
num_signalsA = length(demodulated_signalsA);
fprintf('There are %d demodulated signals available.\n', num_signalsA);
fprintf('To play a specific signal, enter a number between 1 and %d.\n', num_signalsA);
fprintf('=================================================================\n\n');
while true
    signal_indexA = input(sprintf('Enter a number between 1 and %d to play a signal, or 0 to quit: ', num_signalsA));
    if signal_indexA == 0
        fprintf('Exiting.\n');
        break;
    elseif signal_indexA >= 1 && signal_indexA <= num_signalsA
        fprintf('Playing demodulated audio for signal %d (Carrier Frequency: %.2f Hz)\n', signal_indexA, detected_carrier_frequenciesA(signal_indexA));
        playback_signalA = demodulated_signalsA{signal_indexA};
        playback_signalA = playback_signalA / max(abs(playback_signalA));
        playerA = audioplayer(playback_signalA, fs);
        play(playerA);
        pause(length(playback_signalA) / fs + 0.5);
        fprintf('Finished playing signal %d.\n\n', signal_indexA);
        fprintf('=================================================================\n\n');
    else
        fprintf('Invalid input. Please enter a number between 1 and %d.\n', num_signalsA);
    end
end

%% Characterized the Channel - 1.3

carrier_frequencies = [72080, 56100, 40260, 24240, 8260];

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

%% Designed an Inverse Filter - 1.4 & 1.5
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

    % Dynamic Range Compression
    % Threshold above which to compress
    threshold = 0.8;
    % Compression ratio
    ratio = 4;        
    compressed_signal = demodulated_signal;
    exceeds_threshold = abs(demodulated_signal) > threshold;
    compressed_signal(exceeds_threshold) = threshold + ...
        (abs(demodulated_signal(exceeds_threshold)) - threshold) / ratio .* sign(demodulated_signal(exceeds_threshold));

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
