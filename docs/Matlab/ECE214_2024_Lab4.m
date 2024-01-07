%% ECE214 Lab #4 (Spring 2024)

%% Copyright (c) 2024 by David E. Kotecki. All rights reserved.

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
Design_Library = sprintf('Library_Name'); % name of design library
Schematic_Name = sprintf('Schematic_Name'); % name of schematic

% CppSim_Location = sprintf('/Users/Kotecki/CppSim'); % location of CppSim directory
% Design_Library = sprintf('ECE214_2024'); % name of design library
% Schematic_Name = sprintf('Lab4_Measured'); % name of schematic

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

frequency = 50000; % set frequency of the voltage source

fprintf(hspcfile, '**** Simulation Statement ****\n');
fprintf(hspcfile, '.tran %d %d %d 0 \n\n', 0.01/frequency, 10e-3 + 5/frequency, 10e-3);

fprintf(hspcfile, '**** Paramenter Statements ****\n');
fprintf(hspcfile, '.param freq= %d \n\n', frequency);  % define resistor value

fprintf(hspcfile, '**** Include Statements ****\n');
fprintf(hspcfile, '.include ../../../SpiceModels/ECE214_models.mod \n\n');

fprintf(hspcfile, '**** Simulation Options ****\n');
fprintf(hspcfile, '.options post=1 delmax=5p relv=1e-6 reli=1e-6 relmos=1e-6 method=gear \n');
fprintf(hspcfile, '.temp 27\n');
fprintf(hspcfile, '.global gnd \n');
fprintf(hspcfile, '.op \n\n');
fprintf(hspcfile, '**** End of NGspice hspc file \n');
fclose(hspcfile);
 
ngsim(hspc_filename); % run ngspice  

%% Section 3: Load simulation results and analyze data

data = loadsig('simrun.raw');  % load data from simulation into Matlab
time = evalsig(data, 'TIME');  % create vector of time values
V1 = evalsig(data,'va');       % create vector of node Va voltage values
V2 = evalsig(data, 'vb');      % create vector of node Vb voltage values

% calculate peak voltages for V_1 and V_2
V1_peak = max(V1);
V2_peak = max(V2);

% Define empty arrays to calculate the zero crossings for V1 and V2
V1_zero = [ ];
V2_zero = [ ];
% calculate the zero-crossings of V1 for the rising edge
for index = 1:length(V1)-1
    if(V1(index) < 0 && V1(index+1) > 0)
        slope = (V1(index+1) - V1(index)) / (time(index + 1) - time(index));
        V1_zero(end+1) = time(index) - V1(index)./slope;
    end
end
% calculate the zero-crossings of V2 for the rising edge
for index = 1:length(V2)-1
    if(V2(index) < 0 && V2(index+1) > 0)
        slope = (V2(index+1) - V2(index)) / (time(index + 1) - time(index));
        V2_zero(end+1) = time(index) - V2(index)./slope;
    end
end
% Calculate the phase shift in degrees
if V1(1) >= 0
    DeltaT = V2_zero(3) - V1_zero(2);
else
    DeltaT = V2_zero(3) - V1_zero(3);
end
PS = - 360 .* DeltaT .* frequency;

% plot V1 and V2 as a function of time
FigHandle = figure('Position', [200, 75, 850, 600]);  % set figure size and location
fs = 16; % font size
lw = 2;  % linewidth
plot(time.*1000, V1, time.*1000, V2, 'linewidth', lw)
grid on;% add grid
set(gca, 'fontsize', fs);
xlabel('Time (ms)', 'fontsize', fs);   % x-axis label
ylabel('Voltage (V)', 'fontsize', fs); % y-axis label
title(sprintf('Frequency = %.2f kHz', frequency/1000)); % title
legend('Node Voltage V1', 'Node Voltage V2'); % legend
legend show;
% add peak voltages and phase shift information to the graph
t1 = sprintf('V1 peak = %0.3g V \n',V1_peak);
t2 = sprintf('V2 peak = %0.3g V \n',V2_peak);
t3 = sprintf('PS = %0.3g ^{o}',PS);
text=[t1 t2 t3];
dim = [.15, .7 .2 .2];
annotation('textbox',dim,'String',text,'FitBoxToText','on', 'BackgroundColor','white', 'FaceAlpha',0.8,'fontsize', fs);

%% end of .m file
