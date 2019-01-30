%% Example of using the symbolic toolbox in Matlab
% Symbolic calculation of Vout vs R for ECE 214, Lab 1.
% Solve the two nodal equations in Matlab

%% Define variables
freq = 1000;                    % frequency
Vin = 1.0;                      % Input amplitude
Rin = 50;                       % FG resistance
Cp1 = 103e-12;                  % Capacitance of cable 1
Zp1 = -1i/(2.*pi.*freq.*Cp1);   % Impedance of cable 1
Cp2 = 130e-12;                  % Capacitance of cable 2
Zp2 = -1i/(2.*pi.*freq.*Cp2);   % Impedance of cable 2
Cs = 11e-12;                    % Capacitance of scope
Zs = -1i/(2.*pi.*freq.*Cs);     % Impedance of scope
Rs = 1e6;                       % Resistance of scope

%% Create symbolic variables for Va, Vb, and R
syms Va Vb R

%% Input the two nodal equations
eq1 = (Va-Vin)/Rin + Va/Zp1 + (Va-Vb)/R == 0;
eq2 = (Vb-Va)/R + Vb/R + Vb/Rs + Vb/Zp2 + Vb/Zs == 0;

%% Solve the two nodal equations
[Va2,Vb2] = solve(eq1,eq2,Va,Vb);

%% Set magnitude of Vb2 to a symbolic function and display function
digits(5);  % use five digits for symbolic math
Vout(R) = vpa(abs(Vb2));    % variable precision arithmetic
fprintf('Vout = ');
disp(Vout(R));

%% Create vector of resistance values
R = logspace(1,7,101);

%% Plot results 
fs = 16;    % font size
lw = 1.5;   % linewidth
FigHandle = figure('Position', [200, 75, 850, 600]);
semilogx(R, Vout(R), 'linewidth',lw)
grid on;    % add grid
set(gca, 'fontsize', fs);   % set font size
xlabel('Resistance (\Omega)', 'fontsize', fs);
ylabel('Output Voltage (V)', 'fontsize', fs);
title('Output Voltage as a Function of Resistance');

%% end of .m file