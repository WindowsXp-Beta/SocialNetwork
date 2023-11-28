# Cloudlab Setup Guide

## Instantiating an experiment
1. Check resource availability for a Bare Metal machine with 12 free resources, example: rs620, r350.
2. Edit code in `profile.py`.
3. Create a profile using the file at 'cloudlab/profile.py'. Modify the hardware type and node count(12) based on the available resource.
4. Click "Accept".
5. Save changes.
6. Click "Instantiate".
7. Wait for it to come up.

## Downloading Zip File
1. Please download the zip file using the following link:
[Download Zip File](https://filestogeaux.lsu.edu/public/download.php?FILE=xgu5/12038F6iKmz)
2. Add JDK files to these paths in the project directory- '/RubbosClient/elba/rubbos/jdk1.8.0_241', '/RubbosClient/rubbos/jdk-8u241-linux-x64.tar.gz'.
3. Make sure SocialNetwork/RubbosClient/elba/rubbos/jdk1.8.0_241/bin has executable permission, if not run `chmod +x SocialNetwork/RubbosClient/elba/rubbos/jdk1.8.0_241/bin/java`
4. Change hostname in `docker-compose-swarm.yml`.
hostname format is `node-{idx}.{experiment_name}.infosphere-pg0.{ssh-host without the first varying part}`.
> The experiment name's format is `username-number`, e.g. XinpengW-177986
> for ssh-host, suppose a host is `apt186.apt.emulab.net`, then we pick the latter three parts without the first varying one
5. Delete existing zip to obtain new data.

## RUBBoS Properties
Fix hardcoded paths in socialNetwork/runtime_files/rubbos.properties_100 properties to your paths.

## Running Controller Setup Script
Run the Controller setup script. The command might resemble the following:

```bash
./controller_setup.sh \
--username XinpengW \
--private_ssh_key_path "/Users/weixinpeng/.ssh/id_rsa" \
--controller_node apt186.apt.emulab.net \
--git_email william.xp.wei@gatech.edu \
--swarm_node_number 6 \
--client_node_number 5
```

## Debugging in VS Code help
1. Click on the >< symbol in the left bottom corner.
2. Connect to host > Add New SSH Host > Enter SSH Connection command to the controller node - node-0. You can get this from Cloudlab's Experiment List View page too. It would look something like `ssh Preethi@apt183.apt.emulab.net.` 
3. If your ssh key is not the one in the default location, edit config > Open config > Add IdentityFile path /custom/path/id_rsa under the host details.
4. To copy missing files from local machine- scp -o StrictHostKeyChecking=no -i(optional)"/custom/path/id_rsa"  /source/file/path hostname:/destination/path.
5. To access another node(node-6 for example) from node-0, just type `ssh node-6` from node-0's terminal.


# Original README
## Preliminary

- Assume you have all OS ready and they are in the same subnet, ssh each other without password.

- Assume your docker swarm cluster is ready and you know how to deploy socialNetwork on it based on docker-compose-swarm.yml provided by offical github.

- Sync all your VMs to the same timezone and time

- Install collectl, sysdig (apt install collectl sysdig) on all your VMs

## Folder Structure

1. RubbosClient

    * This is the RUBBoS workload generator running framework. It has two folders, elba and rubbos.
    * Put elba and rubbos to your home dir. It has everything you need to run workload generator including JDK.

2. RubbosClient_src

    * Source code file of workload package.
    * Dependency: maven 3
    * It specify the distribution of URLs you are going to run.
    * Only two files you may want to modify:
        * /src/edu/rice/rubbos/client/UserSession.java
            * Method: servletP() to specify the URLs and distributions. Currently, there are only one URL (read-home-timeline)
            * Method: sockshopURLGenerator(): specify the port of socialNetwork frontend
        * /src/edu/rice/rubbos/client/NewEmulator.java
            *	Variable interval: specify warm up length in ms
            *	"sleep(200000);" in line 345: specify the running duration in ms.
    * To compile it: mvn clean && mvn package
        * Send to all clients by ./cpToCloud.sh (change IP to yours)

3. src

    * this is the source code files for socialNetwork

    * to compile it:

        * put it into socialNetwork folder you cloned from offical github

        * follow this link to compile it: https://gitlab.mpi-sws.org/cld/systems/deathstarbench/-/blob/master/socialNetwork/README.md

            1. Build modified docker containers

            2. No need to build deps and nginx

            3. Go to step 3. Build the social network docker image directly. Flag it with your own varaibles

                e.g., `docker build -t yg397/social-network-microservices:withLog_01 .`

            4. After build successfully, change image: `deathstarbench/social-network-microservices:latest` to `yg397/social-network-microservices:withLog_01` in `docker-compose-swarm.yml` to make you compiled files effective

4. socialNetwork

    * Put it to controller node
    * file set_elba_env.sh
        * Specify your global varaibles. Change to your values.
        * source set_elba_env.sh everytime before your run.
    * files in runtime_files:
        * configuration file to for workload generator
        * the number in the file name means the total number of users you are going to simulate
        * take a loop at those files and change ip to your (benchmark and clients)
    * To run experiment:
        * ./start start  # deploy socialNetwork
        * ./start register # seed the database with users
        * ./start compose # seed the database with posts
        * ./start dedicate # pin containers to core
        * ./scripts/CONTROL_exec.sh (read it carefully, it run experiment and collect data)

5. scripts_limit

    * if you run it successfully, you should have results folder in "RUBBOS_RESULTS_HOST/BONN_RUBBOS_RESULTS_DIR_BASE" specified in set_elba_env.sh
    * upload scripts_limit to RUBBOS_RESULTS_HOST/RUBBOS_RESULTS_DIR_NAME
        * cp generateResult.sh to RUBBOS_RESULTS_HOST/RUBBOS_RESULTS_DIR_BASE/RUBBOS_RESULTS_DIR_NAME/
        * ./generateResult.sh to start processing data (if you have a lot of errors, try to run it line by line and debug it)
        * it use python to process the data and gnuplot to draw figures
        * it may have dependencies (collectl, numpy, pdfgrep, gnuplot, ...) try to install them if you have error message.

It is natural if you see errors. Try to understand those scripts.

Email: xgu5@lsu.edu
Skype: live:x.gu3 (xgu5@outlook.com)

## Questions

1. do we need to start jaeger monitor? I don't see pinned.
2. client send requests to which hostname. don't see loadbalancer, or any node? Will swarm network dispatch the traffic?

## TODO

- replace bind mount into volumes or docker config
- **migrate to k8s**