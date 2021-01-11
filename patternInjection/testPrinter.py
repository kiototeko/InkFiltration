#!/usr/bin/env python

import sys, getopt, math
import numpy as np

image_array = np.full((790, 612, 3), 255, dtype = np.uint8) 
        
def add_shape(x, y, width, height):
    global image_array
    
    print("%.2f %.2f %i %i re" %(x, y, width, height))
    
    if(y > 0):
        y_index = int(round(800-y))
        x = int(x)
        image_array[y_index-int(height):y_index, x:x+int(width),:] = (0,200,255)
        
def blank(parameters, packet):
        global total, max_length
        offset = parameters['line_offset'] #offset between lines, the unit is points
        length = parameters['line_length'] #length of the short line, the length of the long line is supposed to be the largest possible in a letter sized page (594)

        if('blank_total' in parameters):
                total = parameters['blank_total']
                
        short_alignment = parameters['short_alignment'] #The short line can be aligned to the 'center', 'left' or 'right'

        
        if(short_alignment == "left"):
                left_margin = 9
        elif(short_alignment == "center"):
                left_margin = int((max_length+9-length)/2)
        elif(short_alignment == "right"):
                left_margin = max_length+9 - length
                
                
        guard_init = parameters['guard_init'] #Modulation may require an initial line that separates the data transmission from the initial printer procedures. You can specify how many initial lines to separate your data lines.
        
        if(guard_init > 0):
                for i in range(guard_init):
                        add_shape(9, total, max_length, 1)
                        total -= offset
                
        for bitidx in packet:

                if(not int(bitidx)):
                                add_shape(left_margin, total, length, 1)
                else:
                        add_shape(9, total, max_length, 1)
                
                total -= offset
                
        if(parameters['guard_end']):
                add_shape(9, total, max_length, 1)#A final "guard" line is added so as to make sure the last time offset falls between individual roller pulses and not with respect to the random noises that the printer makes when it finishes printing a page
        
def text(parameters, packet):
        global total, max_length
        rec_width = parameters['rec_width'] #Rectangle width
        cluster_width = parameters['cluster_width']  #Cluster of lines total width
        cluster_lines = parameters['cluster_lines'] #Number of cluster lines
        cluster_width_after_rec = parameters['cluster_width_after_rec'] #Cluster of lines total width after a rectangle is drawn (special case)
        cluster_lines_after_rec = parameters['cluster_lines_after_rec'] #Number of cluster lines after a rectangle is drawn (special case)
        cluster_left_margin = parameters['cluster_left_margin'] #Cluster of lines left margin
        cluster_line_length = parameters['cluster_line_length'] #Cluster of lines length
        
        custom_space_rules_rec = parameters['custom_space_rules_rec'] #If you need more control over spacing when dealing with different bit sequences
        extra_cluster_line = parameters['extra_cluster_line'] #If you need to add an extra line in some conditions


        if('text_total' in parameters):
                total = parameters['text_total']

        for j,bitidx in enumerate(packet):

                if(not int(bitidx)):
                        add_shape(cluster_left_margin, total, cluster_line_length, 1)
                        total -= cluster_width/(cluster_lines+1)
                        for i in range(cluster_lines):
                                add_shape(cluster_left_margin, total, cluster_line_length, 1)
                                total -= cluster_width/(cluster_lines+1)
                        
                        if(extra_cluster_line):
                                if(j > 0 and not int(packet[j-1])): #An extra line is drawn when a cluster of lines precedes the actual cluster of lines, e.g., bit sequence 0-0
                                        add_shape(cluster_left_margin, total, cluster_line_length, 1)
                                        total -= cluster_width/(cluster_lines+1)
                else:

                        total -= rec_width
                        add_shape(9, total, 594, rec_width)
                        
                        cluster_width_after_rec_tmp = cluster_width_after_rec
                        
                        if(custom_space_rules_rec):
                                if(j + 1 < len(packet)-1 and not int(packet[j+1])): #Space is modified according to whether a rectangle follows another rectangle or a cluster of lines follow a rectangle, e.g., bit sequence 1-1 or 1-0 respectively
                                        cluster_width_after_rec_tmp += 2
                                else:
                                        cluster_width_after_rec_tmp += 10
                       
                        total -= cluster_width_after_rec_tmp/(cluster_lines_after_rec+1)
                        for i in range(cluster_lines_after_rec):
                                        add_shape(cluster_left_margin, total, cluster_line_length, 1)
                                        total -= cluster_width_after_rec_tmp/(cluster_lines_after_rec+1)

                
        total -= rec_width
        if(parameters['guard_end']):
                add_shape(9, total, max_length, rec_width)
        
def SweepOffset(parameters):
        global total
        lower_margin = 10.0

        offset = parameters['line_offset']
        total -= offset

        while total > lower_margin:
        
                add_shape(9, total, 594, 1)
                total -= offset
                offset += 2
                
def SweepLength(parameters):
        global total
        offset = 28.0 #Same offset for all printers
        lower_margin = 10.0
        line_size = 594.0
        start = 9.0
        packet_size = int(math.floor((total - lower_margin)/offset))
        line_decrement = math.floor(line_size/packet_size)

        if(parameters['name'] == "Canon_MG2410" or parameters['name'] == "HP_Photosmart_D110"):
                total -= offset

        for i in range(packet_size):
                add_shape(start, total, line_size, 1)
                total -= offset
                line_size -= line_decrement

                if(parameters['name'] == "HP_Photosmart_D110"):
                        start += line_decrement/2
                elif(parameters['name'] == "Epson_L4150"):
                        start += line_decrement


def printer_parameters(key): #Remember to define your printer name below in printer_name_list
         
        global total
        parameters = {}
        
        if(key == 0): #Canon_MG2410
        
                parameters['guard_end'] = True
        
                #Text
                parameters['rec_width'] = 42.0
                parameters['cluster_width'] = 28.0
                parameters['cluster_lines'] = 1
                parameters['cluster_width_after_rec'] = 28.0
                parameters['cluster_lines_after_rec'] = 1
                parameters['cluster_left_margin'] = 9
                parameters['cluster_line_length'] = 594
                parameters['custom_space_rules_rec'] = False
                parameters['extra_cluster_line'] = True
                parameters['yellow_shade_text'] = 0.94
                parameters['packet_size_text'] = 11
                
                #Blank        
                parameters['line_length'] = 10
                parameters['line_offset'] = 27.0 #Could be adjusted to 21.0
                parameters['short_alignment'] = "left"
                parameters['guard_init'] = 1
                parameters['blank_total'] = 781
                parameters['yellow_shade_blank'] = 0.94
                parameters['packet_size_blank'] = 25
                
        elif(key == 1): #Epson_L4150
        
                parameters['guard_end'] = True
                
                #Text
                parameters['rec_width'] = 24.0
                parameters['cluster_width'] = 42.0
                parameters['cluster_lines'] = 3
                parameters['cluster_width_after_rec'] = 42.0
                parameters['cluster_lines_after_rec'] = 3
                parameters['cluster_left_margin'] = 56.8
                parameters['cluster_line_length'] = 500
                parameters['custom_space_rules_rec'] = False
                parameters['extra_cluster_line'] = False
                parameters['yellow_shade_text'] = 0.99
                parameters['packet_size_text'] = 12
                
                #Blank        
                parameters['line_length'] = 50
                parameters['line_offset'] = 24.0
                parameters['short_alignment'] = "right"
                parameters['guard_init'] = 0
                parameters['yellow_shade_blank'] = 0.97
                parameters['packet_size_blank'] = 32
                
        elif(key == 2): #HP_Photosmart_D110
        
                parameters['guard_end'] = True
                
                #Text
                parameters['rec_width'] = 25.0
                parameters['cluster_width'] = 32.0
                parameters['cluster_lines'] = 10
                parameters['cluster_width_after_rec'] = 21.0
                parameters['cluster_lines_after_rec'] = 5
                parameters['cluster_left_margin'] = 9
                parameters['cluster_line_length'] = 594
                parameters['custom_space_rules_rec'] = True
                parameters['extra_cluster_line'] = False
                parameters['yellow_shade_text'] = 0.99
                parameters['packet_size_text'] = 15
        
                #Blank        
                parameters['line_length'] = 100
                parameters['line_offset'] = 25.0
                parameters['short_alignment'] = "center"
                parameters['guard_init'] = 0
                parameters['yellow_shade_blank'] = 0.99
                parameters['packet_size_blank'] = 30
                
        elif(key == 3): #HP_Deskjet_1115
        
                parameters['guard_end'] = False
                
                #Text
                parameters['rec_width'] = 25 #minimum 25
                parameters['cluster_width'] = 45#45.0 #50.0
                parameters['cluster_lines'] = 3
                parameters['cluster_width_after_rec'] = 50#50#75.0
                parameters['cluster_lines_after_rec'] = 0
                parameters['cluster_left_margin'] = 9#56.8
                parameters['cluster_line_length'] = 594#500
                parameters['custom_space_rules_rec'] = False
                parameters['extra_cluster_line'] = False
                parameters['yellow_shade_text'] = 0.98 
                parameters['packet_size_text'] = 15
                #parameters['text_total'] = 700
        
                #Blank        
                parameters['line_length'] = 10
                parameters['line_offset'] = 25.0
                parameters['short_alignment'] = "center"
                parameters['guard_init'] = 2
                parameters['yellow_shade_blank'] = 0.98
                parameters['packet_size_blank'] = 29 #Not sure about this one, still needs testing
               
        """ 
        Template for new printers, add your printer name in printer_name_list
       
        elif(key == 4): #Printer name
        
                parameters['guard_end'] = True
                
                #Text
                parameters['rec_width'] = 25.0
                parameters['cluster_width'] = 32.0
                parameters['cluster_lines'] = 10
                parameters['cluster_width_after_rec'] = 21.0
                parameters['cluster_lines_after_rec'] = 5
                parameters['cluster_left_margin'] = 9
                parameters['cluster_line_length'] = 594
                parameters['custom_space_rules_rec'] = False
                parameters['extra_cluster_line'] = False
                parameters['yellow_shade_text'] = 0.99
                parameters['packet_size_text'] = 15
        
                #Blank        
                parameters['line_length'] = 100
                parameters['line_offset'] = 25.0
                parameters['short_alignment'] = "center"
                parameters['guard_init'] = 0
                parameters['yellow_shade_blank'] = 0.99
                parameters['packet_size_blank'] = 30
        """
                
        return parameters
        
def get_parity_bit(pattern):
        parity = 0
        for i,bitidx in enumerate(pattern):
                parity += int(bitidx)
                
                if(i == len(pattern)-1):
                        parity %= 2

        return parity


textmod = False
raw_mode = False
info_bits = False
show_image = False
printer_name_list = ['Canon_MG2410', 'Epson_L4150', 'HP_Photosmart_D110', 'HP_Deskjet_1115'] #Add your printer name here

if len(sys.argv) < 2:
        print("Usage: testPrinter.py [OPTIONS] printer_name")
        print("Use this function to generate a bit pattern to inject into a PDF document. By default it prints non-text modulation, use -t otherwise. ")
        print("Current defined printers: ", printer_name_list)
        print("Possible options\n -p [arg] : use provided bit pattern\n -t : specify text modulation\n -s : line length sweep\n -S : offset sweep\n -i : display number of bits for specified printer\n -l : displays current defined printers\n -r : raw mode, used to specify bit patterns of any size without respecting established packet sizes")
        exit()
        
if("-l" in sys.argv): #Special option
        print(printer_name_list)
        exit()


name = sys.argv[-1]

if(name not in printer_name_list):
        print("(ERROR) Printer has not been implemented. Current printer list:", printer_name_list)
        exit(1)


parameters = printer_parameters(printer_name_list.index(name))
parameters['name'] = name

total = 783.0 
"""
total is the upper vertical margin limit in the page, it depends on the size of the page, in this case it is for letter size
For a paper page in portrait mode, the x scale starts at the left edge and the y scale starts at the bottom of the page
It is important to check if the printer doesn't skip the first line or rectangle, for this modifying the total to be lower might help, or putting a "guard" line or rectangle first in the page that won't be part of the packet, just to make place for the next lines or rectangles.
"""

pattern = "1110001010111001001011010010111001001001" #Bit sequence example
preamble = "1010" #Preamble to all packets
max_length = 594 #Maximum line length with respect to the width of the page and its margins

opts, args = getopt.getopt(sys.argv[1:], "SsiItrp:")
for opt, arg in opts:
        if opt == '-t':
                textmod = True
        elif opt == '-p':
                pattern = list(arg)
        elif opt == '-r':
                raw_mode = True
        elif opt == '-i':
                info_bits = True
        elif opt == '-I':
                show_image = True
        elif opt == '-s':
                yellow_shade = parameters['yellow_shade_blank']
                print("q\n1.0 1.0", yellow_shade, "rg")
                SweepLength(parameters)
                print("f\nQ\n")
                exit()
        elif opt == '-S':
                yellow_shade = parameters['yellow_shade_blank']
                print("q\n1.0 1.0", yellow_shade, "rg")
                SweepOffset(parameters)
                print("f\nQ\n")
                exit()
                
                
if(info_bits):
        if(textmod):
                print(parameters['packet_size_text']-5)
        else:
                print(parameters['packet_size_blank']-5)
        exit()



if(textmod):
        
        yellow_shade = parameters['yellow_shade_text'] #this can go from 0 to 1.0, where 0 is completly yellow and 1.0 absence of yellow
        print("q\n1.0 1.0", yellow_shade, "rg") 
        
        if(not raw_mode):
                sz = parameters['packet_size_text']
                if(len(pattern) < sz-5):
                        print("(ERROR) Bit pattern should be greater than:", sz)
                        exit(1)
                parity = get_parity_bit(pattern[0:sz-5])
                text(parameters, preamble + pattern[0:sz-5] + str(parity))
        else:
                text(parameters, pattern)
else:
        
        yellow_shade = parameters['yellow_shade_blank']
        print("q\n1.0 1.0", yellow_shade, "rg")
        
        if(not raw_mode):
                sz = parameters['packet_size_blank']
                if(len(pattern) < sz-5):
                        print("(ERROR) Bit pattern should be greater than:", sz)
                        exit(1)
                parity = get_parity_bit(pattern[0:sz-5])
                blank(parameters, preamble + pattern[0:sz-5] + str(parity))
        else:
                blank(parameters, pattern)

print("f\nQ\n")




if(show_image):

    
    from os import environ
    import cv2

    environ["QT_DEVICE_PIXEL_RATIO"] = "0"
    environ["QT_AUTO_SCREEN_SCALE_FACTOR"] = "1"
    environ["QT_SCREEN_SCALE_FACTORS"] = "1"
    environ["QT_SCALE_FACTOR"] = "1"

    cv2.imshow("Pattern", image_array)
    
    while True:
        key = cv2.waitKey(1)
        if key > 0:
            break
    cv2.destroyAllWindows()




