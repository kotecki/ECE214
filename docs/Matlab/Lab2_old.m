% This is a test of a simple plot 
% similar to the post lab in Lab 2

% close all previous figures
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load data from Micro-cap %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load ~/Dropbox/Lab2b_2016.out

% Define variables
freq = Lab2b_2016(:,1);
Va = 5.* Lab2b_2016(:,2);
Vb = 5.* Lab2b_2016(:,3);
PS = Lab2b_2016(:,4);

% Plot voltages and phase shift
figure
subplot(2,1,1);
semilogx(freq, Va, 'r', freq, Vb, 'b', 'LineWidth', 1.5);
hold on

bx = gca;
bx.FontSize = 16;
grid
title(['Node Voltages V_a and V_b  ', date]);
ylabel('Voltage in V');
text(2000,4.4, '\uparrow V_a', 'FontSize', 14);
text(470, 3.5, 'V_b \rightarrow', 'FontSize', 14);

subplot(2,1,2);
semilogx(freq, PS, 'c', 'LineWidth', 1.5);
bx = gca;
bx.FontSize = 16;
ylabel({'Phase Shift (V_a leads V_b )'});
xlabel('Frequency in Hz');
grid
hold on

% Plot measured data on the same curves
subplot(2,1,1);
freq_m =  [100, 200, 500, 700, 1000, 2000, 5000, 7000, 10000];
Va_m = [5, 5, 5, 5.95, 4.92, 4.88, 4.85, 4.83, 4.8];
semilogx(freq_m, Va_m, 'r*');
Vb_m = [5, 4.8,4.3, 4, 3.2, 2.2, .9, .6, .4];
semilogx(freq_m, Vb_m, 'b*');

subplot(2,1,2);
PS_m = [6, 10, 30, 40, 45, 60, 75, 80, 85];
semilogx(freq_m, PS_m, 'c*', 'LineWidth', 1.5);

% 
% Fit experimental data with a polynomial
% Create frequency data
f = [0 1 2 3 4 5 6 7 8 9 10];

% Create voltage data
v = [ 10 8.5 7.7 7 8 5 4.3 3.5 2 1 0];

% Simulate error data
e = [.5, .5, .5, .5, 1.5, .5, .5, .5, .5, .5, .5];

% generate figure
figure;
plot(f,v, 'b*', 'LineWidth', 1.2);
%errorbar(f,v,e, 'b*', 'LineWidth', 1.2)
bx = gca;
bx.FontSize = 16;
title(['This is the title  ', date])
xlabel('Frequency in Hz')
ylabel('Voltage in mV')
grid;
hold on

% least squares linear fit
p = polyfit(f,v,1);
disp(['Equation: V = ', num2str(p(1)), ' F + ', num2str(p(2))])
f2 = 0:.1:10;
vp = p(1).*f2 + p(2);
plot(f2,vp,'r--', 'LineWidth',1.2);

% least squares quadratic fit
p = polyfit(f,v,2);
vp = p(1).*f2.^2 + p(2).*f2 + p(3);
%plot(f2,vp,'c', 'LineWidth', 1.3);

% least squares nth order fit
n = 4;
p = polyfit(f,v,n);
vp = polyval(p,f2);
%plot(f2,vp,'m', 'LineWidth',1.5);
% 
