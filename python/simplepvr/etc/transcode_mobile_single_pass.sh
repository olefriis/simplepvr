#!/usr/bin/env bash

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

## slow and main options merged
options="-coder 1 -flags +loop -cmp +chroma -partitions +parti8x8+parti4x4+partp8x8+partb8x8 -me_method umh -subq 8 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -b_strategy 2 -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -bf 3 -refs 5 -directpred 3 -trellis 1 -flags2 -dct8x8 -wpredp 2 -rc_lookahead 50"

## slow options overwritten by main
#-flags2=+bpyramid+mixed_refs+wpred+dct8x8+fastpskip 

nice -19 ffmpeg -i "${INPUT_FILE}" -acodec libfaac -ab 160k -vcodec libx264 ${options} -level 30 -crf 22 -threads 0 "${outfile}"

