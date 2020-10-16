function num_bits = bits2packets(bits, limits, type, parameter, filename)

if(type == "Blank")

    bitstring = zeros(parameter.szbits-1,1);
    idx2 = 1;
    idx3 = 1;
    done = 0;
    previdx3 = 1;
    num_packets = 0;
    num_bits = 0;
    num_bits_tmp = 0;
    fID = fopen(strcat('/home/kiototeko/tareas/masterThesis/printer/PDFtemplates/random/',parameter.printer_str,'50_bits'));

    pattern = 'Pt2';
    pt2 = contains(filename, pattern);
    if(pt2)
        fseek(fID, (parameter.szbits-1)*25, 'bof');
    end

    while idx2 < length(bits) - parameter.szbits-4

        if idx3 <= length(limits) && idx2 > limits(idx3) && idx3 <= 25
            bitstring = fscanf(fID, '%1i', parameter.szbits-1).';
            idx3 = idx3 + 1;
            done = 1;
        end

        if(done == 1 && (bits(idx2) == 1 && bits(idx2+1) == 0 && bits(idx2+2) == 1 && bits(idx2+3) == 0))

            parity = mod(sum(bits(idx2+4:idx2+4+parameter.szbits-2)),2);

            if previdx3 < idx3
                num_bits = num_bits + num_bits_tmp;
                previdx3 = idx3;
                num_bits_tmp = 0;
            end
            
            tmp = (parameter.szbits-1) - (parameter.szbits-1)*pdist([bitstring;bits(idx2+4:idx2+4+parameter.szbits-2)], 'hamming');
            
            if tmp > num_bits_tmp
                num_bits_tmp = tmp;
            end
           
            
            if ismember(-1,bits(idx2+4:idx2+4+parameter.szbits-1))
                idx2 = find(bits(idx2+4:idx2+4+parameter.szbits-1) == -1, 1, 'last')+idx2+4;
            elseif parity ~= bits(idx2+4+parameter.szbits-1)
                idx2 = idx2 + 1;
            else
                if isempty(find((bitstring  == bits(idx2+4:idx2+4+parameter.szbits-2)) == 0,1))
                    num_packets = num_packets + 1;
                    done = 0;
                end

                idx2 = idx2 +  2;
            end
        else
            idx2 = idx2 + 1;
        end
    end

elseif(type == "Text")

    limits = find(bits < 0);
    idx2 = 1;
    idx3 = 1;
    done = 0;
    previdx3 = 1;
    num_bits_tmp = 0;
    num_bits = 0;
    bitstring = zeros(parameter.szbits-1,1);

    fID = fopen(strcat('/home/kiototeko/tareas/masterThesis/printer/PDFtemplates/random/',parameter.printer_str,'50text_bits'));
    num_packets = 0;

    pattern = 'Pt2';
    pt2 = contains(filename, pattern);
    if(pt2)
        fseek(fID, (parameter.szbits-1)*25, 'bof');
    end


    while idx2 < length(bits) - parameter.szbits-4

        if idx3 <= length(limits) && idx2 > limits(idx3) && idx3 < 26
            bitstring = fscanf(fID, '%1i', parameter.szbits-1).';
            idx3 = idx3 + 1;
            done = 1;
        end

        if(done == 1 && (bits(idx2) == 1 && bits(idx2+1) == 0 && bits(idx2+2) == 1 && bits(idx2+3) == 0))

            if ismember(-1,bits(idx2+4:idx2+4+parameter.szbits-1))
                idx2 = find(bits(idx2+4:idx2+4+parameter.szbits-1) == -1, 1, 'last')+idx2+4;
                continue;
            end
            
            parity = mod(sum(bits(idx2+4:idx2+4+parameter.szbits-2)),2);

            if previdx3 < idx3
                num_bits = num_bits + num_bits_tmp;
                previdx3 = idx3;
                num_bits_tmp = 0;
            end
            
            tmp = (parameter.szbits-1) - (parameter.szbits-1)*pdist([bitstring;bits(idx2+4:idx2+4+parameter.szbits-2)], 'hamming');
            
            if tmp > num_bits_tmp
                num_bits_tmp = tmp;
            end

            if parity ~= bits(idx2+4+parameter.szbits-1)
                idx2 = idx2 + 1;
            else
                if isempty(find((bitstring  == bits(idx2+4:idx2+4+parameter.szbits-2)) == 0,1))
                    num_packets = num_packets + 1;
                    done = 0;
                end

                idx2 = idx2 +  2;
            end
        else
            idx2 = idx2 + 1;
        end
    end
end

num_bits = num_bits + num_bits_tmp;

end