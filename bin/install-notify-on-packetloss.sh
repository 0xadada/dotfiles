#!/usr/bin/env bash
# Installs notify-on-packetloss.sh
# Author @0xADADA

cp \
  "${HOME}/bin/pub.0xadada.notify-on-packetloss.plist" \
  "${HOME}/Library/LaunchAgents/pub.0xadada.notify-on-packetloss.plist"

# edit path in the ProgramArguments value
sed -i -e "s/USER/$USER/g" \
  ~/Library/LaunchAgents/pub.0xadada.notify-on-packetloss.plist

# install it
launchctl remove pub.0xadada.notify-on-packetloss
launchctl load \
  "/Users/${USER}/Library/LaunchAgents/pub.0xadada.notify-on-packetloss.plist"
result=$?

if (( $result != 0 )); then
  echo "Failed to install with code: ${result}"
else
  pid=$(launchctl list | rg 'pub.0xadada.notify-on-packetloss' | awk '{print $1}')
  echo "Installed launchd service 'pub.0xadada.notify-on-packetloss' with PID ${pid}"
fi