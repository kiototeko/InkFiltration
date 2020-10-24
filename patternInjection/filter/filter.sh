#!/bin/bash
# Have the input at fd0 (stdin) in any case:
test -n "$6" && exec <"$6"

for i in "$@"
do
	echo $i >> "/tmp/log2"
done

FILE_IN="/tmp/filetmp"
cat - > $FILE_IN




GRAY=$(echo $5 | grep "Gray")

TEXT=""

TMP=$(lpstat -e | tr "\n" ",")
IFS=',' read -r -a PRINTERS <<< $TMP



PRINTER_SEARCH=$(lpstat -W "not-completed" -o | cut -d " " -f 1 |  sed 's/\-[0-9]*$//' )

PRINTER=$(echo $PRINTER_SEARCH | sed 's/EPSON_L4150_Series/Epson/; s/MG2400-series/Canon/; s/Photosmart-D110-series/HP/')

echo "$PRINTER" >> /tmp/log

PEEPDF="/tmp/peepdf/peepdf.py"
FORMAT_DATA="/tmp/genericPattern.py"
DATA="/tmp/data"
DATA_TMP="/tmp/data.tmp"
AKA=$($PEEPDF -C 'search "/Type /Page"'  $FILE_IN | cut -f1 -d$'\x1b')
AKA2=$(echo -n $AKA | tr '[]' ' ')
IFS=', ' read -r -a array <<< $AKA2
TMP_FILE="/tmp/tmp"
TMP_PEEP="/tmp/peep"
RGB_PATTERN="[0-9].*\s[0-9].*\s[0-9].*\s"

for i in "${array[@]}"
do
	#We first check if the object corresponds to a content stream
        AKA3=$($PEEPDF -C "object $i" $FILE_IN | grep -oE "/Contents\s[0-9]+" | cut -f2 -d" ")
        if [ -z $AKA3 ]; then
                continue
        fi
	#We obtain the STREAM from that object (page)
	STREAM=$($PEEPDF -C "stream $AKA3" $FILE_IN | cut -f1 -d$'\x1b')
	STREAM2=""
	
	#If that stream contains images, we continue with other pages
	AKA4=$(echo $STREAM | grep -wE 'BI|ID|\sDo\s*$' )
        if [ -n "$AKA4" ]; then
                continue
        fi

	#If grayscale is activated we change all colors to that color scale. (NOTE: for this you first need to modify the printer's PPD file so that choosing grayscale still prints in color).
	if [ -n "$GRAY" ]; then
        	while IFS= read -r line
	        do
        	        LLINE=$(echo -n "$line" | grep -E "\srg")
                	if [ -n "$LLINE" ]; then
                        	RGBLINE=$(echo "$line" | grep -oE $RGB_PATTERN)
	                        BEFORERGB=$(echo "$line" | grep -oP ".*(?= $RGB_PATTERN)")
        	                RED=$(echo $RGBLINE | cut -f1 -d" ")
                	        GREEN=$(echo $RGBLINE | cut -f2 -d" ")
                        	BLUE=$(echo $RGBLINE | cut -f3 -d" ")
	                        GRAY=$(echo "0.3 * $RED + 0.59 * $GREEN + 0.11 * $BLUE" | bc | awk '{printf "%0.2f", $0}')
        	                STREAM2="$STREAM2$BEFORERGB $GRAY g\n"

                	else
                        	STREAM2="$STREAM2$line\n"
	                fi
        	done <<< $STREAM
	else
		STREAM2=$STREAM
	fi

	#We check if text is present on the page
        AKA4=$(echo $STREAM2 | grep -wE 'BT|ET' )
        if [ -n "$AKA4" ]; then
                TEXT="y"
		NUM_BYTES=$($FORMAT_DATA -ti $PRINTER)
	else
		TEXT=""
		NUM_BYTES=$($FORMAT_DATA -i $PRINTER)		
        fi

	#If the printer is Epson or Canon, a tiny decrease in the shade of black is needed
        if [ $PRINTER = "Epson" ] || [ $PRINTER = "Canon" ]; then
		STREAM2=$(echo "$STREAM2" | sed 's/0 0 0 rg/0.01 g/; s/0 0 0 RG/0.01 G/')
	fi

	#We obtain our bits of data
        BYTE_DATA=$(head -c $NUM_BYTES $DATA)
	#echo "$BYTE_DATA" >> /tmp/log
	
	#We create a backup of the data
        dd if=$DATA of=$DATA_TMP ibs=$NUM_BYTES skip=1
        mv $DATA_TMP $DATA	

	#We inject the patterns into the content stream
        if [ -n "$TEXT" ]; then
		$FORMAT_DATA -p $BYTE_DATA -t $PRINTER > $TMP_FILE
	else
		$FORMAT_DATA -p $BYTE_DATA $PRINTER > $TMP_FILE
	fi
        echo -e $STREAM2  >> $TMP_FILE	
        echo -e "modify stream $AKA3 $TMP_FILE\nsave" > $TMP_PEEP
        $PEEPDF -s $TMP_PEEP $FILE_IN

done


#The file should be output to standard output
cat $FILE_IN
