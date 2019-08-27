#!/bin/sh

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$child"
}

trap _term TERM

#echo "\n\n---------- ENV VARIABLES ----------"

sleep 600000

child=$!

wait "$child"

