from fabric import ThreadingGroup

def grp_run_cmd(cmd: str):
    with ThreadingGroup(*[f'node-{idx}' for idx in range(0, 10)]) as grp:
        try:
            grp.run(cmd)
        except Exception as e:
            print(e)

# cmds = ['sudo kill -9 $(pgrep apt-get)', 'sudo dpkg --configure -a', 'sudo apt-get purge -y collectl sysdig']
# cmds = ['DEBIAN_FRONTEND=noninteractive sudo apt-get install -y collectl sysdig']
# cmds = ['sudo apt-get install -y libssl-dev libz-dev luarocks', 'sudo luarocks install luasocket']
cmds = ['ls']
for cmd in cmds:
    grp_run_cmd(cmd)