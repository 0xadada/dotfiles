#!/usr/bin/env bash
# Send a macos notification when packetloss is detected
# Author @0xADADA

GATEWAY=$(netstat -rn | grep 'default' | head -n 1 | awk '{print $2}')
# GATEWAY="10.255.244.19"
COUNT_PACKETS=0
COUNT_DROPPED=0
FAIL_PER=0

while true; do
  DATE=$(date +'%H:%M:%S.%s')
  COUNT_PACKETS=$(($COUNT_PACKETS + 1))
  ping -c 1 -W 150 -q $GATEWAY &>/dev/null
  if (( $? != 0 )); then
    COUNT_DROPPED=$(($COUNT_DROPPED + 1))
    FAIL_PER=$(echo $(bc <<< "scale=2; $COUNT_DROPPED / $COUNT_PACKETS * 100"))
    MESSAGE="Dropped $COUNT_DROPPED of $COUNT_PACKETS packets: $FAIL_PER%"
    echo $MESSAGE
    SCRIPT="$(echo display notification \"$MESSAGE\" with title \"Packetloss\")"
    echo \'"$SCRIPT"\' | xargs osascript -e
  fi
  sleep 1
done