#!/bin/bash

if [ $# -ne 5 ]
then
    echo "Usage: $0 input_file output_file nodes_src nodes_dst limit"
else
    echo "Pos,Source,Target,Weight" > $2
    awk -F';' '{if($2=="Request") print $3" "$4;}' $1\
        | sort\
        | uniq -c\
        | sort -brnk1,1\
        | awk 'BEGIN{counter=0}{print counter","$2","$3","$1;counter++}' >> $2


    #echo "Pos,Source,Target,Weight" > ${2/%.*/_1.csv}
    #echo "Pos,Source,Target,Weight" > ${2/%.*/_10to50.csv}
    echo "Pos,Source,Target,Weight" > ${2/%.csv/_${5}toEnd.csv}

    #awk -F',' '{if($4+0>0 && $4+0 <=10) print $0}' $2 >>${2/%.*/_1to10.csv}
    #awk -F',' '{if($4+0>10 && $4+0 <= 50) print $0}' $2 >>${2/%.*/_10to50.csv}
    awk -F',' '{if($4+0>='$5') print $0}' $2 >>${2/%.csv/_${5}toEnd.csv}

    echo "IP,color" > ${2/%.csv/_important_nodes.csv}
    head -$(($3+1)) ${1/%.csv/.out_src} | tail -$3 | awk -F';' '{print $2",src"}' >> ${2/%.csv/_important_nodes.csv}
    head -$(($4+1)) ${1/%.csv/.out_dst}\
        | tail -$4\
        | cut -d';' -f2\
        | while read ip; do
            if [ $(grep -c $ip ${2/%.csv/_important_nodes.csv}) -eq 0 ]
            then
                echo "${ip},dst" >> ${2/%.csv/_important_nodes.csv}
            else
                sed -i "s/${ip},src/${ip},src+dst/g" ${2/%.csv/_important_nodes.csv}
            fi
        done


    ssconvert -M ${2/%.csv/.xlsx} $2 ${2/%.csv/_important_nodes.csv}
    #ssconvert ${2/%.*/_1to10.csv} ${2/%.*/_1to10.xlsx}
    #ssconvert ${2/%.*/_10to50.csv} ${2/%.*/_10to50.xlsx}
    ssconvert -M ${2/%.csv/_${5}toEnd.xlsx} ${2/%.csv/_${5}toEnd.csv} ${2/%.csv/_important_nodes.csv}

fi
exit 0
