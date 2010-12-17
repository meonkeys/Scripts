#!/bin/bash

count=`mysql -NBe 'SELECT COUNT(0) FROM mythlog WHERE message="Canceled recording (Recorder Failed)" AND logdate > NOW() - INTERVAL 2 HOUR'`
if [ $count -gt 0 ]
then
 echo "Recording failing on jessica!"
fi
