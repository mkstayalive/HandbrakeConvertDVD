#! /bin/bash

DEFAULT_PRESET=Normal
CPU_LIMIT=200

trim() {
    local var=$@
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

process() {
	local input="$1"
	local output="$2"
	local preset="$3"
	local i=0
	local name=`echo "$input" | awk -F/ '{print $(NF-1)}'`
	local outputdir="${output}/${name} [${preset}]"
	mkdir -p "$outputdir"
	echo "" > "${outputdir}/convert.sh"
	echo "Output dir is ${outputdir}"
	titles=$(HandBrakeCLI -i "$input" -t 0 2>&1 | grep "+ title" | wc -l)
	for i in $(seq 1 $titles)
	do
		local outputfile=$(printf "${outputdir}/Track #%02d - ${name}.mp4" $i)
		if [ -f "$outputfile" ]; then
			echo "Skipping: $outputfile"
			continue
		fi
		echo "Converting (). Writing into ${outputfile}.."
		local cmd="HandBrakeCLI --input '$input' --title $i --preset '$preset' --output '$outputfile'"
		echo "Running:"
		echo $cmd
		echo $cmd >> "${outputdir}/convert.sh"
		eval $cmd
		PID=$!
		if [ -x "$(command -v cputhrottle)" ]; then
			# Mac OSX limit CPU usage
			cputhrottle $PID $CPU_LIMIT &
		fi
	done
}

if [ -z "$3" ] ; then
	echo "Usage: ./convert.sh /path/to/input /path/to/output preset"
	exit 1
fi

process "$1" "$2" "$3"

