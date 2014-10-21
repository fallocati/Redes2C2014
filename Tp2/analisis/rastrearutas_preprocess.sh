#!/bin/bash
if [ $# -ne 1 ]
then
    echo "Ingrese el archivo de entrada como parametro"

else
    routes=${1/%.csv/.routes}
    output_base=${1%.csv}
    #Genero la lista de rutas en formato ""#Aparaciones IP1;IP2;...;IPn"
    awk -F\; '{
        for(i=2;i<=NF;i+=2){
            printf("%s;", $i)
        }; 
        print ""
    }' $1 | sort | uniq -c | sort -n > $routes

    suffix=1
    cat $routes | while read i; do
        path=$(echo $i|cut -d' ' -f2)
        output=${output_base}_$(echo $i|cut -d ' ' -f1).path.${suffix}

        #Me genero el archivo con todos los experimentos que corresponden a la ruta
        awk -F\; 'FNR==NR{
            split($0,path,";");
            next
        }{
            j=1;
            for(i=2;i<=NF;i+=2){
                if(path[j]!=$i){
                    j=1;
                    break
                };
                ++j
            };
            if(i>NF||(i==NF&&j!=1)){
                print $0
            };
        }' <(echo $path) $1 > ${output}
        ((suffix++))
    done
fi
