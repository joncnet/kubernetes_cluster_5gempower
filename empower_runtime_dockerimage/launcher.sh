#!/bin/sh

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child"
}

trap _term SIGTERM

env
./db_downloader.sh

if [ "$empower_app" ]; then
    ./empower-runtime/empower-runtime.py apps.$empower_app --tenant_id=$empower_tenant_id &
else
    ./empower-runtime/empower-runtime.py &
fi

child=$!

wait "$child"
