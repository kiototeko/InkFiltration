function [num_bits,num_packets_rec] = bits2packets(bits, parameter, filename, real_num_packets, debug)

previdx3 = 1;


limits = find(bits < 0);
idx2 = 1;
idx3 = 1;
done = 0;

num_bits_tmp = 0;
num_bits = 0;
payload = 0;
bitstring = zeros(parameter.szbits-1,1);
error_packets = [];
missing_packets = [];

if(debug)
    fID = fopen(strcat('payloads/',parameter.printer_str,'_', string(real_num_packets), 'text_bits'));
else
    fID = fopen(strcat('payloads/',parameter.printer_str,'_', string(50), 'text_bits'));
end

num_packets = 0;
num_packets_rec = 0;
num_packets_rec_old = -1;

pattern = 'Pt2';
pt2 = contains(filename, pattern);
if(pt2)
    fseek(fID, (parameter.szbits-1)*real_num_packets, 'bof');
end


while idx2 < length(bits) - parameter.szbits-4

    if idx3 <= length(limits) && idx2 > limits(idx3) && idx3 < real_num_packets+1
        bitstring = fscanf(fID, '%1i', parameter.szbits-1).';
        idx3 = idx3 + 1;
        done = 1;
        if num_packets_rec == num_packets_rec_old
            missing_packets = [missing_packets idx3-2];
        end
        num_packets_rec_old = num_packets_rec;
    end

    if(done == 1)% && (bits(idx2) == 1 && bits(idx2+1) == 0 && bits(idx2+2) == 1 && bits(idx2+3) == 0))

        if ismember(-1,bits(idx2+4:idx2+4+parameter.szbits-1))
            idx2 = find(bits(idx2+4:idx2+4+parameter.szbits-1) == -1, 1, 'last')+idx2+4;
            continue;
        end

        parity = mod(sum(bits(idx2+4:idx2+4+parameter.szbits-2)),2);

        if previdx3 < idx3
            num_bits = num_bits + num_bits_tmp;
            if(num_bits_tmp > 0)
                num_packets_rec = num_packets_rec + 1;

                if (num_bits_tmp < parameter.szbits-1)
                    error_packets = [error_packets previdx3-1];
                end
            end
            if(debug)
                previdx3-1
                payload
            end
            previdx3 = idx3;
            num_bits_tmp = 0;

        end

        tmp = (parameter.szbits-1) - (parameter.szbits-1)*pdist([bitstring;bits(idx2+4:idx2+4+parameter.szbits-2)], 'hamming');

        if tmp > num_bits_tmp
            num_bits_tmp = tmp;
            payload = bits(idx2+4:idx2+4+parameter.szbits-2);
        end

        %{
        if parity ~= bits(idx2+4+parameter.szbits-1)
            idx2 = idx2 + 1;
        else
            if isempty(find((bitstring  == bits(idx2+4:idx2+4+parameter.szbits-2)) == 0,1))
                num_packets = num_packets + 1;
                done = 0;
            end

            idx2 = idx2 +  2;
        end
        %}
        idx2 = idx2 + 1;

    else
        idx2 = idx2 + 1;
    end
end


num_bits = num_bits + num_bits_tmp;
if(num_bits_tmp > 0)
    num_packets_rec = num_packets_rec + 1;
    if(debug)
        previdx3-1
        payload
    end
end

if(debug)
    num_packets_rec
    error_packets
    missing_packets = missing_packets(2:length(missing_packets))
end
end
