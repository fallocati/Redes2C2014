#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage $0 intput_file"
else
    awk -F';' 'BEGIN{counter=0;hour=0}{
        $1=substr($1,1,10);
        if($1-hour == 0){
            if($2 != "Response") ++counter;
        } else {

            printf"%d;%d\n",hour,counter;
            counter=0;
        };
        hour=$1
    }' < $1 > quantity_per_hour.csv
    sed -i 1d quantity_per_hour.csv
fi

gnuplot quantity_per_hour.plt
