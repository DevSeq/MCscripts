#!/usr/bin/env bash

set -e
# Exit if error
syntax='`./MCgetJAR.sh`'

case $1 in
--help|-h)
	echo "Download and chmod 700 the JAR of the current version."
	echo "$syntax"
	exit
	;;
esac
if [ "$#" -gt 1 ]; then
	>&2 echo Too much arguments
	>&2 echo "$syntax"
	exit 1
fi

webpage=$(wget --prefer-family=IPv4 https://www.minecraft.net/en-us/download/server/ -O -)
url=$(echo "$webpage" | grep -Eo 'https://[^ ]+server.jar')
wget --prefer-family=IPv4 "$url"
chmod 700 server.jar
