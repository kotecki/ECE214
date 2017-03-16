function plot_vf2(time, filter_vin, filter_vout)
% PLOT_VF2(time, vin, vout) plots the magnitude of the FFT of two voltage
% signals generated from an NGsice simulation of a simple filter. The input
% should contain three vectors, time, input voltage, and output voltage,
% all of the same length.

% ECE 214 - DEK - 28 January 2017

% check to ensure lengths are the same
if ((length(time) ~= length(filter_vin)) | (length(time) ~= length(filter_vout)))
    display('Error: the "time" and "voltage" vectors do not have');
    display('   the same length');
    return
end

% create evenly spaced time vector with 10000 elements
time_even=linspace(time(1),time(end),10000);
% interpolate to obtain the voltage values
voltage1_even=interp1(time,filter_vin,time_even);
voltage2_even=interp1(time,filter_vout,time_even);

% absolute value of normalized FFT
vf1=fft(voltage1_even);
vf2=fft(voltage2_even);
L = length(vf1);
vf1=abs(vf1/L);
vf2=abs(vf2/L);

% convert to single-sided
vf1=vf1(1:L/2+1);
vf1(2:end-1)=2.*vf1(2:end-1);
vf2=vf2(1:L/2+1);
vf2(2:end-1)=2.*vf2(2:end-1);
% convert to dB
vf1db = 20.*log10(vf1);
vf2db = 20.*log10(vf2);
% generate frequency scale
DeltaT=time_even(5)-time_even(4);
Fs=1/DeltaT;
frequency = Fs.*(0:L/2)/L;

% define font size (fs) and linewidth (lw)
fs = 16;
lw = 1.2;

% plot voltage vs frequency
% set figure size and location
FigHandle = figure('Position', [200, 75, 850, 600]);

% first subplot
subplot(2,1,1);
semilogx(frequency/1000,vf1db, 'linewidth', lw);

% set axis limits
axis([.1,100,-30,10])
% add grid
grid on; 
% grid minor;
% increase font size
set(gca, 'fontsize', fs);
% label y-axis
ylabel('Voltage (dB V)', 'fontsize', fs);
% add title
% title('dB Voltage vs. Frequency');
% legend
legend('Input to Filter');

% second subplot
subplot(2,1,2);
semilogx(frequency/1000,vf2db, 'linewidth', lw);

% set axis limits
axis([.1,100,-40,10])

% add grid
grid on; 
% grid minor;

% increase font size
set(gca, 'fontsize', fs);

% label x- and y-axes and add legend
xlabel('Frequency (kHz)', 'fontsize', fs);
ylabel('Voltage (dB V)', 'fontsize', fs);
legend('Output from Filter');
legend show;

end
