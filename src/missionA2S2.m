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
