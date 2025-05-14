#!/bin/bash

script_path="$0"
port=8080
script_name=$(basename "$script_path")
if [[ "$basename" == *"1"* ]] then; # if filepath has 1
	$port=8081
elif [[ "$basename" == *"2"* ]] then;
	$port=8082

apk add gcc musl-dev make

gcc web.c -o exec
chmod +x exec
./exec $port
