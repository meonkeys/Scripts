#!/bin/bash
# Get current swap usage per pid

for map in /proc/[0-9]*/smaps;
do
    PID=`echo $map | cut -d / -f 3`
    PROGNAME=`ps -p $PID -o comm --no-headers`
    SUM=0
    for SWAP in `grep Swap $map 2>/dev/null| awk '{ print $2 }'`
    do
        SUM=$((SUM+SWAP))
    done
    if [ "$SUM" -gt "0" ]
    then
        echo -e "$SUM\t$PID - $PROGNAME"
    fi
done
