#!/bin/bash

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child"
  kill -INT "$child"
}

trap _term SIGTERM

env
/usr/share/openvswitch/scripts/ovs-ctl start
./mec_agent.py

child=$!

wait "$child"
