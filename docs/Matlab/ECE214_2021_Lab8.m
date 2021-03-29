%% ECE214 Lab #8 Astable Multivibrator Circuit (Spring 2021)

%% Copyright (c) 2021 by David E. Kotecki. All rights reserved.

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
%CppSim_Location = sprintf('/home/David/CppSim');
CppSim_Location = sprintf('/Users/Kotecki/CppSim'); % location of CppSim directory
Design_Library = sprintf('ECE214_2020'); % name of design library
Schematic_Name = sprintf('Lab8_2020'); % name of schematic

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
fprintf(hspcfile, '.tran .1u 40m 10m   \n\n');

fprintf(hspcfile, '**** Paramenter Statements ****\n');
cap1 = .1e-6;
cap2 = .1e-6;
fprintf(hspcfile, '.param rx = 800 \n');
fprintf(hspcfile, '.param ru = 60000 \n');
fprintf(hspcfile, '.param rd = 30000 \n');
fprintf(hspcfile, sprintf('.param amv_c1 = %g \n', cap1));
fprintf(hspcfile, sprintf('.param amv_c2 = %g \n\n', cap2));

fprintf(hspcfile, '**** Include Statements ****\n');
fprintf(hspcfile, '.include ../../../SpiceModels/ECE214_models.mod \n\n');

fprintf(hspcfile, '**** Initial Condition Statement ****\n');
fprintf(hspcfile, '.ic v(vout2) = 0 \n\n');

fprintf(hspcfile, '**** Simulation Options ****\n');
fprintf(hspcfile, '.options post=1 delmax=5p relv=1e-6 reli=1e-6 relmos=1e-6 method=gear \n');
fprintf(hspcfile, '.global gnd \n');
fprintf(hspcfile, '.temp 27 \n');
fprintf(hspcfile, '.op \n\n');
fprintf(hspcfile, '**** End of NGspice hspc file \n');
fclose(hspcfile);

ngsim(hspc_filename); % run ngspice  

%% Section 3: Load simulation results and analyze data

data = loadsig('simrun.raw');  % load data from simulation
time = evalsig(data, 'TIME');  % create vector of time values
Vout1 = evalsig(data, 'vout1');  
Vout2 = evalsig(data, 'vout2');
Vout3 = evalsig(data, 'vout3');

fs = 16;   % define font size
lw = 1.5;  % define linewidth
FigHandle1 = figure('Position', [200, 75, 850, 600]);   % set figure size and location
plot(time.*1000,  Vout1, time.*1000, Vout2, 'linewidth',lw);  % plot Vout1 and Vout2 vs time
grid on;                               % add grid
set(gca, 'fontsize', fs);              % increase font size
ylabel('Voltage (V)', 'fontsize', fs); % y-axis label
xlabel('Time (ms)', 'fontsize', fs);   % x-axis label
legend('Vout', 'Vc');
title('ECE214 Lab #8 - Astable Oscillator - Capacitor Voltages');% title

FigHandle2 = figure('Position', [150, 75, 850, 600]);   % set figure size and location
plot(time.*1000, Vout3, 'linewidth',lw);  % plot Vout3 vs time
grid on;                               % add grid
set(gca, 'fontsize', fs);              % increase font size
ylabel('Voltage (V)', 'fontsize', fs); % y-axis label
xlabel('Time (ms)', 'fontsize', fs);   % x-axis label
title('ECE214 Lab #8 - Oscillator Output Voltage');% title

%% Calculate frequency using 6V crossing (taken from Lab #2)
tx_rising = [ ];
tx_falling = [ ];
% calculate the rising edge 6 Volt-crossings of Vout3
for index = 1:length(Vout3)-1
    if(Vout3(index) < 6 && Vout3(index+1) > 6)
        slope = (Vout3(index+1) - Vout3(index)) / (time(index + 1) - time(index));
        tx_rising(end+1) = time(index) + (6 - Vout3(index))./slope;
    end
    
    if(Vout3(index) > 6 && Vout3(index+1) < 6)
        slope = (Vout3(index+1) - Vout3(index)) / (time(index + 1) - time(index));
        tx_falling(end+1) = time(index) + (6 - Vout3(index))./slope;
    end
end

if length(tx_rising) > length(tx_falling)
    tx_rising(end) = [ ];
elseif length(tx_rising) < length(tx_falling)
        tx_falling(end) = [ ];
end

% Calculate period and frequency
period = zeros(1,length(tx_rising)-1);
for k = 1:length(tx_rising)-1
    period(k) = tx_rising(k+1) - tx_rising(k);
end
freq_mean = mean(1./period);
freq_std = std(1./period);

% Calculate duty cycle
duty_cycle = (tx_falling - tx_rising)/mean(period);
if duty_cycle < 0
    duty_cycle = 1 + duty_cycle;
end
dc_mean = mean(duty_cycle);
dc_std = std(duty_cycle);

%% Annotate graph
text0 = sprintf('Average Frequency (from 6V crossing) = %0.4g kHz\n', 1e-3 * freq_mean);
text1 = sprintf('Standard Deviation (from 6V crossing) = %0.4g kHz\n', 1e-3 * freq_std);
text2 = sprintf('Duty Cycle (from 6V crossing) = %0.4g %%\n', 100 * dc_mean);
text3 = sprintf('Standard Deviation (from 6V crossing) = %0.4g %%', 100 * dc_std); 
text = [text0 text1 text2 text3];
dim=[.15, .5, 0, 0];
annotation('textbox',dim,'String',text,'FitBoxToText','on', 'BackgroundColor','white', ...
    'FaceAlpha',0.85,'fontsize', fs);

%%
return

%% Sensitivity Analysis
% let cap2 vary by +- 10%
cap_nom2 = cap2;
asm_c2 = cap_nom2-0.1*cap_nom2: cap_nom2/50: cap_nom2+0.1*cap_nom2;
cap2_len = length(asm_c2);

f_mean_cross = zeros(1,cap2_len);
f_std_cross = zeros(1,cap2_len);
dc_mean_cross = zeros(1,cap2_len);
dc_std_cross = zeros(1,cap2_len);

for i=1:cap2_len
    hspc_set_param('amv_c2', asm_c2(i), hspc_filename);
    ngsim(hspc_filename);
    data = loadsig('simrun.raw');
    time = evalsig(data, 'TIME');
    Vout3 = evalsig(data, 'vout3');
    
   %% Calculate frequency and duty cycle using 6V crossing (taken from Lab #2)
    tx_rising = [ ];
    tx_falling = [ ];
    % calculate the rising edge 6 Volt-crossings of Vout3
    for index = 1:length(Vout3)-1
        if(Vout3(index) < 6 && Vout3(index+1) > 6)
            slope = (Vout3(index+1) - Vout3(index)) / (time(index + 1) - time(index));
            tx_rising(end+1) = time(index) + (6 - Vout3(index))./slope;
        end
    
        if(Vout3(index) > 6 && Vout3(index+1) < 6)
            slope = (Vout3(index+1) - Vout3(index)) / (time(index + 1) - time(index));
            tx_falling(end+1) = time(index) + (6 - Vout3(index))./slope;
        end
    end
%
    if length(tx_rising) > length(tx_falling)
        tx_rising(end) = [ ];
    elseif length(tx_rising) < length(tx_falling)
        tx_falling(end) = [ ];
    end

    % Calculate period and frequency
    period = zeros(1,length(tx_rising)-1);
    for k = 1:length(tx_rising)-1
        period(k) = tx_rising(k+1) - tx_rising(k);
    end
    f_mean_cross(i) = mean(1./period);
    f_std_cross(i) = std(1./period);

    % Calculate duty cycle
    duty_cycle = (tx_falling - tx_rising)/mean(period);
    if duty_cycle < 0
        duty_cycle = 1 + duty_cycle;
    end
    dc_mean_cross(i) = mean(duty_cycle);
    dc_std_cross(i) = std(duty_cycle);

   
end
%%
FigHandle4 = figure('Position', [100, 75, 850, 600]);   % set figure size and location
plot(asm_c2.*1e9, f_mean_cross.*1e-3, '-*', 'linewidth',lw);  % plot Vout3 vs time
grid on;                             
set(gca, 'fontsize', fs);              
xlabel('Capacitance ''cap2'' (nF)', 'fontsize', fs); 
ylabel('Oscillation Frequency (kHz)', 'fontsize', fs);  
title('ECE214 Lab #8 - Astable Oscillator Sensitivity Analysis');
axis([1e9*(cap_nom2-0.1*cap_nom2) 1e9*(cap_nom2+0.1*cap_nom2) -inf inf])

FigHandle5 = figure('Position', [50, 75, 850, 600]);   % set figure size and location
plot(asm_c2.*1e9, dc_mean_cross.*100, '-*', 'linewidth',lw);  % plot Vout3 vs time
grid on;                             
set(gca, 'fontsize', fs);              
xlabel('Capacitance ''cap2'' (nF)', 'fontsize', fs); 
ylabel('Duty Cycle (%)', 'fontsize', fs);  
title('ECE214 Lab #8 - Astable Oscillator Sensitivity Analysis');
axis([1e9*(cap_nom2-0.1*cap_nom2) 1e9*(cap_nom2+0.1*cap_nom2) -inf inf])

%% end of .m file
