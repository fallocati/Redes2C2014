#!/bin/bash

control_c(){
    exit 0
}

trap control_c SIGINT

alphas=(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1)
betas=(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1)
delays=(0 0.5 1 2.5 5 10 25 50)
probs=(0 1 5 10 30)
port=6677

for prob in ${probs[*]}; do 
    for delay in ${delays[*]}; do 
        for alpha in ${alphas[*]}; do
            for beta in ${betas[*]}; do
                python2.7 ./server.py $port > server_console.log 2>&1 &
                python2.7 ./client.py $alpha $beta $delay $prob $port
                if [ $((port%6677)) -ne 10 ]
                then
                    ((++port))
                else
                    port=6677
                fi
                sleep 5
            done
        done
    done
done
