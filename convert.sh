#! /bin/bash

DEFAULT_PRESET=Normal

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
    local name=$(echo "$inputDir" | awk -F/ '{print $(NF-1)}')
    relPath=$(realpath --relative-to="$input" "$inputDir/..")
    local outputDir="${output}/${relPath}"
    mkdir -p "$outputDir"
    echo "Output dir is ${outputDir}"
    titles=$(trim $(HandBrakeCLI -i "$inputDir" -t 0 2>&1 | grep "+ title" | wc -l))
    for i in $(seq 1 $titles)
    do
        local outputFile=$(printf "${outputDir}/${name} - Track %02d.mp4" $i)
        local outputLockFile=$(printf "${outputDir}/.${name} - Track %02d.mp4.lock" $i)
        if [ -f "$outputFile" ] && [ ! -f "$outputLockFile" ]; then
            echo "Skipping: $outputFile"
            continue
        fi
        echo "Converting title $i of $titles. Start time: $(date)"
        echo "Writing into: ${outputFile}"
        local cmd="HandBrakeCLI --input '$inputDir' --title $i --preset '$preset' --output '$outputFile' </dev/null 2>/dev/null"
        echo $cmd >> "$outputLockFile"
        eval "$cmd"
        rm "$outputLockFile"
    done
}

preset="${3:-$DEFAULT_PRESET}"

if [ -z "$2" ] ; then
    echo "Usage: ./convert.sh /path/to/input /path/to/output [preset]"
    exit 1
fi

input=$(trim "$1")
output=$(trim "$2")
startFrom="${4:-1}"

echo "Searching for DVDs..."
tmpFile="/tmp/dvds.txt"
find "$input" | grep "/VIDEO_TS$" > $tmpFile
total=$(wc "$tmpFile" | awk {'print $1'})
echo "Found $total DVDs"
for ((i=startFrom; i<=total; i++))
do
    line="$(tail -n+$i "$tmpFile" | head -1)"
    echo "#### Processing $i of $total: $line ####"
    process "$line" "$output" "$preset"
done
echo "Completed"
