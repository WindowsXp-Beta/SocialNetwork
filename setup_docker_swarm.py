from fabric import ThreadingGroup
import subprocess
import shlex
import argparse
import re
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
    swarm_grp.run(clone_official_socialnetwork_repo)
    swarm_grp.run(install_docker)

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

    client_grp[0].run(install_sysdig)
    client_grp[0].put(Path(Path.home()), 'DeathStarBench/socialNetwork')
    client_grp.put(Path(Path.home(), 'RubbosClient.zip'))
    client_grp.run('unzip RubbosClient.zip')
    client_grp.run('mv RubbosClient/elba .')
    client_grp.run('mv RubbosClient/rubbos .')
    client_grp.run('ls')