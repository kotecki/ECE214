%% ECE214 Lab #1 (Spring 2024)

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
% CppSim_Location = sprintf('C:/CppSim'); % location of CppSim directory
CppSim_Location = sprintf('/Users/david/CppSim'); % location of CppSim directory
Design_Library = sprintf('ECE214_2022'); % name of design library
Schematic_Name = sprintf('Lab1a'); % name of schematic

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
fprintf(hspcfile, '.tran 1u 1m 0 0 \n\n');

%%%%
resistor = 10000; % set resistance value
%%%%

fprintf(hspcfile, '**** Paramenter Statements ****\n');
fprintf(hspcfile, '.param res = %d \n\n', resistor); 

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

data = loadsig('simrun.raw');  % load data from simulation
time = evalsig(data, 'TIME');  % create vector of time values
Vout_1 = evalsig(data,'vin');   % create vector of node Va voltage values
Vout_2 = evalsig(data, 'vout');  % create vector of node Vb voltage values

fs = 14;   % define font size
lw = 1.5;  % define linewidth
FigHandle = figure('Position', [175, 50, 850, 600]);            % set figure size and location
plot(time.*1000,  Vout_1, time.*1000, Vout_2, 'linewidth',lw);  % plot Vout_1 and Vout_2 vs time
grid on;                               % add grid
set(gca, 'fontsize', fs);              % increase font size
ylabel('Voltage (V)', 'fontsize', fs); % y-axis label
xlabel('Time (ms)', 'fontsize', fs);   % x-axis label
resstr = insertcommas(resistor);
title(strcat('Voltage vs. Time when R = ', resstr, '\Omega'));  % title
legend('Input voltage', 'Output voltage');

%% Generate N logarithmically spaced resistance values
% range is from 10 Ohms - 10 Meg Ohms
N = 20;
Rvalues = logspace(1,7,N);

%% Loop through all values of R and determine peak voltage
for i = 1:N
    hspc_set_param('res', Rvalues(i), hspc_filename); %set resistance value in Lab1.hspc
    ngsim(hspc_filename); % call ngsim and run simulation
    data = loadsig('simrun.raw'); % load simulation reults in variable 'data'
    vout = evalsig(data,'vout'); % store output voltage values in variable 'vout'
    vpeak(i) = abs(max(vout)); % calculate pleak voltage and store in array 'vpeak'
end

%% Plot
FigHandle = figure('Position', [200, 75, 850, 600]); % figure size and location
semilogx(Rvalues, vpeak, '-s', 'linewidth', 2.0) % generate semilog plot
grid on; % turn on the grid
set(gca, 'fontsize', fs); % increase font size of title and axes text
xlabel('Resistance (\Omega)', 'fontsize', fs); % label x-axis
ylabel('Output Voltage (V)', 'fontsize', fs); % label y-axis
title('Output voltage as a function of resistance'); % add title
grid on; % turn on grid

%% Add commas to resistor value in title of the plot
function comma = insertcommas(N)
N = num2str(N);
comma = '';
for j = 1:length(N)
    comma = strcat(N(length(N)-j+1),comma);
    if ~mod(j,3)
        comma = strcat(',',comma);
    end    
end
if strcmp(comma(1), ',')
    comma(1) = [];
end
end

%% end of .m file
