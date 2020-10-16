#!/bin/bash

if [ $1 = "Epson" ]; then
	NUM_BITS=7
	NUM_BITS2=27
elif [ $1 = "HP" ]; then
	NUM_BITS=10
	NUM_BITS2=25
elif [ $1 = "Canon" ]; then
	NUM_BITS=6
	NUM_BITS2=20
fi


./randomBits.sh -ltf simpleLayoutArial.pdf $NUM_BITS $1 50

cp testPDF.pdf tmp.pdf

if [ $1 = "Canon" ]; then
	cp C3Blank.pdf testPDF.pdf
else
	./randomBits.sh -l $NUM_BITS2 $1 50
fi

pdftk A=tmp.pdf B=testPDF.pdf shuffle A B output collated.pdf
