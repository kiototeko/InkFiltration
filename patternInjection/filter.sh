#!/bin/bash
# Have debug info in /var/log/cups/error_log:
set -x
# Set the output file name:
this_script_basename=$( basename ${BASH_SOURCE[0]} )
output_file="/tmp/$this_script_basename.input"
# Have the input at fd0 (stdin) in any case:
test -n "$6" && exec <"$6"

for i in "$@"
do
	echo $i >> "/tmp/log2"
done

FILE_IN="/tmp/filetmp"
cat - > $FILE_IN




GRAY=$(echo $5 | grep "Gray")





PEEPDF="/tmp/peepdf/peepdf.py"
FORMAT_DATA="/tmp/genericPattern.py"
DATA="/tmp/data"
DATA_TMP="/tmp/data.tmp"
AKA=$($PEEPDF -C 'search "/Type /Page"'  $FILE_IN | cut -f1 -d$'\x1b')
AKA2=$(echo -n $AKA | tr '[]' ' ')
IFS=', ' read -r -a array <<< $AKA2
TMP_FILE="/tmp/tmp"
TMP_PEEP="/tmp/peep"
NUM_BYTES=10
RGB_PATTERN="[0-9].*\s[0-9].*\s[0-9].*\s"

for i in "${array[@]}"
do
        AKA3=$($PEEPDF -C "object $i" $FILE_IN | grep -oE "/Contents\s[0-9]+" | cut -f2 -d" ")
        if [ -z $AKA3 ]; then
                continue
        fi
	STREAM=$($PEEPDF -C "stream $AKA3" $FILE_IN | cut -f1 -d$'\x1b')
	STREAM2=""

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

        AKA4=$(echo $STREAM | grep -E '^BI|^ID|\sDo\s*$' )
        if [ -n "$AKA4" ]; then
                continue
        fi
        BYTE_DATA=$(head -c $NUM_BYTES $DATA)
        dd if=$DATA of=$DATA_TMP ibs=$NUM_BYTES skip=1
        mv $DATA_TMP $DATA
        $FORMAT_DATA -p $BYTE_DATA > $TMP_FILE
        echo -e $STREAM2  >> $TMP_FILE
        echo -e "modify stream $AKA3 $TMP_FILE\nsave" > $TMP_PEEP
        $PEEPDF -s $TMP_PEEP $FILE_IN
done


cat $FILE_IN
