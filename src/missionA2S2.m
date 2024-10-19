%% EGB242 Assignment 2, Section 2 %%
% This file is a template for your MATLAB solution to Section 2.
%
% Before starting to write code, generate your data with the ??? as
% described in the assignment task.

%% Initialise workspace
clear all; close all;

% Begin writing your MATLAB solution below this line.

% Constants
alpha = 0.5;
t = linspace(0, 20, 10000); % Time vector from 0 to 20 seconds with 10^4 samples

% Step Response Calculation
psi_out = -4 + 2 * t + 4 * exp(-0.5 * t);

% Step Input (unit step)
step_input = ones(size(t));

% Plotting the step input and step response
figure;
plot(t, psi_out, 'LineWidth', 2);
hold on;
plot(t, step_input, '--', 'LineWidth', 2);
title('Comparison of Step Input and Step Response');
xlabel('Time (seconds)');
ylabel('Response');
legend('Step Response \psi_{out}(t)', 'Step Input u(t)');
grid on;
