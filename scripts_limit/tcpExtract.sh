#!/bin/bash

cp ../../scripts_limit/tcpConn.py ./
cp ../../scripts_limit/RT_Q_tcp.gnuplot ./

python tcpConn.py

x1=100
x2=110

file=$(ls detailRT-client_*.csv)
sed -i.bak 's/\.//g' $file
concurrency=$(echo $file | egrep -o '[0-9]+')

startTime=`head -1 ./Experiments_timestamp.log`
endTime=`tail -1 ./Experiments_timestamp.log`
timestamp=`head -3 Experiments_timestamp.log | tail -1`

startTime=`head -1 Experiments_timestamp.log | tail -1`
endTime=`head -2 Experiments_timestamp.log | tail -1`

timeSpan=${startTime}"-"${endTime:10:2}"59"
printf "\tstartTime: %s\n\tendTime: %s\n\ttimeSpan: %s\n" "$startTime" "$endTime" "$timeSpan"
printf "\tconcurrency: %s\n" "$concurrency"

# gnuplot

title_name="***WL"$concurrency"***"
output_attack="RT_Q_TCP_WL"${concurrency}".pdf"
timestamp_offset=`expr $timestamp / 1000`

gnuplot -e "timespan='$timeSpan'; wl='$concurrency'; output_name='$output_attack'; title_name='$title_name'; x1='$x1'; x2='$x2'; timestamp_offset='$timestamp_offset'" RT_Q_tcp.gnuplot