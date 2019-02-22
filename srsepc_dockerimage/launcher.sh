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

./pod_ip_rest.sh &
./dns_replace.sh
cat /srsLTE/build/srsepc/src/epc.conf
cat /srsLTE/build/srsepc/src/mbms.conf
cat /srsLTE/build/srsepc/src/$db_file.csv

# temporary fix, user db file ignored by srslte
cp /srsLTE/build/srsepc/src/$db_file.csv /root/.srs/user_db.csv 

if [ -z "$local_pod_addr" -o "$tunnelling" = "yes" ]; then
    ./srsLTE/build/srsepc/src/srsepc_if_masq.sh `ip route get 1 | awk '{print $(NF-4);exit}'`
fi

./srsLTE/build/srsepc/src/srsepc /srsLTE/build/srsepc/src/epc.conf &

child=$!

wait "$child"
