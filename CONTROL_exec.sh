#!/bin/bash

ssh attacker "
  mkdir -p $RUBBOS_RESULTS_DIR_BASE
"
ssh benchmark "
  mkdir -p $TMP_RESULTS_DIR_BASE/$RUBBOS_RESULTS_DIR_NAME
  rm -rf $TMP_RESULTS_DIR_BASE/$RUBBOS_RESULTS_DIR_NAME/*
"

# Trying to simulation 5000 users
for i in "rubbos.properties_5000"
do

  ssh benchmark "
    source /root/rubbos/set_elba_env.sh
    rm -f $RUBBOS_HOME/Client/rubbos.properties
  "

  scp $WORK_HOME/runtime_files/$i benchmark:$RUBBOS_HOME/Client/rubbos.properties

  # get HTTP request latency
  ssh node-6 "rm -f /root//root/node6_sysdig.log; sysdig -c httplog > /root/node6_sysdig.log &"

  # Browsing Only
  echo "Start Browsing Only with $i"
  echo "Removing previous logs..."


  ssh benchmark "
    source /root/rubbos/set_elba_env.sh
    cd $RUBBOS_HOME/bench
    \rm -r 20*

    # Execute benchmark
    echo '**************start************'
    date
	rm Experiments_timestamp.log

	ssh node-0 $WORK_HOME/scripts/emptyLogs.sh
    ssh node-0 $WORK_HOME/scripts/collectlMonitor.sh



    sleep 10
    ./log_time.sh
    ./rubbos-servletsBO.sh
    #Collect results
	./log_time.sh
    echo "The benchmark has finished. Now, collecting results..."
	mv Experiments_timestamp.log 20*/
    cd 20*

	ssh node-0 $WORK_HOME/scripts/endCollectl.sh
	ssh node-0 $WORK_HOME/scripts/endSysdig.sh
	ssh node-0 $WORK_HOME/scripts/getLogs.sh
	scp -r node-0:/tmp/*.raw.gz ./
	scp -r node-0:/tmp/log* ./
	scp -r node-0:/tmp/node*.log ./

	scp root@node-6:/root/node6_sysdig.log ./
	scp node-0:$WORK_HOME/set_elba_env.sh ./



    sleep 2

    cd ..
    mv 20* $TMP_RESULTS_DIR_BASE/$RUBBOS_RESULTS_DIR_NAME/
	scp -r $TMP_RESULTS_DIR_BASE/$RUBBOS_RESULTS_DIR_NAME $RUBBOS_RESULTS_HOST:$BONN_RUBBOS_RESULTS_DIR_BASE

  "

  ssh node-6 "pkill -9 sysdig"

  ssh node-0 "

	$WORK_HOME/scripts/stopall.sh
  "

  sleep 15
  echo "End Browsing Only with $i"


  echo "End Read/Write with $i"

done


echo "Finish RUBBoS"