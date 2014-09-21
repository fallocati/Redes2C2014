#!/bin/bash

if [ $# -ne 2 ]
then
    echo "Usage: $0 input_file xrange"
else
    gnuplot -e "input='$1';xrange='$2'" probabilities_bars_with_labels.plt
fi

exit 0
