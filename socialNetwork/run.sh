# !/bin/bash


########### Login ############################
ssh  benchmark "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"
ssh  client1 "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"
ssh  client2 "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"
ssh  client3 "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"
ssh  client4 "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"

scp workload/BHT.jar benchmark:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar
scp workload/BHT.jar client1:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar
scp workload/BHT.jar client2:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar
scp workload/BHT.jar client3:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar
scp workload/BHT.jar client4:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar

./scripts/CONTROL_sockshop_exec_NoInterval.sh


scp -r benchmark:/root/elba/rubbos/results/2022-06-13-Workload client1:~/
########### getFollower ####################

ssh  benchmark "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"
ssh  client1 "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"
ssh  client2 "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"
ssh  client3 "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"
ssh  client4 "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"

scp workload/BPS.jar benchmark:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar
scp workload/BPS.jar client1:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar
scp workload/BPS.jar client2:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar
scp workload/BPS.jar client3:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar
scp workload/BPS.jar client4:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar

./scripts/CONTROL_sockshop_exec_NoInterval.sh


scp -r benchmark:/root/elba/rubbos/results/2022-06-13-Workload client2:~/


ssh  benchmark "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"
ssh  client1 "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"
ssh  client2 "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"
ssh  client3 "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"
ssh  client4 "cd /root/elba/rubbos/RUBBoS/Client/ && make clean"

scp workload/BUT.jar benchmark:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar
scp workload/BUT.jar client1:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar
scp workload/BUT.jar client2:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar
scp workload/BUT.jar client3:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar
scp workload/BUT.jar client4:/root/elba/rubbos/RUBBoS/Client/RubbosClient-0.1.jar

./scripts/CONTROL_sockshop_exec_NoInterval.sh


scp -r benchmark:/root/elba/rubbos/results/2022-06-13-Workload client3:~/

