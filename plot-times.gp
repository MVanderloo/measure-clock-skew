#!/usr/bin/env gnuplot

set terminal png size 800,400
set output ARG1.'.png'
set title "Measured Wall-Clock Time"
set xlabel "Time (µs)"
set ylabel "Wall-Clock Offset (µs)"
set style data points
set pointsize 0.1

plot ARG1.'.txt' using ($0):1 notitle pt 7
