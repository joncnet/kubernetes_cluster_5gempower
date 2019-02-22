#!/usr/bin/env python3

import requests
import os
import socket
import subprocess
from time import sleep


def run_command(*command):

    result = subprocess.run(command,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            shell=True)

    err = result.stderr.decode('utf-8')

    if err != '':
        raise ValueError(err)

    return result.stdout.decode('utf-8')

print('Tunnel setup tool')
print('resolving mec service name')

mec_ip = None

while not mec_ip:
    try:
        print('waiting MEC service')
        mec_ip = socket.gethostbyname('mecservice')
        sleep(5)
    except:
        pass

root_url = 'http://%s:8000' % mec_ip

response = None
code = 404

while code == 404:
    try:
        print('waiting MEC pod ip')
        response = requests.get('%s/podip' % root_url)
        code = response.status_code
        sleep(5)
    except:
        pass

if code != 200:
    print(response)
    raise ValueError()

mec_pod_ip = response.text

epc_id = os.environ['tac']
local_ip = os.environ['local_ip']

print('creating local tunnel on mec server')
response = requests.put('%s/tunnels/%s?local_ip=%s'
                        % (root_url, epc_id, local_ip))
if response.status_code != 201:
    print(response)
    raise ValueError()

print('local tunnel created on mec server')

data = response.json()
tunnel_ip = data['tunnel_ip']

print('creating tunnel on local container')
run_command('ip link add %s type gretap local %s remote %s'
            % (epc_id, local_ip, mec_pod_ip))
run_command('ifconfig %s up' % epc_id)
run_command('ifconfig %s %s/24' % (epc_id, tunnel_ip))

print('tunnel on local container created')
#print(tunnel_ip)

