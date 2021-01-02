function [true_bits, amp] = processSignal(filename, type)

[y, Fs] = audioread(filename);
class_idx = regexp(filename, 'C[0-9]');
class = str2double(filename{1}(class_idx+1));

parameter = struct;

if(type == "Blank")
    switch(class)
        case 1
           parameter.limitH1 = 5;
           parameter.limitH2 = 21;
           parameter.limitL1 = 21;
           parameter.limitL2 = 50;
           parameter.limitI = 5;
           parameter.printer_str = 'HP25';
           parameter.preminH = 180;
           parameter.prelimit = 300;
           parameter.minH = 0.7;
           parameter.szbits = 26;
           parameter.lofrec = 3500;
           parameter.hifrec = 6000;
           parameter.peakdis = 3;
           parameter.env_window = 1000;
        case 2
           parameter.limitL1 = 10;
           parameter.limitL2 = 25;
           parameter.limitH1 = 25;
           parameter.limitH2 = 60;
           parameter.limitI = 7;
           parameter.printer_str = 'Epson27';
           parameter.preminH = 450;
           parameter.prelimit = 600;
           parameter.minH = 1.5;
           parameter.szbits = 28;
           parameter.lofrec = 3500;
           parameter.hifrec = 6000;
           parameter.peakdis = 3;
           parameter.env_window = 1000;
        case 3   
           parameter.limitL1 = 10;
           parameter.limitL2 = 35;
           parameter.limitH1 = 35;
           parameter.limitH2 = 60;
           parameter.limitI = 10;
           parameter.printer_str = 'Canon20';
           parameter.preminH = 450;
           parameter.prelimit = 500;
           parameter.minH = 1.5;
           parameter.szbits = 21;
           parameter.lofrec = 3500;
           parameter.hifrec = 6000;
           parameter.peakdis = 3;
           parameter.env_window = 1000;
%{           
        case 4   
           parameter.limitL1 = 10;
           parameter.limitL2 = 35;
           parameter.limitH1 = 35;
           parameter.limitH2 = 60;
           parameter.limitI = 10;
           parameter.printer_str = 'Canon20';
           parameter.preminH = 450;
           parameter.prelimit = 500;
           parameter.minH = 1.5;
           parameter.szbits = 21;
           parameter.lofrec = 3500;
           parameter.hifrec = 6000;
           parameter.peakdis = 3;
           parameter.env_window = 1000;
%}
           
    end
    
    
    
elseif(type == "Text")
    switch(class)
        case 1
           parameter.limitL1 = 20;
           parameter.limitL2 = 60;
           parameter.limitH1 = 5;
           parameter.limitH2 = 20;
           parameter.minH = 0.7; 
           parameter.env_window = 3000;
           parameter.printer_str = 'HP10';
           parameter.szbits = 11;
           parameter.hi_limit = 2;
           parameter.preminH = 290;
           parameter.prelimit = 1000;
           parameter.hifrec = 6000;
           parameter.lofrec = 3500;
           parameter.peakdis = 3;
        case 2
           parameter.limitL1 = 19;
           parameter.limitL2 = 26.1;
           parameter.limitH1 = 26.1;
           parameter.limitH2 = 60;
           parameter.minH = 1;
           parameter.env_window = 3000;
           parameter.printer_str = 'Epson7';
           parameter.szbits = 8;
           parameter.preminH = 500;
           parameter.hi_limit = 1;
           parameter.prelimit = 500;
           parameter.hifrec = 6000;
           parameter.lofrec = 3500;
           parameter.peakdis = 5;
        case 3   
           parameter.limitL1 = 48;
           parameter.limitL2 = 200;
           parameter.limitH1 = 30;
           parameter.limitH2 = 48;
           parameter.hi_limit = 1;
           parameter.printer_str = 'Canon6';
           parameter.szbits = 7;
           parameter.minH = 2.4;
           parameter.preminH = 600;
           parameter.env_window = 2500;
           parameter.prelimit = 1000;
           parameter.hifrec = 4000;
           parameter.lofrec = 3000;
           parameter.peakdis = 5;
%{
        case 4
           parameter.limitL1 = 48;
           parameter.limitL2 = 200;
           parameter.limitH1 = 30;
           parameter.limitH2 = 48;
           parameter.hi_limit = 1;
           parameter.printer_str = 'Canon6';
           parameter.szbits = 7;
           parameter.minH = 2.4;
           parameter.preminH = 600;
           parameter.env_window = 2500;
           parameter.prelimit = 1000;
           parameter.hifrec = 4000;
           parameter.lofrec = 3000;
           parameter.peakdis = 5;
%}
    end
    
end

peaks_pre = obtainPeaksLocation(y, class, parameter, type, Fs, 1);
peaks = obtainPeaksLocation(y, class, parameter, type, Fs, 0);
[bits,limits] = peaks2bits(type,class,parameter,peaks_pre,peaks);
num_bits = bits2packets(bits, limits, type, parameter, filename);

true_bits = num_bits/((parameter.szbits-1)*25);
amp = 20*log10(rms(y)*sqrt(2));


end