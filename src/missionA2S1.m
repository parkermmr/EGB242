%% EGB242 Assignment 2, Section 1 %%
% This file is a template for your MATLAB solution to Section 1.
%
% Before starting to write code, generate your data with the ??? as
% described in the assignment task.

%% Initialise workspace
clear all; close all;
load DataA2 audioMultiplexNoisy fs sid;


%% 1.1 Freq & Time domain representations of audio signal
% Time vector representation of audio signal
t = (0:length(audioMultiplexNoisy) - 1) / fs;

figure;
plot(t, audioMultiplexNoisy);
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Recorded Audio Waveform In Time Domain');
grid on

% Computed the FT of signal
n = length(audioMultiplexNoisy);
fftaudioMultiplexNoisy = fft(audioMultiplexNoisy);

% Freq vector representation of audio signal
f = (0:n-1)*(fs/n);

% Plotted the magnitude of the FFT (only positive freq due to symmetry)
figure;
plot(f(1:floor(n/2)), abs(fftaudioMultiplexNoisy(1:floor(n/2))));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Frequency Domain Plot of Multiplexed Audio Signal');
grid on;

%% 1.2 De-multiplexing system and signal representations

%% SETUP

system = abs(fftaudioMultiplexNoisy);

% Got only the first half of the FFT (positive freqs) due to symmetry
n = length(system);
half_n = floor(n / 2);
system_half = system(1:half_n);
f_half = f(1:half_n);

% Set the domain for peak detection
minPeakProminence = max(system_half) * 0.1;  
minPeakDistance = 10000; 

% Found peaks with adjusted parameters in the positive freq range
[pks, locs] = findpeaks(system_half, 'MinPeakProminence', minPeakProminence, 'MinPeakDistance', minPeakDistance);
carrier_frequencies = f_half(locs);

% Printed out the detected carrier freqs
fprintf('Detected Carrier Frequencies:\n');
for i = 1:length(carrier_frequencies)
    fprintf('%.2f Hz\n', carrier_frequencies(i));
end

% Visualized the detected peaks in the positive frequency range
figure;
plot(f_half, system_half);
hold on;
plot(carrier_frequencies, pks, 'ro'); 
title('Detected Carrier Frequencies in the Positive Frequency Range');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;


% Pre-allocated cell arrary for demod signals
demodulated_signals = cell(1, length(carrier_frequencies));

%% VISUALIZE & STORE

% Demod set
for i = 1:length(carrier_frequencies)
    % Create a sin carrier freq for demod
    carrier = cos(2 * pi * carrier_frequencies(i) * t);
    
    % Demod with carrier
    demodulated_signal = audioMultiplexNoisy .* carrier;
    
    % Low-pass filter to extract the demod baseband signal
    [b, a] = butter(6, 0.1); 
    demodulated_signal = filter(b, a, demodulated_signal);

    demodulated_signals{i} = demodulated_signal;
    
    % Time domain of demod
    figure;
    plot(t, demodulated_signal);
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    title(sprintf('Demodulated Audio Signal in Time Domain (Carrier: %.2f Hz)', carrier_frequencies(i)));
    grid on;
    
    % FFT of demod signal
    fft_demodulated_signal = fft(demodulated_signal);
    
    % Positive freq plot of demod
    n = length(demodulated_signal);
    f = (0:n-1)*(fs/n);
    figure;
    plot(f(1:floor(n/2)), abs(fft_demodulated_signal(1:floor(n/2))));
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title(sprintf('Demodulated Audio Signal in Frequency Domain (Carrier: %.2f Hz)', carrier_frequencies(i)));
    grid on;
end

%% PLAYBACK

% CLI help
num_signals = length(demodulated_signals);
fprintf('There are %d demodulated signals available.\n', num_signals);
fprintf('To play a specific signal, enter a number between 1 and %d.\n', num_signals);
fprintf('=================================================================================================================\n')
fprintf('\n')


% Takes user input for signal index
while true
    signal_index = input(sprintf('Enter a number between 1 and %d to play a signal, or 0 to quit: ', num_signals));
    
    % End Case
    if signal_index == 0
        fprintf('Exiting.\n');
        break;
    end
    
    % Input validation
    if signal_index >= 1 && signal_index <= num_signals
        fprintf('Playing demodulated audio for signal %d (Carrier Frequency: %.2f Hz)\n', signal_index, carrier_frequencies(signal_index));
        
        player = audioplayer(demodulated_signals{signal_index}, fs);
        play(player);
        
        % Wait for the playback
        while isplaying(player)
            pause(0.1);
        end
        
        fprintf('Finished playing signal %d.\n', signal_index);
        fprintf('\n')
        fprintf('=================================================================================================================\n')
        fprintf('\n')

        
    else
        fprintf('Invalid input. Please enter a number between 1 and %d.\n', num_signals);
    end
end

%% 1.3

% Create a discrete-time impulse signal
x = zeros(n, 1);
x(1) = 1;  % Impulse at the first sample

%% Transmit the Impulse Signal Through the Channel

% Use the provided channel function to transmit the impulse signal
y = channel(sid, x, fs);

% The output y is the impulse response h(t) of the channel

%% Compute the Fourier Transforms

% Compute the Fourier Transform of the impulse response (channel frequency response)
H = fft(y);

% Compute the Fourier Transform of the multiplexed audio signal
X = fft(audioMultiplexNoisy);

% Define the frequency vector
n = length(H);
f = (0:n-1)*(fs/n);

%% Plot the Frequency Responses

% Plot the magnitude of the channel frequency response and the multiplexed audio spectrum
figure;
plot(f(1:floor(n/2)), abs(H(1:floor(n/2))), 'b', 'LineWidth', 1.5, 'DisplayName', '|H(f)| - Channel Response');
hold on;
plot(f(1:floor(n/2)), abs(X(1:floor(n/2))), 'r', 'LineWidth', 1.5, 'DisplayName', '|X(f)| - Multiplexed Audio');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Frequency Response of the Channel and Multiplexed Audio Signal');
legend;
grid on;

%% Analyze Additional Features Caused by Noise

% From the plot, observe any discrepancies between |H(f)| and |X(f)|
% Identify any peaks or irregularities in |X(f)| not present in |H(f)|

% (Further analysis can be added here based on observations)




