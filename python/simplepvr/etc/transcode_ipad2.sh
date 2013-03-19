#!/usr/bin/env bash

## Preset from this page: https://develop.participatoryculture.org/index.php/ConversionMatrix#Apple_Format_Conversions

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

resolution="960:640"

#ffmpeg -i ${INPUT_FILE} -acodec aac -ac 2 -strict experimental -ab 160k -s ${resolution} -vcodec libx264 -preset slow -profile:v baseline -level 30 -maxrate 10000000 -bufsize 10000000 -b 1200k -f mp4 -threads 0 "${outfile}"
nice -19 ffmpeg -i ${INPUT_FILE} -acodec aac -ac 2 -strict experimental -ab 160k -s ${resolution} -vcodec libx264 -vpre slow -vpre main -level 30 -maxrate 10000000 -bufsize 10000000 -b 1200k -f mp4 -threads 0 "${outfile}"