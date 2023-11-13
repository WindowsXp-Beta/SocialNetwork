
#!/bin/bash

echo -e "\e[33mEnding sysdig at each node\e[0m"



for i in "node-0" "node-1" "node-2" "node-3" "node-4" "node-5" "node-6"
do
	ssh $i '
		hostname
		pkill sysdig
		scp /tmp/node*.log node-0:/tmp/
	'
done