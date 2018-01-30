%% Example Matlab m-file for ECE 214 (NGspice_Example.m)

addpath('/users/Kotecki/CppSim/CppSimShared/HspiceToolbox'); % add ngspice matlab toolbox to the path
clear variables; % clear variables
hspc_filename = 'ECE214_2018_NGspice_Example.hspc'; % define hspc filename

%% Define simulation control statement and run ngspice
hspc_addline('.tran 5u 5m 0 0', hspc_filename); % define transient simulation and write to hspc file
%hspc_set_param('cap', 2e-9, hspc_filename); % set capacitance value
ngsim(hspc_filename); % run ngspice

%% Load and extract simulation results
sim_data = loadsig('simrun.raw'); % load simulation data into structured array: sim_data
time = evalsig(sim_data, 'TIME'); % from sim_data, extract vector time
Vin = evalsig(sim_data,'vin');    % from sim_data, extract vector vin
Vout = evalsig(sim_data, 'vout'); % from sim_data, extract vector vout

%% Plot Vin and Vout as a function of time
fs = 16;  % variable for font size
lw = 1.5; % variable for linewidth
Fig1 = figure('Position', [200, 75, 850, 600]); % set figure size and location
plot(time, Vin, time, Vout,   'linewidth',lw);
grid on; % add grid
set(gca, 'fontsize', fs); % increase font size
ylabel('Voltage (V)', 'fontsize', fs); % y-axis label
xlabel('Time (s)', 'fontsize', fs); % x-axis label
title('NGspice\_Example.m'); %title
legend('Voltage Input', 'Voltage Output')

%% end of .m file
