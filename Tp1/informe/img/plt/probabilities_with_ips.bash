#!/bin/bash

if [ $# -ne 3 ]
then
    echo "Usage: $0 input_file output_file xrange"
else
    gnuplot -e "input='$1';output='$2';xrange='$3'" probabilities_bars_with_labels.plt
fi

exit 0
