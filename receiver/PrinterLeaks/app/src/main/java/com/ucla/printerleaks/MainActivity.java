package com.ucla.printerleaks;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.math.MathUtils;

import java.io.BufferedWriter;
import java.io.DataOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Date;
import java.util.concurrent.*;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.icu.util.Calendar;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioRecord;
import android.media.AudioTrack;
import android.media.MediaCodec;
import android.media.MediaCodecList;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.media.MediaRecorder;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.os.SystemClock;
import android.util.Log;
import android.util.Pair;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static java.lang.Boolean.FALSE;
import static java.lang.Boolean.TRUE;


public class MainActivity extends AppCompatActivity {
    final int OPEN_REQUEST_CODE = 100;
    final int STORAGE_REQUEST_CODE = 101;
    final int RECORD_REQUEST_CODE = 102;
    final int WRITE_REQUEST_CODE = 103;
    static int num_lo = 0, num_hi = 0, res = 0;
    File filename;

    private final static int MESSAGE_UPDATE_TEXT_CHILD_THREAD =1;
    Boolean inUse = FALSE, stopRecording = FALSE;
    TextView tv, pay, recording;
    File audioFile;
    String payload;
    int payload_sz;
    Spinner spinn;
    MediaCodec mDecoder;
    MediaExtractor extractor;

    MediaRecorder recorder;
    private Handler updateUIHandler = null;
    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);




        createUpdateUiHandler();
        checkPermission(Manifest.permission.READ_EXTERNAL_STORAGE, OPEN_REQUEST_CODE);
        checkPermission(Manifest.permission.RECORD_AUDIO, RECORD_REQUEST_CODE);
        checkPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE, WRITE_REQUEST_CODE);
        spinn = findViewById(R.id.choose_printer);
        List<String> categories = new ArrayList<String>();
        categories.add(getString(R.string.epson_l415_text));
        categories.add(getString(R.string.canon_mg2410_text));
        categories.add(getString(R.string.hp_envy_7855));
        categories.add(getString(R.string.hp_deskjet_1115_blank));
        categories.add(getString(R.string.hp_deskjet_1115_text));




        ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, categories);
        dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinn.setAdapter(dataAdapter);

        // Example of a call to a native method
        tv = findViewById(R.id.results_text);
        pay = findViewById(R.id.payload_text);
        recording = findViewById(R.id.recording_status);

    }



    public void recordAudio(View view){
        if(! inUse) {
            Calendar c1 = Calendar.getInstance();
            Date dateOne = c1.getTime();
            filename = new File(getExternalFilesDir(Environment.DIRECTORY_MUSIC).toString() + '/' + "temp" + Long.toString(dateOne.getTime()) + ".m4a");

            Log.i("external", getExternalFilesDir(null).toString());

            int android_os = android.os.Build.VERSION.SDK_INT;

            if(android_os >= 26) {
                recorder = new MediaRecorder();
                recorder.setAudioSource(MediaRecorder.AudioSource.MIC);
                recorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
                recorder.setOutputFile(filename);
                recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
                recorder.setAudioSamplingRate(44100);
                recorder.setAudioEncodingBitRate(128000);
            }
            else {
                Log.i("android", Integer.toString(android_os));
                Toast.makeText(this, "API version should be >= 26", Toast.LENGTH_LONG);
                return;
            }

            inUse = TRUE;
            stopRecording = FALSE;
            tv.setText("");
            pay.setText("Recording");
            ExecutorService es = Executors.newFixedThreadPool(1);
            es.execute(new ProcessAudio(ProcessAudio.RECORD_PROCESS, (String) spinn.getSelectedItem()));
        }
    }

    public void stopRecording(View view){
        pay.setText("Processing");
        recorder.stop();
        recorder.reset();
        recorder.release();
        recorder = null;
        stopRecording = TRUE;

    }

    public void openFile(View view){
        if(! inUse) {
            inUse = TRUE;

            Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
            intent.addCategory(Intent.CATEGORY_OPENABLE);
            //intent.setType("audio/x-wav");
            //intent.setType("audio/mp4a-latm");
            intent.setType("audio/mpeg");
            startActivityForResult(intent, OPEN_REQUEST_CODE);
        }
    }



    public void recordProcessAudio(final String printer){

        try {
            recorder.prepare();
        } catch (IOException e) {
            Log.e("media", "prepare() failed");
        }

        recorder.start();

        while(! stopRecording);

        audioFile = filename;
        fileProcessAudio(printer);

    }



    public void fileProcessAudio(String printer){

        processSignal proc;


        //
        File f = audioFile;
        try {
            f = File.createTempFile("tmp", null, this.getCacheDir());

            extractor = new MediaExtractor();
            extractor.setDataSource(audioFile.getAbsolutePath());
            int tracs = extractor.getTrackCount();
            extractor.selectTrack(0);
            MediaFormat format = extractor.getTrackFormat(0);
            format.setInteger(MediaFormat.KEY_PCM_ENCODING, AudioFormat.ENCODING_PCM_FLOAT);
            String mime = format.getString(MediaFormat.KEY_MIME);
            mDecoder = MediaCodec.createDecoderByType("audio/mp4a-latm");
            mDecoder.configure(format, null, null, 0);
            mDecoder.start();


            MediaCodec.BufferInfo info = new MediaCodec.BufferInfo();
            readData(info, f);

        } catch(Exception e){
            Log.i("mediaCodec", "media");
        }
//
        Pair<Integer, Boolean> printer_info = printer2Class(printer);
        InputStream databaseInputStream = getResources().openRawResource(R.raw.samples);

        proc = new processSignalText(printer_info.first, f, databaseInputStream, printer_info.second);


        payload = proc.process();
        payload_sz = proc.getPayloadSize();
        //payload = obtainPayload(bits, PAYLOAD_SZ);
        Message message = new Message();
        // Set message type.
        message.what = MESSAGE_UPDATE_TEXT_CHILD_THREAD;
        // Send message to main thread Handler.
        updateUIHandler.sendMessage(message);

        Log.i("payload", payload);

    }

    public Pair<Integer,Boolean> printer2Class(String printer) {
        int printerclass = 0;
        boolean blank = false;

        if (printer.equals(getString(R.string.epson_l415_text)))
            printerclass = 2;
        else if (printer.equals(getString(R.string.canon_mg2410_text)))
            printerclass = 3;
        else if (printer.equals(getString(R.string.hp_deskjet_1115_text)) || printer.equals(getString(R.string.hp_deskjet_1115_blank))) {
            printerclass = 4;
            if (printer.equals(getString(R.string.hp_deskjet_1115_blank)))
                blank = true;
        } else if (printer.equals(getString(R.string.hp_envy_7855)))
            printerclass = 5;

        return new Pair<>(printerclass, blank);
    }



    //https://github.com/taehwandev/MediaCodecExample/blob/master/src/net/thdev/mediacodecexample/decoder/AudioDecoderThread.java
    //https://gist.github.com/a-m-s/1991ab18fbcb0fcc2cf9
    public ByteBuffer readData( MediaCodec.BufferInfo info, File file) throws IOException{
        boolean end_of_input_file = false;
        //BufferedWriter out = new BufferedWriter(new FileWriter(file));
        FileOutputStream out = new FileOutputStream(file);


        if (mDecoder == null)
            return null;

        while (!end_of_input_file) {
            // Read data from the file into the codec.

            int inputBufferIndex = mDecoder.dequeueInputBuffer(1000);
            if (inputBufferIndex >= 0) {
                ByteBuffer inputBuffer = mDecoder.getInputBuffer(inputBufferIndex);

                int size = extractor.readSampleData(inputBuffer, 0);
                if (size < 0) {
                    // End Of File
                    mDecoder.queueInputBuffer(inputBufferIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM);
                    end_of_input_file = true;
                } else {
                    mDecoder.queueInputBuffer(inputBufferIndex, 0, size, extractor.getSampleTime(), 0);
                    extractor.advance();
                }
            }




            int outputBufferIndex = mDecoder.dequeueOutputBuffer(info, 1000);
            switch (outputBufferIndex) {
                case MediaCodec.INFO_OUTPUT_FORMAT_CHANGED:
                    MediaFormat format = mDecoder.getOutputFormat();

                    break;
                case MediaCodec.INFO_TRY_AGAIN_LATER:
                    break;

                case MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED:
                    break;

                default:
                    ByteBuffer outBuffer = mDecoder.getOutputBuffer(outputBufferIndex);
                    MediaFormat bufferFormat = mDecoder.getOutputFormat(outputBufferIndex);

                    final byte[] chunk = new byte[info.size-info.offset];
                    //int a = outBuffer.position();
                    outBuffer.get(chunk); // Read the buffer all at once
                    outBuffer.clear(); // ** MUST DO!!! OTHERWISE THE NEXT TIME YOU GET THIS SAME BUFFER BAD THINGS WILL HAPPEN
                    out.write(chunk, 0, info.size - info.offset);

                    mDecoder.releaseOutputBuffer(outputBufferIndex, false);
                    break;
            }

            // All decoded frames have been rendered, we can stop playing now
            if ((info.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                Log.d("DecodeActivity", "OutputBuffer BUFFER_FLAG_END_OF_STREAM");
                break;
            }
        }
        mDecoder.stop();
        mDecoder.release();
        mDecoder = null;

        extractor.release();
        extractor= null;

        out.close();
        return null;

    }



    @Override
    public void onActivityResult (int requestCode, int resultCode, Intent resultData) {
        super.onActivityResult(requestCode, resultCode, resultData);

        if(resultCode == Activity.RESULT_OK){
            if(requestCode == OPEN_REQUEST_CODE){
                if(resultData != null){
                    tv.setText("");
                    pay.setText("Processing...");
                    String[] path = resultData.getData().getPath().split(":");
                    audioFile = new File("/storage/self/primary/" + path[1]);
                    //tv.setText(audioFile.toString());
                    ExecutorService es = Executors.newFixedThreadPool(1);
                    es.execute(new ProcessAudio(ProcessAudio.FILE_PROCESS, (String) spinn.getSelectedItem()));
                }
            }
            else if(requestCode == RECORD_REQUEST_CODE){
                ;
            }
        }
    }




    public void checkPermission(String permission, int requestCode){
        if(ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_DENIED){
            ActivityCompat.requestPermissions(this, new String[]{permission}, requestCode);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults){
        if(requestCode == STORAGE_REQUEST_CODE){
            if(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED){
                Toast.makeText(this, "Storage Permission Granted", Toast.LENGTH_SHORT);
            }
        }
    }


    class ProcessAudio implements Runnable{
        final static int FILE_PROCESS = 1;
        final static int RECORD_PROCESS = 2;
        int type;
        String printer;

        ProcessAudio(int type, String printer){
            this.type = type;
            this.printer = printer;
            new Thread(this);
        }
        public void run(){
            if(type == FILE_PROCESS)
                fileProcessAudio(printer);
            else if(type == RECORD_PROCESS)
                recordProcessAudio(printer);
            inUse = FALSE;
            num_lo = 0;
            num_hi = 0;
            res = 0;

        }
    }

    private void createUpdateUiHandler()
    {
        if(updateUIHandler == null)
        {
            updateUIHandler = new Handler()
            {
                @Override
                public void handleMessage(Message msg) {
                    // Means the message is sent from child thread.
                    if(msg.what == MESSAGE_UPDATE_TEXT_CHILD_THREAD)
                    {
                        // Update ui in main thread.
                        tv.setText(payload);
                        int ascii_sz = (int)payload.length()/7;
                        Log.i("ascii", Integer.toString(ascii_sz));
                        char c;
                        String text_payload = new String("");
                        for(int i=0; i < ascii_sz; i++){
                            c = (char) Integer.parseInt(payload.substring(i*7,i*7+7),2);
                            text_payload += c;
                        }
                        pay.setText(text_payload);
                    }
                }
            };
        }
    }





}

