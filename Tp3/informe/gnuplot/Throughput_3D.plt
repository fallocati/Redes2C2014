#Graph parameters
#set size square
#set view map
#set palette grey
#set pm3d interpolate 0,0
#set samples 20, 20
#set isosamples 30
#set contour
#set cntrparam levels auto 5
#set style data lines
#set grid layerdefault   linetype -1 linecolor rgb "gray"  linewidth 0.200,  linetype -1 linecolor rgb "gray"  linewidth 0.200
#set grid front mxtics mytics lw 1.5 lt -1 lc rgb 'white'
#set ztics 0.02

#Graph planes
#set view 60,30,1,1 #default
#set view 90,0,1,1 #XZ o Cant_CPUs X Metrica
#set view 90,90,1,1  #YZ o Quantum X Metrica

#Labels
#set xlabel "Cantidad CPUs" offset 0,-2
#set ylabel "Quantum por CPU" offset 0,-2
#set zlabel "" 
#set xtics 2 offset 0,-1
#set ytics 2 offset 0,-1
#set key inside left top enhanced box linetype -1 linewidth 1.000
#set key at screen 0.75,0.375
#set key below
#unset key

#Rangos
#set xrange [0:1]
#set yrange [0:1]
#set zrange [300000:750000]
#set autoscale x
#set autoscale y
#set autoscale z
#set logscale z

#Terminal info
set terminal png #(.png)


#Graphs
delays = "0 5 10 25 50 100 250 500"
probs = "0 1 5 10"

do for [delay in delays]{
    reset
    set dgrid3
    set grid xtics ytics ztics mztics
    set key outside

    #Source datafile
    set datafile separator ";"

    #Stats Get max
    #max=0
    #do for [prob in probs]{
    #    stats "prob0_delay".delay."_final.csv" using 4
    #    if(max < STATS_max) {
    #        max=STATS_max
    #    }
    #}

    #XYZ
    set output "delay".delay."_throughput_3d_xyz.png"
    set xlabel "Alpha"
    set ylabel "Beta"
    set ticslevel 0.0
    set xtics 0.1 offset -0.2,-0.2
    set ytics 0.1 offset -0.5,-0.5
    set view 60,30,1,1
    set hidden3d

    splot for [prob in probs] "prob".prob."_delay".delay."_final.csv" using 1:2:4 with lines title prob."%"

    #YZ
    set output "delay".delay."_throughput_3d_yz.png"
    set ylabel "Beta" offset 0,-2
    set ytics 0.1 offset 0,-1
    unset xlabel
    unset xtics
    unset hidden3d
    set for [y = 0:10:1] arrow from 0,y/10.0,GPVAL_Z_MIN to 0,y/10.0,GPVAL_Z_MAX nohead lt 0
    set view 90,90,1,1

    splot for [prob in probs] "prob".prob."_delay".delay."_final.csv" using 1:2:4 with lines title prob."%"

    #XZ
    set output "delay".delay."_throughput_3d_xz.png"
    set xlabel "Alpha" offset 0,-2
    set xtics 0.1 offset 0,-1
    unset ylabel
    unset ytics
    unset hidden3d
    set for [x = 0:10:1] arrow from x/10.0,0,GPVAL_Z_MIN to x/10.0,0,GPVAL_Z_MAX nohead lt 0
    set view 90,0,1,1

    splot for [prob in probs] "prob".prob."_delay".delay."_final.csv" using 1:2:4 with lines title prob."%"
}
