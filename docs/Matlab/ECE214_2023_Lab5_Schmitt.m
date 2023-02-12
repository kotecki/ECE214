%% ECE214 Lab #5 Schmitt Trigger (Spring 2023)

%% Copyright (c) 2023 by David E. Kotecki. All rights reserved.

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
fprintf(hspcfile, '.dc V0 0 12 .01 \n\n'); % DC sweep from 0 to 10 V

fprintf(hspcfile, '**** Paramenter Statements ****\n');
fprintf(hspcfile, '.param res1 = 10e3 \n');   % define resistor value res1
fprintf(hspcfile, '.param res2 = 10e3 \n');   % define resistor value res2 
fprintf(hspcfile, '.param vdc = 12 \n\n')

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

%% Section 3: Load simulation results and analyze data

data = loadsig('simrun.raw');  % load data from simulation
Vin = evalsig(data, 'VOLTAGE');  % create vector of voltage values
Vout = evalsig(data,'vout');   % create vector of node vout voltage values

fs = 16;   % define font size
lw = 1.5;  % define linewidth
Fig1 = figure('Position', [200, 75, 850, 600]); % figure size and location
plot(Vin, Vout, 'b', 'linewidth', lw);
hold on
plot(Vin(1:40:end), Vout(1:40:end), 'b>', 'MarkerSize', 12,'linewidth', lw);
set(gca, 'fontsize', fs); % set font size
ylabel('Output Voltage (V)', 'fontsize', fs); % label y-axis
xlabel('Input Voltage (V)', 'fontsize', fs); % label x-axis
title('ECE 214: Lab 5 - Schmitt Trigger'); % title
grid on; % add grid

%% NGspice control statement and run NGspice
hspc_addline('.dc V0 12 0 -.01', hspc_filename); % DC sweep from 10 to 0V
ngsim(hspc_filename); % run NGspice

%% load simulation results and extract time, Vout, and Vin
data = loadsig('simrun.raw');
Vin = evalsig(data, 'VOLTAGE');
Vout = evalsig(data,'vout');

%% Plot result on the same graph
plot(Vin, Vout, 'r', 'linewidth', lw);
plot(Vin(1:40:end), Vout(1:40:end), 'r<', 'MarkerSize', 12, 'linewidth', lw);
%% end of .m file
