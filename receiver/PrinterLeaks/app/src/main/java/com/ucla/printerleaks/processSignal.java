package com.ucla.printerleaks;

import android.util.Log;
import android.util.Pair;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;


abstract public class processSignal {

    InputStream fileSample;
    printerParameters parameter;
    File audioFile;
    int printer, type;
    final int Fs = 44100;

    public native double[] getPeaksB(double[] a, double minH, int window, int printer, int peakdis);
    public native double[] getPeaksPre(double[] a, double[] sample, int window, int minH);

    static protected class printerParameters {
        public double limitL1, limitL2, limitH1, limitH2, minH;
        public int env_window, preminH, peakdis;
        public double szbits, hi_limit, prelimit, limitI;
    }

    processSignal(int type, int printer, File audioFile, InputStream fileSample){
        this.audioFile = audioFile;
        this.printer = printer;
        this.type = type;
        this.fileSample = fileSample;
        this.parameter = new printerParameters();
    }

    protected abstract Pair<List<Integer>, List<Integer>> peaks2bits(List<Double> peaks_pre, List<Double> peaks);


    public int getPayloadSize(){
        return (int) parameter.szbits-1;
    }

    public void setParameter(double limitH1, double limitH2, double limitL1, double limitL2,
                             int preminH, double prelimit, double minH, double szbits, int peakdis, int env_window, double hi_limit){
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
        parameter.hi_limit = hi_limit;
    }

    public void setParameter(double limitH1, double limitH2, double limitL1, double limitL2, double limitI,
                             int preminH, double prelimit, double minH, double szbits, int peakdis, int env_window){
        parameter.limitH1 = limitH1;
        parameter.limitH2 = limitH2;
        parameter.limitL1 = limitL1;
        parameter.limitL2 = limitL2;
        parameter.limitI = limitI;
        parameter.preminH = preminH;
        parameter.prelimit = prelimit;
        parameter.minH = minH;
        parameter.szbits = szbits;
        parameter.peakdis = peakdis;
        parameter.env_window = env_window;
    }

    public printerParameters getParameter(){
        return parameter;
    }
    private double[] readFileCSV() throws IOException {

        /*
        Scanner sc = new Scanner(new File(filenameSample));
        final int lineSz = 179;
        double[] sample = new double[lineSz];
        sc.useDelimiter(",");
        for(int i = 0; i < (printer-1)*2 + (type-1); i++) {
            sc.nextLine();
        }
        for(int i = 0; i < lineSz; i++){
            sample[i] = sc.nextDouble();
        }
        sc.close();
        return sample;
        */

        final int lineSz = 179;
        double[] sample = new double[lineSz];
        String eachline = "";

        BufferedReader bufferedReader= new BufferedReader(new InputStreamReader(fileSample));
        for(int i = 0; i <= (printer-1)*2 + (type-1); i++) {
            eachline = bufferedReader.readLine();
        }
        String[] words = eachline.split(",");

        for(int i = 0; i < lineSz; i++){
            sample[i] = Double.parseDouble(words[i]);
        }

        return sample;
    }

    private List<Double> obtainPeaks(boolean pre) throws IOException,WavFileException {

        WavFile wav = WavFile.openWavFile(audioFile);
        //int Fs = (int) wav.getSampleRate();
        int overlap = 10000 + 10000 * 11*(pre? 1:0);
        int window = Fs + Fs*11*(pre? 1:0);
        int num = (int)Math.ceil(((double)wav.getNumFrames())/((double)(window-overlap)));
        List<Double> peaks = new ArrayList<>();
        double[] remnant = new double[window], frames_temp = new double[window-overlap];
        double[] locs, sample_variable = new double[1];

        if(pre)
             sample_variable = readFileCSV();

        for(int n = 0; n < num; n++) {

            int remaining_sz = (int)wav.getFramesRemaining();
            if(n == 0) {
                wav.readFrames(remnant, window);
            }
            else {
                System.arraycopy(remnant, remnant.length - overlap, remnant, 0, overlap);

                if (window-overlap > remaining_sz) {
                    wav.readFrames(frames_temp, remaining_sz);
                    System.arraycopy(frames_temp, 0, remnant, overlap, remaining_sz);
                } else {
                    wav.readFrames(frames_temp, window - overlap);
                    System.arraycopy(frames_temp, 0, remnant, overlap, window - overlap);
                }
            }


            if(pre) {
                locs = getPeaksPre(remnant, sample_variable, parameter.env_window, parameter.preminH);

            }
            else
                locs = getPeaksB(remnant, parameter.minH, parameter.env_window, printer,parameter.peakdis);

            for(double loc: locs) {
                if(loc < 1 || loc > 100000)
                        continue;

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
        return peaks;
    }

    private  List<Integer> bits2packets(List<Integer> bits, List<Integer> limits){ //falta limits para FPM-DPPM

        int idx = 0, idx2 = 0, parity;
        boolean done = false;
        List<Integer> true_bits = new ArrayList<>();

        if(type == 2){
            limits = new ArrayList<>();
            for (int i = 0; i < bits.size(); i++) {
                if (bits.get(i).intValue() == -1) {
                    limits.add(i);
                }
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
            Log.i("dd", "hello-1");
            List<Double> peaks_pre = obtainPeaks(true);
            Log.i("dd", "hello0 " + Integer.toString(peaks_pre.size()));
            List<Double> peaks = obtainPeaks(false);
            Log.i("dd", "hello " + Integer.toString(peaks.size()));
            Pair<List<Integer>, List<Integer>> res = peaks2bits(peaks_pre, peaks);

            String ress = "";
            for(int i : res.first){
                ress += Integer.toString(i);
            }
            Log.i("dd", "hello2 " + res.first);
            Log.i("dd", "hello2 " + ress);
            bits = bits2packets(res.first, res.second);
            Log.i("dd", "hello4");
        }catch(Exception d){
            Log.i("processSignal", d.getMessage());
        }

        for(int i : bits){
            bitsS += Integer.toString(i);
        }
        Log.i("dd", "aqui: " + bitsS);
        return bitsS;
    }
}
