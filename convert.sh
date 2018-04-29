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
    local inputDir="$1"
    local outputDir="$2"
    local preset="$3"
    local i=0
    relPath=$(realpath --relative-to="$input" "$inputDir/..")
    local outputDir="${output}/${relPath}"
    mkdir -p "$outputDir"
    echo "Output dir is ${outputDir}"
    titles=$(HandBrakeCLI -i "$inputDir" -t 0 2>&1 | grep "+ title" | wc -l)
    for i in $(seq 1 $titles)
    do
        local outputFile=$(printf "${outputDir}/Track #%02d - ${name}.mp4" $i)
        local outputLockFile=$(printf "${outputDir}/.Track #%02d - ${name}.mp4.lock" $i)
        if [ -f "$outputFile" ] && [ ! -f "$outputLockFile" ]; then
            echo "Skipping: $outputFile"
            continue
        fi
        echo "Converting title $i. Writing into: ${outputFile}"
        local cmd="HandBrakeCLI --input '$inputDir' --title $i --preset '$preset' --output '$outputFile' 2>/dev/null"
        echo $cmd >> "$outputLockFile"
        eval "$cmd"
        if [ -x "$(command -v cputhrottle)" ]; then
            # Mac OSX limit CPU usage
            local pid=$(pgrep HandBrakeCLI)
            if [ ! -z $pid ]; then
                cputhrottle $pid $CPU_LIMIT &
            fi
        fi
        rm "$outputLockFile"
    done
}

preset="${3:-$DEFAULT_PRESET}"

if [ -z "$2" ] ; then
    echo "Usage: ./convert.sh /path/to/input /path/to/output [preset]"
    exit 1
fi

input="$1"
output="$2"

echo "Searching for DVDs..."
find "$input" | grep "VIDEO_TS$" | while IFS='' read -r line || [[ -n "$line" ]]; do
    process "$line" "$output/$relPath" "$preset"
done

