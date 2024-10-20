%% EGB242 Assignment 2, Section 2 %%

%% Initialise workspace
clear all; close all;

%% 2.1 Modeling DC Motor System Response

% Constants
alpha = 0.5;
t = linspace(0, 20, 10000);

% Step Response 
psi_out = -4 + 2 * t + 4 * exp(-0.5 * t);

% Step Input (unit step)
step_input = ones(size(t));

% Plotted
figure;
plot(t, psi_out, 'LineWidth', 2);
hold on;
plot(t, step_input, '--', 'LineWidth', 2);
title('Comparison of Step Input and Step Response');
xlabel('Time (seconds)');
ylabel('Response');
legend('Step Response \psi_{out}(t)', 'Step Input u(t)');
grid on;

%% 2.2 Feedback System Integration
K_m = 1;  
K_pot = 1;

% Defined the transfer function of the motor Gm(s)
num_Gm = [K_m];
den_Gm = [1 alpha 0];

% Defined the feedback system F(s) with the transfer function Gm(s) and feedback Hp(s)
sys_Gm = tf(num_Gm, den_Gm);  
sys_Hp = tf([K_pot], [1]);

% Closed-loop feedback system F(s) = Gm(s) / (1 + Gm(s)*Hp(s))
sys_closed_loop = feedback(sys_Gm, sys_Hp);

% Simulated the step response using lsim
[psi_out, t_out] = lsim(sys_closed_loop, step_input, t);

% Plotted the step response
figure;
plot(t_out, psi_out, 'LineWidth', 2);
hold on;
plot(t, step_input, '--', 'LineWidth', 2); 
title('Step Response of the Feedback System');
xlabel('Time (seconds)');
ylabel('Response');
legend('Step Response \psi_{out}(t)', 'Step Input u(t)');
grid on;

%% 2.3 System Dynamics Analysis

% Calculating system characteristics
omega_n = 1;  % Natural frequency
zeta = 0.25;  % Damping ratio

% Time to peak (Tp)
Tp = pi / (omega_n * sqrt(1 - zeta^2));

% Settling time (Ts)
Ts = 4 / (zeta * omega_n);

% Percentage Overshoot (%OS)
OS = 100 * exp(-pi * zeta / sqrt(1 - zeta^2));

% Display results
fprintf('Natural Frequency (ωn): %.2f rad/s\n', omega_n);
fprintf('Damping Ratio (ζ): %.2f\n', zeta);
fprintf('Time to Peak (Tp): %.2f seconds\n', Tp);
fprintf('Settling Time (Ts): %.2f seconds\n', Ts);
fprintf('Percentage Overshoot (%%OS): %.2f%%\n', OS);

%% 2.4 Gain Adjustment Analysis

% Defined the range of Kfb and Kfwd values to simulate
K_fb_values = [0.1, 0.2, 0.5, 1, 2];
K_fwd_values = [0.1, 0.2, 0.5, 1, 2];

% Simulatted for different Kfb values while Kfwd = 1
K_fwd = 1;

figure;
for K_fb = K_fb_values
    % Closed-loop transfer function with gains
    sys_closed_loop = feedback(K_fwd * sys_Gm, K_fb * sys_Hp);
    
    % Simulated the step response
    [psi_out, t_out] = lsim(sys_closed_loop, step_input, t);
    
    % Plotted the step response for each Kfb
    plot(t_out, psi_out, 'LineWidth', 2);
    hold on;
end

title('Step Response for Different K_{fb} with K_{fwd} = 1');
xlabel('Time (seconds)');
ylabel('Response');
legend(arrayfun(@(x) sprintf('K_{fb} = %.1f', x), K_fb_values, 'UniformOutput', false));
grid on;

% Simulatted for different Kfwd values while Kfb = 1
K_fb = 1;

figure;
for K_fwd = K_fwd_values
    % Closed-loop transfer function with gains
    sys_closed_loop = feedback(K_fwd * sys_Gm, K_fb * sys_Hp);
    
    % Simulated the step response
    [psi_out, t_out] = lsim(sys_closed_loop, step_input, t);
    
    % Plotted the step response for each Kfwd
    plot(t_out, psi_out, 'LineWidth', 2);
    hold on;
end

title('Step Response for Different K_{fwd} with K_{fb} = 1');
xlabel('Time (seconds)');
ylabel('Response');
legend(arrayfun(@(x) sprintf('K_{fwd} = %.1f', x), K_fwd_values, 'UniformOutput', false));
grid on;

%% 2.5

Tp = 13;


% Solved for natural frequency based on desired time to peak
omega_n = pi / (Tp * sqrt(1 - zeta^2)); 

% Used the identified omega_n to adjust gains
K_fwd = omega_n^2 * 4.75;  
K_fb = 2 * zeta * omega_n;  

% Defined the potentiometer transfer function Hp(s)
sys_Hp = tf([K_pot], [1]);

% Closed-loop transfer function with adjusted gains
cameraTF = feedback(K_fwd * sys_Gm, K_fb * sys_Hp);


% Simulate the step response of the adjusted system
[psi_out, t_out] = lsim(cameraTF, step_input, t);

% Plotted the step response
figure;
plot(t_out, psi_out, 'LineWidth', 2);
title('Step Response of the Camera Control System (Tp = 13s)');
xlabel('Time (seconds)');
ylabel('Yaw Angle \psi(t)');
legend('Step Response \psi_{out}(t)');
grid on;

% Display the adjusted gains
fprintf('Adjusted Forward Gain (K_fwd): %.2f\n', K_fwd);
fprintf('Adjusted Feedback Gain (K_fb): %.2f\n', K_fb);

%% 2.6 Control System for Panoramic Views

startAngle_deg = 30;
endAngle_deg = 210;  
actual_end_deg = 228;

% Convert angles to radians
startAngle_rad = startAngle_deg * (pi/180);  
endAngle_rad = endAngle_deg * (pi/180);

% Initial voltage calculations
voltageRange = 1;
startVoltage = (startAngle_rad / (2*pi)) * voltageRange;
endVoltage = (endAngle_rad / (2*pi)) * voltageRange;

% Behaviour Correction
endVoltage_corrected = endVoltage * (endAngle_deg / actual_end_deg);

% System Simulation
[startIm, finalIm] = cameraPan(startVoltage, endVoltage_corrected, cameraTF);

% Final Images
figure;
subplot(1,2,1);
imshow(startIm);
title(sprintf('Starting Image at %.0f°', startAngle_deg));

subplot(1,2,2);
imshow(finalIm);
title(sprintf('Final Image at %.0f°', endAngle_deg));

% Display Settings
fprintf('Adjusted Start Voltage: %.2f V (for %.0f°)\n', startVoltage, startAngle_deg);
fprintf('Adjusted End Voltage: %.2f V (for %.0f°)\n', endVoltage, endAngle_deg);
fprintf('Mapped Start Angle: %.2f radians\n', startAngle_rad);
fprintf('Mapped End Angle: %.2f radians\n', endAngle_rad);
