set grid
set key font ",9"
set key bottom right
#set key below
#set key horizontal
#set terminal pdf
set terminal epslatex color
set title "Tiempo de ejecución conforme aumenta la cantidad de nodos"

set output "ej2_nodos_planar.tex"
#set yrange [1:1000000]
#set xrange [1:3000]
set xlabel "Cantidad de Nodos\n(Escala Lineal)"
set ylabel "Tiempo (microsegundos)\n(Escala Lineal)"
#set   autoscale
#set logscale x
#set logscale y
#set xtics 1
#set key samplen 10

#Lineal
#f(n) = n
g(n) = n/400 + 3

#Polinomial
#f(n) = n**5
#g(n) = ((n/10)**5)

#Logaritmico
#f(n) = -500 + n*(log10(n)/log(131072))
#g(n) = +600 + n*(log10(n)/log(131072))

#Exponencial
#f(n) = (n/100000000**2)*2**n

#plot "ejercicio2.complejidad.familia2.lst" using 1:($2*1000000) title "Familia 2" with lines lt 1 lw 1,\
#	"ejercicio2.complejidad.familia3.lst" using 1:($2*1000000) title "Familia 3" with lines lt 2 lw 1,\
#	"ejercicio2.complejidad.familia4.lst" using 1:($2*1000000) title "Familia 4" with lines lt 3 lw 1,\
#	f(x) title "Cota teórica inferior Omega(nlog(n))" with lines lt 4 lw 6 ,\
#	g(x) title "Cota teórica superior O(nlog(n))" with lines lt 5 lw 6

#plot "ej2.backtracking.connected_sparse.out.sorted_by_nodes.average" using 1:5 title "Poco denso" with linespoints,\
#    "ej2.backtracking_golosa.connected_sparse.out.sorted_by_nodes.average" using 1:5 title "Poco denso (Golosa)" with linespoints,\
#    "ej2.backtracking.connected_regular.out.sorted_by_nodes.average" using 1:5 title "Regular" with linespoints,\
#    "ej2.backtracking_golosa.connected_regular.out.sorted_by_nodes.average" using 1:5 title "Regular (Golosa)" with linespoints,\
#    "ej2.backtracking.connected_dense.out.sorted_by_nodes.average" using 1:5 title "Denso" with linespoints,\
#    "ej2.backtracking_golosa.connected_dense.out.sorted_by_nodes.average" using 1:5 title "Denso (Golosa)" with linespoints,\
#    f(x) title "Cota teórica superior $\\mathcal O(n \\cdot 2^n)$" with lines lt 5 lw 6

plot "ej2.backtracking.plannar.out.sorted_by_nodes.average" using 1:(($5*1000000)**(1.0/5)) title "Planar " with linespoints,\
    "ej2.backtracking_golosa.plannar.out.sorted_by_nodes.average" using 1:(($5*1000000)**(1.0/5)) title "Planar (Golosa)" with linespoints,\
    g(x) title "Cota teórica superior $\\mathcal O(n^5)$" with lines lt 5 lw 6

set out
