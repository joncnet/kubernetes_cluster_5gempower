#!/bin/bash

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child"
}

trap myterm SIGTERM

env
./pod_ip_rest.sh &
./dns_replace.sh
cat /srsLTE/build/srsepc/src/epc.conf
cat /srsLTE/build/srsepc/src/mbms.conf
./srsLTE/build/srsepc/src/srsepc_if_masq.sh `ip route get 1 | awk '{print $(NF-4);exit}'`
./srsLTE/build/srsepc/src/srsepc /srsLTE/build/srsepc/src/epc.conf &

child=$!

wait "$child"
