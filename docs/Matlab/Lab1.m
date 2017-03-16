% Matlab m-file for ECE 214 Lab 1.

% add ngspice matlab toolbox to the path
addpath('/users/Kotecki/CppSim/CppSimShared/HspiceToolbox');

% set format long; clear variables; access the test.hspc file
format long;
clear variables;
hspc_filename = sprintf('test.hspc');

% define and set the value of frequency
f = 1000;
hspc_set_param('freq', f, hspc_filename);

% generate N logarithmically spaced resistance values ranging
% from 10 Ohms - 10 Meg Ohms
N = 10;
Rvalues = logspace(1,7,N);

% Loop through all values of R
for i = 1:N
    % set resistance value in test.hspc
    hspc_set_param('res', Rvalues(i), hspc_filename);
    % call ngsim and run simulation
    ngsim(hspc_filename);
    % load simulation results in variable 'data'
    data = loadsig('simrun.raw');
    % store output voltage values in variable 'Vout'
    vout = evalsig(data,'vout');
    % calculate peak value of sinusoidal outut voltage and store in array Vpeak
    vpeak(i) = max(vout);
end

% set figure size and location
FigHandle = figure('Position', [200, 75, 850, 600]);
% generate a semilog plot of the peak output voltage as a function of the
% resistance
semilogx(Rvalues, vpeak, 'linewidth',2.0)
%semilogx(Rvalues, vpeak, '-s', 'linewidth',2.0)
% turn on the grid
grid on;
% increase the font size of title and axes text
set(gca, 'fontsize', 16);
% label the x- and y-axis and add a title
xlabel('Resistance (\Omega)', 'fontsize', 16);
ylabel('Output Voltage (V)', 'fontsize', 16);
title('Expected output voltage as a function of resistance');
% turn on grid
grid on;
