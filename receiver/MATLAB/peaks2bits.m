function [bits, limits] = peaks2bits(type, class, parameter, peaks_pre, peaks)

bits = [];
limits = [];

locs_diff = diff(peaks);

if(type == "Blank")
    
    idx = 1;
    preidx = 1;
    sum_locs = 0;

    for n=1:length(locs_diff)

        sum_locs = sum_locs + locs_diff(n);
        if preidx <= length(peaks_pre) && sum_locs > peaks_pre(preidx)
           limits(preidx) = idx;
           preidx = preidx + 1;
        end

       if class == 1
           if locs_diff(n) > 25 && locs_diff(n) < 26
               locs_diff(n+1) = locs_diff(n+1) + locs_diff(n);
               continue;
           end
           
       elseif class == 2

           if locs_diff(n) > 48 && locs_diff(n) < 53
               bits(idx) = 1;
               idx = idx + 1;
               bits(idx) = 0;
               idx = idx + 1;
               continue;
           elseif locs_diff(n) >= 45 && locs_diff(n) < 48
               bits(idx) = 0;
               idx = idx + 1;
               continue;
           elseif locs_diff(n) >= 21 && locs_diff(n) < 22
               locs_diff(n+1) = locs_diff(n+1) + locs_diff(n);
               continue;
           end
           
       elseif class == 3
           
           if locs_diff(n) >= 55
               bits(idx) = 0;
               idx = idx + 1;
               bits(idx) = 1;
               idx = idx + 1;
               continue;
           end
       end
       
       if locs_diff(n)  < parameter.limitL2 && locs_diff(n) >= parameter.limitL1 
           bits(idx) = 0;
       elseif locs_diff(n) < parameter.limitH2 && locs_diff(n) >= parameter.limitH1
           bits(idx) = 1;
       elseif locs_diff(n) < parameter.limitI
           continue;
       else
           bits(idx) = -1;
       end
       idx = idx + 1;
    end
    
elseif(type == "Text")
    
    idx = 1;
    num_hi = 0;
    num_lo = 0;
    first_hi = 1;
    preidx = 1;
    last_hi = 0;

    for n=1:length(locs_diff)

       if preidx <= length(peaks_pre) && peaks(n) > peaks_pre(preidx)
           bits(idx) = 1;
           idx = idx + 1;
           bits(idx) = -1;
           idx = idx + 1;
           bits(idx) = 1;
           idx = idx + 1;
           preidx = preidx + 1;
       end

        if class == 2
           if locs_diff(n) >= 43 && locs_diff(n) < 45 || locs_diff(n) >= 31 && locs_diff(n) < 35
               locs_diff(n) = parameter.limitL1;
           elseif n+1 <= length(locs_diff) && ((locs_diff(n) >= 21 && locs_diff(n) < 22) || ((locs_diff(n) >= 10 && locs_diff(n) < parameter.limitL1) && (locs_diff(n+1) >= 10 && locs_diff(n+1) < parameter.limitL1)))
               locs_diff(n+1) = locs_diff(n+1) + locs_diff(n);
               continue;
           end
        elseif class == 3
            if locs_diff(n) >= 10 && locs_diff(n) < 30
                locs_diff(n) = parameter.limitL1;
            end
        end

       if locs_diff(n) >= parameter.limitH1 && locs_diff(n) < parameter.limitH2
           
           num_lo = 0;
           num_hi = num_hi +1;
           if num_hi >= parameter.hi_limit && first_hi
                bits(idx) = 1;
                idx = idx + 1;
                first_hi = 0;
           end
           last_hi = 1;

       elseif locs_diff(n) >= parameter.limitL1 && locs_diff(n) < parameter.limitL2

           first_hi = 1;
           num_lo = num_lo + 1;

           if class == 3
               if locs_diff(n) > 100
                    num_lo = num_lo + 1;
               end

               if last_hi
                   if num_lo > 2
                       bits(idx) = 0;
                       idx = idx + 1;
                       num_lo = num_lo -2;
                       last_hi = 0;
                   end
               else
                   if ~mod(num_lo,2)
                       bits(idx) = 0;
                       idx = idx + 1;
                   end
               end
           else
               if ~mod(num_lo,2)
                    bits(idx) = 0;
                    idx = idx + 1;
               end
           end

           num_hi = 0;
       end
    end
end

end