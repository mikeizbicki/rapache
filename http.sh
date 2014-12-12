#!/bin/bash

# FIXME: what if the file named "pipe" already exists and is being used by something else?
mkfifo pipe
doBreak=0

#trap SIGINT and cause it to set doBreak to 1
trap "doBreak=1" SIGINT

while true; do
	nc -lp 8080 < pipe | ./http-stdin.sh > pipe

	#if SIGINT has been received, break the loop
	if [ doBreak=1 ]; then
		break
	fi
done


# FIXME: every other web request has a broken connection;
# to get the points, you'll have to make every web request succeed



