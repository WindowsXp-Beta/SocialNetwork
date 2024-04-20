#!/bin/bash
set -e

cp ../../../scripts_limit/aggregateInOutPut_ALL.py ./
cp ../../../scripts_limit/aggregateInOutPut_ExcludeLongReq1.py ./
cp ../../../scripts_limit/aggregateInOutPut_LongReq1.py ./
cp ../../../scripts_limit/extract_queue_length.py ./
cp ../../../scripts_limit/detailRT_fig3.py ./
cp ../../../scripts_limit/histogram_plot.py ./
cp ../../../scripts_limit/tier_visualization.py ./
cp ../../../scripts_limit/RT_Q_conn.py ./

fileClient=$(ls detailRT-client*.csv)
sed -i.bak 's/\.//g' $fileClient
fileHome=$(ls detailRT-home*.csv)
filepost=$(ls detailRT-post*.csv)

concurrency=$(echo $fileClient | egrep -o '[0-9]+')

startTime=`head -1 Experiments_timestamp.log`
endTime=`head -2 Experiments_timestamp.log | tail -1`

timeSpan=${startTime}"00-"${endTime}"59"
printf "\tstartTime: %s\n\tendTime: %s\n\ttimeSpan: %s\n" "$startTime" "$endTime" "$timeSpan"
printf "\tconcurrency: %s\n" "$concurrency"

python2 ./aggregateInOutPut_ALL.py $timeSpan $startTime $endTime $concurrency $fileClient "detailRT-client"
python2 ./aggregateInOutPut_ExcludeLongReq1.py $timeSpan $startTime $endTime $concurrency $fileClient "detailRT-client"
python2 ./aggregateInOutPut_LongReq1.py $timeSpan $startTime $endTime $concurrency $fileClient "detailRT-client"

python2 ./aggregateInOutPut_ALL.py $timeSpan $startTime $endTime $concurrency $fileHome "detailRT-home-timeline-service"
python2 ./aggregateInOutPut_ExcludeLongReq1.py $timeSpan $startTime $endTime $concurrency $fileHome "detailRT-home-timeline-service"
python2 ./aggregateInOutPut_LongReq1.py $timeSpan $startTime $endTime $concurrency $fileHome "detailRT-home-timeline-service"

python2 ./aggregateInOutPut_ALL.py $timeSpan $startTime $endTime $concurrency $filepost "detailRT-post-storage-service"
python2 ./aggregateInOutPut_ExcludeLongReq1.py $timeSpan $startTime $endTime $concurrency $filepost "detailRT-post-storage-service"
python2 ./aggregateInOutPut_LongReq1.py $timeSpan $startTime $endTime $concurrency $filepost "detailRT-post-storage-service"

tiers="detailRT-client,detailRT-home-timeline-service,detailRT-post-storage-service"
types="ALL,ExcludeLongReq1,LongReq1"

python3 extract_queue_length.py $timeSpan $concurrency $tiers $types

timestamp=`head -3 Experiments_timestamp.log | tail -1`
timestamp_offset=`expr $timestamp / 1000`
output="RT_Q_conn.pdf"
output_name="_TPRS_WL"${concurrency}"_3L.pdf"
# have to hard code the title name, because otherwise output_name will be used as title for some reason?
# title_name="***WL"${concurrency}"***"
x1=100
x2=220
hosts="VM0,VM1,VM2,VM3,VM4,VM5"
# list all directories -> find all files that match the pattern -> replaces newlines with commas -> removes trailing comma
collectls=`ls |egrep '\w+[0-9]_CPU+.csv' | tr '\n' ',' | sed 's/,$//'`
collectlNW=`ls |egrep '\w+[0-9]_collectl+.csv' | tr '\n' ',' | sed 's/,$//'`

python3 detailRT_fig3.py $output_name "***WL"${concurrency}"***" $x1 $x2 $timestamp_offset $collectls $collectlNW $hosts
python3 histogram_plot.py $tiers $concurrency
python3 tier_visualization.py $tiers $timeSpan $concurrency $output "***WL"${concurrency}"***" $x1 $x2 $timestamp_offset $types
