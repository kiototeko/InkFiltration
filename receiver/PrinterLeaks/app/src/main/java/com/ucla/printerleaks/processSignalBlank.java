package com.ucla.printerleaks;

import android.util.Pair;

import java.io.File;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class processSignalBlank extends processSignal{

    processSignalBlank(int printer, File audioFile, InputStream fileSample) {
        super(1,printer,audioFile, fileSample);

        double limitL1, limitL2, limitH1, limitH2, minH;
        int env_window, preminH, peakdis;
        double szbits, prelimit, limitI;

        switch (printer) {
            case 1:
                limitH1 = 5;
                limitH2 = 21;
                limitL1 = 21;
                limitL2 = 50;
                limitI = 5;
                preminH = 180;
                prelimit = 300;
                minH = 0.7;
                szbits = 26;
                break;
            case 2:
                limitL1 = 10;
                limitL2 = 25;
                limitH1 = 25;
                limitH2 = 60;
                limitI = 7;
                preminH = 450;
                prelimit = 600;
                minH = 1.5;
                szbits = 28;
                break;
            case 3:
            default:
                limitL1 = 10;
                limitL2 = 35;
                limitH1 = 35;
                limitH2 = 60;
                limitI = 10;
                preminH = 450;
                prelimit = 500;
                minH = 1.5;
                szbits = 21;
                break;


        }
        peakdis = 3;
        env_window = 1000;

        setParameter(limitH1, limitH2, limitL1, limitL2, limitI, preminH, prelimit, minH, szbits, peakdis, env_window);
    }
    @Override
    protected Pair<List<Integer>, List<Integer>> peaks2bits(List<Double> peaks_pre, List<Double> peaks) {

        List<Integer> bits = new ArrayList<>();
        List<Integer> limits = new ArrayList<>();
        List<Double> locs_diff = new ArrayList<>();
        final printerParameters parameter = getParameter();

        for(int i = 1; i < peaks.size(); i++)
            locs_diff.add(peaks.get(i) - peaks.get(i-1));


        int preidx = 0;
        double sum_locs = 0;

        for(int n = 0; n < locs_diff.size(); n++) {

            sum_locs = sum_locs + locs_diff.get(n);
            if (preidx < peaks_pre.size() && sum_locs > peaks_pre.get(preidx)) {
                limits.add(bits.size());
                preidx++;
            }

            if (printer == 1) {
                if (locs_diff.get(n) > 25 && locs_diff.get(n) < 26) {
                    locs_diff.set(n + 1, locs_diff.get(n + 1) + locs_diff.get(n));
                    continue;
                }
            } else if (printer == 2) {

                if (locs_diff.get(n) > 48 && locs_diff.get(n) < 53) {
                    bits.add(1);
                    bits.add(0);
                    continue;
                } else if (locs_diff.get(n) >= 45 && locs_diff.get(n) < 48) {
                    bits.add(0);
                    continue;
                } else if (locs_diff.get(n) >= 21 && locs_diff.get(n) < 22) {
                    locs_diff.set(n + 1, locs_diff.get(n + 1) + locs_diff.get(n));
                    continue;
                }
            } else if (printer == 3) {

                if (locs_diff.get(n) >= 55) {
                    bits.add(0);
                    bits.add(1);
                    continue;
                }
            }

            if (locs_diff.get(n) < parameter.limitL2 && locs_diff.get(n) >= parameter.limitL1)
                bits.add(0);
            else if (locs_diff.get(n) < parameter.limitH2 && locs_diff.get(n) >= parameter.limitH1)
                bits.add(1);
            else if (locs_diff.get(n) < parameter.limitI)
                continue;
            else
                bits.add(-1);


        }
        return new Pair<>(bits, limits);
    }

}
