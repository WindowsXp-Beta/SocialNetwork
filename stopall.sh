#!/bin/bash

cd /root/DeathStarBench/socialNetwork/
source ./set_elba_env.sh

#$OUTPUT_HOME/scripts/stop_all.sh

for i in "$BENCHMARK_HOST" "$CLIENT1_HOST" "$CLIENT2_HOST" "$CLIENT3_HOST" "$CLIENT4_HOST"
do

    ssh $i "
      sudo pkill -9 java;
      sudo pkill -9 iostat;
      sudo pkill -9 collectl;
      sudo pkill -9 httpd;
      sudo pkill -9 mysql
      sudo pkill -9 cpu_mem;
    "
done

ssh node-0 "
	cd /root/DeathStarBench/socialNetwork/
	./scripts/endCollectl.sh

"

for i in "node-0" "node-1" "node-2" "node-3" "node-4" "node-5" "node-6"
do
	ssh $i "
	pkill -9 pidstat
	pkill -9 sysdig
	"
done