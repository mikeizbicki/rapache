#!/bin/bash

#TMPFILE is a unique filename
TMPFILE=$(mktemp -ut tmp_pipe.XXXXXXX) || exit 1

#make a pipe with this unique name
mkfifo "$TMPFILE"

doBreak=0

#trap SIGINT and cause it to set doBreak to 1
trap "doBreak=1" SIGINT

while true; do
	nc -l 8080 < $TMPFILE | ./http-stdin.sh > $TMPFILE

	#if SIGINT has been received, break the loop
	if [ "$doBreak" -eq 1 ]; then
		#delete the temp file
		rm "$TMPFILE"
		break
	fi
done

# FIXME: every other web request has a broken connection;
# to get the points, you'll have to make every web request succeed
