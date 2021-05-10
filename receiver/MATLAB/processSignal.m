function true_bits = processSignal(filename, type, num_packets, snr, debug)
warning('off','all');

%{
Arguments:
filename: should be named as "C#....format", where # is a number that
identifies the product line (see getParameter.m).
type: should be "Text" for text documents or "Blank" for blank documents,
although only for HP DeskJet printers is there any difference.
num_packets: the number of packets you transmitted.
snr: specify a SNR, or just use -1 to use the signal as it is.
debug: if it is 1, it will desplay a series of debug messages. Be careful,
with this variable as not using 1 could give bad results.
%}


[y, Fs] = audioread(filename);
class_idx = regexp(filename, 'C[0-9]');
class = str2double(filename{1}(class_idx+1));

if(snr >= 0)
    y = awgn(y, snr, 'measured');
end

parameter = getParameter(class, type);

peaks_pre = obtainPeaksLocation(y, class, parameter, Fs, 1);
peaks = obtainPeaksLocation(y, class, parameter, Fs, 0);
bits = peaks2bits(type,class,parameter,peaks_pre,peaks, debug);
num_bits = bits2packets(bits, parameter, filename, num_packets, debug);

true_bits = num_bits/((parameter.szbits-1)*num_packets);


end