#!/bin/bash

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child"
}

trap myterm SIGTERM

env
./dns_replace.sh
cat /empower-srsLTE/build/srsenb/src/enb.conf
./empower-srsLTE/build/srsenb/src/srsenb /empower-srsLTE/build/srsenb/src/enb.conf &

child=$!

wait "$child"
