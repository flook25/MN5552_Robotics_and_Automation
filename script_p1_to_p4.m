%% DC MOTOR CONTROL SYSTEM DESIGN (P1 - P4)
% Student ID: 2503146
% Module: MN5552 Robotics and Manufacturing Automation

clear all; clc; close all;

%% --- 1. MOTOR PHYSICAL PARAMETERS (P1) ---
% These values are based on the specific motor requirements
J = 0.0113;  % Moment of inertia (Kg.m^2)
b = 0.028;   % Viscous damping (Nms)
L = 0.1;     % Armature inductance (H)
R = 0.45;    % Armature resistance (Ohm)
Kt = 0.067;  % Torque constant (Nm/Amp)
Ke = 0.067;  % Back EMF constant (Vs/rad)

%% --- 2. OPEN-LOOP STATE-SPACE MODEL (P2) ---
% Defining State-Space Matrices: x = [angular_velocity; current]
A = [-b/J, Kt/J; 
     -Ke/L, -R/L];
     
B = [0; 
     1/L];
     
C = [1, 0];  % Output is angular velocity (omega)
D = 0;       % No direct feedthrough

% Create Open-loop model object
sys_open = ss(A, B, C, D);

%% --- 3. STATE FEEDBACK CONTROLLER DESIGN (P4) ---
% We use 'Pole Placement' for maximum stability and zero oscillations.
% Desired poles are chosen at -20 and -10 for a fast response.
DesiredPoles = [-20, -10];
K_gain = place(A, B, DesiredPoles); % Automatically calculate k1 and k2

% Calculate Kr (Feedforward Gain) to eliminate Steady-State Error.
% This ensures the motor reaches exactly 1.0 rad/s.
Kr = -1 / (C * inv(A - B * K_gain) * B);

% Define Closed-Loop State-Space Matrices
Ac = A - B * K_gain;
Bc = B * Kr;
Cc = C;
Dc = D;

% Create Closed-loop model object
sys_closed = ss(Ac, Bc, Cc, Dc);

%% --- 4. PERFORMANCE ANALYSIS & PLOTTING ---
t = 0:0.01:3; % Time vector for 3 seconds

% Compare Open-loop vs Closed-loop
[y_open, t_open] = step(sys_open, t);
[y_closed, t_closed] = step(sys_closed, t);

figure('Color', 'w');
plot(t_closed, y_closed, 'b', 'LineWidth', 2); hold on;
plot(t_open, y_open, 'r--', 'LineWidth', 1.5);
line([0 3], [1 1], 'Color', 'k', 'LineStyle', ':'); % Target line

xlabel('Time (seconds)');
ylabel('Angular Velocity (rad/s)');
title('DC Motor Speed Response: Open-Loop vs. State Feedback');
legend('State Feedback (P4)', 'Open-Loop (P2)', 'Target Setpoint');
grid on;

% Display the calculated gains in the command window for the report
fprintf('--- Controller Design Results ---\n');
fprintf('Feedback Gain K: [%.4f, %.4f]\n', K_gain(1), K_gain(2));
fprintf('Feedforward Gain Kr: %.4f\n', Kr);