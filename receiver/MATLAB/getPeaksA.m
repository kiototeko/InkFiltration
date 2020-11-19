function p = getPeaksA(y, minH, window, printer, peakdis)

if printer == 3
    lofrec = 3000;
    hifrec = 4000;
    Wp = [lofrec hifrec]/(44100/2);
    Rp = 0.1;
    Rs = 60;
    n = 6;
    [b, c] = ellip(n,Rp,Rs,Wp);
else
    lofrec = 3500;
    hifrec = 6000;
    Wp = [lofrec hifrec]/(44100/2);
    Rp = 0.1;
    Rs = 60;
    n = 6;
    [b, c] = ellip(n,Rp,Rs,Wp);
end


yband = filtfilt(b, c, y);

[ff, ~] = envelope(yband, window, 'rms'); %1000
out = ff/sqrt(sum(abs(ff .^2)) / length(ff));

out = downsample(out, 1000);
[~, p] = findpeaks(out,'MinPeakHeight', minH, 'MinPeakDistance', peakdis);
%findpeaks(out,'MinPeakHeight', minH, 'MinPeakDistance', peakdis);
end