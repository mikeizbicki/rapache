#!/bin/bash
#running server using tcpserver which can hanlde multiple tcp connections
nohup tcpserver localhost 8080 ./http-stdin.sh &

