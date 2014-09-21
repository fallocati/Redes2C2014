#Output format and titles
set grid
#set key font ",9"
#set key bottom right
#set key below
#set key horizontal
set nokey

#------------------------------
set terminal png size 800,600 #(.png)
set output output."_probabilities_with_labels.png"

#set terminal pdf #(.pdf)
#set output ".pdf"

#set terminal epslatex color #(.tex)
#set output output."_probabilities_with_labels.tex"

#set termina postscript enhanced colour #(.eps)
#set output ".eps"

#set title "Probabilidad por IP\n(Ordenadas de mayor a menor segun probabilidad)"
set notitle
set xlabel "IP"
set ylabel "Probabilidad"

#------------------------------

#Scale and tics
#set yrange [0:1]
set xrange [1:xrange]

#set autoscale
#set logscale x
#set logscale y

set xtics 1
#set ytics 1

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
plot input using 1:3:xticlabel(2) with boxes lc rgb "red" fs solid 0.7 noborder notitle

#MultiData per key histogram
#set style histogram clustered
#plot for [COL=2:3] 'result.prob' using COL:xticlabels(1) title columnheader

#Data lines
#set style data lines

set out
