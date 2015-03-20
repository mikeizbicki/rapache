#!/bin/bash

#TMPFILE is a unique filename
TMPFILE=$(mktemp -ut tmp_pipe.XXXXXXX) || exit 1

#make a pipe with this unique name
mkfifo "$TMPFILE"

doBreak=0

#trap SIGINT and cause it to set doBreak to 1
trap "doBreak=1" SIGINT

while true; do
	nc -l 8080 < $TMPFILE | ./cgi.sh > $TMPFILE

	#if SIGINT has been received, break the loop
	if [ "$doBreak" -eq 1 ]; then
		#delete the temp file
		rm "$TMPFILE"
		break
	fi
done
