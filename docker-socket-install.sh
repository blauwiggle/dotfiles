#!/bin/sh
# Install the root LaunchDaemon that recreates /var/run/docker.sock -> OrbStack's socket at every boot.
# Run once on the Mac mini with admin rights: ssh -t michi@mac-mini-m4 'sudo sh ~/dotfiles/docker-socket-install.sh'
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
cd "$(dirname "$0")"
dst=/Library/LaunchDaemons/com.blauwiggle.docker-socket.plist
install -m 644 -o root -g wheel launchd/com.blauwiggle.docker-socket.plist "$dst"
launchctl bootout system "$dst" 2>/dev/null || true
launchctl bootstrap system "$dst"
ls -l /var/run/docker.sock
