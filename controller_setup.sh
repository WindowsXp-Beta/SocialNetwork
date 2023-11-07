#!/bin/bash

# Copyright (C) 2022 Georgia Tech Center for Experimental Research in Computer
# Systems
# Source:

# Setup the specified node to run the `benchmarkcontroller` application.


# Process command-line arguments.
set -u
while [[ $# > 1 ]]; do
  case $1 in
    --username )
      username=$2
      ;;
    --private_ssh_key_path )
      private_ssh_key_path=$2
      ;;
    --controller_node )
      controller_node=$2
      ;;
    --git_email )
      git_email=$2
      ;;
    --social_network_path )
      social_network_path=$2
      ;;
    --node_number )
      node_number=$2
      ;;
    * )
      echo "Invalid argument: $1"
      exit 1
  esac
  shift
  shift
done

# Copy the SSH private key to the controller node.
scp -o StrictHostKeyChecking=no -i ${private_ssh_key_path} ${private_ssh_key_path} ${username}@${controller_node}:.ssh/id_rsa
scp -o StrictHostKeyChecking=no -i ${private_ssh_key_path} -r ${social_network_path} ${username}@${controller_node}:socialNetworkLSU

# clone env_setup repo in manager node
ssh -o StrictHostKeyChecking=no -i ${private_ssh_key_path} ${username}@${controller_node} "
    ssh-keygen -F github.com || ssh-keyscan github.com >> ~/.ssh/known_hosts
    git config --global user.email ${git_email}
    git config --global user.name ${username}
    git clone git@github.com:WindowsXp-Beta/SocialNetwork.git SetupScripts
    git clone https://github.com/delimitrou/DeathStarBench.git
    unzip socialNetworkLSU
    sudo apt-get update
    sudo apt-get install -y python3-pip maven
    cd SetupScripts
    pip3 install -r requirements.txt
    python setup_docker_swarm.py -a 10.10.1.1 -n ${node_number}
"