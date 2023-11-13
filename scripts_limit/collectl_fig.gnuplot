# user-defined variables
#plot_file = <var1>
#x_range = <var2>
#output_name = <var3>
#title_name = <var4>
#timestamp_offset = <var5>
#################################################################################
set terminal pdfcairo size 10in,70in
# set size 0.9,1
set terminal pdfcairo enhanced color dashed font "Helvetica, 18"

# The data in a CSV file are separated by comma.
set datafile separator " "

set output output_name

set multiplot layout 40,1 title title_name font "Helvetica, 24"

set key right top nobox #font "Helvetica, 10"#horizontal vertical
set key Left
#set key horizontal outside center top samplen 2 height 1 width -4.0 #below #inside left top

#### X-axis ####
# set xlabel "Timeline [s]" offset 0,.6
set xrange [ x1:x2 ] 

f(x) = system("sed -n '1p' ".plot_file."|cut -d' ' -f".x)
g(x) = x * 1.1

# subfigure for CPU
do for [i=2:22] {
	set title ""
	set ylabel f(i)
	stats plot_file using ($1-timestamp_offset):i name "col" nooutput
    #show variables all
    # set yrange [:GPVAL_Y_MAX + 10]
	plot [:][:col_max_y*1.1] plot_file using ($1-timestamp_offset):i w l lw 2 title sprintf("%s (mean=%.4f)", f(i), col_mean_y) axis x1y1
}

# subfigures for network
do for [i=23:31] {
	set title ""
	set ylabel f(i)
	stats plot_file using ($1-timestamp_offset):i name "col" nooutput
	plot plot_file using ($1-timestamp_offset):i w l lw 2 title sprintf("%s (mean=%.4f)", f(i), col_mean_y) axis x1y1
}

# subfigures for disk
do for [i=32:40] {
	set title ""
	set ylabel f(i)
	stats plot_file using ($1-timestamp_offset):i name "col" nooutput
	plot plot_file using ($1-timestamp_offset):i w l lw 2 title sprintf("%s (mean=%.4f)", f(i), col_mean_y) axis x1y1
}
