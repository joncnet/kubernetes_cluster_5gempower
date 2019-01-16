#!/bin/sh

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child"
}

trap myterm SIGTERM

env
./db_downloader.sh
./empower-runtime/empower-runtime.py &

child=$!

wait "$child"
