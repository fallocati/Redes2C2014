#!/bin/bash

if [ $# -lt 2 ]
then
    echo "Usage: $0 intput_file output_file [network1] [network2] [network3]"
    exit 1
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
    }' < $1 | sort | uniq -i > pre_graph.csv


    echo "graph {" >$2
    echo "graph [fontsize=8]" >>$2

        awk -F',' \
            `[[ -n "$3" ]] && echo -v net1="$3"` \
            `[[ -n "$4" ]] && echo -v net2="$4"` \
            `[[ -n "$5" ]] && echo -v net3="$5"` \
        'BEGIN {
            #Guardamos en un array multidimencional los octetos de las redes
            if(net1 != ""){
                split(net1,network1,".");
                networks[1,1] = network1[1];
                networks[1,2] = network1[2];
                networks[1,3] = network1[3];
                networks[1,4] = network1[4];
                networks[1,color] = "yellow";
            };
            if(net2 != ""){
                split(net2,network2,".");
                networks[2,1] = network2[1];
                networks[2,2] = network2[2];
                networks[2,3] = network2[3];
                networks[2,4] = network2[4];
                networks[2,color] = "darkgreen";
            };
            if(net3 != ""){
                split(net3,network3,".");
                networks[3,1] = network3[1];
                networks[3,2] = network3[2];
                networks[3,3] = network3[3];
                networks[3,4] = network3[4];
                networks[3,color] = "red";
            };

        }{
            #Formateamos los nodos del grafo
            for(i=1;i<=2;++i){
                if(map[$i] != 1){
                    if(length(networks) > 0){

                        split($i,ip,".");
                        for(net=1;net<=length(networks)/4;++net){
                            for(oct=1;oct<=4 && map[$i] != 1;++oct){
                                if(networks[net,oct] == 0 || networks[net,oct] == ip[oct]){
                                    if(networks[net,oct] == 0){
                                        print "\""ip[1]"."ip[2]"."ip[3]"."ip[4]"\" [shape=ellipse,color="networks[net,color]",style=filled];";
                                        map[$i] = 1;
                                        break;
                                    }
                                } else
                                    break;
                            }
                        }
                        if(map[$i] != 1){
                            print "\""ip[1]"."ip[2]"."ip[3]"."ip[4]"\" [shape=ellipse,color=blue,style=filled];";
                            map[$i] = 1;
                        }
                    }
                }
            };

            #Agregamos los edges
            print "\""$1"\" -- \""$2"\";";
        }' < pre_graph.csv >>$2

    echo "}" >>$2
fi

exit 0
