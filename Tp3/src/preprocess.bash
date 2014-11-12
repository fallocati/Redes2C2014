#!/bin/bash

if [ $# -ne 2 ]
then
    echo "Faltan los parametros"
    echo "Usage: ./$0 [probabilidad] [delay]"

else
    alphas=(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0)
    betas=(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0)

    output_file="prob${1}_delay${2}_final.csv"
    echo "Alpha,Beta;RMSD;Throughput[bps]" > $output_file

    for alpha in ${alphas[*]}; do
        for beta in ${betas[*]}; do
            time=$(tail -1 prob${1}.0_delay${2}.0ms_beta${beta}_alpha${alpha}_throughput.csv | cut -d';' -f1)
            rmsd=`awk -F\; 'BEGIN {
                sum=0;
            }{
                sum+=($6-$7)^2;
            } END {
                RMSD=sqrt(sum/(NR-1));
                print RMSD;
            }' prob${1}.0_delay${2}.0ms_beta${beta}_alpha${alpha}.csv`

            echo "$alpha;$beta;$rmsd;$(echo 400000/$time | bc -l)" >> $output_file
        done
    done
fi
