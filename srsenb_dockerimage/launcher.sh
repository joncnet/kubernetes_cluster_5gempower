#!/bin/bash

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child"
}

trap _term SIGTERM

env

if [ "$tunnelling" = "yes" ]; then
    export local_ip=$(ip route get 1 | awk '{print $(NF-2);exit}')
    ./tunnel_setup.py
fi

./dns_replace.sh
cat /empower-srsLTE/build/srsenb/src/enb.conf
./empower-srsLTE/build/srsenb/src/srsenb /empower-srsLTE/build/srsenb/src/enb.conf &

child=$!

wait "$child"
