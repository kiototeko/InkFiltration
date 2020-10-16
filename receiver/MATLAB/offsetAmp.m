function  [offsets, peaks] = offsetAmp(filename)


[y, Fs] = audioread(filename);
class_idx = regexp(filename, 'C[0-9]');
class = str2double(filename{1}(class_idx+1));


yband = bandpass(y, [3500 6000], Fs);
[ff, ~] = envelope(yband, 1000, 'rms');
ff = downsample(ff, 1000);

idx = 1;
idx2 = 1;
packet = 0;

if class == 1
    [~, p] = findpeaks(ff, 'MinPeakHeight', 0.0006, 'MinPeakDistance', 20);
    locs_diff = diff(p).';
    num_peaks = 17;
    peaks = zeros(43, num_peaks);
    
    for n = 1:length(locs_diff)
        
        if(idx+num_peaks > length(locs_diff))
            break
        end
        
        if(sum(locs_diff(idx:idx+num_peaks) < 30 & locs_diff(idx:idx+num_peaks) > 20) == num_peaks+1)
            packet = packet + 1;
            
            peaks(idx2,:) = ff(p(idx+1:idx+num_peaks));
            
            idx = idx + num_peaks+1;
            idx2 = idx2 + 1;
        else
            idx = idx + 1;
        end
    end
    offsets = zeros(num_peaks,1);
    offset = 25;
    
elseif class == 2
    [~, p] = findpeaks(ff, 'MinPeakHeight', 0.0015, 'MinPeakDistance', 25);
    locs_diff = diff(p).';
    num_peaks = 17;
    peaks = zeros(48, num_peaks);
    
    
    for n = 1:length(locs_diff)
        
        if(idx+16 > length(locs_diff))
            break
        end
        
        if(sum(locs_diff(idx:idx+num_peaks-1) < 31 & locs_diff(idx:idx+num_peaks-1) > 24) == num_peaks)
            packet = packet + 1;
            
            peaks(idx2,:) = ff(p(idx:idx+num_peaks-1));
            
            idx = idx + num_peaks;
            idx2 = idx2 + 1;
        else
            idx = idx + 1;
        end
    end
    
    offsets = zeros(num_peaks,1);
    offset = 24;
        
elseif class == 3
    [~, p] = findpeaks(ff, 'MinPeakHeight', 0.0011, 'MinPeakDistance', 39);
    locs_diff = diff(p).';
    num_peaks = 15;
    peaks = zeros(48, num_peaks);
    
    for n = 1:length(locs_diff)
        
        if(idx+17 > length(locs_diff))
            break
        end
        
        if(sum(locs_diff(idx:idx+num_peaks+2) < 50 & locs_diff(idx:idx+num_peaks+2) > 39) == num_peaks+3)
            packet = packet + 1;
            
            peaks(idx2,:) = ff(p(idx+3:idx+num_peaks+2));
            
            idx = idx + num_peaks+2;
            idx2 = idx2 + 1;
        else
            idx = idx + 1;
        end
    end
    
    offsets = zeros(num_peaks,1);
    offset = 21;
    
end

for n = 1:num_peaks
    offsets(n) = 0.03528*offset;
    offset = offset + 2;
end


peaks = mean(peaks,1);
peaks = 20*log10(abs(peaks));

end