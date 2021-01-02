filename = "samples2/C4Text3.wav";

lofrec = 8000; %Lower cutoff frequency 
hifrec = 12000; %Upper cutoff frequency

[y, Fs] = audioread(filename);
info = audioinfo(filename); %Check for mono audio

%Filter parameters
Wp = [lofrec hifrec]/(44100/2);
Rp = 0.1;
Rs = 60;
n = 6;

[b, c] = ellip(n,Rp,Rs,Wp);
yband = filtfilt(b, c, y);

env_window = 1000; %sliding window for envelope function

[ff, ~] = envelope(yband, env_window, 'rms'); %1000
out = ff/sqrt(sum(abs(ff .^2)) / length(ff));

out = downsample(out, 1000);

figure
plot(out)

%% Spectrogram of signal

figure
spectrogram(y,256,250,[],Fs, 'yaxis')

%% Signal peaks

minH = 1; %Minimum peak height to consider
peakdis = 3; %Minimun distance between peaks

[~, p] = findpeaks(out,'MinPeakHeight', minH, 'MinPeakDistance', peakdis);
figure
findpeaks(out,'MinPeakHeight', minH, 'MinPeakDistance', peakdis);

locs_diff = diff(p)' %This variable will contain all the time differences between peaks

%% Bits processing

%{
Based on the time differences obtained previously, we will define some
lower and upper margins which we will consider to represent either a 1 or 0.
For example we could define bit 0 to be such that its time difference should be 
between limitL1 and limitL2, while bit 1 time difference would be between limitH1 and limitH2

%}

limitL1 = 10; %inclusive lower limit of first bit 
limitL2 = 21; %exclusive upper limit of first bit
limitH1 = 30; %inclusive lower limit of second bit
limitH2 = 70; %exclusive upper limit of second bit

limitI = 5; %used to ignore all time differences below that value

%This loop should only be used for DPPM (blank pages)
idx = 1;
bits = [];
for n=1:length(locs_diff)
       if locs_diff(n)  < limitL2 && locs_diff(n) >= limitL1 
           bits(idx) = 0;
       elseif locs_diff(n) < limitH2 && locs_diff(n) >= limitH1
           bits(idx) = 1;
       elseif locs_diff(n) < limitI
           continue;
       else
           bits(idx) = -1;
       end
       idx = idx + 1;
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

An example of saved samples can be shown by loading the samples.mat file:

load("samples.mat").

%}

sample = out(113:177); 

%{
By visual inspection of the waveform, we determine this section to be a 
good candidate for our matched filter.

We save our sample for further use:

save("samples.mat", 'sample','-append') 
%}

preminH = 80; %The peaks to consider in the cross-correlation should be filtered by a minimum value

[c,lags] = xcorr(out,sample);
p = lags(c > preminH);

figure
plot(lags,c)


%prelimit is used to establish a minimum limit between the
%cross-correlation peaks
