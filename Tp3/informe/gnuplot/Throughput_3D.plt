#Terminal info
#set terminal png #(.png)
#set output 'Throughput_3D.png'

#Graph parameters
set size square
set view map
set dgrid3
set palette grey
set pm3d interpolate 0,0
#set hidden3d
#set samples 20, 20
#set isosamples 50
#set contour
#set cntrparam levels auto 5
#set style data lines
#set grid layerdefault   linetype -1 linecolor rgb "gray"  linewidth 0.200,  linetype -1 linecolor rgb "gray"  linewidth 0.200
set grid
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
#set key outside
#set key at screen 0.75,0.375
#set key below

#Rangos
#set xrange [0:1]
#set yrange [0:1]
#set zrange [300000:750000]
#set autoscale x
#set autoscale y
#set autoscale z

#Source datafile
set datafile separator ";"

#Multiplot
#set multiplot layout 2,2

#XYZ
#set xlabel "Alpha" offset 0,-2
#set ylabel "Beta" offset 0,-2
#set xtics 0.1 offset -1,-1
#set ytics 0.1 offset -1,-1
#set view 60,30,1,1
set xlabel "Alpha"
set ylabel "Beta"
set cblabel "Throughput [bps]"
set xtics 0.1
set ytics 0.1
#set nocbtics
splot "prob0_delay0_final.csv" using 1:2:4 with pm3d notitle,\
#    "prob0_delay50_final.csv" using 1:2:4 with lines title "50ms",\
#    "prob0_delay100_final.csv" using 1:2:4 with lines title "100ms",\
#    "prob0_delay250_final.csv" using 1:2:4 with lines title "250ms",\
#    "prob0_delay500_final.csv" using 1:2:4 with lines title "500ms"

#YZ o Beta x RMS
#set ylabel "Beta" offset 0,-2
#set ytics 0.1 offset 0,-1
#unset xlabel
#unset xtics
#set view 90,90,1,1
#splot "prob0_delay0_final.csv" using 1:2:4 with lines title "0ms",\
#    "prob0_delay50_final.csv" using 1:2:4 with lines title "50ms",\
#    "prob0_delay100_final.csv" using 1:2:4 with lines title "100ms",\
#    "prob0_delay250_final.csv" using 1:2:4 with lines title "250ms",\
#    "prob0_delay500_final.csv" using 1:2:4 with lines title "500ms"

#XZ o Alpha x RMS
#set xlabel "Alpha" offset 0,-2
#set xtics 0.1 offset 0,-1
#unset ylabel
#unset ytics
#set view 90,0,1,1
#splot "prob0_delay0_final.csv" using 1:2:4 with lines title "0ms",\
#    "prob0_delay50_final.csv" using 1:2:4 with lines title "50ms",\
#    "prob0_delay100_final.csv" using 1:2:4 with lines title "100ms",\
#    "prob0_delay250_final.csv" using 1:2:4 with lines title "250ms",\
#    "prob0_delay500_final.csv" using 1:2:4 with lines title "500ms"

#unset multiplot
