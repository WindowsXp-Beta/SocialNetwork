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
      git_email=$3
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

# clone env_setup repo in manager node
ssh -o StrictHostKeyChecking=no -i ${private_ssh_key_path} ${username}@${controller_node} "
    ssh-keygen -F github.com || ssh-keyscan github.com >> ~/.ssh/known_hosts
    git config --global user.email ${git_email}
    git config --global user.name ${username}
    git clone git@github.com:WindowsXp-Beta/SocialNetwork.git SetupScripts
    sudo apt-get update
    sudo apt-get install -y pip maven
    cd SetupScripts
    pip install -r requirements.txt
    python setup_docker_swarm.py
"