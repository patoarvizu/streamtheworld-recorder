#!/bin/bash

while :; do
  case $1 in

    -s|--call-signal)
      CALL_SIGNAL=$2
      shift 2;;

    -l|--time-length)
      TIME_LENGTH=$2
      shift 2;;

    -d|--destination-path)
      DESTINATION_PATH=$2
      shift 2;;

    -n|--recording-name)
      RECORDING_NAME=$2
      shift 2;;

    *)
      if [[ -z $CALL_SIGNAL ]]; then
        echo "--call-signal flag is expected"
      fi
      TIME_LENGTH=${TIME_LENGTH:-60}
      DESTINATION_PATH=${DESTINATION_PATH:-/recordings/}
      RECORDING_NAME=${RECORDING_NAME:-$(date +%y-%m-%d-%H-%M)}
      shift
      break;;
  esac
done

servers=$(curl -s "http://playerservices.streamtheworld.com/api/livestream?version=1.5&mount=$CALL_SIGNAL&lang=en" | xml2json | jq '.live_stream_config.mountpoints.mountpoint.servers.server')

for i in $(seq 0 $(echo $servers | jq -r 'length - 1')); do
  server_info=$(echo $servers | jq '.['$i']')
  server_id=$(echo $server_info | jq -r '.sid')
  ip=$(echo $server_info | jq -r '.ip["$t"]')
  for j in $(seq 0 $(echo $server_info | jq -r '.ports.port | length - 1')); do
    protocol=$(echo $server_info | jq -r '.ports.port['$j'].type')
    port=$(echo $server_info | jq -r '.ports.port['$j']["$t"]')
    mkdir -p /tmp/.recordings
    mplayer $protocol://$ip:$port/$CALL_SIGNAL -forceidx -dumpstream -dumpfile /tmp/.recordings/$RECORDING_NAME-$CALL_SIGNAL-$server_id-$port.mp3 & pid=$!
    (sleep $TIME_LENGTH && kill -9 $pid) &
  done
done

wait

mkdir -p $DESTINATION_PATH
cp /tmp/.recordings/* $DESTINATION_PATH/