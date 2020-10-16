package com.ucla.printerleaks;

import android.util.Pair;

import java.io.File;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class processSignalText extends processSignal {


    processSignalText(int printer, File audioFile, InputStream fileSample) {
        super(2, printer, audioFile, fileSample);

        double limitL1, limitL2, limitH1, limitH2, minH;
        int env_window, preminH, peakdis;
        double szbits, prelimit, hi_limit;

        switch(printer){
            case 1:
                limitL1 = 20;
                limitL2 = 60;
                limitH1 = 5;
                limitH2 = 20;
                minH = 0.7;
                env_window = 3000;
                szbits = 11;
                hi_limit = 2;
                preminH = 290;
                prelimit = 1000;
                peakdis = 3;
                break;
            case 2:
                limitL1 = 19;
                limitL2 = 26.1;
                limitH1 = 26.1;
                limitH2 = 60;
                minH = 1;
                env_window = 3000;
                szbits = 8;
                preminH = 500;
                hi_limit = 1;
                prelimit = 500;
                peakdis = 5;
                break;
            case 3:
            default:
                limitL1 = 48;
                limitL2 = 200;
                limitH1 = 30;
                limitH2 = 48;
                hi_limit = 1;
                szbits = 7;
                minH = 2.4;
                preminH = 600;
                env_window = 2500;
                prelimit = 1000;
                peakdis = 5;
                break;
        }

        setParameter(limitH1, limitH2, limitL1, limitL2, preminH, prelimit, minH, szbits, peakdis, env_window, hi_limit);
    }

    @Override
    protected Pair<List<Integer>, List<Integer>> peaks2bits(List<Double> peaks_pre, List<Double> peaks) {

        List<Integer> bits = new ArrayList<>();
        List<Integer> limits = new ArrayList<>();
        List<Double> locs_diff = new ArrayList<>();
        final printerParameters parameters = getParameter();

        for (int i = 1; i < peaks.size(); i++)
            locs_diff.add(peaks.get(i) - peaks.get(i - 1));
        
        int num_hi = 0, num_lo = 0, preidx = 0;
        boolean last_hi = false, first_hi = true;

        for (int n = 0; n < locs_diff.size(); n++) {

            if (preidx < peaks_pre.size() && peaks.get(n) > peaks_pre.get(preidx)) {
                bits.add(1);
                bits.add(-1);
                bits.add(1);
                preidx++;
            }

            if (printer == 2) {
                if (locs_diff.get(n) >= 43 && locs_diff.get(n) < 45 || locs_diff.get(n) >= 31 && locs_diff.get(n) < 35)
                    locs_diff.set(n, parameter.limitL1);
                else if (n + 1 < locs_diff.size() && ((locs_diff.get(n) >= 21 && locs_diff.get(n) < 22) || ((locs_diff.get(n) >= 10 && locs_diff.get(n) < parameter.limitL1) && (locs_diff.get(n + 1) >= 10 && locs_diff.get(n + 1) < parameter.limitL1)))) {
                    locs_diff.set(n + 1, locs_diff.get(n + 1) + locs_diff.get(n));
                    continue;
                }
            } else if (printer == 3) {
                if (locs_diff.get(n) >= 10 && locs_diff.get(n) < 30)
                    locs_diff.set(n, parameter.limitL1);
            }

            if (locs_diff.get(n) >= parameter.limitH1 && locs_diff.get(n) < parameter.limitH2) {

                num_lo = 0;
                num_hi++;
                if (num_hi >= parameter.hi_limit && first_hi) {
                    bits.add(1);
                    first_hi = false;
                }
                last_hi = true;
            } else if (locs_diff.get(n) >= parameter.limitL1 && locs_diff.get(n) < parameter.limitL2) {

                first_hi = true;
                num_lo++;

                if(printer == 3) {
                    if (locs_diff.get(n) > 100)
                        num_lo++;

                    if (last_hi && num_lo > 2) {
                        bits.add(0);
                        num_lo -= 2;
                        last_hi = false;
                    } else if ((num_lo % 2) == 0) {
                        bits.add(0);
                    }
                }
               else if ((num_lo % 2) == 0)
                    bits.add(0);

               num_hi = 0;

            }
        }
        return new Pair<>(bits, limits);
    }
}
