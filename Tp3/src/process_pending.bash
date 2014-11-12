#!/bin/bash

port=6677

while [ -f pendientes.lst ]; do
    mv pendientes.lst processing.lst
    cat processing.lst | while read line; do
        alpha=$(echo $line | awk '{print $11}')
        beta=$(echo $line | awk '{print $8}')
        delay=$(echo $line | awk '{print $5}')
        prob=$(echo $line | awk '{print $2}')

        rm -f prob${prob}.0_delay$(echo $delay\*10 | bc -l | cut -d. -f1).0ms_beta${beta}_alpha${alpha}*.csv 
        python2.7 ./server.py $alpha $beta 0 0 $port >> server_console.log 2>&1 &
        python2.7 ./client.py $alpha $beta $delay $prob $port >> client_console.log 2>&1 &
        sleep 10
        while [ $(pgrep python2.7 | wc -l) -gt 0 ]; do
            if [ $(find ./ -mmin -5 -name prob${prob}.0_delay$(echo $delay\*10 | bc -l | cut -d. -f1).0ms_beta${beta}_alpha${alpha}.csv | wc -l) -eq 0 ]
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
    rm -f processing.lst
done
