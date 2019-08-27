#!/bin/sh

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child"
}

trap _term SIGTERM

echo "\n\n---------- ENV VARIABLES ----------"
env
./db_downloader.sh

echo "\n\n---------- GIT INFO ---------------"
git --no-pager -C /empower-runtime log -1

echo "\n\n------ EMPOWER RUNTIME BEGIN ------"

#if [ "$empower_app" ]; then
#    ./empower-runtime/empower-runtime.py apps.$empower_app --tenant_id=$empower_tenant_id &
#else
#    ./empower-runtime/empower-runtime.py &
#fi

./empower-runtime/empower-runtime.py $empower_params

child=$!

wait "$child"

