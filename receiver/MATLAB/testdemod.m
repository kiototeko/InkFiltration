filename = "samples2/C4Blank1.wav";

window = 1000;
lofrec = 3500;
hifrec = 20000;

[y, Fs] = audioread(filename);
info = audioinfo(filename); %Check for mono audio

Wp = [lofrec hifrec]/(44100/2);
Rp = 0.1;
Rs = 60;
n = 6;

[b, c] = ellip(n,Rp,Rs,Wp);
yband = filtfilt(b, c, y);

[ff, ~] = envelope(yband, window, 'rms'); %1000
out = ff/sqrt(sum(abs(ff .^2)) / length(ff));

out = downsample(out, 1000);
plot(out)

%% Spectrogram of signal

figure
spectrogram(y,256,250,[],Fs, 'yaxis')
