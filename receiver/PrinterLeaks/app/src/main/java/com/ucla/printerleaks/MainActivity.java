package com.ucla.printerleaks;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.math.MathUtils;

import java.io.DataOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.concurrent.*;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaCodec;
import android.media.MediaFormat;
import android.media.MediaRecorder;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.os.SystemClock;
import android.util.Log;
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
    final int SAMPLE_SZ = 44100;
    static int num_lo = 0, num_hi = 0, res = 0;
    File filename;

    private final static int MESSAGE_UPDATE_TEXT_CHILD_THREAD =1;
    final String PREAMBLE = "1010";
    Boolean inUse = FALSE, stopRecording = FALSE;
    TextView tv, pay, recording;
    File audioFile;
    AudioRecord adr;
    String payload;
    int payload_sz;
    Spinner spinn;

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
        categories.add(getString(R.string.hp_photo_d110_blank));
        categories.add(getString(R.string.hp_photo_d110_text));
        categories.add(getString(R.string.epson_l415_blank));
        categories.add(getString(R.string.epson_l415_text));
        categories.add(getString(R.string.canon_mg2410_blank));
        categories.add(getString(R.string.canon_mg2410_text));




        ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, categories);
        dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinn.setAdapter(dataAdapter);

        // Example of a call to a native method
        tv = findViewById(R.id.results_text);
        pay = findViewById(R.id.payload_text);
        recording = findViewById(R.id.recording_status);

        Log.i("jkljk", Integer.toString(AudioRecord.getMinBufferSize(SAMPLE_SZ,AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT)));
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    //public native double[] getPeaksA(double[] a, double minH);

    public void recordAudio(View view){
        if(! inUse) {
            filename = new File(getExternalFilesDir(Environment.DIRECTORY_MUSIC).toString() + '/' + "temp");
            Log.i("external", getExternalFilesDir(null).toString());
            inUse = TRUE;
            stopRecording = FALSE;
            pay.setText("Recording");
            ExecutorService es = Executors.newFixedThreadPool(1);
            es.execute(new ProcessAudio(ProcessAudio.RECORD_PROCESS, spinn.getSelectedItemPosition()));
        }
    }

    public void stopRecording(View view){
        stopRecording = TRUE;
        pay.setText("Processing");
        /*
        recorder.stop();
        recorder.release();
        recorder = null;
        */
    }

    public void openFile(View view){
        if(! inUse) {
            inUse = TRUE;
            Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
            intent.addCategory(Intent.CATEGORY_OPENABLE);
            intent.setType("audio/x-wav");
            startActivityForResult(intent, OPEN_REQUEST_CODE);
        }
    }


    public void recordProcessAudioOld(final int printer){
        int android_os = android.os.Build.VERSION.SDK_INT;
        if(android_os >= 26) {
            recorder = new MediaRecorder();
            recorder.setAudioSource(MediaRecorder.AudioSource.MIC);
            recorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
            recorder.setOutputFile(filename);
            recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
            recorder.setAudioSamplingRate(44100);
            recorder.setAudioEncodingBitRate(128000);

            try {
                recorder.prepare();
            } catch (IOException e) {
                Log.e("media", "prepare() failed");
            }

            recorder.start();
        }
        while(! stopRecording);

        fileProcessAudio(printer);

    }
    public void recordProcessAudio(final int printer){
        FileOutputStream wavOut = null;
        AudioRecord adr = null;
        long startTime = 0;
        long endTime = 0;
        final int BUFFER_SIZE = AudioRecord.getMinBufferSize(SAMPLE_SZ,AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT);

        adr = new AudioRecord(MediaRecorder.AudioSource.MIC, SAMPLE_SZ, AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT, BUFFER_SIZE*4);
        try {
            wavOut = new FileOutputStream(filename);
            writeWavHeader(wavOut, AudioFormat.CHANNEL_IN_MONO, SAMPLE_SZ, AudioFormat.ENCODING_PCM_16BIT);
            // Avoiding loop allocations
            byte[] buffer = new byte[BUFFER_SIZE];
            boolean run = true;
            int read;
            long total = 0;

            // Let's go
            startTime = SystemClock.elapsedRealtime();
            adr.startRecording();
            while (! stopRecording) {
                read = adr.read(buffer, 0, buffer.length);

                // WAVs cannot be > 4 GB due to the use of 32 bit unsigned integers.
                if (total + read > 4294967295L) {
                    // Write as many bytes as we can before hitting the max size
                    for (int i = 0; i < read && total <= 4294967295L; i++, total++) {
                        wavOut.write(buffer[i]);
                    }
                    run = false;
                } else {
                    // Write out the entire read buffer
                    wavOut.write(buffer, 0, read);
                    total += read;
                }
            }
        } catch (IOException ex) {
            Log.i("Record", ex.getMessage());
        } finally {
            if (adr != null) {
                try {
                    if (adr.getRecordingState() == AudioRecord.RECORDSTATE_RECORDING) {
                        adr.stop();
                        endTime = SystemClock.elapsedRealtime();
                    }
                } catch (IllegalStateException ex) {
                    //
                }
                if (adr.getState() == AudioRecord.STATE_INITIALIZED) {
                    adr.release();
                }
            }
            if (wavOut != null) {
                try {
                    wavOut.close();
                } catch (IOException ex) {
                    //
                }
            }
        }

        try {
            // This is not put in the try/catch/finally above since it needs to run
            // after we close the FileOutputStream
            updateWavHeader(filename);
        } catch(Exception e){
            Log.i("Record", e.getMessage());
        }

        audioFile = filename;
        fileProcessAudio(printer);

    }



    public void fileProcessAudio(int printer){

        processSignal proc;

        //classification clas = new classification(this);
        //printer = Integer.parseInt(clas.classifyNoise(audioFile));

        //Log.i("printer", Integer.toString(printer));




        int printer2 = (int) Math.floor(printer/2.0)+1;
        int type = (int) printer % 2 + 1;
        InputStream databaseInputStream = getResources().openRawResource(R.raw.samples);
        if(type == 1)
            proc = new processSignalBlank(printer2, audioFile, databaseInputStream);
        else
            proc = new processSignalText(printer2, audioFile, databaseInputStream);

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




    @Override
    public void onActivityResult (int requestCode, int resultCode, Intent resultData) {
        super.onActivityResult(requestCode, resultCode, resultData);

        if(resultCode == Activity.RESULT_OK){
            if(requestCode == OPEN_REQUEST_CODE){
                if(resultData != null){
                    tv.setText("Processing...");
                    pay.setText("");
                    String[] path = resultData.getData().getPath().split(":");
                    audioFile = new File("/storage/self/primary/" + path[1]);
                    //tv.setText(audioFile.toString());
                    ExecutorService es = Executors.newFixedThreadPool(1);
                    es.execute(new ProcessAudio(ProcessAudio.FILE_PROCESS, spinn.getSelectedItemPosition()));
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
        int printer;

        ProcessAudio(int type, int printer){
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

    private static void writeWavHeader(OutputStream out, int channelMask, int sampleRate, int encoding) throws IOException {
        short channels;
        switch (channelMask) {
            case AudioFormat.CHANNEL_IN_MONO:
                channels = 1;
                break;
            case AudioFormat.CHANNEL_IN_STEREO:
                channels = 2;
                break;
            default:
                throw new IllegalArgumentException("Unacceptable channel mask");
        }

        short bitDepth;
        switch (encoding) {
            case AudioFormat.ENCODING_PCM_8BIT:
                bitDepth = 8;
                break;
            case AudioFormat.ENCODING_PCM_16BIT:
                bitDepth = 16;
                break;
            case AudioFormat.ENCODING_PCM_FLOAT:
                bitDepth = 32;
                break;
            default:
                throw new IllegalArgumentException("Unacceptable encoding");
        }

        writeWavHeader(out, channels, sampleRate, bitDepth);
    }

    /**
     * Writes the proper 44-byte RIFF/WAVE header to/for the given stream
     * Two size fields are left empty/null since we do not yet know the final stream size
     *
     * @param out        The stream to write the header to
     * @param channels   The number of channels
     * @param sampleRate The sample rate in hertz
     * @param bitDepth   The bit depth
     * @throws IOException
     */
    private static void writeWavHeader(OutputStream out, short channels, int sampleRate, short bitDepth) throws IOException {
        // Convert the multi-byte integers to raw bytes in little endian format as required by the spec
        byte[] littleBytes = ByteBuffer
                .allocate(14)
                .order(ByteOrder.LITTLE_ENDIAN)
                .putShort(channels)
                .putInt(sampleRate)
                .putInt(sampleRate * channels * (bitDepth / 8))
                .putShort((short) (channels * (bitDepth / 8)))
                .putShort(bitDepth)
                .array();

        // Not necessarily the best, but it's very easy to visualize this way
        out.write(new byte[]{
                // RIFF header
                'R', 'I', 'F', 'F', // ChunkID
                0, 0, 0, 0, // ChunkSize (must be updated later)
                'W', 'A', 'V', 'E', // Format
                // fmt subchunk
                'f', 'm', 't', ' ', // Subchunk1ID
                16, 0, 0, 0, // Subchunk1Size
                1, 0, // AudioFormat
                littleBytes[0], littleBytes[1], // NumChannels
                littleBytes[2], littleBytes[3], littleBytes[4], littleBytes[5], // SampleRate
                littleBytes[6], littleBytes[7], littleBytes[8], littleBytes[9], // ByteRate
                littleBytes[10], littleBytes[11], // BlockAlign
                littleBytes[12], littleBytes[13], // BitsPerSample
                // data subchunk
                'd', 'a', 't', 'a', // Subchunk2ID
                0, 0, 0, 0, // Subchunk2Size (must be updated later)
        });
    }

    /**
     * Updates the given wav file's header to include the final chunk sizes
     *
     * @param wav The wav file to update
     * @throws IOException
     */
    private static void updateWavHeader(File wav) throws IOException {
        byte[] sizes = ByteBuffer
                .allocate(8)
                .order(ByteOrder.LITTLE_ENDIAN)
                // There are probably a bunch of different/better ways to calculate
                // these two given your circumstances. Cast should be safe since if the WAV is
                // > 4 GB we've already made a terrible mistake.
                .putInt((int) (wav.length() - 8)) // ChunkSize
                .putInt((int) (wav.length() - 44)) // Subchunk2Size
                .array();

        RandomAccessFile accessWave = null;
        //noinspection CaughtExceptionImmediatelyRethrown
        try {
            accessWave = new RandomAccessFile(wav, "rw");
            // ChunkSize
            accessWave.seek(4);
            accessWave.write(sizes, 0, 4);

            // Subchunk2Size
            accessWave.seek(40);
            accessWave.write(sizes, 4, 4);
        } catch (IOException ex) {
            // Rethrow but we still close accessWave in our finally
            throw ex;
        } finally {
            if (accessWave != null) {
                try {
                    accessWave.close();
                } catch (IOException ex) {
                    //
                }
            }
        }
    }


}

