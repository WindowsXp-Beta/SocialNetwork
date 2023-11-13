#!/bin/bash

echo -e "\e[33mremove previous logs of each container\e[0m"

for i in "node-0" "node-1" "node-2" "node-3" "node-4" "node-5"
do
	#i=$(echo $i|cut -f2 -d"=")
	echo 'come here1'
	#echo $i
	ssh $i '
	hostname
	for j in $(sudo docker ps --format '{{.ID}}')
	do
		sudo sh -c "echo '' > $(sudo docker inspect --format='{{.LogPath}}' $j)"
	done
	'
done