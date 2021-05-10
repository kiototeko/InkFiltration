function p = getPeaksA(y, minH, window, printer, peakdis)

Rp = 0.1;
Rs = 60;
n = 6;

if printer == 2
    lofrec = 3500;
    hifrec = 6000;
    Wp = [lofrec hifrec]/(44100/2);
    [b, c] = ellip(n,Rp,Rs,Wp);
elseif printer == 3
    lofrec = 1400;
    hifrec = 4000; 
    Wp = [lofrec hifrec]/(44100/2);
    [b, c] = ellip(n,Rp,Rs,Wp);
elseif printer == 4
    lofrec = 6700;
    hifrec = 9700; 
    Wp = [lofrec hifrec]/(44100/2);
    [b, c] = ellip(n,Rp,Rs,Wp);
else % printer == 5
    lofrec = 8000;
    hifrec = 18000; 
    Wp = [lofrec hifrec]/(44100/2);
    [b, c] = ellip(n,Rp,Rs,Wp);
end



yband = filtfilt(b, c, y);

[ff, ~] = envelope(yband, window, 'rms'); %1000
out = ff/sqrt(sum(abs(ff .^2)) / length(ff));

out = downsample(out, 1000);

[~, p] = findpeaks(out,'MinPeakHeight', minH, 'MinPeakDistance', peakdis);


end