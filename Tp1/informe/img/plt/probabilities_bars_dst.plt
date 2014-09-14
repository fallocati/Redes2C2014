#Output format and titles
set grid
#set key font ",9"
#set key bottom right
#set key below
#set key horizontal

#------------------------------
set terminal png size 800,600 #(.png)
set output "probabilities_dst.png"

#set terminal pdf #(.pdf)
#set output ".pdf"

#set terminal epslatex color #(.tex)
#set output ".tex"

#set termina postscript enhanced colour #(.eps)
#set output ".eps"

set title "Probabilidades\nDe Fuente Destino"
set xlabel "Direcciones IP\n(con probabilidad mayor a 0.005)"
set ylabel "Probabilidad"

#------------------------------

#Scale and tics
#set yrange [1:1000000]
#set xrange [1:200]

set autoscale
#set logscale x
set logscale y

#set xtics 1
#set ytics 1

set xtics rotate out

set xtics font ",08"
#set ytics font ",08"

#set key samplen 10

#------------------------------

#Bars chart
#http://psy.swansea.ac.uk/staff/carter/gnuplot/gnuplot_histograms.htm
set boxwidt 0.5
set style data histogram
set style fill solid border
set datafile separator ";"
plot 'result.dst' using 1:3:xticlabels(2) with boxes notitle
#plot 'result.prob' using ($2 > 0.01 ? $2 : 1/0):xticlabels(1) notitle #Conditional graphing if column is > than a value

#MultiData per key histogram
#set style histogram clustered
#plot for [COL=2:3] 'result.prob' using COL:xticlabels(1) title columnheader

set out
