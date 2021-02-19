#!/bin/bash

if [ "$#" -lt 1 ]; then
	echo "Wrong number of paramenters. Usage: display_bits.sh file_name [paylod_bits]"
	echo "Use this function to display the bit packets in an intelligible way. You can optionally specify the number of payload bits to use when splitting the bit stream."
	exit 1
fi

BITS="$(cat $1)"


if [ -n "$2" ]; then

        PAYLOAD_LEN=$2
        
else
	IFS='_'
        read -ra parts <<< $1
        PAYLOAD_LEN=${parts[-3]}
        
fi

NUM_PACKETS=$((${#BITS} / $PAYLOAD_LEN))

MIDDLE=$(($NUM_PACKETS/2))

echo

echo -e "PREAMBLE|PAYLOAD|PARITY"

echo

for (( i=0; i<$NUM_PACKETS; i++ ))
do

        if [ $i = $MIDDLE ]; then
                echo
        fi
        
        PAYLOAD=${BITS:$(($i*$PAYLOAD_LEN)):$PAYLOAD_LEN}
        PARITY=0
        
        for (( j=0; j<$PAYLOAD_LEN; j++ ))
        do
                let PARITY+=${PAYLOAD:$j:1}
        done
        
        let PARITY%=2
        
        echo -e "1010\t$PAYLOAD\t$PARITY"

done

echo
