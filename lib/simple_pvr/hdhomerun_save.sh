#!/bin/bash

hdhomerun_config $1 save /tuner$2 "$3" > "$4" 2>&1 &
COMMAND_PID=$!

while [ -f $5 ]; do
	sleep 1
done

kill -SIGINT $COMMAND_PID