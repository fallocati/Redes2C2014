#!/bin/bash

if [ $# -ne 4 ]
then
    echo "Usage: $0 input_file output_file xrange xtics"
else
    gnuplot -e "input='$1';output='$2';xrange='$3';xtics='$4'" probabilities_bars.plt
    gnuplot -e "input='$1';output='$2';xrange='$3';xtics='$4'" probabilities_percentile90.plt
    gnuplot -e "input='$1';output='$2';xrange='$3';xtics='$4'" probabilities_bars_percentile90.plt
fi

exit 0
