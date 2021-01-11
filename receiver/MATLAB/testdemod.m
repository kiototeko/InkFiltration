%{
testdemod.m - Program to test various parameters used at the receiving side
to process the acoustic signals
%}


filename = "samples2/C4Blank3.wav"; %Filename to use

class_idx = regexp(filename, 'C[0-9]');
class = str2double(filename{1}(class_idx+1));

type = "";
if(contains(filename, "Blank"))
    type = "Blank";
elseif(contains(filename, "Text"))
    type = "Text";
end

%Load existing parameters, change according to whether you want to experiment with parameters here or load previous ones
load_existing_param = 1; %0 or 1

if(load_existing_param)
    parameter = getParameter(class, type); %Get saved parameters
else
    parameter = struct;
end

if(~load_existing_param)
    parameter.lofrec = 8000; %Lower cutoff frequency 
    parameter.hifrec = 12000; %Upper cutoff frequency
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
plot(out)

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
spectrogram(y,256,250,[],Fs, 'yaxis')

%% Signal peaks

if(~load_existing_param)
    parameter.minH = 1.7; %Minimum peak height to consider
    parameter.peakdis = 3; %Minimun distance between peaks
end

[~, p] = findpeaks(out,'MinPeakHeight', parameter.minH, 'MinPeakDistance', parameter.peakdis); %Find all peaks

figure
findpeaks(out,'MinPeakHeight', parameter.minH, 'MinPeakDistance', parameter.peakdis);

locs_diff = diff(p)' %This variable will contain all the time differences between peaks

%% Bits processing

%{
Based on the time differences obtained previously, we will define some
lower and upper margins which we will consider to represent either a 1 or 0.
For example we could define bit 0 to be such that its time difference should be 
between limitL1 and limitL2, while bit 1 time difference would be between limitH1 and limitH2

%}

if(~load_existing_param)
    parameter.limitL1 = 15; %inclusive lower limit of bit 0
    parameter.limitL2 = 40; %exclusive upper limit of bit 0
    parameter.limitH1 = 40; %inclusive lower limit of bit 1
    parameter.limitH2 = 150; %exclusive upper limit of bit 1
    
    parameter.limitI = 5; %used to ignore all time differences below that value
    
    parameter.hi_limit = 1; %used to determine how many time differences between limitH1 and limitH2 to consider as bit 1 (FPM-DPPM)
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

