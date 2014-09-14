#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage: $0 input_file"
else
    awk -F';' 'BEGIN{line=0}{if ($2 >= 0.005) {printf "%d;%s\n", line, $0;++line;}}' < "$1" > result.src
    gnuplot probabilities_bars_src.plt

    awk -F';' 'BEGIN{line=0}{if ($3 >= 0.005) {printf "%d;%s\n", line, $0;++line;}}' < "$1" > result.dst
    gnuplot probabilities_bars_dst.plt
fi

exit 0
