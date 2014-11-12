#!/bin/bash

if [ $# -ne 2 ]
then
    echo "Faltan los parametros"
    echo "Usage: $0 [probabilidad] [delay(ms)]"

else
    alphas=(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0)
    betas=(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0)

    output_file="prob${1}_delay${2}_final.csv"
    echo "Alpha,Beta;RMSD;Throughput[bps];Throughput/RMSD;#Sent;#Drop;#Retransmitted" > $output_file

    for alpha in ${alphas[*]}; do
        for beta in ${betas[*]}; do
            time=$(tail -1 prob${1}.0_delay${2}.0ms_beta${beta}_alpha${alpha}_throughput.csv | cut -d';' -f1)
            sent=$(tail -1 prob${1}.0_delay${2}.0ms_beta${beta}_alpha${alpha}_throughput.csv | cut -d';' -f2)
            drop=$(tail -1 prob${1}.0_delay${2}.0ms_beta${beta}_alpha${alpha}_throughput.csv | cut -d';' -f3)
            retransmitted=$(tail -1 prob${1}.0_delay${2}.0ms_beta${beta}_alpha${alpha}_throughput.csv | cut -d';' -f4)
            rmsd=`awk -v delay="${2}" -F\; 'BEGIN {
                sum=0;
                n=0;
            }{
                if ($7 >= (2*delay-10)){
                    sum+=($6-$7)^2;
                    ++n;
                }
            } END {
                RMSD=sqrt(sum/n);
                print RMSD;
            }' prob${1}.0_delay${2}.0ms_beta${beta}_alpha${alpha}.csv`

            throughput=$(echo 400000/$time | bc -l)
            throughput_rmsd=$(echo $throughput/$rmsd | bc -l)
            echo "$alpha;$beta;$rmsd;$throughput;$throughput_rmsd;$sent;$drop;$retransmitted" >> $output_file
        done
    done
fi
