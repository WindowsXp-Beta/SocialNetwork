# user-defined variables
#################################################################################
set terminal pdfcairo size 10in,375in
# set size 0.9,1
set terminal pdfcairo enhanced color dashed font "Helvetica, 18"

# The data in a CSV file are separated by comma.
set datafile separator ","

set output output_name

set multiplot layout 200,1 title title_name font "Helvetica, 24"
set linetype 1 lc rgb "red"
set linetype 4 lc rgb "blue"
set linetype 2 lc rgb "#ffe119"
set linetype 3 lc rgb "#000075"
set linetype 5 lc rgb "#a9a9a9"
#set key right top nobox  noenhanced #font "Helvetica, 10"#horizontal vertical
#set key Right
#set key horizontal outside center top samplen 2 height 1 width -4.0 #below #inside left top
#set key bottom horizontal outside center

#### X-axis ####
# set xlabel "Timeline [s]" offset 0,.6
set xrange [ x1:x2 ] 

# client side
#set title offset 0,-.8


do for [h=1:words(components)] {

    # subfigures for Req Rate
    set datafile separator ","
    stats timespan.'_'.word(components, h).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2*20) name "col" nooutput
    set ylabel "RR [req/s]"
    plot timespan.'_'.word(components, h).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2*20) w l lw 2 title sprintf("%s mean=%.4f", word(components, h), col_mean_y) axis x1y1

    # subfigures for TP
    set datafile separator ","
    stats timespan.'_'.word(components, h).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($3*20) name "col" nooutput
    set ylabel "TP [req/s]"
    plot timespan.'_'.word(components, h).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($3*20) w l lw 2 title sprintf("%s mean=%.4f", word(components, h), col_mean_y) axis x1y1

    # subfigures for QL
    set datafile separator ","
    stats timespan.'_'.word(components, h).'_multiplicity_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) name "col" nooutput
    set ylabel "QL [#/s]"
    plot timespan.'_'.word(components, h).'_multiplicity_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) w l lw 2 title sprintf("%s mean=%.4f", word(components, h), col_mean_y) axis x1y1


    # subfigures for RS
    set datafile separator ","
    stats timespan.'_'.word(components, h).'_responsetime_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) name "col" nooutput
    set ylabel "RT [s]"
    plot timespan.'_'.word(components, h).'_responsetime_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) w l lw 2 title sprintf("%s mean=%.4f", word(components, h), col_mean_y) axis x1y1

}
