set term postscript eps enhanced color
set output "concurency.eps"
set title "Request Rate with several client"
set xlabel "Number of client"
set ylabel "Number of requests per second"
set xrange [1:10]
set yrange [1:24]

plot "concurency.dat" using 1:2 with linespoints title "Request.s^{-1}"
