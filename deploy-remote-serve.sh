#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

allowed_actions=("start" "stop" "cleanup")
if [ -z "${1:-}" ] || ! [[ " ${allowed_actions[@]} " =~ " ${1} " ]]; then
    echo "Usage: $0 COMMAND <remote_user> <remote_host>"
    echo "COMMAND can be one of: ${allowed_actions[@]}"
    echo "start implies stop first"
    exit 1
fi

desired_action=$1
shift
remote_user=$1
remote_host=$2
shift 2

if [ "$desired_action" == "cleanup" ]; then
    ssh $remote_user@$remote_host "rm -rf /tmp/ratvnc-started-at-*.XXXXXX"
    exit 0
fi

if [ "$desired_action" == "start" ] || [ "$desired_action" == "stop" ]; then
    ssh $remote_user@$remote_host "pkill -f remote-serve.sh" || echo "No remote-serve.sh process found"
fi

if [ "$desired_action" == "start" ]; then
    remote_temp_dir=$(ssh $remote_user@$remote_host "mktemp -d /tmp/ratvnc-started-at-$(date +%s).XXXXXX")
    scp $script_dir/remote-serve.sh $remote_user@$remote_host:$remote_temp_dir/remote-serve.sh
    ssh -f $remote_user@$remote_host "nohup bash $remote_temp_dir/remote-serve.sh > /dev/null 2>&1 & exit"
    open http://$remote_host:8000/screenshot-latest.png
fi

