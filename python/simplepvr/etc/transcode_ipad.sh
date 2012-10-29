#!/bin/bash

if [ $# != 1 ]; then
	echo "Usage: $0 stream.ts"
	exit 1
fi

if [ -f "$1" ]; then
	INPUT_FILE="$1"
else
	echo "File '$1' not found"
	exit 1
fi

outfile="${INPUT_FILE}.m4v"

options_ipad_1="-vf scale=640:480,crop=in_w:in_h-4:(in_w-out_w)/2:4 -v 1 -y -map 0:0 -er 4 -f ipod -pass 1 -deinterlace -vcodec libx264 -vpre slow_firstpass -b 1200k -bt 1200k -maxrate 1200k -bufsize 1200k -level 30 -r 30 -g 90 -an -threads 0"
options_ipad_2="-vf scale=640:480,crop=in_w:in_h-4:(in_w-out_w)/2:4 -v 1 -y -map 0:0 -map 0:1 -er 4 -f ipod -pass 2 -acodec libfaac -ac 2 -ab 128k -ar 44100 -deinterlace -vcodec libx264 -vpre slow -vpre main -b 1200k -bt 1200k -maxrate 1200k -bufsize 1200k -level 30 -r 30 -g 90 -async 2 -threads 0"

ffmpeg -i "$INPUT_FILE" $options_ipad_1 "$outfile"
ffmpeg -i "$INPUT_FILE" $options_ipad_2 "$outfile"

echo "Done - output file '${outfile}' created"