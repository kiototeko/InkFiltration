package com.ucla.printerleaks;

import android.util.Log;
import android.util.Pair;

import com.github.psambit9791.jdsp.filter.Chebyshev;
import com.github.psambit9791.jdsp.misc.UtilMethods;
import com.github.psambit9791.jdsp.signal.Decimate;
import com.github.psambit9791.jdsp.signal.peaks.FindPeak;
import com.github.psambit9791.jdsp.signal.peaks.Peak;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import static java.lang.Math.abs;
import static java.lang.Math.pow;
import static java.lang.Math.sqrt;


abstract public class processSignal {

    InputStream fileSample;
    printerParameters parameter;
    File audioFile;
    int printer;
    final int Fs = 44100;

    public native double[] getPeaksB(double[] a, double minH, int window, int printer, int peakdis);

    public native double[] getPeaksPre(double[] a, double[] sample, int window, int minH);

    static protected class printerParameters {
        public double limitL1, limitL2, limitH1, limitH2, minH;
        public int env_window, preminH, peakdis;
        public double szbits, prelimit;
        public boolean blank;
    }

    processSignal(int printer, File audioFile, InputStream fileSample) {
        this.audioFile = audioFile;
        this.printer = printer;
        this.fileSample = fileSample;
        this.parameter = new printerParameters();
    }

    protected abstract List<Integer> peaks2bits(List<Double> peaks_pre, List<Double> peaks);


    public int getPayloadSize() {
        return (int) parameter.szbits - 1;
    }

    public void setParameter(double limitH1, double limitH2, double limitL1, double limitL2,
                             int preminH, double prelimit, double minH, double szbits, int peakdis, int env_window, boolean blank) {
        parameter.limitH1 = limitH1;
        parameter.limitH2 = limitH2;
        parameter.limitL1 = limitL1;
        parameter.limitL2 = limitL2;
        parameter.preminH = preminH;
        parameter.prelimit = prelimit;
        parameter.minH = minH;
        parameter.szbits = szbits;
        parameter.peakdis = peakdis;
        parameter.env_window = env_window;
        parameter.blank = blank;
    }


    public printerParameters getParameter() {
        return parameter;
    }

    private double[] readFileCSV() throws IOException {


        final int lineSz = 179; //Maximum sample size
        double[] sample = new double[lineSz];
        String eachline = "";

        BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(fileSample));
        for (int i = 0; i < printer; i++) {
            eachline = bufferedReader.readLine();
        }
        String[] words = eachline.split(",");

        for (int i = 0; i < lineSz; i++) {
            sample[i] = Double.parseDouble(words[i]);
        }

        return sample;
    }

    private int timesCharacter(String s, char c){
        int positionOfLetter = s.indexOf(c);
        int countNumberOfLetters = 0;

        while (positionOfLetter != -1) {
            countNumberOfLetters++;
            positionOfLetter = s.indexOf(c, positionOfLetter + 1);
        }
        return countNumberOfLetters;
    }

    private void getFloats(double[] fl, byte[] chunk, int sz){
        //double[] fl = new double[(int)sz/2];

        for(int i = 0; i < sz; i += 2) {
            double f;
            short pcm = (short)(((chunk[i+1] & 0xFF) << 8) | (chunk[i] & 0xFF));
            f = ((double) pcm) / (double) 32768.0;
            if (f > 1) f = 1;
            if (f < -1) f = -1;
            fl[(int) i/2] = f;

        }

    }

    // This function is not actually used, it performs worse than using the matlab function getPeaksB
    private double[] getPeaks(double[] y, double minH, int window, int peakdis){
        Chebyshev cheb = new Chebyshev(y, Fs, 0.01, 1);
        double[] yband = cheb.bandPassFilter(6, 3500, 6000);
        double[] ycentered, xrms = new double[yband.length]; //= new double[yband.length];
        double mean = 0;

        for(double n: yband)
            mean += n;

        mean /= yband.length;

        /**
        for(int i = 0; i < yband.length; i++) {
            ycentered[i] = yband[i] - mean;
        }
         **/

        ycentered = UtilMethods.scalarArithmetic(yband, mean, "sub");
        double xrms_tmp;
        for(int n = 0; n < yband.length; n++){
            xrms_tmp = 0;
            if(n < window-1)
                for (int i = 0; i <= n; i++) {
                    xrms_tmp += pow(ycentered[i], 2);
                }
            else {
                for (int i = n - window+1; i <= n; i++) {
                    xrms_tmp += pow(ycentered[i], 2);
                }
            }
            xrms[n] = sqrt(xrms_tmp/window);
        }

        double[] yupper = UtilMethods.scalarArithmetic(xrms, mean, "add");
        double yupper_tmp = 0;
        for(double n: yupper){
            yupper_tmp += abs(pow(n,2));
        }
        yupper_tmp = sqrt(yupper_tmp/yupper.length);
        double[] out = UtilMethods.scalarArithmetic(yupper, yupper_tmp, "div");

        Decimate dec = new Decimate(out, Fs);
        double[] outD = dec.decimate(1000);

        FindPeak fp = new FindPeak(outD);
        Peak peaks = fp.detectPeaks();
        int[] peaks_loc = peaks.filterByHeight(minH, "lower");
        double[] peaks_res;

        if(peaks_loc.length > 0) {
            peaks_res = new double[peaks_loc.length];
            peaks_res[0] = peaks_loc[0];

            if(peaks_loc.length > 1) {
                int[] peaks_diff = UtilMethods.diff(peaks_loc);
                int sum = 0;
                for (int i = 0, idx = 1; i < peaks_diff.length; i++) {
                    sum += peaks_diff[i];
                    if (sum >= peakdis) {
                        peaks_res[idx] = peaks_loc[i+1];
                        idx++;
                        sum = 0;
                    }
                }
            }
        }
        else {
            peaks_res = new double[1];
            peaks_res[0] = 0;
        }

        return peaks_res;

    }

    private List<Double> obtainPeaks(boolean pre) throws IOException {

        FileInputStream in = new FileInputStream(audioFile);
        int numFrames = (int) audioFile.length()/2;
        int overlap = 10000 + 10000 * 11*(pre? 1:0);
        int window = Fs + Fs*11*(pre? 1:0);
        int remaining_sz = numFrames, bytesObtained = 0;
        int num = (int)Math.ceil(((double)numFrames)/((double)(window-overlap)));
        List<Double> peaks = new ArrayList<>();
        double[] remnant = new double[window], frames_temp = new double[window-overlap];
        double[] locs, sample_variable = new double[1];
        byte[] remnantRaw = new byte[window*2];

        if(pre)
             sample_variable = readFileCSV();

        for(int n = 0; n < num; n++) {


            remaining_sz -= bytesObtained;
            if(n == 0) {
                in.read(remnantRaw, 0, window*2);
                getFloats(remnant, remnantRaw, window*2);
                bytesObtained = window-overlap;
            }
            else {
                System.arraycopy(remnant, remnant.length - overlap, remnant, 0, overlap);

                if (window-overlap > remaining_sz) {
                    in.read(remnantRaw, 0, remaining_sz*2);
                    getFloats(frames_temp, remnantRaw, remaining_sz*2);
                    System.arraycopy(frames_temp, 0, remnant, overlap, remaining_sz);
                } else {
                    bytesObtained = window-overlap;
                    in.read(remnantRaw, 0, bytesObtained*2);
                    getFloats(frames_temp, remnantRaw, bytesObtained*2);

                    System.arraycopy(frames_temp, 0, remnant, overlap, window - overlap);
                }
            }


            if(pre) {
                locs = getPeaksPre(remnant, sample_variable, parameter.env_window, parameter.preminH);

            }
            else{
                locs = getPeaksB(remnant, parameter.minH, parameter.env_window, printer,parameter.peakdis);
            }

            for(double loc: locs) {
                if(loc < 1 || loc > 100000)
                        break;

                loc += n * (window - overlap) / 1000.0;

                if(pre) {
                    //Log.i("locs", Double.toString(loc));
                    if (peaks.isEmpty() || loc - peaks.get(peaks.size() - 1) > parameter.prelimit) {
                        peaks.add(loc);
                    }
                }else{
                    if (peaks.isEmpty() || loc > peaks.get(peaks.size() - 1)) {
                        peaks.add(loc);
                    }
                }
            }

        }
        in.close();
        return peaks;
    }

    private  List<Integer> bits2packets(List<Integer> bits){

        int idx = 0, idx2 = 0, parity;
        boolean done = false;
        List<Integer> true_bits = new ArrayList<>();
        List<Integer> limits = new ArrayList<>();


        for (int i = 0; i < bits.size(); i++) {
            if (bits.get(i).intValue() == -1) {
                limits.add(i);
            }
        }


        while(idx < bits.size() - parameter.szbits-4){
            if(idx2 < limits.size() && idx > limits.get(idx2)) {
                idx2++;
                done = true;
            }

            if(done && (bits.get(idx) == 1 && bits.get(idx+1) == 0 && bits.get(idx+2) == 1 && bits.get(idx+3) == 0)) {

                if (bits.subList(idx+4, (int)(idx+4+parameter.szbits)).contains(-1)) {
                    idx += bits.subList(idx + 4, (int) (idx + 4 + parameter.szbits)).lastIndexOf(-1) + 4;
                    continue;
                }

                int sum = 0;
                for(int i = idx+4; i < idx+4+parameter.szbits-1; i++) {
                    sum += bits.get(i);
                }

                parity = sum % 2;


                if(parity != bits.get((int) (idx+4+parameter.szbits-1)))
                    idx++;
                else {
                    true_bits.addAll(bits.subList(idx+4, (int)(idx+4+parameter.szbits-1)));
                    idx += 2;
                    done = false;
                }

            }else
                idx++;
        }
        return true_bits;

    }

    public String process(){
        List<Integer> bits = new ArrayList<>();
        String bitsS = "";
        try {
            List<Double> peaks_pre = obtainPeaks(true);
            Log.i("Process", "Output obtainPeaksPre " + Integer.toString(peaks_pre.size()));
            long start = System.currentTimeMillis();
            List<Double> peaks = obtainPeaks(false);
            Log.i("Time elapsed", Long.toString(System.currentTimeMillis() - start));
            Log.i("Process", "Output obtainPeaks " + Integer.toString(peaks.size()));
            List<Integer> res = peaks2bits(peaks_pre, peaks);

            StringBuilder ress = new StringBuilder();
            for(int i : res){
                ress.append(Integer.toString(i));
            }
            Log.i("Process", "Output peaks2bits " + ress);
            bits = bits2packets(res);
            Log.i("Process", "End");
        }catch(Exception d){
            Log.i("processSignal", d.getMessage());
        }

        for(int i : bits){
            bitsS += Integer.toString(i);
        }
        return bitsS;
    }
}
