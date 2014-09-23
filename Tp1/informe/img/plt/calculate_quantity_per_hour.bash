#!/bin/bash

if [ $# -lt 2 ]
then
    echo "Usage $0 output_file intput_file [intput_file_2] [input_file_..]"
else
    days=(Dom Lun Mar Mie Jue Vie Sab)
    counter=0
    output="$1"
    
    shift
    while (( "$#" )); do 
        output_file_tmp="${1/%.csv/_per_hour.csv}"
        echo "Hora;${days[counter%7]}" > $output_file_tmp
        awk -F';' 'BEGIN{counter=0;hour=0}{
            $1=substr($1,9,2);
	    if($1 < 18){
                if($1-hour == 0){
                    if($2 != "Response") ++counter;
                } else {
    
                    printf"%d;%d\n",hour,counter;
                    counter=0;
                };
                hour=$1

            }

         } END{
                printf"%d;%d\n",hour,counter;

        }' < $1 >> $output_file_tmp

        sed -i 2d $output_file_tmp
        input+="$output_file_tmp "
        ((++counter))
        shift
    done

    paste -d\; $input | cut -d\; -f 1,2,4,6,8,10,12,14 > ${output}.csv

    #gnuplot -e "input='$input';output='$2'" ${0/#\//quantity_per_hour.plt}
    gnuplot -e "input='${output}.csv';output='$output'" `dirname $0`/quantity_per_hour.plt
fi
