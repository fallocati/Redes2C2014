#!/bin/bash

if [ $# -ne 3 ]
then
    echo "Usage: $0 input_file xrange xtics"
else
    gnuplot -e "input='$1';xrange='$2';xtics='$3'" probabilities_bars.plt
    gnuplot -e "input='$1';xrange='$2';xtics='$3'" probabilities_percentile90.plt
    gnuplot -e "input='$1';xrange='$2';xtics='$3'" probabilities_bars_percentile90.plt
fi

exit 0
