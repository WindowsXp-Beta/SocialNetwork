#!/bin/bash

cp ../../scripts_limit/aggregateInOutPut_ClientTier_ALL.py ./
cp ../../scripts_limit/aggregateInOutPut_ClientTier_ExcludeLongReq1.py ./
cp ../../scripts_limit/aggregateInOutPut_ClientTier_LongReq1.py ./
cp ../../scripts_limit/detailRT_fig3.gnuplot ./
cp ../../scripts_limit/histgramPlot.gnuplot ./
cp ../../scripts_limit/RT_dist_extract.py ./
cp ../../scripts_limit/RT_dist.gnuplot ./
cp ../../scripts_limit/plotPID.gnuplot ./

cp ../../scripts_limit/RT_Q_conn.gnuplot ./
cp ../../scripts_limit/RT_Q_components.gnuplot ./

x1=100
x2=220



file=$(ls detailRT-client_*.csv)
sed -i.bak 's/\.//g' $file
concurrency=$(echo $file | egrep -o '[0-9]+')
#file=detailRT-client_wl8000_back.csv

startTime=`head -1 ./Experiments_timestamp.log`
endTime=`tail -1 ./Experiments_timestamp.log`


timestamp=`head -3 Experiments_timestamp.log | tail -1`

#startTime=20200910220340
startTime=`head -1 Experiments_timestamp.log | tail -1`
endTime=`head -2 Experiments_timestamp.log | tail -1`


timeSpan=${startTime}"-"${endTime:10:2}"59"
printf "\tstartTime: %s\n\tendTime: %s\n\ttimeSpan: %s\n" "$startTime" "$endTime" "$timeSpan"
printf "\tconcurrency: %s\n" "$concurrency"



# do the real work
python2 ./aggregateInOutPut_ClientTier_ALL.py $timeSpan $startTime $endTime $concurrency $file "detailRT-client"
python2 ./aggregateInOutPut_ClientTier_ExcludeLongReq1.py $timeSpan $startTime $endTime $concurrency $file "detailRT-client"
python2 ./aggregateInOutPut_ClientTier_LongReq1.py $timeSpan $startTime $endTime $concurrency $file "detailRT-client"

python2 ./aggregateInOutPut_ClientTier_ALL.py $timeSpan $startTime $endTime $concurrency "front_req.csv" "detailRT-front"
python2 ./aggregateInOutPut_ClientTier_ExcludeLongReq1.py $timeSpan $startTime $endTime $concurrency "front_req.csv" "detailRT-front"
python2 ./aggregateInOutPut_ClientTier_LongReq1.py $timeSpan $startTime $endTime $concurrency "front_req.csv" "detailRT-front"

python2 RT_dist_extract.py

# gnuplot
title_name="***WL"$concurrency"***"
output_name="_TPRS_WL"${concurrency}"_3L.pdf"
output="RT_Q_conn_WL"${concurrency}".pdf"
output_dist="RT_dist.pdf"



tiers="detailRT-client detailRT-front"
#tiers="detailRT-client detailRT-apache detailRT-tomcat"
timestamp_offset=`expr $timestamp / 1000`
collectls=`ls |egrep '\w+[0-9]_CPU+.csv'`
collectlNW=`ls |egrep '\w+[0-9]_collectl+.csv'`

dists=`ls |egrep '\w_dist+.csv'`

hosts="VM0 VM1 VM2 VM3 VM4 VM5"
gnuplot -e "tiers='$tiers'; timespan='$timeSpan'; wl='$concurrency'; output_name='$output_name'; \
    title_name='$title_name'; x1='$x1'; x2='$x2'; timestamp_offset='$timestamp_offset'; \
    collectls='$collectls'; collectlNW='$collectlNW' ; hosts='$hosts'" detailRT_fig3.gnuplot

gnuplot -e "datasource='detailRT-client_wl"${concurrency}"'" histgramPlot.gnuplot
ps2pdf detailRT-client_wl*.ps

gnuplot -e "tiers='$tiers'; timespan='$timeSpan'; wl='$concurrency'; output_name='$output_dist'; \
    title_name='$title_name'; x1='$x1'; x2='$x2'; timestamp_offset='$timestamp_offset'; \
    dists='$dists';" RT_dist.gnuplot

gnuplot -e "tiers='$tiers'; timespan='$timeSpan'; wl='$concurrency'; output_name='$output'; \
    title_name='$title_name'; x1='$x1'; x2='$x2'; timestamp_offset='$timestamp_offset'; \
    collectls='$collectls'" RT_Q_conn.gnuplot

#find . -type f -iname '20*' -delete
