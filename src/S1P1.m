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