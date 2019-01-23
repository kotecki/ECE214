%% Matlab m-file template for ECE 214 Lab 1 (Post-Lab Part B)

%% Set path, clear variables, and define hspc filename

% Note: you will need to set the correct path in the line below:
addpath('/users/Kotecki/CppSim/CppSimShared/HspiceToolbox'); % ngspice matlab toolbox

clear variables; % clear variables
hspc_filename = 'ECE214_2019_Lab1.hspc'; % set the hspc filename

%% Simulation control statement
hspc_addline('.tran 20u 20m', hspc_filename); % define transient simulation and write to hspc file

%% Generate N logarithmically spaced resistance values
% range is from 10 Ohms - 10 Meg Ohms
N = 30;
Rvalues = logspace(1,7,N);

%% Single transient plot to ensure the circuit is behaving properly
hspc_set_param('res', Rvalues(5), hspc_filename); %set resistance value in Lab1.hspc
ngsim(hspc_filename); % call ngsim and run simulation
data = loadsig('simrun.raw'); % load simulation reults in variable 'data'
vout = evalsig(data,'vout'); % store output voltage values as variable 'vout'
time = evalsig(data,'TIME'); % store time values in variable 'time'

% quick transient plot
FigHandle = figure('Position', [200, 75, 850, 600]); % figure size and location
plot(time * 1e3, vout, 'linewidth', 1.5);
grid on; % turn on the grid
set(gca, 'fontsize', 16); % increase font size of title and axes text
xlabel('Time (ms)', 'fontsize', 16); % label x-axis
ylabel('Output Voltage (V)', 'fontsize', 16); % label y-axis
title('Output voltage as a function of time'); % add title

%% Loop through all values of R and determine peak voltage
for i = 1:N
    hspc_set_param('res', Rvalues(i), hspc_filename); %set resistance value in Lab1.hspc
    ngsim(hspc_filename); % call ngsim and run simulation
    data = loadsig('simrun.raw'); % load simulation reults as variable 'data'
    vout = evalsig(data,'vout'); % store output voltage values as variable 'vout'
    vpeak(i) = abs(min(vout)); % calculate pleak voltage and store in array 'vpeak'
end

%% Plot
FigHandle = figure('Position', [200, 75, 850, 600]); % figure size and location
semilogx(Rvalues, vpeak, '-s', 'linewidth', 2.0) % generate semilog plot
grid on; % turn on the grid
set(gca, 'fontsize', 16); % increase font size of title and axes text
xlabel('Resistance (\Omega)', 'fontsize', 16); % label x-axis
ylabel('Output Voltage (V)', 'fontsize', 16); % label y-axis
title('Expected output voltage as a function of resistance'); % add title

%% End of .m file