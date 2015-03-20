#!/bin/bash
nt=./netcat.sh
cgi=./cgi.sh
case $1 in
#run server using netcat 
-n)
	$nt
	;;
#run server using tcpserver in daemon mode
-b)
	nohup tcpserver localhost 8080 $cgi &
	;;
#run server using tcpserver
*)
	tcpserver localhost 8080 $cgi
	;;
esac
