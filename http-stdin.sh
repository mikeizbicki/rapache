#!/bin/bash

# $webroot is the location of all the files
# by default, $webroot is current directory, but can be changed
# by setting $webroot variable before running rapache
if [ -z $webroot ]; then
    webroot="."
fi

# read in the http request from stdin
read cmd request protocol

# print the request to stderr
echo "$cmd $request $protocol" >&2

# urls have lots of weird characters in them like "%20" instead of spaces
# this function converts the weird encoding into normal ascii encoding
# input is stdin, output is stdout
function urldecode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

# the GET request is the most common http command
if [ "$cmd" = "GET" ]; then

    file=$webroot$(cut -d'?' -f1 <<< "$request")
    args=$(cut -d'?' -f2 <<< "$request")

    # if the requested file is a shell script, execute the script
    # this is a Computer Generated Information (CGI) webpage
    if [ ${file##*.} = "sh" ] && [ -f "$file" ]; then

        # FIXME: php, perl, python, and ruby are also popular languages for writing cgi scripts;
        # add support for one (or more) of these other languages

        for arg in $(tr '&' ' ' <<< "$args"); do
            arg=$(urldecode "$arg")
            export "$arg"
            echo "$arg" >&2
        done
        info=$($file)

        echo "HTTP/1.1 200 OK"
        echo "Content-length: ${#info}"
        echo ""
        echo "$info"

    # if the requested file is a CSS file,
    # we send the contents of the file to allow for complex formatting of webpages
    elif [ ${file##*.} = "css" ] && [ -f "$file" ]; then
         info=$(cat $file)
 
         echo "HTTP/1.1 200 OK"
         echo "Content-type: text/css"
         echo "Content-length: ${#info}"
         echo ""
         echo "$info"

    # the requested file is not a shell script, so just return the file exactly
    else
        
        #check if requested file is a directory
        if [ -d "$file" ]; then
            if [ -f "./$file/index.html" ]; then
                #display index.html
                info=$(cat "$file/index.html")

                echo "HTTP/1.1 200 OK"
                echo "Content-length: ${#info}"
                echo ""
                echo "$info"

            else
                #print out each file in the directory
                for entry in "$file"/*; do
                    echo "$entry"
                done
            fi
        #if requested file isn't a directory
        else
            info=$(cat "$file")
    
            # check if the file exists in order to use it
            if [ $? = 0 ]; then

                # if the file is an executable, we run it
                if [ -x "$file" ]; then
                    #$file $(tr '&' ' ' <<< "$args")
                    for arg in $(tr '&' ' ' <<< "$args"); do
                        arg=$(urldecode "$arg")
                        export "$arg"
                        echo "$arg" >&2
                    done
                    info=$($file)

                    echo "HTTP/1.1 200 OK"
                    echo "Content-length: ${#info}"
                    echo ""
                    echo "$info"

                # otherwise, we print it to stdout
                else
                    #check content-type via mime-type
                    CONTENT_TYPE=$(file --mime-type "$file")
                
                    echo "HTTP/1.1 200 OK"
                    echo -ne "Content-type: $CONTENT_TYPE"
                    echo "Content-length: ${#info}"
                    echo ""
                
                    #Its important that you 'cat' the file, because if it is echo'd, the
                    #binary data can get mangled.

                    cat $file

                fi

            # the file could not be accessed
            else
                echo ""
                 # This implements the 404 error page and checks if 404.html exists in the webroot directory.
                if [ ! -e "$file" ]; then
                    info=$(cat "$webroot/404.html")
                    # If the provided 404 page exists, we will display that page.
                    if [ $? = 0 ]; then
                        echo "HTTP/1.1 404 Not Found"
                        echo "Content-length: ${#info}"
                        echo ""
                        echo "$info"
                    # Else, if the provided 404 page does not exist, we will display a standard error page.
                    else
                        info="
                            <html>
                              <head>
                                <title>404 Not Found</title>
                              </head>
                              <body>
                                <h1>Not Found</h1>
                                <p>The requested URL $file was not found on this server.</p>
                              </body>
                            </html>
                        "
                        echo "HTTP/1.1 404 Not Found"
                        echo "Content-length:${#info}"
                        echo ""
                        echo "$info"
                    fi
                # This section of code handles 403: Forbidden Errors.
                elif ! [ -r "$file" ]; then
                    echo "HTTP/1.1 403 Forbidden"
                    error403=$(cat "$webroot/403.html")
                    # If $webroot/403.html exists, display that file.
                    if [ $? = 0 ]; then
                        echo "Content-length: ${#error403}"
                        echo ""
                        echo "$error403"
                    # Otherwise, display a default 403 error page.			
                    else
                        info="
                            <html>
                              <head>
                                <title>
                                  403 Error: Forbidden
                                </title>
                              </head>
                              <body>
                                403 Error: Forbidden. You don't have permission to access $file on this server.
                              </body>
                            </html>
                        "
                        echo "Content-length: ${#info}"
                        echo ""
                        echo $info
                    fi
                fi
            fi
           fi
    fi

# the POST request is also a valid http command
elif ["$cmd" = "POST" ]; then
    echo "po"
    # FIXME: implement post requests
    # this will require a bit of research about what exactly post requests do
fi
