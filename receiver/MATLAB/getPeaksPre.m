function [p,c] = getPeaksPre(y, sample, window, minH)


Wp = [3500 6000]/(44100/2);
Rp = 0.1;
Rs = 60;
n = 6;


[b, c] = ellip(n,Rp,Rs,Wp);
yband = filtfilt(b, c, y);

[ff, ~] = envelope(yband, window, 'rms');
out = ff/sqrt(sum(abs(ff .^2)) / length(ff));

out = downsample(out, 1000);

[c,lags] = xcorr(out,sample);
p = lags(c > minH);

end