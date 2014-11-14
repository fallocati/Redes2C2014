#Output format and titles
#set grid xtics ytics mytics
#set grid

#set key font ",9"
#set key bottom right
#set key below
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
set xlabel "Alpha"
set ylabel "Beta"
set cblabel "Throughput [bps]"

#------------------------------

#Scale and tics
#set offset graph 0.1, graph 0.1, graph 0.1, graph 0.1

#set yrange [*:200]
#set y2range [0:1]
#set xrange [0:1]
#set x2range [:]

#set autoscale
#set logscale x
#set logscale y

#set xtics nomirror
set xtics 0.1

#set x2tics nomirror
#set x2tics 0.05

#set ytics nomirror
set ytics 0.1
#set ytics mirror
#set mytics 5 

#set y2tics nomirror
#set y2tics 0.1
#set my2tics 5


set xtics font ",12"
set ytics font ",12"

#------------------------------
set size square
set view map
set dgrid3
set palette grey
set pm3d interpolate 0,0

set style data lines
set datafile separator ";"

betas = "0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0"
beta(n) = word(betas,n)

#probs = "0"
probs = "0 1 5 10"
#prob(n) = word(probs,n)

#delays = "0"
delays = "0 5 10 25 50 100 250 500"
#delay = word(delays,n)

do for [prob in probs]{
    do for [delay in delays]{
        set output "prob".prob."_delay".delay."_throughput_heatmap.eps"
        #unset logscale y
        #stats "prob".prob."_delay".delay."_final.csv" using 4

        #Ticks
        #set ytics ()
        #set logscale y 10
        #set y2tics ()
        #set logscale y2 10

        #numtics = 10
        #numtics2 = 1
        #increment = ((STATS_up_quartile-STATS_min)/numtics)
        #do for [t=0:numtics]{
        #    tic = STATS_min+increment*t
        #    set ytics add (tic)

        #    #increment2 = increment/numtics2
        #    #do for [t2=1:numtics2]{
        #    #    set ytics add (tic+increment2*t2)
        #    #}
        #}

        #Plot
        splot "prob".prob."_delay".delay."_final.csv" using 1:2:4 with pm3d notitle
    }
}

set out
