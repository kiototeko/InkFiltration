function peaks = obtainPeaksLocation2()

    filename = "samples2/good/C4TextNovoJust50cmPt2.wav";
    [y, Fs] = audioread(filename);
    class_idx = regexp(filename, 'C[0-9]');
    class = str2double(filename{1}(class_idx+1));
    parameter = getParameter(class, "Text");
    n = 1;

    sample_variable = strcat('sampleC', num2str(class), "Text");
    load('samples.mat', sample_variable); %Load sample with largest size (179)
    overlap = 10000*12;
    window = Fs*12;
    lowerBound = (n-1)*(window-overlap)+1;
    locs = getPeaksPre(y(lowerBound:n*window-overlap*(n-1)), eval(sample_variable), parameter.env_window, parameter.preminH);
    
    
    overlap = 10000;
    window = Fs;
    
    peaks = [];
    idx = 1;
    remnant = zeros(window,1);

	n = 1;
    lowerBound = (n-1)*(window-overlap)+1;

    locs = getPeaksA(y(lowerBound:n*window-overlap*(n-1)), parameter.minH, parameter.env_window, class,parameter.peakdis);
            
end