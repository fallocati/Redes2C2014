#Output format and titles
set grid
#set key font ",9"
#set key bottom right
#set key below
#set key horizontal
#set key left top
set key outside horizontal bottom

#------------------------------
set terminal png size 800,600 #(.png)
set output input.".bars_percentile90.png"

#set terminal pdf #(.pdf)
#set output ".pdf"

#set terminal epslatex color #(.tex)
#set output ".tex"

#set termina postscript enhanced colour #(.eps)
#set output ".eps"

set title "Probabilidad por IP\n(Ordenadas de mayor a menor segun probabilidad)"
set xlabel "Cantidad de IPs con mayor probabilidad "
set ylabel "Probabilidad"
set y2label "Probabilidad acumulada"

#------------------------------

#Scale and tics
set yrange [0:*]
set y2range [0:1]
set xrange [1:xrange]
#set x2range [:]

#set autoscale
#set logscale x
#set logscale y

#set xtics nomirror
set xtics xtics

#set x2tics nomirror
#set x2tics 1

#set ytics nomirror
#set ytics 1

set y2tics nomirror
set y2tics 0.1

set xtics rotate out

set xtics font ",08"
#set ytics font ",08"

#set key samplen 10

#------------------------------

#Bars chart
#http://psy.swansea.ac.uk/staff/carter/gnuplot/gnuplot_histograms.htm
#set boxwidt 0.5
set style data histogram
set style fill solid border
set datafile separator ";"

plot \
    input using 1:3 with boxes lc rgb "red" fs solid 0.7 noborder axes x1y1 title "Probabilidad de IP",\
    input using 1:($4 <= 0.9 ? $4 : 1/0) with boxes lc rgb "blue" fs transparent pattern 5 noborder axes x1y2 title "Percentil 90",\
    input using 1:4 with lines lc rgb "blue" lw 2 axes x1y2 title "Probabilidad Acumulada",\

#MultiData per key histogram
#set style histogram clustered
#plot for [COL=2:3] 'result.prob' using COL:xticlabels(1) title columnheader

#Data lines
#set style data lines

set out
