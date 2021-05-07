function [bits, limits] = peaks2bits(type, class, parameter, peaks_pre, peaks, debug)

bits = [];
limits = [];

locs_diff = diff(peaks);

if(type == "Blank")
    blank = 1;
else
    blank = 0;
end


num_lo_pot = 0;
num_hi_pot = 0;
real_hi_count = 0;
num_hi = 0;
num_lo = 0;
first_hi = 1;
preidx = 1;
flag28 = 0;
flag26 = 0;
new_packet = 0;
not_par = 0;

if class == 4
    was_here = 0;
    residual = 0;
    previdx = 0;
    for n=1:length(locs_diff)
        if(locs_diff(n) > 2)
            if(n > 1 && locs_diff(n) < parameter.limitL1 && previdx > 0)
                if(~was_here)
                    locs_diff(previdx) = locs_diff(previdx) + locs_diff(n);
                    locs_diff(n) = 0;
                    was_here = 1;
                else
                    residual = residual + locs_diff(n);
                end
            else
                was_here = 0;
                if(~blank)
                    locs_diff(n) = locs_diff(n) + residual;
                end
                residual = 0;
            end
            previdx = n;
        end
    end
elseif class == 2
    residual = 0;
    for n=1:length(locs_diff)
        if(locs_diff(n) < parameter.limitL1)
            residual = residual + locs_diff(n);
            locs_diff(n) = residual;
        else
            residual = 0;
        end
    end
end

for n=1:length(locs_diff)


   if preidx <= length(peaks_pre) && peaks(n) > peaks_pre(preidx) %Determines packet boundaries and adds some extra bits
       bits = add_bit(bits, 1,0);
       bits = add_bit(bits, -1,0);
       bits = add_bit(bits, 1,0);
       preidx = preidx + 1;
       if(debug)
           fprintf("Packet %i in n = %i\n", preidx-1, n);
       end
       new_packet = 1;
       num_hi = 0;
       num_lo = 0;
   end


   if locs_diff(n) >= parameter.limitH1 && locs_diff(n) < parameter.limitH2

       if class == 4 || class == 3 
       %Case 1: low offset in between high offsets == 0
       %Case 2: high offset in between low offsets == 0
       %Case 3: there is a 15 before low offsets == 0
       %Case 4: > 20 after low offset and 15 28 case

           if class == 4
           %%{    
               real_hi_count = real_hi_count + 1;

               if (~blank)
                   if num_hi > 0 && num_lo == 1 %Case 1
                       bits = add_bit(bits, 0,0);
                       num_lo = 0;
                   end

                   if (num_hi > 0 && locs_diff(n) >= 15 && locs_diff(n) < 16) %Case 3
                       if num_hi_pot == 0
                           num_lo_pot = 1;
                           num_hi_pot = 1;
                       else %Case 3 two 15
                           num_hi = num_hi + 1;
                           if ~mod(num_hi,2)
                                bits = add_bit(bits, 1,0);
                           end
                           num_lo = 0;
                       end
                       continue
                   end



                   if num_hi_pot %Case 3 cancel
                       num_hi = num_hi + 1;
                       if ~mod(num_hi,2)
                            bits = add_bit(bits, 1,0);
                       end
                   end


                   if (num_hi == 0 && num_lo > 0 && locs_diff(n) >= 20) || (num_hi > 0 && num_hi_pot && locs_diff(n) >= 21) %Case 4
                       num_lo = num_lo + 1;
                       if ~mod(num_lo,2)
                            bits = add_bit(bits, 0,0);
                       end
                       continue
                   end
                   num_lo_pot = 0;
                   num_hi_pot = 0;
               else
                   num_lo = 0;
                   num_hi = num_hi + 1;
                   if ~mod(num_hi,2)
                        bits = add_bit(bits, 1,0);
                   end
                   continue;
               end
               %}

           elseif class == 2
               if locs_diff(n) >= 28 && locs_diff(n) < 29
                   flag28 = 1;
               else
                   flag28 = 0;
               end
           end
           %%{




           if num_hi > 0

               if class == 2
                   if ~flag26 && mod(num_lo,2) %(num_lo == 1 || (mod(num_lo,2) && locs_diff(n-1) < 28))%mod(num_lo,2) % o num_lo == 1
                       bits = add_bit(bits, 0,0);
                       if locs_diff(n) > 40
                           num_hi = num_hi -1;
                       end
                   elseif flag26
                       num_hi = num_hi +1;
                       if ~mod(num_hi,2)
                            bits = add_bit(bits, 1,0);
                       end
                   end
                   flag26 = 0;
               end

               num_lo = 0;

           elseif flag26 && flag28
               num_lo = 0;
           end
           %}
           num_hi = num_hi +1;


           if ~mod(num_hi,2)
                bits = add_bit(bits, 1,0);
                first_hi = 0;
           end

       elseif class == 5
           bits = add_bit(bits, 1,0);

       elseif class == 2

           if locs_diff(n) >= 30 && locs_diff(n) < 44
               num_lo = num_lo + 1;
               bits = add_bit(bits, 0,0);
               num_hi = 0;
               if new_packet
                   if num_hi > 1
                       num_lo_pot = 1;
                   end
               end

               continue
           end



           if new_packet
               if flag26
                   num_lo = 0;
                   num_lo_pot = 0;
                   num_hi = num_hi +1;
                   if ~mod(num_hi,2)
                        bits = add_bit(bits, 1,0);
                   end
               elseif num_lo_pot
                   num_lo_pot = 0;
                   new_packet = 0;
                   bits = add_bit(bits, 0,0);
               end
           end

           if ~new_packet && num_lo > 1 && mod(num_lo,2)
               num_hi = num_hi + 1;
           end

           if not_par
               not_par = 0;
               num_hi = num_hi + 1;
           end

           num_hi = num_hi +1;
           num_lo = 0;
           flag26 = 0;

           if ~mod(num_hi,2)
                bits = add_bit(bits, 1,0);
           end
       else

           num_lo = 0;
           num_hi = num_hi +1;
           if num_hi >= parameter.hi_limit && first_hi
                bits = add_bit(bits, 1,0);
                first_hi = 0;
           end
       end

   elseif locs_diff(n) >= parameter.limitL1 && locs_diff(n) < parameter.limitL2

       if class == 4
           if(~blank)
               %%{
               if num_hi == 1 || num_lo_pot %|| (flag16 && ~mod(num_hi,2))

                   if num_lo_pot && num_hi == 1 %Case where a single high offset is before a 15 and before low offsets
                       bits = add_bit(bits, 1,0);
                   else
                       num_lo = num_lo + 1;
                       if ~mod(num_lo,2)
                            bits = add_bit(bits, 0,0);
                       end
                   end
               end
               %}

               num_lo_pot = 0;
               real_hi_count = 0;

           else
               if num_hi > 2 && ~mod(num_hi, 2)
                   bits = add_bit(bits, 0,1);
               end
               num_hi = 0;
               num_lo = num_lo + 1;
               if mod(num_lo,2)
                    bits = add_bit(bits, 0,0);
               end
               continue;

           end
       elseif class == 2

           if num_lo_pot
               num_lo_pot = 0;
               new_packet = 0;
           end

           if not_par
               not_par = 0;
           end

           if new_packet
               if num_hi > 1
                   num_lo_pot = 1;
               end
               if locs_diff(n) > 26 && num_lo == 0
                   flag26 = 1;
               else
                   flag26 = 0;
               end
           elseif mod(num_hi,2)
               num_lo = num_lo +1;
           else
               if (num_hi > 1)
                   not_par = 1;
               end
           end


       end
       flag28 = 0;
       num_hi_pot = 0;
       first_hi = 1;
       num_lo = num_lo + 1;


       if class == 5
           bits = add_bit(bits, 0,0);
       elseif class == 3
           if mod(num_lo,2)
                bits = add_bit(bits, 0,0);
           end
       else

           if ~mod(num_lo,2)
                bits = add_bit(bits, 0,0);
           end

       end


       num_hi = 0;
   end
end


end

function bits = add_bit(bits, type, subs)
persistent idx;

if isempty(bits)
    idx = 1;
end

if subs
    idx = idx -1;
else
    bits(idx) = type;
    idx = idx + 1;
end

end