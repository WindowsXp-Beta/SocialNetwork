from fabric import ThreadingGroup
import subprocess
import shlex
import argparse
import re

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', '--number', type=int, required=True, help='Docker Swarm Cluter Size')
    parser.add_argument('-ip', '--ip', type=str, required=True, help='Mgr IP')
    return parser.parse_args()

install_docker = '''sudo apt-get update && \
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install \
ca-certificates curl gnupg lsb-release && \
sudo mkdir -p /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update && \
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
docker-ce docker-ce-cli containerd.io'''
args = parse_args()
# proc = subprocess.Popen(shlex.split(install_docker))

with ThreadingGroup(*[f'node-{idx}' for idx in range(1, args.number)]) as grp:
    # res = grp.run(install_docker)
    # while True:
    #     try:
    #         proc.wait(1)
    #     except subprocess.TimeoutExpired as timeout:
    #         continue
    #     break
    def stop_swarm_cluster():
        grp.run('sudo docker swarm leave')
        subprocess.run(shlex.split('sudo docker swarm leave -f'))
    # stop_swarm_cluster()
    ret = subprocess.run(['sudo', 'docker', 'swarm', 'init', '--advertise-addr', args.ip], capture_output=True)
    swarm_join_cmd_ptn = r'(docker swarm join --token .*:\d+)'
    swarm_join_cmd = re.search(swarm_join_cmd_ptn, ret.stdout.decode('utf-8'))
    if swarm_join_cmd is None:
        print('Don\'t find match pattern for docker swarm join:')
        print(f'The ret of swarm init is {ret}')
        exit(0)
    else:
        swarm_join_cmd = swarm_join_cmd.group()
    grp.run('sudo ' + swarm_join_cmd)