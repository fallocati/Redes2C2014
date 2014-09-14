#Output format and titles
set grid
#set key font ",9"
#set key bottom right
#set key below
#set key horizontal

#------------------------------
set title "Probabilidades\nDe Fuente Origen"

set terminal png size 800,600 #(.png)
set output "probabilities_src.png"

#set terminal pdf #(.pdf)
#set output ".pdf"

#set terminal epslatex color #(.tex)
#set output ".tex"

#set termina postscript enhanced colour #(.eps)
#set output ".eps"

#------------------------------

#Scale and tics
#set yrange [1:1000000]
#set xrange [1:200]
set xlabel "Direcciones IP\n(con probabilidad mayor a 0.005)"
set ylabel "Probabilidad"

set autoscale
#set logscale x
#set logscale y

#set xtics 1
#set ytics 5

set xtics rotate out

set xtics font ",08"
#set ytics font ",08"


#set key samplen 10

#------------------------------

#plot "ejercicio2.complejidad.familia2.lst" using 1:($2*1000000) title "Familia 2" with lines lt 1 lw 1,\
#	"ejercicio2.complejidad.familia3.lst" using 1:($2*1000000) title "Familia 3" with lines lt 2 lw 1,\
#	"ejercicio2.complejidad.familia4.lst" using 1:($2*1000000) title "Familia 4" with lines lt 3 lw 1,\
#	f(x) title "Cota teórica inferior Omega(nlog(n))" with lines lt 4 lw 6 ,\
#	g(x) title "Cota teórica superior O(nlog(n))" with lines lt 5 lw 6

#plot "ej2.backtracking.plannar.out.sorted_by_nodes.average" using 1:(($5*1000000)**(1.0/5)) title "Planar " with linespoints,\
#    "ej2.backtracking_golosa.plannar.out.sorted_by_nodes.average" using 1:(($5*1000000)**(1.0/5)) title "Planar (Golosa)" with linespoints,\
#    g(x) title "Cota teórica superior $\\mathcal O(n^5)$" with lines lt 5 lw 6

#------------------------------

#Bars chart
#http://psy.swansea.ac.uk/staff/carter/gnuplot/gnuplot_histograms.htm
set boxwidt 0.5
set style data histogram
set style fill solid border

#Graph
set datafile separator ";"
plot 'result.src' using 1:3:xticlabels(2) with boxes notitle
#plot 'result.prob' using ($2 > 0.01 ? $2 : 1/0):xticlabels(1) notitle #Conditional graphing if column is > than a value

#MultiData per key histogram
#set style histogram clustered
#plot for [COL=2:3] 'result.prob' using COL:xticlabels(1) title columnheader

set out
