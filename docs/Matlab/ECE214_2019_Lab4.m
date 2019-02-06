%% Matlab m-file Template for ECE 214 Lab #4

addpath('/users/Kotecki/CppSim/CppSimShared/HspiceToolbox'); % add ngspice matlab toolbox to the path
clear variables;
hspc_filename = 'ECE214_2019_lab4.hspc';

%% Define variables
frequency = 30.e3;       % Frequency
vpk = .005;             % Input peak voltage
R1 = 1e3;               % Resistor 1
R2 = 5e3;               % Resistor 2
voffset = .0;           % Input offset voltage
hspc_set_param('vpeak', vpk, hspc_filename);
hspc_set_param('res1', R1, hspc_filename);
hspc_set_param('res2', R2, hspc_filename);
hspc_set_param('voffset', voffset, hspc_filename);
hspc_set_param('freq',frequency, hspc_filename);
T = 1./frequency;
ctrl_string = sprintf('.tran %0.5g %0.5g %0.5g %0.5g', T, 30.*T, 0, 0);

%% run ngspice
hspc_addline(ctrl_string, hspc_filename);
ngsim(hspc_filename);

%% load simulation results and extract time, Va, and Vb
data = loadsig('simrun.raw');
time = evalsig(data, 'TIME');
Vout = evalsig(data,'output');
Vin = evalsig(data, 'input');

%% plot Vin and Vout as a function of time

fs = 16;    % define font size (fs)
lw = 1.5;   % define linewidth (lw)
FigHandle = figure('Position', [200, 75, 850, 600]);    % set figure size and location

plot(time.*1000,  Vin, time*1000, Vout, 'linewidth',lw);
grid on;   % add grid
set(gca, 'fontsize', fs);   % increase font size
ylabel('Voltage (V)', 'fontsize', fs);
xlabel('Time (ms)', 'fontsize', fs);
legend('Input', 'Output');
title(sprintf('ECE 214 - Lab 4,  Frequency = %0.5g kHz', frequency./1000));

%% end of .m file