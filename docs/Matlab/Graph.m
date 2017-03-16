% Template file for ECE 214 Lab #1
% linear and semi-log graphs

% set format; clear variables; access the test.hspc file
format long;
clear variables;

% plot a function exp^(-at) cos(wt) and exp^(-at) on a linear graph
% set the variables
a = 130;
w = 2.*pi.*1000;
% establish liear time vector between 0 and 10ms
Tlin = linspace(0, 1e-2, 301);
% establish a log time vector between 10u and 10m
Tlog = logspace(-5, -2, 301);

% make up voltages V1 with name 'Node Voltage V1'
V1a = exp(-a.*Tlin);
V1b = exp(-a.*Tlog);
legendname1 = 'Node Voltage V1';
% make up voltage V2 with name 'Node Voltage V2'
V2a = exp(-a.*Tlin) .* cos(w.*Tlin - pi/2);
V2b = exp(-a.*Tlog) .* cos(w.*Tlog - pi/2);
legendname2 = 'Node Voltage V2';

%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot on a linear scale %
%%%%%%%%%%%%%%%%%%%%%%%%%%
% set figure size and location for linear graph
FigHandle = figure('Position', [200, 75, 850, 600]);

% turn on grid and hold
grid on;
hold on;

% plot V1 and V2; 
plot(Tlin*1000, V1a, '-^', 'linewidth',2.0, 'displayname', legendname1);
plot(Tlin*1000, V2a, '-o', 'linewidth',2.0, 'displayname', legendname2);

% set font size
set(gca, 'fontsize', 16);
legend show
% x- and y-axis labels
xlabel('Time (ms)', 'fontsize', 16);
ylabel('Voltage V1 (V)', 'fontsize', 16);
title('Linear plot of V1 and V2 as a function of time')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% to plot on a semilog-x scale %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create 2nd figure and set size and location
FigHandle = figure('Position', [200, 75, 850, 600]);

% plot V1 and V2 on a semilog-x graph
semilogx(Tlog, V1b, '-^', 'linewidth',2.0, 'displayname', legendname1);
hold on
grid on
semilogx(Tlog, V2b, '-o', 'linewidth',2.0, 'displayname', legendname2);

% set font size
set(gca, 'fontsize', 16);
legend show
% x- and y-axis labels
xlabel('Time (s)', 'fontsize', 16);
ylabel('Voltage V1 (V)', 'fontsize', 16);
title('Semilog-X plot of V1 and V2 as a function of time');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% to plot V1 on a semilog-y graph %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create 3rd figure and set size and location
FigHandle = figure('Position', [200, 75, 850, 600]);

% plot V1 on a semilog-y graph
semilogy(Tlin.*1000, V1a, '-^', 'linewidth',2.0, 'displayname', legendname1);
grid on

% set font size
set(gca, 'fontsize', 16);
legend show
% x- and y-axis labels
xlabel('Time (ms)', 'fontsize', 16);
ylabel('Voltage V1 (V)', 'fontsize', 16);
title('Semilog-Y plot of V1 as a function of time');


% end of Graph.m 