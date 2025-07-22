#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

user_at_host=$1

ssh $user_at_host "DISPLAY=:0 xwd -display :0 -root -out /tmp/screenshot.xwd && convert /tmp/screenshot.xwd /tmp/screenshot.png"
scp $user_at_host:/tmp/screenshot.png /tmp/screenshot.png
open /tmp/screenshot.png
