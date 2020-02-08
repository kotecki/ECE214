%% ECE214 Lab #3 Low Pass Filter Design (Spring 2020)

%% Copyright (c) 2020 by David E. Kotecki. All rights reserved.

% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:

% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.

% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.

% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

%% Section 1: Define: CPPSim location, library, and schematic
clear variables;  
CppSim_Location = sprintf('C:/CppSim'); % location of CppSim directory
Design_Library = sprintf('Library Name'); % name of design library
Schematic_Name = sprintf('Schematic Name'); % name of schematic

%% Section 2: Generate HSPC file and run NGspice
addpath(sprintf('%s/CppSimShared/HspiceToolbox', CppSim_Location)); % add ngspice matlab toolbox to the path
Working_Dir = sprintf('%s/SimRuns/%s/%s', CppSim_Location, Design_Library, Schematic_Name);
if ~exist(Working_Dir, 'dir')  
    mkdir(Working_Dir)  % create working directory if it does not exist
end
cd(Working_Dir) % set current folder to the working directory
hspc_filename = sprintf('%s.hspc', Schematic_Name);   % define hspc filename

hspcfile = fopen(hspc_filename, 'w');    % open file 'hspc_filename' for write
fprintf(hspcfile, '**** NGspice HSPC file **** \n');
fprintf(hspcfile, '**** File: %s/%s **** \n', pwd, hspc_filename);
fprintf(hspcfile, '**** Date: %s **** \n\n', datestr(datetime('now')));

fprintf(hspcfile, '**** Simulation Statement ****\n');
fprintf(hspcfile, '.tran 100u 125m 25m 10u \n\n');

fprintf(hspcfile, '**** Paramenter Statements ****\n');
fprintf(hspcfile, '.param res1 = 10000 \n');   % define resistor value res1
fprintf(hspcfile, '.param res2 = 100000 \n');   % define resistor value res2 
fprintf(hspcfile, '.param cap1 = 40e-9 \n');  % define resistor value cap1
fprintf(hspcfile, '.param cap2 = 4e-9 \n\n');  % define resistor value ?ap2

fprintf(hspcfile, '**** Include Statements ****\n');
fprintf(hspcfile, '.include ../../../SpiceModels/ECE214_models.mod \n\n');

% fprintf(hspcfile, '**** Initial Conditions ****\n');
% fprintf(hspcfile, '.ic v(out1)=5 \n\n');

fprintf(hspcfile, '**** Simulation Options ****\n');
fprintf(hspcfile, '.options post=1 delmax=5p relv=1e-6 reli=1e-6 relmos=1e-6 method=gear \n');
fprintf(hspcfile, '.temp 27\n');
fprintf(hspcfile, '.global gnd \n');
fprintf(hspcfile, '.op \n\n');
fprintf(hspcfile, '**** End of NGspice hspc file \n');
fclose(hspcfile);
 
ngsim(hspc_filename); % run ngspice  

%% load simulation results and extract time, Vout, and Vin
data = loadsig('simrun.raw');  % load data from simulation into Matlab
time = evalsig(data, 'TIME');  % create vector of time values
Vin = evalsig(data, 'vin');    % create vector of node vin voltage values
Vout = evalsig(data,'vout');   % create vector of node Vout voltage values

%% plot Vin and Vout as a function of time
fs = 16; % define font size
lw = 1.5; % define linewidth
Fig1 = figure('Position', [200, 75, 850, 600]); % figure size and location

subplot(2,1,1); % first subplot
plot(time.*1000,  Vin, 'linewidth',lw);
grid on; % add grid
set(gca, 'fontsize', fs); % set font size
ylabel('Voltage (V)', 'fontsize', fs); % label y-axis
title('ECE 214: Lab 3 - Low Pass Filter (time domain)'); % title
legend('Filter Input'); % add legend
axis([35 40 -2 2]); % set axis limits

subplot(2,1,2); % second subplot
plot(time.*1000, Vout, 'linewidth',lw);
grid on; % add grid
set(gca, 'fontsize', fs); % set font size
xlabel('Time (ms)', 'fontsize', fs); % label x-axis
ylabel('Voltage (V)', 'fontsize', fs); % label y-axis
legend('Filter Output'); % add legend
axis([35 40 -2 2]); %set axis limits

%% Plot the FFT (Approximate Fourier Series)
Fig2 = figure('Position', [150, 75, 850, 600]); % figure size and location

subplot(2,1,1);
[freq, mag_in] = vt_to_vf(time, Vin); % generate Fourier components
semilogx(freq, mag_in, 'linewidth', lw);
grid on;
set(gca, 'fontsize', fs);
axis([100,1e5,-30,10]); % set axis limits
legend('Filter Input'); % add legend
ylabel('Voltage (dB)', 'fontsize', fs); % label y-axis
title('ECE 214: Lab 3 - Low Pass Filter (Fourier components of square wave)')

subplot(2,1,2);
[freq, mag_out] = vt_to_vf(time, Vout); % generate Fourier components
semilogx(freq, mag_out, 'linewidth', lw);
grid on;
set(gca, 'fontsize', fs);
axis([100,1e5,-40,10]);
legend('Filter Output'); % add legend
ylabel('Voltage (dB)', 'fontsize', fs); % label y-axis
xlabel('Frequency (Hz)', 'fontsize', fs); % label x-axis

% %% Post Lab - Frequency response of Low Pass Filter (ac analysis)
% % set the AC_Voltage = 1 volt in the schematic
% hspc_addline('.ac dec 201 100 1e5', hspc_filename); % change from transient to ac analysis
% ngsim(hspc_filename); % run NGspice
% 
% %% Load simulation results and extract Frequency and Vout
% data = loadsig('simrun.raw');
% frequency = evalsig(data, 'FREQUENCY');
% Vout = evalsig(data,'vout');
% 
% %% Plot amplitude and phase
% 
% Fig3 = figure('Position', [100, 75, 850, 600]);
% 
% subplot(2,1,1)
% semilogx(frequency, 20*log10(abs(Vout)), 'linewidth',lw);
% grid on;
% set(gca, 'fontsize', fs);
% ylabel('dB Voltage', 'fontsize', fs);
% title('ECE 214: Lab 3, Low Pass Filter (frequency response)');
% legend('Filter Input'); % add legend
% 
% subplot(2,1,2)
% semilogx(frequency, phase(Vout)*180/pi, 'linewidth',lw);
% grid on;
% set(gca, 'fontsize', fs);
% xlabel('Frequency (Hz)', 'fontsize', fs);
% ylabel('Phase (degrees)', 'fontsize', fs);
% legend('Filter Output'); % add legend

%% end of .m file
