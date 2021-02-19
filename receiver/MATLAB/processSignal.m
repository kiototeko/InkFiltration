function [true_bits, amp] = processSignal(filename, type, num_packets)
warning('off','all');

[y, Fs] = audioread(filename);
class_idx = regexp(filename, 'C[0-9]');
class = str2double(filename{1}(class_idx+1));

parameter = getParameter(class, type);

peaks_pre = obtainPeaksLocation(y, class, parameter, type, Fs, 1);
peaks = obtainPeaksLocation(y, class, parameter, type, Fs, 0);
[bits,limits] = peaks2bits(type,class,parameter,peaks_pre,peaks);
num_bits = bits2packets(bits, limits, type, parameter, filename, num_packets);

true_bits = num_bits/((parameter.szbits-1)*num_packets);
amp = 20*log10(rms(y)*sqrt(2));


end