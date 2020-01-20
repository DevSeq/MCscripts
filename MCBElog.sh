#!/usr/bin/env bash

# Exit if error
set -e
syntax='`./MCBElog.sh $sessionname [$tmux_socket]`'
thyme=$(date -d '1 min ago' '+%Y-%m-%d %H:%M')

case $1 in
--help|-h)
	echo Post Minecraft Bedrock Edition server connect/disconnect messages running in tmux session to IRC.
	echo "$syntax"
	exit
	;;
esac
if [ "$#" -lt 1 ]; then
	>&2 echo Not enough arguments
	>&2 echo "$syntax"
	exit 1
elif [ "$#" -gt 2 ]; then
	>&2 echo Too much arguments
	>&2 echo "$syntax"
	exit 1
fi

sessionname=$1

if [ -n "$2" ]; then
	# Remove trailing slash
	tmux_socket=${2%/}
else
	# $USER = `whoami` and is not set in cron
	tmux_socket=/tmp/tmux-$(id -u "$(whoami)")/default
fi
if ! tmux -S "$tmux_socket" ls | grep -q "^$sessionname:"; then
	>&2 echo "No session $sessionname on socket $tmux_socket"
	exit 2
fi

scrape=$(tmux -S "$tmux_socket" capture-pane -pJt "$sessionname:0.0" -S -)
# grep fails if there's no match
buffer=$(echo "$scrape" | grep "$thyme" || true)
echo "$buffer" | while read line; do
	player=$(echo "$line" | cut -d ' ' -f 6)
	player=${player%,}
	if echo "$line" | grep -q 'Player connected'; then
		echo "PRIVMSG #minecraft :$player connected" >> ~/.MCBE_Bot/${sessionname}_BotBuffer
	elif echo "$line" | grep -q 'Player disconnected'; then
		echo "PRIVMSG #minecraft :$player disconnected" >> ~/.MCBE_Bot/${sessionname}_BotBuffer
	fi
done
