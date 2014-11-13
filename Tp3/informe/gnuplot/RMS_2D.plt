#Output format and titles
set grid
#set key font ",9"
#set key bottom right
set key below
#set key horizontal
#set key left top
#set key outside horizontal bottom
#set key outside top right
#set nokey

#------------------------------
#set terminal png size 800,600 #(.png)
#set output output."_bars_percentile90.png"
#set terminal png #(.png)
#set output "prueba.png"

#set terminal pdf #(.pdf)
#set output ".pdf"

#set terminal epslatex color #(.tex)
#set output "prueba.tex"

set terminal postscript enhanced colour #(.eps)
#set output ".eps"

#set terminal latex #(.tex)

#set title "Probabilidad por IP\n(Ordenadas de mayor a menor segun probabilidad)"
#set title "RMS para Probabilidad de Dropeo 0 y Delay 0"
set xlabel "Alpha"
set ylabel "RMS"
#set y2label "Probabilidad acumulada"

#------------------------------

#Scale and tics
#set yrange [*:200]
#set y2range [0:1]
set xrange [0:1]
#set x2range [:]

#set autoscale
#set logscale x
#set logscale y

#set xtics nomirror
set xtics 0.1

#set x2tics nomirror
#set x2tics 0.05

#set ytics nomirror
#set ytics 1

#set y2tics nomirror
#set y2tics 0.1

#set xtics rotate out

set xtics font ",12"
set ytics font ",12"

#set key samplen 10

#------------------------------

#Bars chart
#http://psy.swansea.ac.uk/staff/carter/gnuplot/gnuplot_histograms.htm
#set boxwidt 0.5
#set style data histogram
#set style fill solid border
#set datafile separator ";"

#plot \
#    input using 1:3 with boxes lc rgb "red" fs solid 0.7 noborder axes x1y1 title "Probabilidad de IP",\
#    input using 1:($4 <= 0.9 ? $4 : 1/0) with boxes lc rgb "blue" fs transparent pattern 5 noborder axes x1y2 title "Percentil 90",\
#    input using 1:4 with lines lc rgb "blue" lw 2 axes x1y2 title "Probabilidad Acumulada",\

#MultiData per key histogram
#set style histogram clustered
#plot for [COL=2:3] 'result.prob' using COL:xticlabels(1) title columnheader

#Data lines
set style data lines
set datafile separator ";"

betas = "0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0"
beta(n) = word(betas,n)

probs = "0 1 5 10"
#prob(n) = word(probs,n)

delays = "0 5 10 25 50 100 250 500"
#delay = word(delays,n)

do for [prob in probs]{
    do for [delay in delays]{
        set output "prob".prob."_delay".delay."_rmsd.eps"
        stats "prob".prob."_delay".delay."_final.csv" using 3
        plot [0:1][STATS_min:STATS_up_quartile] for [i=0:10] "prob".prob."_delay".delay."_final.csv" every 11::i using 1:3 with linespoints lw 2 title "Beta ".beta(i+1)
        #plot for [i=0:10] "prob".prob."_delay".delay."_final.csv" every 11::i using 1:3 with linespoints lw 2 title "Beta ".beta(i+1)
    }
}

set out
