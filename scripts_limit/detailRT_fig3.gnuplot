# user-defined variables
#################################################################################
set terminal pdfcairo size 8in,500in
# set size 0.9,1
set terminal pdfcairo enhanced color dashed font "Helvetica, 18"

# The data in a CSV file are separated by comma.
set datafile separator ","

set output output_name

set multiplot layout 250,1 title title_name font "Helvetica, 24"

#set key right top nobox  noenhanced #font "Helvetica, 10"#horizontal vertical
#set key Right
#set key horizontal outside center top samplen 2 height 1 width -4.0 #below #inside left top
set key bottom horizontal outside center

#### X-axis ####
# set xlabel "Timeline [s]" offset 0,.6
set xrange [ x1:x2 ] 
set autoscale y
# client side
set title offset 0,-.8

# subfigures for CPU
set datafile separator " "
do for [h=1:words(collectls)] {
    #a(x) = system("bash getHostName.sh ".x)
    g(x) = system("sed -n '1p' ".word(collectls, h)."|cut -d' ' -f".x)
    
    set ylabel g(2)
    set title word(hosts, h)."--".g(2)
        stats word(collectls, h) using ($1-timestamp_offset):2 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):2 w l lw 2 title sprintf("%s (mean=%.4f)", g(2), col_mean_y) axis x1y1

    set ylabel g(4)
    set title word(hosts, h)."--".g(4)
        stats word(collectls, h) using ($1-timestamp_offset):4 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):4 w l lw 2 title sprintf("%s (mean=%.4f)", g(4), col_mean_y) axis x1y1

    set ylabel g(5)
    set title word(hosts, h)."--".g(5)
        stats word(collectls, h) using ($1-timestamp_offset):5 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):5 w l lw 2 title sprintf("%s (mean=%.4f)", g(5), col_mean_y) axis x1y1

    set ylabel g(10)
    set title word(hosts, h)."--".g(10)
	stats word(collectls, h) using ($1-timestamp_offset):10 name "col" nooutput
	plot word(collectls, h) using ($1-timestamp_offset):10 w l lw 2 title sprintf("%s (mean=%.4f)", g(10), col_mean_y) axis x1y1


    set ylabel g(14)
    set title word(hosts, h)."--".g(14)
        stats word(collectls, h) using ($1-timestamp_offset):14 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):14 w l lw 2 title sprintf("%s (mean=%.4f)", g(14), col_mean_y) axis x1y1

    set ylabel g(16)
    set title word(hosts, h)."--".g(16)
        stats word(collectls, h) using ($1-timestamp_offset):16 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):16 w l lw 2 title sprintf("%s (mean=%.4f)", g(16), col_mean_y) axis x1y1

    set ylabel g(17)
    set title word(hosts, h)."--".g(17)
        stats word(collectls, h) using ($1-timestamp_offset):17 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):17 w l lw 2 title sprintf("%s (mean=%.4f)", g(17), col_mean_y) axis x1y1

    set ylabel g(22)
    set title word(hosts, h)."--".g(22)
	stats word(collectls, h) using ($1-timestamp_offset):22 name "col" nooutput
	plot word(collectls, h) using ($1-timestamp_offset):22 w l lw 2 title sprintf("%s (mean=%.4f)", g(22), col_mean_y) axis x1y1


    set ylabel g(26)
    set title word(hosts, h)."--".g(26)
        stats word(collectls, h) using ($1-timestamp_offset):26 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):26 w l lw 2 title sprintf("%s (mean=%.4f)", g(26), col_mean_y) axis x1y1    

    set ylabel g(28)
    set title word(hosts, h)."--".g(28)
        stats word(collectls, h) using ($1-timestamp_offset):28 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):28 w l lw 2 title sprintf("%s (mean=%.4f)", g(28), col_mean_y) axis x1y1

    set ylabel g(29)
    set title word(hosts, h)."--".g(29)
        stats word(collectls, h) using ($1-timestamp_offset):29 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):29 w l lw 2 title sprintf("%s (mean=%.4f)", g(29), col_mean_y) axis x1y1

    set ylabel g(34)
    set title word(hosts, h)."--".g(34)
        stats word(collectls, h) using ($1-timestamp_offset):34 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):34 w l lw 2 title sprintf("%s (mean=%.4f)", g(34), col_mean_y) axis x1y1


    set ylabel g(38)
    set title word(hosts, h)."--".g(38)
        stats word(collectls, h) using ($1-timestamp_offset):38 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):38 w l lw 2 title sprintf("%s (mean=%.4f)", g(38), col_mean_y) axis x1y1

    set ylabel g(40)
    set title word(hosts, h)."--".g(40)
        stats word(collectls, h) using ($1-timestamp_offset):40 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):40 w l lw 2 title sprintf("%s (mean=%.4f)", g(40), col_mean_y) axis x1y1

    set ylabel g(41)
    set title word(hosts, h)."--".g(41)
        stats word(collectls, h) using ($1-timestamp_offset):41 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):41 w l lw 2 title sprintf("%s (mean=%.4f)", g(41), col_mean_y) axis x1y1

    set ylabel g(46)
    set title word(hosts, h)."--".g(46)
        stats word(collectls, h) using ($1-timestamp_offset):46 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):46 w l lw 2 title sprintf("%s (mean=%.4f)", g(46), col_mean_y) axis x1y1


    set ylabel g(50)
    set title word(hosts, h)."--".g(50)
        stats word(collectls, h) using ($1-timestamp_offset):50 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):50 w l lw 2 title sprintf("%s (mean=%.4f)", g(50), col_mean_y) axis x1y1

    set ylabel g(52)
    set title word(hosts, h)."--".g(52)
        stats word(collectls, h) using ($1-timestamp_offset):52 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):52 w l lw 2 title sprintf("%s (mean=%.4f)", g(52), col_mean_y) axis x1y1

    set ylabel g(53)
    set title word(hosts, h)."--".g(53)
        stats word(collectls, h) using ($1-timestamp_offset):53 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):53 w l lw 2 title sprintf("%s (mean=%.4f)", g(53), col_mean_y) axis x1y1

    set ylabel g(58)
    set title word(hosts, h)."--".g(58)
        stats word(collectls, h) using ($1-timestamp_offset):58 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):58 w l lw 2 title sprintf("%s (mean=%.4f)", g(58), col_mean_y) axis x1y1


    set ylabel g(62)
    set title word(hosts, h)."--".g(62)
        stats word(collectls, h) using ($1-timestamp_offset):62 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):62 w l lw 2 title sprintf("%s (mean=%.4f)", g(62), col_mean_y) axis x1y1

    set ylabel g(64)
    set title word(hosts, h)."--".g(64)
        stats word(collectls, h) using ($1-timestamp_offset):64 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):64 w l lw 2 title sprintf("%s (mean=%.4f)", g(64), col_mean_y) axis x1y1

    set ylabel g(65)
    set title word(hosts, h)."--".g(65)
        stats word(collectls, h) using ($1-timestamp_offset):65 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):65 w l lw 2 title sprintf("%s (mean=%.4f)", g(65), col_mean_y) axis x1y1

    set ylabel g(70)
    set title word(hosts, h)."--".g(70)
        stats word(collectls, h) using ($1-timestamp_offset):70 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):70 w l lw 2 title sprintf("%s (mean=%.4f)", g(70), col_mean_y) axis x1y1
    

    set ylabel g(74)
    set title word(hosts, h)."--".g(74)
        stats word(collectls, h) using ($1-timestamp_offset):74 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):74 w l lw 2 title sprintf("%s (mean=%.4f)", g(74), col_mean_y) axis x1y1

    set ylabel g(76)
    set title word(hosts, h)."--".g(76)
        stats word(collectls, h) using ($1-timestamp_offset):76 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):76 w l lw 2 title sprintf("%s (mean=%.4f)", g(76), col_mean_y) axis x1y1

    set ylabel g(77)
    set title word(hosts, h)."--".g(77)
        stats word(collectls, h) using ($1-timestamp_offset):77 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):77 w l lw 2 title sprintf("%s (mean=%.4f)", g(77), col_mean_y) axis x1y1

    set ylabel g(82)
    set title word(hosts, h)."--".g(82)
        stats word(collectls, h) using ($1-timestamp_offset):82 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):82 w l lw 2 title sprintf("%s (mean=%.4f)", g(82), col_mean_y) axis x1y1


    set ylabel g(86)
    set title word(hosts, h)."--".g(74)
        stats word(collectls, h) using ($1-timestamp_offset):74 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):74 w l lw 2 title sprintf("%s (mean=%.4f)", g(74), col_mean_y) axis x1y1

    set ylabel g(88)
    set title word(hosts, h)."--".g(88)
        stats word(collectls, h) using ($1-timestamp_offset):88 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):88 w l lw 2 title sprintf("%s (mean=%.4f)", g(88), col_mean_y) axis x1y1

    set ylabel g(89)
    set title word(hosts, h)."--".g(89)
        stats word(collectls, h) using ($1-timestamp_offset):89 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):89 w l lw 2 title sprintf("%s (mean=%.4f)", g(89), col_mean_y) axis x1y1

    set ylabel g(94)
    set title word(hosts, h)."--".g(94)
        stats word(collectls, h) using ($1-timestamp_offset):94 name "col" nooutput
        plot word(collectls, h) using ($1-timestamp_offset):94 w l lw 2 title sprintf("%s (mean=%.4f)", g(94), col_mean_y) axis x1y1

}

#collectlNW
do for [h=1:words(collectlNW)] {
	g(x) = system("sed -n '1p' ".word(collectlNW, h)."|cut -d' ' -f".x)
	set ylabel g(2)
	set title word(hosts, h)."--".g(2)
	stats word(collectlNW, h) using ($1-timestamp_offset):2 name "col" nooutput
        plot word(collectlNW, h) using ($1-timestamp_offset):2 w l lw 2 title sprintf("%s (mean=%.4f)", g(2), col_mean_y) axis x1y1


	set ylabel g(3)
        set title word(hosts, h)."--".g(3)
        stats word(collectlNW, h) using ($1-timestamp_offset):3 name "col" nooutput
        plot word(collectlNW, h) using ($1-timestamp_offset):3 w l lw 2 title sprintf("%s (mean=%.4f)", g(3), col_mean_y) axis x1y1

	set ylabel g(4)
        set title word(hosts, h)."--".g(4)
        stats word(collectlNW, h) using ($1-timestamp_offset):4 name "col" nooutput
        plot word(collectlNW, h) using ($1-timestamp_offset):4 w l lw 2 title sprintf("%s (mean=%.4f)", g(4), col_mean_y) axis x1y1

	set ylabel g(5)
        set title word(hosts, h)."--".g(5)
        stats word(collectlNW, h) using ($1-timestamp_offset):5 name "col" nooutput
        plot word(collectlNW, h) using ($1-timestamp_offset):5 w l lw 2 title sprintf("%s (mean=%.4f)", g(5), col_mean_y) axis x1y1

	set ylabel g(12)
        set title word(hosts, h)."--".g(12)
        stats word(collectlNW, h) using ($1-timestamp_offset):12 name "col" nooutput
        plot word(collectlNW, h) using ($1-timestamp_offset):12 w l lw 2 title sprintf("%s (mean=%.4f)", g(12), col_mean_y) axis x1y1

	set ylabel g(13)
        set title word(hosts, h)."--".g(13)
        stats word(collectlNW, h) using ($1-timestamp_offset):13 name "col" nooutput
        plot word(collectlNW, h) using ($1-timestamp_offset):13 w l lw 2 title sprintf("%s (mean=%.4f)", g(13), col_mean_y) axis x1y1
	
	set ylabel g(14)
        set title word(hosts, h)."--".g(14)
        stats word(collectlNW, h) using ($1-timestamp_offset):14 name "col" nooutput
        plot word(collectlNW, h) using ($1-timestamp_offset):14 w l lw 2 title sprintf("%s (mean=%.4f)", g(14), col_mean_y) axis x1y1

	set ylabel g(15)
        set title word(hosts, h)."--".g(15)
        stats word(collectlNW, h) using ($1-timestamp_offset):15 name "col" nooutput
        plot word(collectlNW, h) using ($1-timestamp_offset):15 w l lw 2 title sprintf("%s (mean=%.4f)", g(15), col_mean_y) axis x1y1


}
