#!/bin/bash

# Change IP to your clients; change dir to your location
for i in node-6 node-7 node-8 node-9 node-10
do
	ssh -o StrictHostKeyChecking=no $i "cd $HOME/elba/rubbos/RUBBoS/Client/ && make clean"
	scp -o StrictHostKeyChecking=no target/RubbosClient-0.1.jar $i:$HOME/elba/rubbos/RUBBoS/Client/
done