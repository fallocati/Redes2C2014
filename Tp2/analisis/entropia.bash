for i in `ls -l mcgill_*.path.* | cut -d'_' -f2 | cut -d'.' -f1 | sort -n | uniq`; do j=0; while [ $j -lt `ls -l mcgill_${i}.* | wc -l` ]; do echo "${i};1"; ((++j))  ; done; done' > entropia.csv
awk -F\; '{printf("%f;%d;%d",$1/6000,$1,$2)}' entropia.csv > entropia_probabilidad.csv ^C
awk -F\; '{sum-=$1*log($1)/log(2)}END{print sum}' entropia_probabilidad.csv   ^C
