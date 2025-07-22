#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

python3 -m http.server 8000 --directory ${script_dir} &
server_pid=$!
trap "kill $server_pid" EXIT

max_stored=100
loop_counter=0
while true; do
    echo -ne "$loop_counter / $max_stored   \r"
    xwd -display :0 -root -out ${script_dir}/screenshot.xwd && convert ${script_dir}/screenshot.xwd ${script_dir}/screenshot-$loop_counter.png
    ln -sf ${script_dir}/screenshot-$loop_counter.png ${script_dir}/screenshot-latest.png
    loop_counter=$((loop_counter + 1))
    [ $loop_counter -ge $max_stored ] && loop_counter=0 || true
    sleep 1
done
