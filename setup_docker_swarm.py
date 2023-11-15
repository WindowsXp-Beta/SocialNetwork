from fabric import ThreadingGroup
import subprocess
import shlex
import argparse
import re
import os
from pathlib import Path

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', '--number', type=int, required=True, help='Docker Swarm Cluter Size')
    parser.add_argument('-a', '--ip', type=str, required=True, help='Mgr IP')
    parser.add_argument('-cn', '--client-number', type=int, required=True, help='Client Cluster Size')
    return parser.parse_args()

install_docker = '''sudo apt-get update && \
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install \
ca-certificates curl gnupg lsb-release && \
sudo install -m 0755 -d /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update && \
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
docker-ce docker-ce-cli containerd.io'''
install_collectl = 'sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y collectl'
install_sysdig = 'sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y sysdig'
clone_official_socialnetwork_repo = 'ssh-keygen -F github.com || ssh-keyscan github.com >> ~/.ssh/known_hosts && git clone https://github.com/delimitrou/DeathStarBench.git'
args = parse_args()

with ThreadingGroup(*[f'node-{idx}' for idx in range(0, args.number)]) as swarm_grp, \
     ThreadingGroup(*[f'node-{idx}' for idx in range(args.number, args.number + args.client_number)]) as client_grp:
    swarm_grp.run(install_collectl)
    print('** collectl installed **')
    swarm_grp.run(clone_official_socialnetwork_repo)
    print('** socialNetwork cloned **')
    swarm_grp.run(install_docker)
    print('** docker installed **')

    def stop_swarm_cluster():
        swarm_grp.run('sudo docker swarm leave')
        subprocess.run(shlex.split('sudo docker swarm leave -f'))
    # stop_swarm_cluster()
    def clear_env():
        swarm_grp.run('sudo apt-get -y purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras')
        swarm_grp.run('for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done')
        swarm_grp.run('sudo rm -rf /var/lib/containerd')
        swarm_grp.run('sudo rm -rf /var/lib/docker')
        swarm_grp.run('sudo rm /etc/apt/keyrings/docker.gpg')
    # clear_env()

    ret = subprocess.run(['sudo', 'docker', 'swarm', 'init', '--advertise-addr', args.ip], capture_output=True)
    print('** swarm manager initialized **')
    swarm_join_cmd_ptn = r'(docker swarm join --token .*:\d+)'
    swarm_join_cmd = re.search(swarm_join_cmd_ptn, ret.stdout.decode('utf-8'))
    if swarm_join_cmd is None:
        print('Don\'t find match pattern for docker swarm join:')
        print(f'The ret of swarm init is {ret}')
        exit(0)
    else:
        swarm_join_cmd = swarm_join_cmd.group()
    with ThreadingGroup.from_connections(swarm_grp[1:]) as grp_worker:
        grp_worker.run('sudo ' + swarm_join_cmd)
        grp_worker.run('if [ ! -e "$HOME/.ssh/config" ]; then echo -e "Host *\n\tStrictHostKeyChecking no" >> $HOME/.ssh/config; fi')
        grp_worker.put(Path.home()/'.ssh'/'id_rsa', '.ssh')
    print('** swarm cluster ready **')

    subprocess.run(shlex.split('sudo docker service create --name registry \
                               --publish published=5000,target=5000 registry:2'))
    print('** registry service created **')

    client_grp[0].run(install_sysdig)
    client_grp.put(Path.home()/'.ssh/id_rsa', '.ssh')
    client_grp.run('if [ ! -e "$HOME/.ssh/config" ]; then echo -e "Host *\n\tStrictHostKeyChecking no" >> $HOME/.ssh/config; fi')
    client_grp.put(Path.home()/'RubbosClient.zip')
    client_grp.run('unzip RubbosClient.zip')
    client_grp.run('mv RubbosClient/elba .')
    client_grp.run('mv RubbosClient/rubbos .')
    client_grp.run('gcc /users/XinpengW/elba/rubbos/RUBBoS/bench/flush_cache.c -o /users/XinpengW/elba/rubbos/RUBBoS/bench/flush_cache')
    print('** RubbosClient copied **')

    os.chdir(Path.home())
    for file in ['src', 'RubbosClient_src', 'socialNetwork', 'scripts_limit']:
        subprocess.run(shlex.split(f'unzip {file}.zip'))
    subprocess.run(shlex.split('mv DeathStarBench/socialNetwork/src DeathStarBench/socialNetwork/src.bk'))
    subprocess.run(shlex.split('mv src DeathStarBench/socialNetwork/'))
    os.chdir(Path.home()/'DeathStarBench'/'socialNetwork')
    subprocess.run(shlex.split('sudo docker build -t 127.0.0.1:5000/social-network-microservices:withLog_01 .'))
    subprocess.run(shlex.split('sudo docker push 127.0.0.1:5000/social-network-microservices:withLog_01'))
    print('** customized socialNetwork docker image built **')

    os.chdir(Path.home())
    subprocess.run('mv socialNetwork/* DeathStarBench/socialNetwork/', shell=True)
    subprocess.run('mv socialNetwork/scripts/*.sh DeathStarBench/socialNetwork/scripts/', shell=True)
    os.chdir(Path.home()/'DeathStarBench'/'socialNetwork')
    subprocess.run(shlex.split('sudo ./start.sh start'))
    print('** socialNetwork stack deployed **')

    os.chdir(Path.home()/'RubbosClient_src')
    subprocess.run(shlex.split('mvn clean'))
    subprocess.run(shlex.split('mvn package'))
    subprocess.run('./cpToCloud.sh')
    print('** client binary distributed **')

    # we move register here to ensure all the services have launched
    os.chdir(Path.home()/'DeathStarBench'/'wrk2')
    subprocess.run('make')
    subprocess.run(shlex.split('sudo apt-get -y install libssl-dev libz-dev luarocks'))
    subprocess.run(shlex.split('sudo luarocks install luasocket'))
    os.chdir(Path.home()/'DeathStarBench'/'socialNetwork')
    subprocess.run(shlex.split('./start.sh register'))
    subprocess.run(shlex.split('./start.sh compose'))
    print('** socialNetwork data created **')

    subprocess.run(shlex.split('sudo ./start.sh dedicate'))
    print('** core dedicated **')