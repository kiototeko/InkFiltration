#!/bin/bash

if [ "$#" -lt 2 ]; then
	echo "Wrong number of paramenters. Usage: raw_injection.sh [options] printer bit_pattern"
	echo "Use this function to inject a specified bit pattern of any size into a pdf document according to a specific printer"
	echo -e "Current defined printers: $(python3 ./testPrinter.py -l)"
	echo -e "Options:\n -t : use text modulation\n -f [file] : PDF file to be injected with patterns (by default it injects to a blank document)\n -b : Make less black the text on a document\n -I : display a graphical representation of the desired pattern\n -m : apply manchester coding\n -r [file] : raw mode, specify raw patterns on file"
	exit 1
fi

FILE_IN="Layouts/simpleLayoutBlank.pdf"
TEXT=""
LESS_BLACK=""
DISPLAY_IMAGE=""
MANCHESTER=""
RAW=""

ARGUMENTS=(${@: -2})

while getopts "tmbIf:r:" arg; do
	case ${arg} in
		t ) 
		TEXT="yes"
		;;
		f ) 
		FILE_IN="${OPTARG}"
		;;
		b ) 
		LESS_BLACK="yes"
		;;
		I )
		DISPLAY_IMAGE="yes"
		;;
		m )
		MANCHESTER="-m"
		;;
		r )
                RAW="${OPTARG}"
                ;;
	esac
done

PEEPDF="python2 peepdf/peepdf.py"

cp Layouts/whitePDF.pdf.old Layouts/whitePDF.pdf

FINAL=${ARGUMENTS[1]}
PRINTER=${ARGUMENTS[0]}

if [ -n "$TEXT" ]; then
	AKA=$($PEEPDF -C 'search "/Type /Page"'  $FILE_IN | cut -f1 -d$'\x1b')
	AKA2=$(echo -n $AKA | tr -d '[]')
	IFS=', ' read -r -a array <<< $AKA2
	AKA=$($PEEPDF -C 'search "/Type /Pages"'  $FILE_IN | cut -f1 -d$'\x1b')
	AKA2=$(echo -n $AKA | tr -d '[]')
	array=( ${array[@]/$AKA2} )
	pdftk $FILE_IN cat 1 output Layouts/whitePDF.pdf
fi

AKA=$($PEEPDF -C 'search "/Type /Page"'  Layouts/whitePDF.pdf | cut -f1 -d$'\x1b')
AKA2=$(echo -n $AKA | tr -d '[]')
IFS=', ' read -r -a array2 <<< $AKA2
AKA=$($PEEPDF -C 'search "/Type /Pages"'  Layouts/whitePDF.pdf | cut -f1 -d$'\x1b')
AKA2=$(echo -n $AKA | tr -d '[]')
array2=( ${array2[@]/$AKA2} )
AKA3=$($PEEPDF -C "object ${array2[0]}" Layouts/whitePDF.pdf | grep -oE "/Contents\s[0-9]+" | cut -f2 -d" ")
echo -e "modify stream $AKA3 randomStream\nsave" > randomScript

echo -e "\nSUCCESSFUL INJECTION (testPDF.pdf)----------------\n"


if [ -z "$RAW" ]; then

        if [ -z "$TEXT" ]; then
                python3 ./testPrinter.py $MANCHESTER -rp $FINAL $PRINTER > randomStream
                cat randomStream
                
                if [ -n "$DISPLAY_IMAGE" ]; then
                
                python3 ./testPrinter.py $MANCHESTER -rIp $FINAL $PRINTER > /dev/null
                
                fi

        else
                AKA3=$($PEEPDF -C "object ${array[0]}" $FILE_IN | grep -oE "/Contents\s[0-9]+" | cut -f2 -d" ")
                STREAM=$($PEEPDF -C "stream $AKA3" $FILE_IN | cut -f1 -d$'\x1b')

                python3 ./testPrinter.py $MANCHESTER -rt -p $FINAL $PRINTER > randomStream
                cat randomStream
                
                if [ -n "$DISPLAY_IMAGE" ]; then
                
                python3 ./testPrinter.py $MANCHESTER -rtIp $FINAL $PRINTER > /dev/null
                
                fi

                if [ -n "$LESS_BLACK" ] || [ $PRINTER = "Epson_L4150" ] || [ $PRINTER = "Canon_MG2410" ]; then
                        echo "$STREAM" | sed 's/0 0 0 rg/0.01 g/; s/0 0 0 RG/0.01 G/' >> randomStream						
                else
                        echo "$STREAM" >> randomStream
                fi

        fi		

else

        cat $RAW | tee randomStream
        echo
        
        AKA3=$($PEEPDF -C "object ${array[0]}" $FILE_IN | grep -oE "/Contents\s[0-9]+" | cut -f2 -d" ")
        STREAM=$($PEEPDF -C "stream $AKA3" $FILE_IN | cut -f1 -d$'\x1b')
        
        if [ -n "$LESS_BLACK" ]; then
                echo "$STREAM" | sed 's/0 0 0 rg/0.01 g/; s/0 0 0 RG/0.01 G/' >> randomStream						
        else
                echo "$STREAM" >> randomStream
        fi
        
fi



$PEEPDF -s randomScript Layouts/whitePDF.pdf > log


cp Layouts/whitePDF.pdf testPDF.pdf
	

