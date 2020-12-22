#!/usr/bin/env python

import sys, getopt, math

printers_list = ["HP", "Epson", "Canon"]


pattern = [1,0,1,1,1,0,0,0,1,1,0,1,1,0,0,1,0,1,0,0,0,0,1,1,0,1,1,1,0,1,0,1,1,1,1]
total = 783.0
preamble = [1,0,1,0]
text = False
sweep = False
sweep2 = False
infoB = False



opts, args = getopt.getopt(sys.argv[1:], "T:p:tsSil")
for opt, arg in opts:
	if opt == '-T':
		total = int(arg)
	elif opt == '-p':
		pattern = list(arg)
	elif opt == '-t':
		text = True
	elif opt == '-s':
		sweep = True
	elif opt == '-S':
		sweep2 = True
	elif opt == '-i':
		infoB = True
	elif opt == '-l':
		print(printers_list)
		exit()


if len(sys.argv) < 2:
	print("Usage: genericPattern.py [OPTIONS] printer")
	print("Use this function to generate a bit pattern to inject into a PDF document. By default it prints non-text modulation, use -t otherwise. ")
	print("Current defined printers: ", printers_list)
	print("Possible options\n -T [arg] : change upper page boundary\n -p [arg] : use provided bit pattern\n -t : specify text modulation\n -s : line length sweep\n -S : offset sweep\n -i : display number of bits for specified printer\n -l : displays current defined printers")
	exit()


printer = sys.argv[-1]


def info():
	if(printer == "HP"):
		if(text):
			return 10
		else:
			return 25
	elif(printer == "Epson"):
		if(text):
			return 7
		else:
			return 27
	elif(printer == "Canon"):
		if(text):
			return 6
		else:
			return 20
	
if(infoB):
	print(info())
	exit()

def HP_text():
	partitions = 10
	sizeL=42.0
	sizeL2=25.0
	size0=32.0
	packet_size = 15
	packet = preamble + pattern[0:packet_size-len(preamble)-1]
	global total
	
	parity = 0
	for i in range(packet_size):
		if(i == packet_size-1):
			bitidx = parity % 2
		else:
			bitidx = int(packet[i])
			parity += bitidx
		if(not bitidx):
			total -= size0/(partitions+1)
			for i in range(partitions):
					print("9 %.2f 594 1 re" %(total))
					total -= size0/(partitions+1)
			print("9 %.2f 594 1 re" %(total))

		else:

			sizeH = sizeL/2
			partitionsH = partitions

			total -= sizeL2
			print("9 %.2f 594 %.2f re" %(total, sizeL2))
			
			if(i +1 < packet_size-1 and not int(packet[i+1])):
				sizeH += 2
			else:
				sizeH += 10
			partitionsH /= 2
			

			total -= sizeH/(partitionsH+1)
			for i in range(partitionsH):
					print("9 %.2f 594 1 re" %(total))
					total -= sizeH/(partitionsH+1)
			print("9 %.2f 594 1 re" %(total))
	total -= sizeL2
	print("9 %.2f 594 %.2f re" %(total, sizeL2))

def HP_blank():
	sizeL= 25.0 
	packet_size=30 
	packet = preamble + pattern[0:packet_size-len(preamble)-1]
	global total
	parity = 0
	for i in range(packet_size):
		if(i == packet_size-1):
			bitidx = parity % 2
		else:
			bitidx = int(packet[i])
			parity += bitidx
		
		if(bitidx):
				print("250 %.2f 100 1 re" %(total))
		else:
			print("9 %.2f 594 1 re" %(total))
		
		total -= sizeL
	print("9 %.2f 594 1 re" %(total))
	
		


def Canon_blank():
	sizeL=27.0
	packet_size=25
	packet = preamble + pattern[0:packet_size-len(preamble)-1]
	total = 781
	
	parity = 0
	print("9 %.2f 594 1 re" %(total))
	total -= sizeL

	for i in range(packet_size):
		if(i == packet_size-1):
			bitidx = parity % 2
		else:
			bitidx = int(packet[i])
			parity += bitidx
		
		if(not bitidx):
			print("9 %.2f 10 1 re" %(total))
		else:
			print("9 %.2f 594 1 re" %(total))
		
		total -= sizeL
	print("9 %.2f 594 1 re" %(total))
	
		
def Canon_text():
        sizeL=57.0
        packet_size=11
        partitions = 1
        packet = preamble + pattern[0:packet_size-len(preamble)-1]
        global total

        parity = 0
        for i in range(packet_size):
                if(i == packet_size-1):
                        bitidx = parity % 2
                else:
                        bitidx = int(packet[i])
                        parity += bitidx

                if(bitidx):

			total -= 42
                        print("9 %.2f 594 %.2f re" %(total,42))
			total -= 14
                        print("9 %.2f 594 %.2f re" %(total, 1))
			total -= 14			

                else:
	                print("9 %.2f 594 %.2f re" %(total, 1))
				
			total -= 14
                        print("9 %.2f 594 %.2f re" %(total, 1))
			total -=14
			if(not int(packet[i-1])):
	                        print("9 %.2f 594 %.2f re" %(total, 1))
				total -=14

	total -= 42
        print("9 %.2f 594 %.2f re" %(total,42))

	

def Epson_blank():
	sizeL=24
	packet_size=32
	packet = preamble + pattern[0:packet_size-len(preamble)-1]
	global total

	parity = 0
	for i in range(packet_size):
		if(i == packet_size-1):
			bitidx = parity % 2
		else:
			bitidx = int(packet[i])
			parity += bitidx
		
		if(not bitidx):
				print("553 %.2f 50 1 re" %(total))
		else:
			print("9 %.2f 594 1 re" %(total))
		
		total -= sizeL
	print("9 %.2f 594 1 re" %(total))

		
def Epson_text():
        sizeL=42.0
	sizeL2 = 24.0
        packet_size=12 
        partitions = 3
        packet = preamble + pattern[0:packet_size-len(preamble)-1]
        global total

        parity = 0
	for i in range(packet_size):
                if(i == packet_size-1):
                        bitidx = parity % 2
                else:
                        bitidx = int(packet[i])
                        parity += bitidx
                if(not bitidx):
                        print("56.8 %.2f 500 1 re" %(total))
                        total -= sizeL/(partitions+1)
                        for j in range(partitions):
                                        print("56.8 %.2f 500 1 re" %(total))
                                        total -= sizeL/(partitions+1)
                else:
                        total -= sizeL2
                        print("9 %.2f 594 %.2f re" %(total, sizeL2))
                        total -= sizeL/(partitions+1)
	                for j in range(partitions):
        	                        print("56.8 %.2f 500 1 re" %(total))
                	                total -= sizeL/(partitions+1)

		
        total -= sizeL2
        print("9 %.2f 594 %.2f re" %(total, sizeL2))



def Sweep(printer):
	global total
	sizeL = 28.0
	lower_margin = 10.0
	line_size = 594.0
	start = 9.0
	packet_size = int(math.floor((total - lower_margin)/sizeL))
	line_decrement = math.floor(line_size/packet_size)

	if(printer == "Canon" or printer == "HP"):
		total -= sizeL

	for i in range(packet_size):
	        print("%.2f %.2f %.2f 1 re" %(start, total, line_size))
		total -= sizeL
		line_size -= line_decrement

		if(printer == "HP"):
			start += line_decrement/2
		elif(printer == "Epson"):
			start += line_decrement


def offsetSweep(minsizeL, printer):
	global total
	lower_margin = 10.0

	total -= minsizeL
	sizeL = minsizeL

	while total > lower_margin:
	
		print("9 %.2f 594 1 re" %(total))
		total -= sizeL
		sizeL += 2


if(printer == "HP"):

	print("q\n1.0 1.0 0.99 rg")

	if(sweep):
		Sweep(printer)
	elif(sweep2):
		offsetSweep(25.0, printer)

	else:
		if(text):
			HP_text()
		else:
			HP_blank()

elif(printer == "Canon"):

	print("q\n1.0 1.0 0.94 rg")
	#print("q\n1.0 1.0 0.5 rg")

	if(sweep):
		Sweep(printer)
	elif(sweep2):
		offsetSweep(21.0, printer)

	else:

		if(text):
			Canon_text()
		else:
			Canon_blank()

elif(printer == "Epson"):


	if(sweep):
		print("q\n1.0 1.0 0.97 rg")
		Sweep(printer)
	elif(sweep2):
		print("q\n1.0 1.0 0.97 rg")
		offsetSweep(24.0, printer)

	else:
		if(text):
			print("q\n1.0 1.0 0.99 rg")
			Epson_text()
		else:
			print("q\n1.0 1.0 0.97 rg")
			Epson_blank()

			
print("f\nQ\n")

