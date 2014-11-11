#!/bin/bash

control_c(){
    exit 0
}

trap control_c SIGINT

alphas=(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0)
betas=(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0)
delays=(0 0.5 1 2.5 5 10 25 50)
probs=(0 1 5 10 30)
port=6677

for prob in ${probs[*]}; do 
    for delay in ${delays[*]}; do 
        for alpha in ${alphas[*]}; do
            for beta in ${betas[*]}; do
                python2.7 ./server.py $alpha $beta 0 0 $port >> server_console.log 2>&1 &
                python2.7 ./client.py $alpha $beta $delay $prob $port >> client_console.log 2>&1 &
                sleep 10
                while [ $(pgrep -c python2.7) -gt 0 ]; do
                    if [ $(find ${PWD}/ -mmin -5 -name prob${prob}.0_delay*ms_beta${beta}_alpha${alpha}.csv | wc -l) -eq 0 ]
                    then
                        echo "prob: ${prob} | delay: $delay | beta: ${beta} | alpha: ${alpha}" >> pendientes.lst
                        killall python2.7 2>/dev/null
                    else
                        sleep 10
                    fi
                done
                echo "---------------------------------" >> server_console.log
                echo "---------------------------------" >> client_console.log
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
