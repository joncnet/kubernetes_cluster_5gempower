#!/bin/sh

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child"
}

trap _term TERM

echo -e "\n\n---------- ENV VARIABLES ----------"
env


until nc -z localhost 27017
do
    echo "waiting for mongodb to come up..."
    sleep 2
done

sleep 5

mongoimport --db nextepc --collection accounts --file /accounts.json
mongoimport --db nextepc --collection subscribers --file /subscribers.json

/usr/sbin/sshd
/setup.sh
/usr/bin/nextepc-epcd

child=$!

wait "$child"

