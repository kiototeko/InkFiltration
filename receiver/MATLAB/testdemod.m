filename = "samples2/C4Blank2.wav";

lofrec = 3500; %Lower cutoff frequency 
hifrec = 6000; %Upper cutoff frequency

[y, Fs] = audioread(filename);
info = audioinfo(filename); %Check for mono audio

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

minH = 0.7; %Minimum peak height to consider
peakdis = 3; %Minimun distance between peaks

[~, p] = findpeaks(out,'MinPeakHeight', minH, 'MinPeakDistance', peakdis);
figure
findpeaks(out,'MinPeakHeight', minH, 'MinPeakDistance', peakdis);

peak_time_diff = diff(p)' %This variable will contain all the time differences between peaks

%{
Based on the time differences obtained previously, we will define some
lower and upper margins which we will consider to represent either a 1 or 0.
For example we could define bit 0 to be such that its time difference should be between limitL1 and limitL2, while
 bit 1 time difference would be between limitH1 and limitH2

limitL1 = lower limit of first bit 
limitL2 = upper limit of first bit
limitH1 = lower limit of second bit
limitH2 = upper limit of second bit

limitI = used to ignore all time differences below that value

As part of the signal processing, a matched filter is first used which
utilizes a saved sample to detect the beginning of the sequence. This 

preminH
prelimit
%}