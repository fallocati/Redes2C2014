#!/bin/bash

if [ $# -ne 2 ]
then
    echo "Faltan los parametros"
    echo "Usage: ./$0 [probabilidad] [delay]"
else
    output_file="prob${1}_delay${2}_throughput_final.csv"
    echo "Alpha,Beta;Tiempo" > $output_file
    for file in prob${1}*_delay${2}*ms*throughput.csv; do
        alpha=$(awk -F_ '{print $4}' <(echo ${file}) | tr -d "alpha")
        beta=$(awk -F_ '{print $3}' <(echo ${file}) | tr -d "beta")
        time=$(tail -1 $file | cut -d';' -f1)

        echo "$alpha;$beta;$time" >> $output_file
    done
fi
