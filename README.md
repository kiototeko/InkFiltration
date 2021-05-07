# InkFiltration: Using Inkjet Printers for Acoustic Data Exfiltration From Air-Gapped Networks

A covert channel can be established by leveraging the acoustic emissions of inkjet printers to exfiltrate information from an air-gapped network. In essence, malware installed on a computer with access to a printer can inject certain imperceptible patterns into all documents being sent to the printer, so as to control the printing process in such a way that an acoustic signal is generated which can be captured with a nearby smartphone.

The code consists of the follwing:

1. A series of programs used to inject the patterns into documents. These are located in the **patternInjection** directory.
1. The **receiver** code that was implemented both in MATLAB and for an Android app.

To download with the submodules use the next command: `git clone --recurse-submodules https://github.com/nesl/InkFiltration.git`

## Required packages

- For *patternInjection*:
  - poppler-utils
  - [pdftk](https://wilransz.com/pdftk-on-ubuntu-18-04/)
  - You will need both python 2 and 3, as python 2 is used with peepdf
  - pip install *opencv-python* and *numpy* if you want image functionality

## How to obtain the results shown in the paper

1. Download all the samples [here](https://drive.google.com/file/d/1t_86g_xM_IdVnexTRP-ofNn5NBgw28pK/view?usp=sharing). 

2. Extract the samples on *receiver/MATLAB/samples2/good/*

3. Run the MATLAB script *receiver/MATLAB/test.m*
  
## Procedure to add a new printer

### Trying existing parameters

- First of all, to add a new printer, you could try to test if the existing parameters defined for other printers work with it. For that you may print a page using one of these set of parameters and record the sounds for both the case were you have a blank page and were you have a page with text.

  - The program *patternInjection/randomBits.sh* is useful in this case. The next command to create a blank page with modulation for a desired printer (e.g. for an Epson printer): `./randomBits.sh -f Layouts/whitePages.pdf Epson_L4150 1`

  - Or to create a text page with modulation, you can use one of the layouts in the Layouts directory: `./randomBits.sh -f Layouts/simpleLayoutArial.pdf Epson_L4150 1`

  - Executing either command will result in two files: one text file containing the random bits used in the modulation, with a name like *Epson_L4150_9_1text_bits* in the *receiver/MATLAB/payloads/* directory. The other file will be a pdf file named *testPDF.pdf*: this file will be the one that should be printed.

- In Linux, when testing, printing should be made from the command line, as other programs may add some modifications to the pdf file that would render ineffective the modulation.

  - To print from command line you first need to get the printer's name, which can be retrieved by calling: `lpstat -e`. This will display a list of printers that have been configured in your system.

  - Search for the name of your desired printer, copy its name and use the next command to print the file: `lp -d PRINTER_NAME testPDF.pdf`. With this command you can specify the page range with the -P option, and the number of copies with the -n option.

- After recording the sound of the printer while printing, you can use the MATLAB program *receiver/MATLAB/testdemod.m* to inspect the waveform and spectrogram. This may be useful to see if the modulation is effective. Or you can directly call *receiver/MATLAB/processSignal.m*, where depending on how you name your audio recording, it will use certain parameters to process the signal (check file). 

- You may want to convert the sound file into .wav format by using for example: `ffmpeg -i filename.oldformat filename.newformat`

- Save the audio files in *receiver/MATLAB/samples2/*.

- For testing purposes you can record directly from your computer by using the following command: `arecord -t wav -c 1 -r 44100 -f S16_LE file.wav`

### Discovering new parameters

- If the previous parameters defined for other printers don't seem to be effective, you will need to define new ones. The program you will use to first find the rectangle width parameter is *patternInjection/raw_injection.sh*. It has already a predetermined yellow tint, but you can change it in the code. Use this program the following way: `./raw_injection.sh -r - -f Layouts/whitePages.pdf -w WIDTH`. This program creates also a file to be printed called *testPDF.pdf*. In WIDTH you should test different widths according to the procedure described on the paper:

    - First try a width that does not generate any intermediate paper displacements.
    - Increase it until a change on print mode is achieved.
    - Increase it even more until an extra paper displacement is generated.
    
- In the paper we talk about a transition width and a modulation width. Just take into account that you should not stop increasing the width after you increase the number of paper displacements two times or three, try to increase it at least 5 times, until you notice that the difference between widths is constant. Annotate this constant width and sum up all the other initial widths that are not equal to this constant width. That sum of initial widths is the transition width. 

- In *patternInjection/testPrinter.py*, you will find a section were you can start writing the parameters of the printer you are testing, inside the *printer_parameters* function. Start with the *rec_width* and *initial_offset*, which correspond to the modulation width and transition width respectively. The exact yellow tint *yellow_shade_text* can be found to use can be found by incrementing the value (where 1.0 is the maximum) before a change in the print mode is observed, which should already be very difficult if not invisible to the human eye. As will be apparent on the parameters, the rectangle's lenghts are not define by a single value, but by two: *rec_left_margin* refers to the position of the leftmost edge of the rectangle, while *rec_line_length* is the actual length. The second set of parameters *rec_left_margin2* and *rec_line_length2* refer to the short rectangle. This rectangle may be aligned to the left side or right side of the page, it depends on the resting position of the printhead, which you should observe when you print a document (to which position does it normally return?). *packet_size_text* refers to the number of bits to transmit, the number of data rectangles that fit in a page, *special_transition* is True when there is a requirement for buffering between large and short rectangles, buffering which can be controlled by *transition_factor*, where a lower factor means a greater buffer size, a parameter that can be ignored if *special_transition* is False. Finally *text_guard_init* and *guard_end* refer to the number of rectangles to use as padding at the beginning and end of a page, respectively. 

- To print a page use the program *patternInjection/raw_injection.sh* as, for example, `./raw_injection -f Layouts/simpleLayoutArial.pdf Epson_L4150 "101010010010"` to inject a specific bit payload into a page from the chosen Layout. A cool feature that has been added to this program is the capacity to output a representation of the pattern to be injected into the document, so as to get a sense of what you are doing. To activate this functionality, just add the *-I* flag when calling the program.

- Once you think you got correct all parameters, you can use the progam *patternInjection/randomBits.sh* with any quantity of pages to inject random patterns into them.


## Programs included in this repository

- As described above, all types of programs to obtain the necessary transmitter and receiver parameters, apply them and process the results are contained in *patternInjection* and *receiver/MATLAB* folders.

- An Android app is included in *receiver/PrinterLeaks* that does exactly the same as the MATLAB scripts.

- In *receiver/filter* both the actual implementation of a CUPS filter that injects the malicious patterns into documents and the filter that defends against this are included.
