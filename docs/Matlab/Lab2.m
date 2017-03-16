% Matlab m-file for ECE 214 Lab #2

% add ngspice matlab toolbox to the path
addpath('/users/Kotecki/CppSim/CppSimShared/HspiceToolbox');

% set format; clear variables; access the test.hspc file
format long;
clear variables;
hspc_filename = sprintf('Lab2.hspc');

% define frequency
frequency = 50000;

% set test.hspc paramater: frequency
hspc_set_param('freq', frequency, hspc_filename);

% run ngspice
ngsim(hspc_filename);

% load simulation results and extract time, Va, and Vb
data = loadsig('simrun.raw');
time = evalsig(data, 'TIME');
Va = evalsig(data,'va');
Vb = evalsig(data, 'vb');

% calculate peak voltages for Va and Vb
Va_peak = max(Va);
Vb_peak = max(Vb);

% Define empty arrays to calculate the zero crossings for Va and Vb
Va_zero = [ ];
Vb_zero = [ ];
% calculate the zero-crossings of Va for the rising edge
for index = 1:length(Va)-1
    if(Va(index) < 0 && Va(index+1) > 0)
        slope = (Va(index+1) - Va(index)) / (time(index + 1) - time(index));
        Va_zero(end+1) = time(index) + -Va(index)./slope;
    end
end
% calculate the zero-crossings of Va for the rising edge
for index = 1:length(Vb)-1
    if(Vb(index) < 0 && Vb(index+1) > 0)
        slope = (Vb(index+1) - Vb(index)) / (time(index + 1) - time(index));
        Vb_zero(end+1) = time(index) + -Vb(index)./slope;
    end
end
% Calculate the phase shift in degrees
if Va(1) >= 0
    DeltaT = Vb_zero(3) - Va_zero(2);
else
    DeltaT = Vb_zero(3) - Va_zero(3);
end
PS = 360 .* DeltaT .* frequency;

% plot Va and Vb as a function of time
% set figure size and location
FigHandle = figure('Position', [200, 75, 850, 600]);
plot(time.*1000, Va, time.*1000, Vb, 'linewidth',2.0)
% add grid
grid on;
% increase font size
set(gca, 'fontsize', 16);
% x- and y-axis labels
xlabel('Time (ms)', 'fontsize', 16);
ylabel('Voltage (V)', 'fontsize', 16);
% title
title(sprintf('Frequency = %d kHz', frequency/1000));
% legend
legend('Node Voltage Va', 'Node Voltage Vb');
legend show;
% add peak voltages and phase shift information to the graph
t1 = sprintf('V_A peak = %0.3g V \n',Va_peak);
t2 = sprintf('V_B peak = %0.3g V \n',Vb_peak);
t3 = sprintf('PS = %0.3g ^{o}',PS);
text=[t1 t2 t3];
dim = [.15, .7 .2 .2];
annotation('textbox',dim,'String',text,'FitBoxToText','on', 'BackgroundColor','white', 'FaceAlpha',0.8,'fontsize', 16);

% end of M file