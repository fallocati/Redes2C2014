#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage: $0 intput_file"
else
    awk -F';' '{split($3,src,".");split($4,dst,".");
        if( \
            (src[1] > dst[1]) || \
            (src[1] == dst[1] && src[2] > dst[2]) || \
            (src[1] == dst[1] && src[2] == dst[2] && src[3] > dst[3]) || \
            (src[1] == dst[1] && src[2] == dst[2] && src[3] == dst[3] && src[4] > dst[4]) \
        )
            print $4","$3;
        else
            print $3","$4;
    }' < $1 | uniq -i > pre_graph.csv
fi

exit 0
