function [ber] = testInter(filename)

[y, Fs] = audioread(filename);
class_idx = regexp(filename, 'C[0-9]');
class = str2double(filename{1}(class_idx+1));
parameterBlank = struct;
parameterText = struct;



switch(class)
    case 1
       parameterBlank.limitH1 = 5;
       parameterBlank.limitH2 = 21;
       parameterBlank.limitL1 = 21;
       parameterBlank.limitL2 = 50;
       parameterBlank.limitI = 5;
       parameterBlank.printer_str = 'HP25';
       parameterBlank.preminH = 186;
       parameterBlank.prelimit = 500;
       parameterBlank.minH = 0.7;
       parameterBlank.szbits = 26;
    case 2
       parameterBlank.limitL1 = 10;
       parameterBlank.limitL2 = 25;
       parameterBlank.limitH1 = 25;
       parameterBlank.limitH2 = 60;
       parameterBlank.limitI = 7;
       parameterBlank.printer_str = 'Epson27';
       parameterBlank.preminH = 450;
       parameterBlank.prelimit = 600;
       parameterBlank.minH = 1.5;
       parameterBlank.szbits = 28;
    case 3   
       parameterBlank.limitL1 = 10;
       parameterBlank.limitL2 = 35;
       parameterBlank.limitH1 = 35;
       parameterBlank.limitH2 = 60;
       parameterBlank.limitI = 10;
       parameterBlank.printer_str = 'Canon20';
       parameterBlank.preminH = 450;
       parameterBlank.prelimit = 500;
       parameterBlank.minH = 1.5;
       parameterBlank.szbits = 21;
end

parameterBlank.lofrec = 3500;
parameterBlank.hifrec = 6000;
parameterBlank.peakdis = 3;
parameterBlank.env_window = 1000;

switch(class)
    case 1
       parameterText.limitL1 = 20;
       parameterText.limitL2 = 60;
       parameterText.limitH1 = 5;
       parameterText.limitH2 = 20;
       parameterText.minH = 0.7; 
       parameterText.env_window = 3000;
       parameterText.printer_str = 'HP10';
       parameterText.szbits = 11;
       parameterText.hi_limit = 2;
       parameterText.preminH = 290;
       parameterText.prelimit = 1000;
       parameterText.hifrec = 6000;
       parameterText.lofrec = 3500;
       parameterText.peakdis = 3;
    case 2
       parameterText.limitL1 = 19;
       parameterText.limitL2 = 26.1;
       parameterText.limitH1 = 26.1;
       parameterText.limitH2 = 60;
       parameterText.minH = 1;
       parameterText.env_window = 3000;
       parameterText.printer_str = 'Epson7';
       parameterText.szbits = 8;
       parameterText.preminH = 500;
       parameterText.hi_limit = 1;
       parameterText.prelimit = 500;
       parameterText.hifrec = 6000;
       parameterText.lofrec = 3500;
       parameterText.peakdis = 5;
    case 3   
       parameterText.limitL1 = 48;
       parameterText.limitL2 = 200;
       parameterText.limitH1 = 30;
       parameterText.limitH2 = 48;
       parameterText.hi_limit = 1;
       parameterText.printer_str = 'Canon6';
       parameterText.szbits = 7;
       parameterText.minH = 2.4;
       parameterText.preminH = 600;
       parameterText.env_window = 2500;
       parameterText.prelimit = 1000;
       parameterText.hifrec = 4000;
       parameterText.lofrec = 3000;
       parameterText.peakdis = 5;
end

peaks_pre = obtainPeaksLocation(y, class, parameterBlank, "Blank", Fs, 1);
peaksBlank = obtainPeaksLocation(y, class, parameterBlank, "", Fs, 0);
peaksText = obtainPeaksLocation(y, class, parameterText, "", Fs, 0);
[bitsBlank,limits] = peaks2bits("Blank", class, parameterBlank, peaks_pre, peaksBlank);
bitsText = peaks2bits("Text", class, parameterText, peaks_pre, peaksText);

num_bits = interbits2packets(bitsBlank, limits, 1, parameterBlank, filename);
num_bits = num_bits + interbits2packets(bitsText, [], 0, parameterText, filename);

pattern = 'Pt2';
if(contains(filename, pattern))
    w1 = 13;
    w2 = 12;
else
    w1 = 12;
    w2 = 13;
end

ber = 1- num_bits/((parameterBlank.szbits-1)*w1+(parameterText.szbits-1)*w2);

end