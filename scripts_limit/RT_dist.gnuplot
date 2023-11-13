# user-defined variables
#################################################################################
set terminal pdfcairo size 5in,5in
mag=15
# set size 0.9,1
#set terminal pdfcairo enhanced color dashed font "Helvetica, 18"

# The data in a CSV file are separated by comma.
#set datafile separator ","

set output output_name

#set multiplot layout 80,1 title title_name font "Helvetica, 24"

#set key right top nobox  noenhanced #font "Helvetica, 10"#horizontal vertical
#set key Right
#set key horizontal outside center top samplen 2 height 1 width -4.0 #below #inside left top

#### X-axis ####
# set xlabel "Timeline [s]" offset 0,.6
#set xrange [ x1:x2 ] 

# client side
#set title offset 0,-.8

# subfigures for CPU
set size 0.8,1
set xrange [ 30:101 ]
set yrange [ 0:2000 ]
    set datafile separator ","
    set ylabel "Response Time [ms]" font "Bold-Times_Roman,22"
    set title "" font "Bold-Times_Roman,22"
    set xlabel "X-ile [%]" font "Bole-Times_Roman,22"
    set xtics 5
do for [i=1:words(dists)] {
    stats word(dists, i) using ($1):($2) name "col" nooutput
}
    plot word(dists, 1) using ($1):($2) with linespoints pt 1 lt 1 lw 1 lc rgb "red" title sprintf("%s","Client") axis x1y1
