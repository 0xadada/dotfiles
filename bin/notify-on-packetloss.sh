#!/usr/bin/env bash
# Send a macos notification when packetloss is detected
# Author @0xADADA

trap 'echo -n "white" | nc -4u -w0 localhost 1738' EXIT # reset anybar upon exit

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
    # set anybar color to white every 5 packet/seconds
    if (( $count_packets % 5 == 0 )); then echo -n "white" | nc -4u -w0 localhost 1738; fi
    if (( $result != 0 )); then
      count_dropped=$(($count_dropped + 1))
      fail_per=$(bc <<< "${count_dropped} * 100 / ${count_packets}")
      # change anybar color based on packet dropped rate
      if (( $fail_per >= 1 )); then echo -n "green" | nc -4u -w0 localhost 1738; fi
      if (( $fail_per >= 3 )); then echo -n "yellow" | nc -4u -w0 localhost 1738; fi
      if (( $fail_per >= 5 )); then echo -n "orange" | nc -4u -w0 localhost 1738; fi
      if (( $fail_per >= 8 )); then echo -n "red" | nc -4u -w0 localhost 1738; fi
      if (( $fail_per >= 21 )); then echo -n "exclamation" | nc -4u -w0 localhost 1738; fi
      # compose messaging
      message="packet ${count_packets} dropped ${fail_per}% of ${count_dropped} total"
      logger -is -p 'user.err' -t "pub.0xadada.notify-on-packetloss" "${message}"
      script="$(echo display notification \"${message}\" with title \"${fail_per}% packetloss\")"
      echo \'"${script}"\' | xargs osascript -e
    fi
    sleep 1
  else
    logger -is -p 'user.notice' -t "pub.0xadada.notify-on-packetloss" "network inactive"
    # set anybar color to question
    echo -n "question" | nc -4u -w0 localhost 1738
    sleep 10
  fi
done