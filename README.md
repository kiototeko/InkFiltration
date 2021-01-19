# InkFiltration: Using Inkjet Printers for Acoustic Data Exfiltration from Air-Gapped Networks

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

## Procedure to add a new printer

### Trying existing parameters

- First of all, to add a new printer, you could try to test if the existing parameters defined for other printers work with it. For that you may print a page using one of these set of parameters and record the sounds for both the case were you have a blank page and were you have a page with text.

  - Use the next command to create a blank page with modulation for a desired printer (e.g. for an HP printer): `./randomBits.sh HP_Photosmart_D110 1`

  - Or to create a text page with modulation, you can use one of the layouts in the Layouts directory: `./randomBits.sh -tf Layouts/simpleLayoutArial.pdf HP_Photosmart_D110 1`

  - Executing either command will result in two files: one text file containing the random bits used in the modulation, with a name like *HP_Photosmart_D110_251_bits* or *HP_Photosmart_D110_101text_bits* respectively. The other file will be a pdf file named *testPDF.pdf*: this file will be the one that should be printed.

- In Linux, when testing, printing should be made from the command line, as other programs may add some modifications to the pdf file that would render ineffective the modulation.

  - To print from command line you first need to get the printer's name, which can be retrieved by calling: `lpstat -e`. This will display a list of printers that have been configured in your system.

  - Search for the name of your desired printer, copy its name and use the next command to print the file: `lp -d PRINTER_NAME testPDF.pdf`. With this command you can specify the page range with the -P option, and the number of copies with the -n option.

- After recording the sound of the printer while printing, you can use the MATLAB program *receiver/MATLAB/testdemod.m* to inspect the waveform and spectrogram. This may be useful to see if the modulation is effective.

- You may want to convert the sound file into .wav format by using for example: `ffmpeg -i filename.oldformat filename.newformat`

- Save the audio files in *receiver/MATLAB/samples2/*.

- For testing purposes you can record directly from your computer by using the following command: `arecord -t wav -c 1 -r 44100 -f S16_LE file.wav`

### Discovering new parameters

- If the previous parameters defined for other printers don't seem to be effective, you will need to define new ones. As there are two different modulations, two different procedures are defined. The program you will use to define the parameters is in *patternInjection/testPrinter.py*. In this program there is a template in *printer_parameters* function that you will use to define the parameters for your new printer. You can start with the predefined parameters and adjust them later. 

- To print a page use the program *patternInjection/raw_injection.sh* as explained below. A cool feature that has been added to this program is the capacity to output a representation of the pattern to be injected into the document, so as to get a sense of what you are doing. To activate this functionality, just add the *-I* flag when calling the program.

- To aide you through this testing procedure, you may want to record the sound with your smartphone so that you can inspect the recording immediately as many times as you want and notice the patterns. 

- Finally, you may want to use the script *receiver/MATLAB/testdemod.m* to test the receiver side parameters through all this process, placing your audio files in *receiver/MATLAB/samples2/*.

#### Testing algorithm for DPPM (blank pages):

1. Open the *patternInjection/testPrinter.py* file and go to the definition of the *printer_parameters* function, which contains all pertinent parameters. 
  - Two parameters are important at first, *line_offset* and *yellow_shade_blank*. The first printing tests should try to print sequences of lines and see if the number of roller sounds the printer makes is equivalent to the number of lines drawn in the page document (just take into account that the first and last lines may not generate the same sound because of their proximity to the initial and final random sounds the printer makes). A sequence like **111111** or **000000** may be good enough to determine this. It should be noticed that in this step you shouldn't try at first to use the lightest yellow shade as that may not be recognized by the printer (a *yellow_shade_blank* of **0.9** or less should be fine). 
  - Then, if the number of lines doesn't correspond to the number of sounds, you should try to increase the line offset with the *line_offset* parameter. If your line offset is sufficient, you may try decreasing it until you find its lower limit, the same with the yellow shade value, you may increase it until you see the printer stops recognizing the lines. Just remember that decreasing the offset size may also attenuate the sound, so to take this into account.

2. Once you have the correct offset and color, you should try printing patterns like **1010110101**, which should result in a combination of short and large delays in the sound pulses. It should be noted that you should try both **10** and **01** patterns as there may be some issues when changing the bit order. If this results in problems, you may try changing the *short_alignment* parameter towards either **right**, **center**, or **left**, as this aligns the short lines towards a respective side.

3. You may want to play with the *line_length* parameter so as to produce the maximum difference in time between pulses by combining the shortest line possible with the longest line possible. Finally, you may want to add a buffer line both at the start of the page (*guard_init*) as well as at the end (*guard_end*) to isolate the pulse sounds from the random sounds the printer makes at start and end. It may also work for you to change the vertical starting point in the page by modifying the *blank_total* parameter.

4. Calculating the packet size (*packet_size_blank*) is just a matter of counting the number of lines that you are able to inject into the document without bypassing the page's margins (remember that the lower limit is **9**).

#### Testing algorithm for FPM-DPPM (text pages):

1. Open the *patternInjection/testPrinter.py* file and go to the definition of the *printer_parameters* function, which contains all pertinent parameters. 
  - You may want to start with a relatively large rectangle width (*rec_width* of maybe **50** or **100**) and print a bit sequence like **101010** and see if a frequency change occurs. You should also try this procedure with a not so light yellow shade (*yellow_shade_text* of **0.9** or less). 
  - After this you should try to reduce the rectangle width to its minimum. For this point it is recommended to use the blank file *Layouts/whitePages.pdf*, example: `./raw_injection.sh -tf Layouts/whitePages.pdf HP_Deskjet_1115 "101010101010"`

2. Because this type of modulation is supposed to be used with text documents, and blank documents might produce other behaviours, if somehow the previous procedure didn't produce any change, don't worry. Either way you should now try with a text document. You may repeat the above procedure again. 
  - You can start by printing a pattern like **11111** and see if there is small frequency change between rectangle printing. If you only hear a constant roller frequency that may mean that the spacing between rectangles is not enough. To modify this spacing, you should try to use both the *cluster_width_after_rec* and *cluster_lines_after_rec* parameters, which modify both the space after rectangles and the number of lines to insert as a buffer. You should note that inserting too many lines as buffer might be counterproductive, maybe start with **0** as the value for that parameter. There should be a least a sound pulse between rectangle sounds so as to ascertain the separation between rectangles. 
  - After these parameters are found, you should now test with a pattern like **101010** and make sure that a zero corresponds at least with two pulses (in contrast to one pulse that serves as separation between rectangles), by modifying the *cluster_width* and *cluster_lines* parameters that modify the space allocated to zeroes and the number of buffer lines used, respectively. 
  - Finally, you should test to see that a pattern like **0000** works. There is a trick you can do so as to lower the blackness of the text in the document and enhance the potential of the patterns by specifying the -b flag while using the *patternInjection/raw_injection.sh* program. Another trick you can use is to reduce the length of the cluster lines so as to make them encompass only the same space as the text in the document, by modifying the *cluster_left_margin* and *cluster_line_length* parameters (by using **56.8** and **500** as values respectively, for example).

3. Once you can achieve the same frequency effect with text documents, you may want to add cluster lines and test the modulation in text documents with blank gaps in them, to see if it is robust to those spacings (you may also want to test it again on a blank page). Now, at this point you may want to make sure the next patterns are also handled well: **111**, **000**, and derived variations. At this point you may need further parameter adjustment by utilizing both the *cluster_width_after_rec* and *cluster_lines_after_rec* parameters, which are bit sequence dependent. The first one modifies the buffer cluster lines introduced after every rectangle and the second one modifies the number of lines in this cluster. This is important specially when you have continous rectangles, as each of this should be separated by a cluster of lines to ensure they produce independent sounds. For this part you may already want to use the MATLAB scripts to find the time offset between pulses and analyze the waveform. There is also *custom_space_rules_rec* parameter which gives you a finer control on the space following a rectangle and the *extra_cluster_line* parameter for controlling the space following a cluster of lines.
