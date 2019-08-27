#!/bin/bash

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child"
}

trap _term SIGTERM

env

./env_replace.sh
./generate_certificate.sh
cat /etc/ipsec.conf
cat /etc/ipsec.secrets

#./rules.sh

./usr/sbin/ipsec start --nofork --debug-all

child=$!

wait "$child"
