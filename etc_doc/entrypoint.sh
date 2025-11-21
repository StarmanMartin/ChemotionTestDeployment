#!/bin/bash

REPO_CHECK="ComPlat/chemotion_ELN"

INTERVAL=${UPDATE_INTERVAL:-600}            # Seconds between checks

echo "" > last_commit.txt
echo "" > $PIDFILE
last_process=""

while true; do
    source ./set_git_branch.sh

    new_commit=$(git  ls-remote https://github.com/$REPO_CHECK.git refs/heads/$ELN_BRANCH)
    PID=$(cat $PIDFILE)
    if ! ps -p $PID > /dev/null || [[ "$new_commit" != $(cat last_commit.txt) ]]; then
        echo "[$(date)] New commit detected: $REPO_CHECK -> $ELN_BRANCH: $new_commit"

        echo "$new_commit" > last_commit.txt
        kill -TERM -$PID
        source ./clone_repo.sh
        source ./run_scripts.sh
        setsid ./run.sh &
    fi
    sleep $INTERVAL
done