function peaks = obtainPeaksLocation(y,class, parameter, type, Fs, pre)

    if(pre) %Loads the sample used to detect packet boundaries
        sample_variable = strcat('sampleC', num2str(class), type);
        load('samples.mat', sample_variable);
        overlap = 10000*12;
        window = Fs*12;
    else
        overlap = 10000;
        window = Fs;
    end
    
    num = ceil(length(y)/(window-overlap));
    peaks = [];
    idx = 1;
    remnant = zeros(window,1);

    for n = 1:num
        lowerBound = (n-1)*(window-overlap)+1;
        if(lowerBound + window > length(y))
            remnant(1:length(y)-lowerBound+1) = y(lowerBound:length(y));
            if(pre)
                locs = getPeaksPre(remnant, eval(sample_variable), parameter.env_window, parameter.preminH);
            else
                locs = getPeaks(remnant,parameter.minH, parameter.env_window, parameter.lofrec,parameter.hifrec,parameter.peakdis);
            end
        else
            if(pre)
                locs = getPeaksPre(y(lowerBound:n*window-overlap*(n-1)), eval(sample_variable), parameter.env_window, parameter.preminH);
            else
                locs = getPeaks(y(lowerBound:n*window-overlap*(n-1)), parameter.minH, parameter.env_window, parameter.lofrec,parameter.hifrec,parameter.peakdis);
            end
        end
        
       
        locs = locs+(n-1)*(window-overlap)/1000;

        
        for i = 1:length(locs)
            if(pre)
                if idx == 1 || (idx > 1 && locs(i) - peaks(idx-1) > parameter.prelimit)
                    peaks(idx) = locs(i);
                    idx = idx + 1;
                end
            else
                if(idx == 1 || locs(i) > peaks(idx-1))
                    peaks(idx) = locs(i);
                    idx = idx + 1;
                end
            end
        end

    end
end