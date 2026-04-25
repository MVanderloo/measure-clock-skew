#!/usr/bin/env gnuplot

set terminal png size 800,400
set output 'times.png'

set title "Wall-Clock Time Measured Every Millisecond"
set xlabel "Time (milliseconds)"
set ylabel "Realtime Measurement (microseconds)"
set style data points

plot 'times.txt' using 0:1 notitle
