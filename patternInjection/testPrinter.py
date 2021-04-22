#!/usr/bin/env python

import sys, getopt, math
import numpy as np

image_array = np.full((790, 612, 3), 255, dtype = np.uint8) 
        
def add_shape(x, y, width, height):
    global image_array
    
    print("%.2f %.2f %i %.2f re" %(x, y, width, height))
    
    """
    if width < 100:
        print("%.2f %.2f %i %.2f re" %(x, y, width, height))
    else:
        print("9 %.2f 10 %.2f re" %(y, height))
        print("583 %.2f 20 %.2f re" %(y, height))
    """
    
    
    if(y > 0):
        y_index = int(round(800-y))
        x = int(x)
        image_array[y_index-int(height):y_index, x:x+int(width),:] = (0,200,255)
        
def add_defense():
    add_shape(9, 9, 3, 783)
    add_shape(600, 9, 3, 783)
        
def add_line_rectangle(x, width, height, num_lines):
        global total
        
        add_shape(x, total, width, 1)
        total -= height/(num_lines+1)
        for i in range(num_lines):
                add_shape(x, total, width, 1)
                total -= height/(num_lines+1)
        add_shape(x, total, width, 1)
        

def to_manchester(pattern):
        
        new_pattern = ""
        for i in pattern:
                if(int(i)):
                        new_pattern += "01"
                else:
                        new_pattern += "10"
                        
        return new_pattern
        
        
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
        
        
        text_guard_init = parameters['text_guard_init'] #Extra element at the beginning of the page
        guard_end = parameters['guard_end'] #Extra element at the end of the page
        initial_offset = parameters['initial_offset']
        special_transition = parameters['special_transition']
        if(special_transition):
                transition_factor = parameters['transition_factor']
        rec_width = parameters['rec_width'] #Rectangle width
        rec_left_margin = parameters['rec_left_margin'] #Rectangle left margin
        rec_line_length = parameters['rec_line_length'] #Rectangle length
        rec_left_margin2 = parameters['rec_left_margin2'] #Rectangle left margin
        rec_line_length2 = parameters['rec_line_length2'] #Rectangle length


        if('text_total' in parameters):
                total = parameters['text_total']
                
        packet = "1"*text_guard_init + packet + "1"*guard_end
                
        for j,bitidx in enumerate(packet):
                        

                if(not int(bitidx)):
                                
                        total -= rec_width
                        add_shape(rec_left_margin2, total, rec_line_length2, rec_width)
                                        #add_shape(300, total, 1, rec_width2)
                                                
                
                else:
                       
                        #For Canon, problems when there is no initial padding
                        if(special_transition and j + 1 < len(packet) and packet[j:j+2] == "10" and j):
                                
                                total -= rec_width/2.0
                                add_shape(rec_left_margin, total, rec_line_length, rec_width/2.0)
                                total -= rec_width/transition_factor
                                add_shape(rec_left_margin2, total, rec_line_length2, rec_width/transition_factor)          
                                
                                continue
                        
                        if(j == 0):
                                total -= initial_offset#91.4#20.04
                                add_shape(rec_left_margin, total, rec_line_length, initial_offset)# 91.4)#20.04) 
                        else:
                                total -= rec_width
                                add_shape(rec_left_margin, total, rec_line_length, rec_width)
                                
                                
        
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
                        
def SweepColor():
        global total
        step_size = round(1/(total - 9),4) #To include zero
        
        yellow_shade = 0
        for i in range(int(total)-9):
                print("1.0 1.0", round(yellow_shade,4), "rg") 
                #print(round(yellow_shade,4), "g") 
                add_shape(9, total, 594, 1)
                print("f")
                yellow_shade += step_size
                total -= 1
                
                if(yellow_shade > 1):
                        break
                
def SweepTriangle(left=True):
        global total
        
        line_length = 594
        step_size = round(line_length/(total - 9),4)
        
        for i in range(int(total)-9):
                if(left):
                        line_start = 9
                else:
                        line_start = 9 + (594-round(line_length,4))
                add_shape(line_start, total, round(line_length,4), 1)
                line_length -= step_size
                total -= 1
                
                if(line_length < 1):
                        break
                
def testLength(parameters):
        global total
        line_length = 594
        factor = parameters['rec_line_length2']
        margin = parameters['rec_left_margin2']
        
        step_size = math.floor((total-9)/5)
        
        print("q\n1.0 1.0", 0, "rg")
        total -= step_size
        add_shape(9, total, line_length, step_size)
        print("f\n")
        print("1.0 1.0", parameters['yellow_shade_text'], "rg")
        total -= step_size
        if(margin > 250):
            add_shape(9+line_length-factor, total, factor, step_size)
        else:
            add_shape(9, total, factor, step_size)
        print("f\nQ\n")
        """
        total -= parameters['initial_offset'] + parameters['rec_width']
        add_shape(9, total, line_length, parameters['initial_offset'] + parameters['rec_width'])
        
        step_size = parameters['rec_width']*10
        
        #for i in range(2):
        total -= step_size
        line_length -= factor
        add_shape(9+factor, total, line_length, step_size)
        """
        


def printer_parameters(key): #Remember to define your printer name below in printer_name_list
         
        global total
        parameters = {}
        
        if(key == 0): #Canon_MG2410
                
        
                
                parameters['guard_end'] = 1
                
                #Text
                parameters['rec_width'] = 38.4#33#33#35.0 Cambiar a menos
                parameters['rec_left_margin'] = 9
                parameters['rec_line_length'] = 594
                parameters['rec_left_margin2'] = 590 #550
                parameters['rec_line_length2'] = 13 #53
                parameters['initial_offset'] = 21.12#20.04
                parameters['special_transition'] = False
                parameters['yellow_shade_text'] = 0.94
                parameters['packet_size_text'] = 14#11
                parameters['text_guard_init'] = 1 #cambie esto add more??
                parameters['transition_factor'] = 2.0
                
                

                
                #Blank        
                parameters['line_length'] = 10
                parameters['line_offset'] = 27.0 #Could be adjusted to 21.0
                parameters['short_alignment'] = "left"
                parameters['guard_init'] = 1
                parameters['blank_total'] = 781
                parameters['yellow_shade_blank'] = 0.94
                parameters['packet_size_blank'] = 25
                
        elif(key == 1): #Epson_L4150
        
        
                parameters['guard_end'] = 1
                
                #Text
                parameters['rec_width'] = 46.4#23.2#35#33#35.0
                parameters['rec_left_margin'] = 9
                parameters['rec_line_length'] = 594
                parameters['rec_left_margin2'] = 9 #550
                parameters['rec_line_length2'] = 3 #53
                parameters['initial_offset'] = 45
                parameters['special_transition'] = False#True
                parameters['yellow_shade_text'] = 0.99
                parameters['packet_size_text'] = 14#11
                parameters['text_guard_init'] = 1
                parameters['transition_factor'] = 2.0
                #parameters['text_total'] = 600

                
                #Blank        
                parameters['line_length'] = 50
                parameters['line_offset'] = 24.0
                parameters['short_alignment'] = "right"
                parameters['guard_init'] = 0
                parameters['yellow_shade_blank'] = 0.97
                parameters['packet_size_blank'] = 32
                
        elif(key == 2): #HP_Photosmart_D110
            
                parameters['guard_end'] = 1
                
                #Text
                parameters['rec_width'] = 16.08#8.04#32.16
                parameters['rec_left_margin'] = 9
                parameters['rec_line_length'] = 594
                parameters['rec_left_margin2'] = 590#600#583#601#560
                parameters['rec_line_length2'] = 10#20#2#43
                parameters['initial_offset'] = 25.56#79#67.6#30.73
                parameters['special_transition'] = False
                parameters['yellow_shade_text'] = 0
                parameters['packet_size_text'] = 20
                parameters['text_guard_init'] = 1 #2
                parameters['transition_factor'] = 1.0
        
                """
                parameters['guard_end'] = True
                
                #Text
                parameters['use_rectangles'] = False
                parameters['cluster_width2'] = 28#30#25#25#30#34 #28
                parameters['cluster_lines2'] = 15 #16 #12
                parameters['cluster_left_margin2'] = 9
                parameters['cluster_line_length2'] = 594
                parameters['cluster_width'] = 42#45
                parameters['cluster_lines'] = 12#19#12#14#5#14#15#15
                parameters['cluster_left_margin'] = 400
                parameters['cluster_line_length'] = 1
                parameters['yellow_shade_text'] = 0.99#0.98 
                parameters['extra_cluster_line'] = False
                parameters['packet_size_text'] = 10#9#8#10
                #parameters['text_total'] = 700 #750
                parameters['text_guard_init'] = 0
                

        
                #Blank        
                parameters['line_length'] = 100
                parameters['line_offset'] = 25.0
                parameters['short_alignment'] = "center"
                parameters['guard_init'] = 0
                parameters['yellow_shade_blank'] = 0.99
                parameters['packet_size_blank'] = 30
                """
                
        elif(key == 3): #HP_Deskjet_1115
        
        
                parameters['guard_end'] = 1
                
                #Text
                parameters['rec_width'] = 22.8#11.4
                parameters['rec_left_margin'] = 9
                parameters['rec_line_length'] = 594
                parameters['rec_left_margin2'] = 560#583#601#560
                parameters['rec_line_length2'] = 43#20#2#43
                parameters['initial_offset'] = 30.72#79#67.6#30.73
                parameters['special_transition'] = True
                parameters['yellow_shade_text'] = 0.98
                parameters['packet_size_text'] = 16#20#20#20
                parameters['text_guard_init'] = 2 #2
                parameters['transition_factor'] = 1.0
        

                
                
                #Blank        
                parameters['line_length'] = 10
                parameters['line_offset'] = 25.0
                parameters['short_alignment'] = "center"
                parameters['guard_init'] = 2
                parameters['yellow_shade_blank'] = 0.98
                parameters['packet_size_blank'] = 29 #Not sure about this one, still needs testing
                
        elif(key == 4): #HP_Envy
        
                parameters['guard_end'] = 1
        
                #Text
                parameters['use_rectangles'] = True
                parameters['use_only_rectangles'] = True
                parameters['rec_width'] = 24#25#30#35.0
                parameters['rec_left_margin'] = 9
                parameters['rec_line_length'] = 594
                parameters['rec_width2'] = 100#95#90#60.0
                parameters['rec_left_margin2'] = 590 #550
                parameters['rec_line_length2'] = 13 #53

                parameters['yellow_shade_text'] = 0.98
                parameters['packet_size_text'] = 10#11
                parameters['text_guard_init'] = 0
                
                #Blank        
                parameters['line_length'] = 10
                parameters['line_offset'] = 27.0 #Could be adjusted to 21.0
                parameters['short_alignment'] = "left"
                parameters['guard_init'] = 1
                parameters['blank_total'] = 781
                parameters['yellow_shade_blank'] = 0.94
                parameters['packet_size_blank'] = 25
                
        elif(key == 5): #Test
                
                parameters['guard_end'] = 1
        
                #Text
                parameters['use_rectangles'] = True
                parameters['use_only_rectangles'] = True
                parameters['rec_width'] = 33#35.0
                parameters['rec_left_margin'] = 9
                parameters['rec_line_length'] = 594
                parameters['rec_width2'] = 56#60.0
                parameters['rec_left_margin2'] = 590 #550
                parameters['rec_line_length2'] = 13 #53

                parameters['yellow_shade_text'] = 0.94
                parameters['packet_size_text'] = 10#11
                parameters['text_guard_init'] = 0
                
                #Blank        
                parameters['line_length'] = 10
                parameters['line_offset'] = 27.0 #Could be adjusted to 21.0
                parameters['short_alignment'] = "left"
                parameters['guard_init'] = 1
                parameters['blank_total'] = 781
                parameters['yellow_shade_blank'] = 0.94
                parameters['packet_size_blank'] = 25
               
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
manchester = False
printer_name_list = ['Canon_MG2410', 'Epson_L4150', 'HP_Photosmart_D110', 'HP_Deskjet_1115', 'HP_Envy', 'Test'] #Add your printer name here

if len(sys.argv) < 2:
        print("Usage: testPrinter.py [OPTIONS] printer_name")
        print("Use this function to generate a bit pattern to inject into a PDF document. By default it prints non-text modulation, use -t otherwise. ")
        print("Current defined printers: ", printer_name_list)
        print("Possible options\n -p [arg] : use provided bit pattern\n -t : specify text modulation\n -s : line length sweep\n -S : offset sweep\n -i : display number of bits for specified printer\n -l : displays current defined printers\n -r : raw mode, used to specify bit patterns of any size without respecting established packet sizes\n -m : apply manchester encoding")
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
overhead = 5

opts, args = getopt.getopt(sys.argv[1:], "L:SCTmsiItrp:")
for opt, arg in opts:
        if opt == '-t':
                textmod = True
        elif opt == '-p':
                pattern = str(arg)
        elif opt == '-r':
                raw_mode = True
        elif opt == '-m':
                manchester = True
                overhead = 3
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
        elif opt == '-C':
                print("q")
                SweepColor()
                print("Q\n")
                exit()
        elif opt == '-T':
                print("q\n1.0 1.0", 0, "rg")
                if(parameters['rec_left_margin2'] > 250):
                    left = False
                else:
                    left = True
                SweepTriangle(left)
                print("f\nQ\n")
                exit()
        elif opt == '-L':
                testLength(parameters)
                
                exit()
                
                
if(info_bits):
        if(textmod):
                print(parameters['packet_size_text']-overhead)
        else:
                print(parameters['packet_size_blank']-overhead)
        exit()


if(textmod):
        
        yellow_shade = parameters['yellow_shade_text'] #this can go from 0 to 1.0, where 0 is completly yellow and 1.0 absence of yellow
        print("q\n1.0 1.0", yellow_shade, "rg") 
        
        if(not raw_mode): #modificar para manchester
                sz = parameters['packet_size_text']
                if(len(pattern) < sz-overhead):
                        print("(ERROR) Bit pattern should be greater than:", sz)
                        exit(1)
                
                parity = get_parity_bit(pattern[0:sz-overhead])
                packet = pattern[0:sz-overhead] + str(parity)
                
                if(manchester):
                        packet = to_manchester(packet)
                        
                text(parameters, preamble + packet)
        else:
                packet = pattern
                
                if(manchester):
                        packet = to_manchester(packet)
                text(parameters, packet)
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


#add_defense()
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




