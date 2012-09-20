set term postscript eps enhanced color
set output "size_queue.eps"
set title "Size variation of the message's queue"
set xlabel "Number of client"
set ylabel "Maximum size of the queue"
set xrange [1:25]
set yrange [1:200]

plot "size_queue.dat" using 1:2 with linespoints title "Size"
