#!/bin/bash
# Have the input at fd0 (stdin) in any case:
test -n "$6" && exec <"$6"

for i in "$@"
do
	echo $i >> "/tmp/log2"
done

FILE_IN="/tmp/filetmp"
cat - > $FILE_IN


TEXT=""

PEEPDF="/tmp/peepdf/peepdf.py"

AKA=$($PEEPDF -C 'search "/Type /Page"'  $FILE_IN | cut -f1 -d$'\x1b')
AKA2=$(echo -n $AKA | tr -d '[]')
IFS=', ' read -r -a array <<< $AKA2
AKA=$($PEEPDF -C 'search "/Type /Pages"'  $FILE_IN | cut -f1 -d$'\x1b')
AKA2=$(echo -n $AKA | tr -d '[]')
array=( ${array[@]/$AKA2} )

TMP_FILE="/tmp/tmp"
TMP_PEEP="/tmp/peep"
RGB_PATTERN="[0-9].*\s[0-9].*\s[0-9].*\s"

echo "${array[@]}" > /tmp/array

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
	
	STREAM2=$STREAM

        #If yellow value is greater than 0.9, use white instead
	STREAM2=$(echo "$STREAM2" | sed 's/\([1-9]\.*[0-9]* [1-9]\.*[0-9]*\) 0\.9[1-9][0-9]* \([Rr][Gg]\)/\1 1.0 \2/')

        echo -e $STREAM2  > $TMP_FILE	
        echo -e "modify stream $AKA3 $TMP_FILE\nsave" > $TMP_PEEP
        $PEEPDF -s $TMP_PEEP $FILE_IN


done


#The file should be output to standard output
cat $FILE_IN
