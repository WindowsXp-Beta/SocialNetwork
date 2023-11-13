#!/bin/bash

echo -e "\e[33mGet logs of each container\e[0m"

for i in "node-0" "node-1" "node-2" "node-3" "node-4" "node-5"
do
	#i=$(echo $i|cut -f2 -d"=")
	#echo $i
	ssh $i '
	hostname
	for j in $(sudo docker ps --format '{{.ID}}')
	do
		k=$(sudo docker inspect --format='{{.Config.Hostname}}' $j)
		sudo docker logs $j >& /tmp/log_$k.log
		scp /tmp/log_$k.log node-0:/tmp/
	done
	'
done