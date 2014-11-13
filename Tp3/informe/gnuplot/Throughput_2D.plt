#Output format and titles
set grid
#set key font ",9"
#set key bottom right
#set key below
#set key horizontal
#set key left top
set key outside horizontal bottom
#set key outside top right
#set nokey

#------------------------------
#set terminal png size 800,600 #(.png)
#set output output."_bars_percentile90.png"
set terminal png size 1600,600 #(.png)
set output "throughput.png"

#set terminal pdf #(.pdf)
#set output ".pdf"

#set terminal epslatex color #(.tex)
#set output "prueba.tex"

#set termina postscript enhanced colour #(.eps)
#set output ".eps"

#set title "Probabilidad por IP\n(Ordenadas de mayor a menor segun probabilidad)"
set title "Throughput"
set xlabel "(Alpha,Beta)"
set ylabel "Thoughput[bps]"
#set y2label "Probabilidad acumulada"

#------------------------------

#Scale and tics
#set yrange [*:125]
#set y2range [0:1]
#set xrange [0:10]
#set x2range [1:12]

#set autoscale
#set logscale x
#set logscale y

#set xtics nomirror
#set xtics 0.1

#set x2tics nomirror
#set x2tics 0.05

#set ytics nomirror
#set ytics 1

#set y2tics nomirror
#set y2tics 0.1

set xtics rotate out

set xtics font ",08"
set ytics font ",08"

#set key samplen 10

#------------------------------

#Bars chart
#http://psy.swansea.ac.uk/staff/carter/gnuplot/gnuplot_histograms.htm
set boxwidt 0.5
set style data histogram
set style fill solid border
set datafile separator ";"

plot "prob0_delay0_final.csv" using 5:xticlabels(sprintf("(%.1f,%.1f)",$1,$2)) with boxes title "Delay 0/DropChance 0"
#plot \
#    input using 1:3 with boxes lc rgb "red" fs solid 0.7 noborder axes x1y1 title "Probabilidad de IP",\
#    input using 1:($4 <= 0.9 ? $4 : 1/0) with boxes lc rgb "blue" fs transparent pattern 5 noborder axes x1y2 title "Percentil 90",\
#    input using 1:4 with lines lc rgb "blue" lw 2 axes x1y2 title "Probabilidad Acumulada",\

#MultiData per key histogram
#set style histogram clustered
#plot for [COL=2:3] 'result.prob' using COL:xticlabels(1) title columnheader

set out
