#!/usr/bin/env bash

set -e
# Exit if error
backup_dir=/tmp
files='worlds whitelist.json permissions.json server.properties'

if [ -z "$1" ] || [ -z "$2" ] || [ "$1" = -h ] || [ "$1" = --help ]; then
	>&2 echo 'Update Minecraft Bedrock Edition server keeping worlds, whitelist, permissions, and properties. You can convert a Windows $server_dir to Ubuntu and vice versa.'
	>&2 echo '`./MCBEupdate.sh $server_dir $minecraft_zip`'
	>&2 echo Remember to stop server before updating.
	exit 1
fi

server_dir=${1%/}
# Remove trailing slash
if [ "$server_dir" -ef "$backup_dir" ]; then
	>&2 echo '$server_dir cannot be '"$backup_dir"
	exit 4
fi
server_dir=$(realpath "$server_dir")

echo "Enter Y if you stopped the server you're updating"
read -r input
input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
if [ "$input" != y ]; then
	>&2 echo "$input != y"
	exit 5
fi

minecraft_zip=$(realpath "$2")
unzip -tq "$minecraft_zip"
# Test extracting $minecraft_zip partially quietly

cd "$server_dir"
for file in $files; do
	mv "$file" "$backup_dir/"
done

rm -r "$server_dir"/*
unzip "$minecraft_zip"

for file in $files; do
	mv "$backup_dir/$file" .
done
