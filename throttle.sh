#! /bin/bash

cpuLimit=$1

if [ ! -x "$(command -v cputhrottle)" ]; then
	echo "cputhrottle not installed"
	exit 1
fi

if [ -z "$cpuLimit" ]; then
	echo "Usage example:"
	echo "    sudo ./throttle.sh 200"
	exit 1
fi

donePid=""
while true
do
	# Mac OSX throttle CPU usage
	pid=$(pgrep HandBrakeCLI)
	if [ ! -z $pid ] && [ "$pid" != "$donePid" ]; then
		echo "Throttling $pid to $cpuLimit"
	    cputhrottle "$pid" "$cpuLimit" &
	    donePid="$pid"
	fi
	sleep 1
done

