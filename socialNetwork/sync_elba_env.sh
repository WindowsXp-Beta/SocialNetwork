#!/bin/bash

for node in "node-6" "node-7" "node-8" "node-9" "node-10"
do
    scp $WORK_HOME/set_elba_env.sh $node:~/rubbos/
done