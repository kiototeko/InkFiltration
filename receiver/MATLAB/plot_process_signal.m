function peaks = plot_process_signal(parameter)

warning('off','all');


subplot(3,1,1)
plot(parameter.out)
title("Original processed signal")

subplot(3,1,2)

overlap = 10000;
window = parameter.Fs;
num = ceil(length(parameter.y)/(window-overlap));
peaks = [];
idx = 1;
remnant = zeros(window,1);

for n = 1:num
    lowerBound = (n-1)*(window-overlap)+1;
    
    try
        if(lowerBound + window > length(parameter.y))
            remnant(1:length(parameter.y)-lowerBound+1) = parameter.y(lowerBound:length(parameter.y));
            [locs,out2] = getPeaks(remnant,parameter.minH, parameter.env_window, parameter.lofrec,parameter.hifrec,parameter.peakdis);

        else
            [locs,out2] = getPeaks(parameter.y(lowerBound:n*window-overlap*(n-1)), parameter.minH, parameter.env_window, parameter.lofrec,parameter.hifrec,parameter.peakdis);
        end
        
    catch
        warning('Filtering error');
        plot(0);
        legend("");
        return
    end
    
    plot((1:length(out2))+(n-1)*(window-overlap)/1000, out2, '-o','MarkerIndices',locs) %In this plot, each color graph corresponds to one time window (which are overlapped)
    hold on
    locs = locs+(n-1)*(window-overlap)/1000;
    
    
    for i = 1:length(locs)
        if(idx == 1 || locs(i) > peaks(idx-1)) %This check is because there can appear negative offsets
            peaks(idx) = locs(i);
            idx = idx + 1;
        end
            
    end
end

maxx = get(gca,'XLim'); 
plot(1:maxx(2), ones(1,maxx(2))*parameter.minH, '-r')



title("Windowed processed signal")
legend("Considered peaks (> minH)")

end