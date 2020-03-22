#!/usr/bin/env bash
# Send a macos notification when packetloss is detected
# Author @0xADADA

trap '' EXIT

count_packets=0
count_dropped=0
fail_per=0

while true; do
  datetime=$(date +'%Y-%m-%d %H:%M:%S')
  count_packets=$(($count_packets + 1))
  network_state="$(ifconfig en0 | grep 'status:' | awk '{print $2}')" # active|inactive
  # run only if the network interface is active
  if [[ "${network_state}" == "active" ]]; then
    gateway=$(netstat -rn | grep 'default' | head -n 1 | awk '{print $2}')
    ping="$(ping -c 1 -W 500 -q ${gateway} 2>&1)"
    result=$?
    packet_loss=$(echo "${ping}" | grep 'packet loss' | awk '{print $7}')
    logger -is -p 'user.notice' -t 'pub.0xadada.notify-on-packetloss' "packet ${count_packets} status ${packet_loss}"
    if (( $result != 0 )); then
      count_dropped=$(($count_dropped + 1))
      fail_per=$(echo $(bc <<< "scale=2; ${count_dropped} / ${count_packets} * 100"))
      message="packet ${count_packets} dropped ${fail_per}% of ${count_dropped} total"
      logger -is -p 'user.err' -t "pub.0xadada.notify-on-packetloss" "${message}"
      script="$(echo display notification \"${message}\" with title \"${fail_per}% packetloss\")"
      echo \'"${script}"\' | xargs osascript -e
    fi
    sleep 1
  else
    logger -is -p 'user.notice' -t "pub.0xadada.notify-on-packetloss" "network inactive"
    sleep 10
  fi
done