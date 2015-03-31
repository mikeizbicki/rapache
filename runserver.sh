#!/bin/sh

# check parameters
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "usage: $0 protocolscript port"
    exit 1
fi

# make a pipe with a unique filename
# FIXME: there is a minor race condition bug in this code
TMPFILE=$(mktemp -ut tmp_pipe.XXXXXXX) || exit 1
mkfifo "$TMPFILE"

# loop until SIGINT is received
notdone=0
trap "notdone=1" INT

while [ $notdone = 0 ]; do
	nc -lp 8080 < $TMPFILE | "$1" > $TMPFILE
done

# clean up
rm "$TMPFILE"

# FIXME: every other web request has a broken connection;
# to get the points, you'll have to make every web request succeed
