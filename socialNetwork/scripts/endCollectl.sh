#!/bin/bash
#cd /home/xgu/rubbos/xgu_111
#source ./set_elba_env.sh

echo -e "\e[33mclearn the collectl data in benchmark node\e[0m"
sleep 1

echo "collect collectl data"

for i in "node-0" "node-1" "node-2" "node-3" "node-4" "node-5" "node-6"
do
	#i=$(echo $i|cut -f2 -d"=")
	echo 'come here1'
	ssh $i '
	sudo pkill collectl
	'
	scp $i:/tmp/node* /tmp/
done

## example of how to replay back the collectl results
#collectl -scdn -p ./VMelba9-20130922-083628.raw  -P -f . -oUmz --from 20130922:08:36-08:39