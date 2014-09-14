#Output format and titles
set grid
#set key font ",9"
#set key bottom right
#set key below
#set key horizontal

set output "arp_per_hour_src.png"
set terminal png size 800,600 #(.png)

#set terminal pdf #(.pdf)
#set output ".pdf"

#set terminal epslatex color #(.tex)
#set output ".tex"

#set termina postscript enhanced colour #(.eps)
#set output ".eps"

set title "#ARP por Hora"
set xlabel "Hora"
set ylabel "Cantidad de Paquetes ARP"

#------------------------------

#Scale and tics
#set yrange [1:1000000]
#set xrange [1:200]
#set autoscale
#set logscale x
#set logscale y

#set xtics 1
#set ytics 1

set xtics rotate out

set xtics font ",08"
#set ytics font ",08"

#set key samplen 10

#------------------------------

#Bars chart
#http://psy.swansea.ac.uk/staff/carter/gnuplot/gnuplot_histograms.htm
#set boxwidth 0.5
#set style data histogram
#set style fill solid border
#set datafile separator ";"
#plot 'quantity_per_our.csv' using 1:2:xticlabels(1) with boxes notitle
#plot 'result.prob' using ($2 > 0.01 ? $2 : 1/0):xticlabels(1) notitle #Conditional graphing if column is > than a value

#MultiData per key histogram
#set style histogram clustered
#plot for [COL=2:3] 'result.prob' using COL:xticlabels(1) title columnheader

#Time graph
set xdata time
set timefmt "%Y%m%d%H"
set xtics format "%d/%m %H:%M"
set datafile separator ";"
plot 'quantity_per_hour.csv' using 1:2:xticlabels(1) notitle with lines

set out
