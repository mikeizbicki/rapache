rapache
=======
Rapache is a simple Common Gateway Interface(CGI) webserver written in bash.

How to use
-------
1. Clone `rapache` to your machine.
2. Enter `rapache` directory.
3. Run `./run.sh` to start server.
```
$ git clone https://github.com/Dongdongshe/rapache
$ cd rapache
$ ./run.sh
```
Examples
---------
Run server using tcpserver which can handle multiple connections
```
./run.sh
```
Run server using netcat which response to one conection a time.
```
./run.sh -n
```
Run server using tcpserver in deamon mode
```
./run.sh -b
```
prerequisites
---------
1.`bash`,any version should work.
2.`netcat` or `tcpserver` to handle TCP connection.

Feature
-----------
1. Rapache supports HTTP GET and POST methods.
2. Rapache implemnts two ways(netcat or tcpserver) to handle tcp connections.
3. Rapache supports running in deamon mode by adding `-b` flag.

