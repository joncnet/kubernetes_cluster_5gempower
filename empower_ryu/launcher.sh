#!/bin/sh

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child"
}

trap _term SIGTERM

echo -e "\n\n---------- ENV VARIABLES ----------"
env

echo -e "\n\n---------- GIT INFO ---------------"
git --no-pager -C /empower-ryu log -1

echo -e "\n\n-------- EMPOWER RYU BEGIN --------"
PYTHONPATH=/empower-ryu/ python3 empower-ryu/bin/ryu-manager --observe-links /empower-ryu/ryu/app/intent.py &

child=$!

wait "$child"
