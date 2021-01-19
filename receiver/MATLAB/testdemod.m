%{
testdemod.m - Program to test various parameters used at the receiving side
to process the acoustic signals
%}


%Load existing parameters, change according to whether you want to experiment with parameters here or load previous ones

load_existing_param = 1; %0 or 1

filename = "samples2/C4Blank3.wav"; %Filename to use

class_idx = regexp(filename, 'C[0-9]');
class = str2double(filename{1}(class_idx+1));

type = "";
if(contains(filename, "Blank"))
    type = "Blank";
elseif(contains(filename, "Text"))
    type = "Text";
end

if(load_existing_param)
    parameter = getParameter(class, type); %Get saved parameters
else
    parameter = struct;
end

if(~load_existing_param)
    parameter.lofrec = 13000; %11000; %Lower cutoff frequency 
    parameter.hifrec = 15000;%15000; %Upper cutoff frequency
    parameter.env_window = 1000; %Sliding window for envelope function
end


[y, Fs] = audioread(filename); %Load audio file samples
info = audioinfo(filename); %Check for mono audio

%Filter parameters
Wp = [parameter.lofrec parameter.hifrec]/(44100/2);
Rp = 0.1;
Rs = 60;
n = 6;

[b, c] = ellip(n,Rp,Rs,Wp);
yband = filtfilt(b, c, y); %Filter the signal
[ff, ~] = envelope(yband, parameter.env_window, 'rms'); %Compute signal's envelope


out = ff/sqrt(sum(abs(ff .^2)) / length(ff)); %Normalize

out = downsample(out, 1000); %Downsample

figure
plot((1:length(out))*1000/Fs,out)
xlabel('Time(s)')

%{
%% Frequency domain

xx =y(1034000:1041000);

yf = fftshift(fft(xx));
powerhi = abs(yf).^2/length(yf);
n = length(yf);
f = (-n/2:n/2-1)*(Fs/n);
figure
plot(f, powerhi);
%}

%% Spectrogram of signal

figure
spectrogram(y,2560,2500,[],Fs, 'yaxis')

%% Signal peaks

if(~load_existing_param)
    parameter.minH = 1.7; %Minimum peak height to consider
    parameter.peakdis = 3; %Minimun distance between peaks
end


%{
This code section is part of obtainPeaksLocation.m
A similar call could be peaks = obtainPeaksLocation(y, 0, parameter, type, Fs, 0);

Basically, in this part we are processing the signal exactly as in the previous part, but using windows of a certian size.
Then, we extract the peaks and compute the difference in time between them.
%}


parameter2 = parameter;
parameter2.y = y;
parameter2.out = out;
parameter2.Fs = Fs;



scanParameters = figure;


scanParameters.UserData = parameter2;
uicontrol('Style', 'text', 'Parent', scanParameters, 'unit', 'normalized', 'Position', [0.05 0.3 0.9 0.04], 'String', strcat('High frequency: ',string(parameter.hifrec), ' Hz'), 'Tag','hifrec_str');
uicontrol('Style','slider', 'Parent', scanParameters, 'unit', 'normalized', 'Position', [0.05 0.28 0.9 0.025], 'Max', 20000, 'Tag', 'hifrec', 'Value', parameter.hifrec, 'sliderstep',[0.005 0.01], 'Callback', @uiCallback);
uicontrol('Style', 'text', 'Parent', scanParameters, 'unit', 'normalized', 'Position', [0.05 0.23 0.9 0.04], 'String', strcat('Low frequency: ',string(parameter.lofrec), ' Hz'), 'Tag','lofrec_str');
uicontrol('Style','slider', 'Parent', scanParameters, 'unit', 'normalized', 'Position', [0.05 0.21 0.9 0.025], 'Max', 20000, 'Min', 1, 'Tag', 'lofrec', 'Value', parameter.lofrec, 'sliderstep',[0.005 0.01], 'Callback', @uiCallback);
uicontrol('Style', 'text', 'Parent', scanParameters, 'unit', 'normalized', 'Position', [0.05 0.15 0.9 0.04], 'String', strcat('Smoothing window size: ', string(parameter.env_window)), 'Tag','env_window_str');
uicontrol('Style','slider', 'Parent', scanParameters, 'unit', 'normalized', 'Position', [0.05 0.13 0.9 0.025], 'Max', 20000, 'Min', 1, 'Tag', 'env_window', 'Value', parameter.env_window, 'sliderstep',[0.001 0.01], 'Callback', @uiCallback);
uicontrol('Style', 'text', 'Parent', scanParameters, 'unit', 'normalized', 'Position', [0.05 0.08 0.9 0.04], 'String', strcat('Minimum peak height: ', string(parameter.minH)), 'Tag','minH_str');
uicontrol('Style','slider', 'Parent', scanParameters, 'unit', 'normalized', 'Position', [0.05 0.06 0.9 0.025], 'Max', 5, 'Tag', 'minH', 'Value', parameter.minH, 'sliderstep',[0.005 0.01], 'Callback', @uiCallback);


peaks = plot_process_signal(parameter2);

%WARNING: peaks variable is not updated when you change the parameters in the
%figure controls. Whenever you find the correct parameters change them
%above this code.

peaks %Peaks location
locs_diff = diff(peaks) %This variable will contain all the time differences between peaks
 


%% Bits processing

%{
Based on the time differences obtained previously, we will define some
lower and upper margins which we will consider to represent either a 1 or 0.
For example we could define bit 0 to be such that its time difference should be 
between limitL1 and limitL2, while bit 1 time difference would be between limitH1 and limitH2

%}

if(~load_existing_param)
    parameter.limitL1 = 19; %inclusive lower limit of bit 0
    parameter.limitL2 = 50; %exclusive upper limit of bit 0
    parameter.limitH1 = 6; %inclusive lower limit of bit 1
    parameter.limitH2 = 19; %exclusive upper limit of bit 1
    
    parameter.limitI = 5; %used to ignore all time differences below that value
    
    parameter.hi_limit = 3; %used to determine how many time differences between limitH1 and limitH2 to consider as bit 1 (FPM-DPPM)
end


idx = 1;
bits = [];


if(strcmp(type, "Text")) %This for loop should only be used for FPM-DPPM (text pages)
    num_hi = 0;
    num_lo = 0;
    first_hi = 1;
    
    for n=1:length(locs_diff)
       if locs_diff(n) >= parameter.limitH1 && locs_diff(n) < parameter.limitH2
           num_lo = 0;
           num_hi = num_hi +1;
           if num_hi >= parameter.hi_limit && first_hi
                bits(idx) = 1;
                idx = idx + 1;
                first_hi = 0;
           end

       elseif locs_diff(n) >= parameter.limitL1 && locs_diff(n) < parameter.limitL2
           first_hi = 1;
           num_lo = num_lo + 1;
           if ~mod(num_lo,2)
                bits(idx) = 0;
                idx = idx + 1;
           end
           num_hi = 0;
       end
    end
    
elseif(strcmp(type, "Blank")) %This for loop should only be used for DPPM (blank pages)
    
    for n=1:length(locs_diff)
           if locs_diff(n)  < parameter.limitL2 && locs_diff(n) >= parameter.limitL1 
               bits(idx) = 0;
           elseif locs_diff(n) < parameter.limitH2 && locs_diff(n) >= parameter.limitH1
               bits(idx) = 1;
           elseif locs_diff(n) < parameter.limitI
               continue;
           else
               bits(idx) = -1;
           end
           idx = idx + 1;
    end
    
end

bits

%{
There will be certain irregular sound patterns that sometimes surface on
the printer, this patterns may need of extended processing. You can check
peaks2bits.m script to see and example of this.
%}

%% Preamble processing

%{
As part of the signal processing, a matched filter is first used to detect
the boundaries of the packet. This process utilizes a saved sample 
which is cross-correlated with the signal.

%}

%An example of saved samples can be shown by loading the samples.mat file:

sample_name = strcat("sampleC", string(class), type);

load("samples.mat", sample_name);

sample = eval(sample_name);

%sample = out(113:177); 

%{
By visual inspection of the waveform, we determine this section to be a 
good candidate for our matched filter.

We save our sample for further use:

save("samples.mat", 'sample','-append') 
%}

if(~load_existing_param)
    parameter.preminH = 80; %The peaks to consider in the cross-correlation should be filtered by a minimum value
    parameter.prelimit = 500; %The separation between these peaks
end

[c,lags] = xcorr(out,sample);
p = lags(c > parameter.preminH);

figure
plot(lags,c)

idx = 1;
peaks = [];

%prelimit is used to establish a minimum distance limit between the
%cross-correlation peaks

for i = 1:length(p)
    if idx == 1 || (idx > 1 && p(i) - peaks(idx-1) > parameter.prelimit)
        peaks(idx) = p(i);
        idx = idx + 1;
    end
end

peaks

