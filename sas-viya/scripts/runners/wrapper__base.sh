#!/bin/bash
if [ -e "$HOME/.profile" ]; then
	. $HOME/.profile
fi
if [ -e "$HOME/.bash_profile" ]; then
	. $HOME/.bash_profile
fi
#set -x
#set -v
ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# import the exported global source
. "/sas/install/env.ini"

#Setup the watcher locations to target
PID_FILE="/tmp/install_runner.pid"
RETURN_FILE="/tmp/install_runner.out"
FILE_OF_RECORD="/var/log/sas/install/install_runner.log"
if [ -z "$TOUCHPOINT_FILE" ]; then
    TOUCHPOINT_FILE="$RETURN_FILE"
fi
if [ -z "$FINAL" ]; then
    FINAL="0"
fi

if [ ! -e "$PID_FILE" ]; then
    if [ ! -e "$RETURN_FILE" ]; then
        touch "$FILE_OF_RECORD"
        chmod 600 "$FILE_OF_RECORD"
        cd "${ScriptDirectory}"
        nohup "${ScriptDirectory}/install_runner_base.sh" "$RETURN_FILE"  </dev/null &> "$FILE_OF_RECORD" &
        PID=$!
        echo $PID > "$PID_FILE"
    else
        exit $(cat $RETURN_FILE)
    fi
else
    if [ ! -e "$RETURN_FILE" ]; then
        PID="$(cat "$PID_FILE")"
        if ! kill -s 0 $PID; then
            echo "Install did not write return file. Assuming install is dead"
            exit 1
        fi
    else
        exit $(cat $RETURN_FILE)
    fi
fi

#tail -100f "$FILE_OF_RECORD" &
#tail_command_pid=$!
# one hour and 0 min
TIME_TO_LIVE_IN_SECNDS=$((60*60))
CURRENT_TIME_ALIVE_IN_SECONDS=0
# wait for an hour or until the child process finishes.
while [ "$TIME_TO_LIVE_IN_SECNDS" -gt "$CURRENT_TIME_ALIVE_IN_SECONDS" ] && kill -s 0 $PID && [ ! -e "$TOUCHPOINT_FILE" ]; do
    sleep 1
    CURRENT_TIME_ALIVE_IN_SECONDS=$((CURRENT_TIME_ALIVE_IN_SECONDS+1))

done
#kill $tail_command_pid
tail -1000 "$FILE_OF_RECORD"
if [ -e "$RETURN_FILE" ]; then
    # if we hit the end and have a return file, then return the value of that (which is the value of the underlying script
    exit $(cat $RETURN_FILE)
else
    if kill -s 0 $PID; then
        # if the script phase is 8, or finishing, then the system still running is a problem and return a 1
        if [ "$FINAL" -eq "1" ]; then
            echo ""
            echo "Script did not finish by the end of the time allotted. The install may still finish successfully, but to be sure you will need to check ansible: $FILE_OF_RECORD"
            exit 1
        else
            # if the process is still running and we just ran out of time, return 0
            exit 0
        fi
    else
        # if the process is not running and we don't have a return file, then something went wrong and investigation should happen
        echo ""
        echo "Install finished with errors. For more details, please check ansible:/tmp/install_run_orchestration.log"
        exit 1
    fi
fi
