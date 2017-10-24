#!/bin/bash
exec 2>&1

SRC_DIR="/scripts/nationalparks"
FILEEXT="hart"
HART=`ls -tr1d "${SRC_DIR}/"*.${FILEEXT} 2>/dev/null | tail -1`

if pgrep -x "java" > /dev/null
then
        echo "java process is Running"
        processid=`ps -eaf | grep hab-sup | awk '{print $2,$3}' | head -n 1`
        kill -9 $processid
        echo "java process killed"
else
        echo "java process is not running"
fi

if pgrep -x "hab-sup" > /dev/null
then
        echo "hab-sup process is Running"
        processid=`ps -eaf | grep hab-sup | awk '{print $2,$3}' | head -n 1`
        kill -9 $processid
        echo "hab-sup process killed"
else
        echo "hab-sup process is not running"
        nohup hab sup start $HART >> /scripts/sup-national-parks.log 2>1 &
fi
