function [lines, timing] = sweep_analysis(filename)

[y, Fs] = audioread(filename);
class_idx = regexp(filename, 'C[0-9]');
class = str2double(filename{1}(class_idx+1));

if class == 1
    [locs, amp] = getPeaks(y, 1, 3000,3500, 6000, 3);
    locs_diff = diff(locs).';
    
    idx = 0;
    idx2 = 1;
    timing = zeros(50,26);
    lines = zeros(1,26);
    peak_amps = zeros(50,27);
    offset = 22;
    for i=1:length(locs_diff)
       if locs_diff(idx2) >= 22 && locs_diff(idx2) < 24 && locs_diff(idx2+1) < 23 && locs_diff(idx2+1) >= 20
           idx = idx + 1;
           timing(idx,:) = locs_diff(idx2:idx2+25);
           peak_amps(idx,:) = amp(idx2:idx2+26).';
           idx2 = idx2 + 20;
           

       else
           idx2 = idx2 + 1;
       end

       if idx == 50
           break;
       end
    end

    total = 594;

    
elseif class == 2
    [locs, amp] = getPeaks(y, 0.65, 3000,3500, 6000, 5);
    locs_diff = diff(locs).';

    idx = 0;
    idx2 = 1;
    timing = zeros(50,25);
    lines = zeros(1,25);
    peak_amps = zeros(50,26);
    offset = 22;
    for i=1:length(locs_diff)
       if locs_diff(idx2) > 26 && locs_diff(idx2) < 41 && locs_diff(idx2+1) < 28 && locs_diff(idx2+1) > 24
           idx = idx + 1;
           timing(idx,:) = locs_diff(idx2+1:idx2+25);
           peak_amps(idx,:) = amp(idx2+1:idx2+26).';
           idx2 = idx2 + 20;

       else
           idx2 = idx2 + 1;
       end

       if idx == 50
           break;
       end
    end

    total = 572;


elseif class == 3
    [locs, amp] = getPeaks(y, 0.54, 3000,3500, 6000, 5);
    locs_diff = diff(locs).';
    
    idx = 0;
    idx2 = 1;
    timing = zeros(50,24);
    lines = zeros(1,24);
    peak_amps = zeros(50,24);
    offset = 22;
    for i=1:length(locs_diff)
       if locs_diff(idx2) > 40 && locs_diff(idx2) < 45 && locs_diff(idx2+1) < 41 && locs_diff(idx2+1) > 36
           idx = idx + 1;
           timing(idx,:) = locs_diff(idx2:idx2+23);
           peak_amps(idx,:) = amp(idx2:idx2+23).';
           idx2 = idx2 + 20;

       else
           idx2 = idx2 + 1;
       end

       if idx == 50
           break;
       end
    end

    total = 594;
    
    
end

for i=1:length(lines)
    lines(i) = total;
    total = total - offset;
end

end