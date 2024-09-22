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
[Download Zip File](https://gtvault-my.sharepoint.com/:f:/g/personal/xwei303_gatech_edu/Evp7rsyycVJOqMeiWWEAXwwBzQLPChBwBxhOgLZPibAvTQ?e=KIJGp9)
2. Add JDK files to these paths in the project directory- '/RubbosClient/elba/rubbos/jdk1.8.0_241', '/RubbosClient/rubbos/jdk-8u241-linux-x64.tar.gz'.
3. Make sure SocialNetwork/RubbosClient/elba/rubbos/jdk1.8.0_241/bin has executable permission, if not run `chmod +x SocialNetwork/RubbosClient/elba/rubbos/jdk1.8.0_241/bin/java`
4. Populate `config/config.json` with your values. Instructions:
hostname format is `node-{idx}.{experiment_name}.infosphere-pg0.{ssh-host without the first varying part}`.
> You can get the experiment name from cloudlab the format is `username-number`, e.g. XinpengW-177986
> for ssh-host, suppose a host is `apt186.apt.emulab.net`, then we pick the latter three parts without the first varying one.
> Username would be your cloudlab usernane, for example: Preethi
5. Delete existing zip to obtain new data.

## RUBBoS Properties
Fix hardcoded paths in `socialNetwork/runtime_files/rubbos.properties_1000` properties to your paths.

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

## Starting a New Experiment via JobManager
Ensure python3 is installed on your system. To initialize a new experiment, enter in terminal `python3 JobManager.py`. Enter in the following fields similar to the controller_setup.sh script:
```
CloudLab Username: (example: [kfry9])
Total path of private ssh key: (example: [/Users/kfry9/.ssh/id_rsa])
Hostname of controller node: (example: [pc506.emulab.net])
Github email address: (example: [kylemfry3@gmail.com])
Number of Swarm Nodes: (example: [6])
Number of Client Nodes: (example: [5])
```

You will then be asked if you want to add another job. You may add as many experiments as you like during this time. To continue, input `n`. You will then be brought to the `config/config.json` file in a terminal text editor (nano). You may use the arrow keys to navigate and change the needed values. Once done, press CTRL + O to bring up the save prompt. After saving, press CTRL + X to exit and continue. Follow similar suit for the Docker Swarm template and Dedicate scripts that will follow.

Confirm all information is correct and start the experiment once prompted.

## Re-starting an Experiment via JobManager
Your previously entered experiments via JobManager are automatically saved once entered. You may view them via `python3 JobManager.py -custom`. You can re-run any given experiment by simply typing in the job ID once prompted and entering in the correct `config/config.json`, Docker Swarm, and Dedicate values.

## Deleting a Saved Experiment via JobManager
You can delete any saved experiment in JobManager with `python3 JobManager.py -remove` and selecting the job to remove when prompted.

## Editing a Saved Experiment via JobManager
You may edit any experiment saved in JobManager with `python3 JobManager.py -edit` and selecting the job to edit. This will bring up an in-terminal text editor where you can edit the values inputted into the control script. The lines of each job are as follows:
```
CloudLab Username
Total path of private ssh key
Hostname of controller node
Github email address
Number of Swarm Nodes
Number of Client Nodes
```
Please make sure to keep each value on a seperate line similar to how it already looks before making edits.

## Chaining Jobs via JobManager
One of the strong-suits of JobManager is that you can chain together experiments to test multiple bottleneck triggers with one script run. Enter the chain manager with `python3 JobManager.py -chain`. You will be given a choice of jobs to chain from from your custom jobs library. You may go back and add as many jobs with the regular job instantiation `python3 JobManager.py`. Select the jobs to chain by entering in the job ID followed by a space, then the next job ID. 

After entering in all desired jobs, the `config/config.json`, Docker Swarm, and Dedicate files will populate for the first experiment. Enter as needed, then continue. The experiment will run as usual and once returned will automatically start the next experiment with configuring the containers to use via Docker Swarm in-line text editing.

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

## Issues
1. We currently do not have a reliable way to determine the constraints in `docker-compose-swarm-yml.template`, specifically whether it should be `infosphere` or `infosphere-pg0` as it seems to be determined based on what host you use. To figure out the correct hostname for your experiment, `ssh` into one of the nodes and type `hostname`.
2. The upstream repository, [DeathStarBench](https://github.com/delimitrou/DeathStarBench), had changes that broke the experiment resulting in certain logs (specifically `post-storage-service.log`). Therefore we implemented a temporary fix in `setup_docker_swarm.py` where we checkout to the last commit before the issue, `b2b7af9`. This is a temporary fix and should be removed once the upstream gets fixed or we changed the rubbos code affected by the upstream changes.

## TODO

- replace bind mount into volumes or docker config
- **migrate to k8s**
