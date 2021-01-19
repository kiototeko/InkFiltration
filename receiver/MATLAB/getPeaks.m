function [p,out] = getPeaks(y, minH, window, lofrec, hifrec, peakdis)

Wp = [lofrec hifrec]/(44100/2);
Rp = 0.1;
Rs = 60;
n = 6;


[b, c] = ellip(n,Rp,Rs,Wp);
yband = filtfilt(b, c, y);

[ff, ~] = envelope(yband, window, 'rms'); %1000
out = ff/sqrt(sum(abs(ff .^2)) / length(ff));

out = downsample(out, 1000);
[~, p] = findpeaks(out,'MinPeakHeight', minH, 'MinPeakDistance', peakdis);
%figure
%findpeaks(out,'MinPeakHeight', minH, 'MinPeakDistance', peakdis);
end