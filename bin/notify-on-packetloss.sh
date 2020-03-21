#!/usr/bin/env bash
# Send a macos notification when packetloss is detected
# Author @0xADADA

trap '' EXIT

GATEWAY=$(netstat -rn | grep 'default' | head -n 1 | awk '{print $2}')
# GATEWAY="10.255.244.19"
COUNT_PACKETS=0
COUNT_DROPPED=0
FAIL_PER=0

while true; do
  DATE=$(date +'%Y-%m-%d %H:%M:%S')
  COUNT_PACKETS=$(($COUNT_PACKETS + 1))
  NETWORK_STATE=$(ifconfig en0 | rg 'status:' | awk '{print $2}') # active|inactive
  # run only if the network interface is active
  if [[ "${NETWORK_STATE}" == "active" ]]; then
    PING_MS=$(ping -c 1 -W 500 -q $GATEWAY | rg 'round-trip' | awk '{print $4}')
    echo "${DATE} response: ${PING_MS}"
    if (( $? != 0 )); then
      COUNT_DROPPED=$(($COUNT_DROPPED + 1))
      FAIL_PER=$(echo $(bc <<< "scale=2; $COUNT_DROPPED / $COUNT_PACKETS * 100"))
      MESSAGE="Dropped $COUNT_DROPPED of $COUNT_PACKETS packets: $FAIL_PER%"
      echo $MESSAGE
      SCRIPT="$(echo display notification \"$MESSAGE\" with title \"Packetloss\")"
      echo \'"$SCRIPT"\' | xargs osascript -e
    fi
    sleep 1
  else
    echo "${DATE} network inactive"
    sleep 10
  fi
done