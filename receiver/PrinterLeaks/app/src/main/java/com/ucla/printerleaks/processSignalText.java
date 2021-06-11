package com.ucla.printerleaks;

import android.util.Log;
import android.util.Pair;

import java.io.File;
import java.io.InputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

public class processSignalText extends processSignal {


    processSignalText(int printer, File audioFile, InputStream fileSample, boolean blank) {
        super(printer, audioFile, fileSample);

        double limitL1, limitL2, limitH1, limitH2, minH;
        int env_window, preminH, peakdis;
        double szbits, prelimit;

        switch(printer){
            case 1:
            case 2:

                limitL1 = 16;
                limitL2 = 27;
                limitH1 = 27;
                limitH2 = 60;
                minH = 1;
                env_window = 3000;
                szbits = 10;
                preminH = 450;
                prelimit = 500;
                peakdis = 5;
                break;
            case 3:
                limitL1 = 15;
                limitL2 = 40;
                limitH1 = 40;
                limitH2 = 80;
                szbits = 10;
                minH = 1.2;
                preminH = 600;
                env_window = 2500;
                prelimit = 950;
                peakdis = 5;
                break;
            case 4:
                if(blank) {
                    limitL1 = 6;
                    limitL2 = 8;
                    limitH1 = 10;
                    limitH2 = 33;
                }
                else {
                    limitL1 = 7;
                    limitL2 = 15;
                    limitH1 = 15;
                    limitH2 = 33;
                }


                szbits = 12;
                minH = 1;
                preminH = 400;
                env_window = 1031;
                prelimit = 550;
                peakdis = 2;
                break;
            case 5:
            default:
                limitL1 = 8;
                limitL2 = 26;
                limitH1 = 26;
                limitH2 = 51;
                szbits = 12;
                minH = 1.4;
                preminH = 150;
                env_window = 1031;
                prelimit = 400;
                peakdis = 5;
                break;
        }

        setParameter(limitH1, limitH2, limitL1, limitL2, preminH, prelimit, minH, szbits, peakdis, env_window, blank);
    }

    @Override
    protected List<Integer> peaks2bits(List<Double> peaks_pre, List<Double> peaks) {

        List<Integer> bits = new ArrayList<>();
        List<Double> locs_diff = new ArrayList<>();
        BigDecimal bg = new BigDecimal(0);

        for (int i = 1; i < peaks.size(); i++) {
            bg = new BigDecimal(Double.toString(peaks.get(i) - peaks.get(i - 1)));
            locs_diff.add(bg.setScale(4, RoundingMode.HALF_EVEN).doubleValue());
            //locs_diff.add(peaks.get(i) - peaks.get(i - 1));
        }
        
        int num_hi = 0, num_lo = 0, preidx = 0;
        boolean num_lo_pot = false, num_hi_pot = false, flag26 = false, new_packet = false, not_par = false;
        Log.i("locs_diff", locs_diff.toString());
        Log.i("peaks", peaks.toString());
        Log.i("peaks_pre", peaks_pre.toString());
        Log.i("audioFile bytes", Long.toString(audioFile.length()));
        if(printer == 4) {
            boolean was_here = false;
            double residual = 0;
            int previdx = -1;

            for(int n = 0; n < locs_diff.size(); n++) {
                if (locs_diff.get(n) > 2) {
                    if (n > 1 && locs_diff.get(n) < parameter.limitL1 && previdx > -1) {
                        if (!was_here) {
                            locs_diff.set(previdx, locs_diff.get(previdx) + locs_diff.get(n));
                            locs_diff.set(n, 0.0);
                            was_here = true;
                        } else
                            residual += locs_diff.get(n);
                    } else {
                        was_here = false;
                        if (! parameter.blank) {
                            locs_diff.set(n, locs_diff.get(n) + residual);
                        }
                        residual = 0;
                    }
                    previdx = n;
                }
            }
        }
        else if (printer == 2){
            double residual = 0;
            for(int n = 0; n < locs_diff.size(); n++) {
                if (locs_diff.get(n) < parameter.limitL1) {
                    residual += locs_diff.get(n);
                    locs_diff.set(n, residual);
                }
                else
                    residual = 0;
            }
        }

        for (int n = 0; n < locs_diff.size(); n++) {

            if (preidx < peaks_pre.size() && peaks.get(n) > peaks_pre.get(preidx)) {
                bits.add(1);
                bits.add(-1);
                bits.add(1);
                preidx++;
                new_packet = true;
                num_hi = 0;
                num_lo = 0;
            }


            if (locs_diff.get(n) >= parameter.limitH1 && locs_diff.get(n) < parameter.limitH2) {

                if (printer == 4 || printer == 3) {
                    if (printer == 4) {

                        if (!parameter.blank) {
                            if (num_hi > 0 && num_lo == 1) {
                                bits.add(0);
                                num_lo = 0;
                            }

                            if (num_hi > 0 && locs_diff.get(n) >= 15 && locs_diff.get(n) < 16) {
                                if (!num_hi_pot) {
                                    num_lo_pot = true;
                                    num_hi_pot = true;
                                } else {
                                    num_hi += 1;
                                    if (num_hi % 2 == 0) {
                                        bits.add(1);
                                    }
                                    num_lo = 0;
                                }
                                continue;
                            }

                            if (num_hi_pot) {
                                num_hi += 1;
                                if (num_hi % 2 == 0) {
                                    bits.add(1);
                                }
                            }


                            if ((num_hi == 0 && num_lo > 0 && locs_diff.get(n) >= 20) || (num_hi > 0 && num_hi_pot && locs_diff.get(n) >= 21)) {
                                num_lo = num_lo + 1;
                                if (num_lo % 2 == 0) {
                                    bits.add(0);
                                }
                                continue;
                            }
                            num_lo_pot = false;
                            num_hi_pot = false;
                        } else {
                            num_lo = 0;
                            num_hi += 1;
                            if (num_hi % 2 == 0) {
                                bits.add(1);
                            }
                            continue;
                        }

                    }

                    if (num_hi > 0) {
                        num_lo = 0;
                    }

                    num_hi += 1;

                    if (num_hi % 2 == 0) {
                        bits.add(1);
                    }
                } else if (printer == 5)
                    bits.add(1);

                else if (printer == 2) {

                    if (locs_diff.get(n) >= 30.0 && locs_diff.get(n) < 44.0) {
                        num_lo++;
                        bits.add(0);
                        num_hi = 0;

                        if (new_packet && num_hi > 1) {
                            num_lo_pot = true;
                        }

                        continue;
                    }


                    if (new_packet) {
                        if (flag26) {
                            num_lo = 0;
                            num_lo_pot = false;
                            num_hi++;
                            if (num_hi % 2 == 0) {
                                bits.add(1);
                            }
                        } else if (num_lo_pot) {
                            num_lo_pot = false;
                            new_packet = false;
                            bits.add(0);
                        }
                    }

                    if ((! new_packet) && num_lo > 1 && (num_lo % 2 == 1)) {
                        num_hi++;
                    }


                    if (not_par) {
                        not_par = false;
                        num_hi++;
                    }

                    num_hi++;
                    num_lo = 0;
                    flag26 = false;

                    if (num_hi % 2 == 0) {
                        bits.add(1);
                    }
                } else {

                    num_lo = 0;
                    num_hi++;
                    if (num_hi % 2 == 0) {
                        bits.add(1);
                    }
                }
            } else if (locs_diff.get(n) >= parameter.limitL1 && locs_diff.get(n) < parameter.limitL2) {

                if (printer == 4) {
                    if (! parameter.blank) {

                        if (num_hi == 1 || num_lo_pot) {

                            if (num_lo_pot && num_hi == 1) {
                                bits.add(1);
                            }
                            else{
                                num_lo++;
                                if (num_lo % 2 == 0) {
                                    bits.add(0);
                                }
                            }
                        }
                        num_lo_pot = false;
                    } else {

                        if (num_hi > 2 && num_hi % 2 == 0) {
                            bits.remove(bits.size() - 1);
                        }

                        num_hi = 0;
                        num_lo++;
                        if (num_lo % 2 == 1) {
                            bits.add(0);
                        }
                        continue;
                    }

                }
                else if (printer == 2) {

                    if (num_lo_pot) {
                        num_lo_pot = false;
                        new_packet = false;
                    }

                    if (not_par) {
                        not_par = false;
                    }


                    if (new_packet) {
                        if (num_hi > 1) {
                            num_lo_pot = true;
                        }

                        if (locs_diff.get(n) > 26.0 && num_lo == 0) {
                            flag26 = true;
                        }
                        else {
                            flag26 = false;
                        }
                    }
                    else if (num_hi % 2 == 1) {
                        num_lo++;
                    }
                    else {
                        if (num_hi > 1) {
                            not_par = true;
                        }
                    }
                }
                num_hi_pot = false;
                num_lo++;


                if (printer == 5) {
                    bits.add(0);
                }
                else if (printer == 3) {
                    if (num_lo % 2 == 1) {
                        bits.add(0);
                    }
                }
                else {
                    if (num_lo % 2 == 0) {
                        bits.add(0);
                    }
                }
                num_hi = 0;
            }
        }
        return bits;
    }
}
