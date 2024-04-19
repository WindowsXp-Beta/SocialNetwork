# user-defined variables
#################################################################################
set terminal pdfcairo size 10in,300in
# set size 0.9,1
set terminal pdfcairo enhanced color dashed font "Helvetica, 18"

# The data in a CSV file are separated by comma.
set datafile separator ","

set output output_name

set multiplot layout 160,1 title title_name font "Helvetica, 24"
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

# subfigures for TP
set datafile separator ","
stats timespan.'_'.word(tiers, 1).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2*20) name "col1" nooutput

        set ylabel "RR [req/s]"
        plot timespan.'_'.word(tiers, 1).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2*20) w l lw 2 title sprintf("%s-RR mean=%.4f","client", col1_mean_y) axis x1y1

set datafile separator ","
stats timespan.'_'.word(tiers, 1).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($3*20) name "col1" nooutput
	set ylabel "TP [req/s]"
	plot timespan.'_'.word(tiers, 1).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($3*20) w l lw 2 title sprintf("%s-TP mean=%.4f","client", col1_mean_y) axis x1y1

set datafile separator ","
# stats timespan.'_'.word(tiers, 2).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($3*20) name "col1" nooutput

#         set ylabel "TP [req/s]"
#         plot timespan.'_'.word(tiers, 2).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($3*20) w l lw 2 title sprintf("%s mean=%.4f","front", col1_mean_y) axis x1y1


set datafile separator ","

stats timespan.'_'.word(tiers, 1).'_multiplicity_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) name "col1" nooutput
# stats timespan.'_'.word(tiers, 2).'_multiplicity_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) name "col2" nooutput
	#set arrow from 0,150 to 180,150 nohead linestyle 0 lw 5 linecolor 'red'
        set ylabel "QL [/s]"
	plot timespan.'_'.word(tiers, 1).'_multiplicity_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) w l lw 2 title sprintf("%s mean=%.4f","client", col1_mean_y) axis x1y1

	# plot timespan.'_'.word(tiers, 2).'_multiplicity_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) w l lw 2 title sprintf("%s mean=%.4f","front", col2_mean_y) axis x1y1
	unset arrow	

	#unset key
    	set ylabel "Long Requests [#]"
        #set ytics 5
    	stats timespan.'_'.word(tiers, 1).'_inout_wl'.wl.'-50ms-LongReq1.csv' using ($1-timestamp_offset):($2) name "col" nooutput
        plot timespan.'_'.word(tiers, 1).'_inout_wl'.wl.'-50ms-LongReq1.csv' using ($1-timestamp_offset):($2) w l lw 2 title sprintf("Client long req (mean=%.4f)", col_mean_y) axis x1y1
                                       
        #set key right top nobox  noenhanced #font "Helvetica, 10"#horizontal vertical
        #set key Right
        set key bottom horizontal outside center
	
set datafile separator ","
#do for [i=1:words(tiers)] {
#    f(x) = system("sed -n '1p' ".timespan.'_'.word(tiers, 1).'_inout_wl'.wl.'-50ms-ALL.csv'."|cut -d',' -f".x)
# #       set title word(tiers, i)." ALL"
##        set ylabel "RT [s]"
#        stats timespan.'_'.word(tiers, i).'_responsetime_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) name "col" nooutput
#}	
stats timespan.'_'.word(tiers, 1).'_responsetime_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) name "col1" nooutput

        set ylabel "RT [s]"
        plot timespan.'_'.word(tiers, 1).'_responsetime_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) w l lw 2 title sprintf("%s-RT mean=%.4f","client", col1_mean_y) axis x1y1


# stats timespan.'_'.word(tiers, 2).'_responsetime_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) name "col1" nooutput

#         set ylabel "RT [s]"
#         plot timespan.'_'.word(tiers, 2).'_responsetime_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) w l lw 2 title sprintf("%s-RT mean=%.4f","front", col1_mean_y) axis x1y1

#set datafile separator ","
#do for [i=1:words(tiers)] {
#    f(x) = system("sed -n '1p' ".timespan.'_'.word(tiers, 1).'_inout_wl'.wl.'-50ms-ALL.csv'."|cut -d',' -f".x)
       # set title word(tiers, i)." ALL"
#       set ylabel "TP [req/s]"
#     stats timespan.'_'.word(tiers, i).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2*20) name "col" nooutput
#}
#        set ylabel "TP [req/s]"
#        plot timespan.'_'.word(tiers, 2).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2*20) w l lw 2 title sprintf("%s","apache"), timespan.'_'.word(tiers, 3).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2*20) w l lw 2 title sprintf("%s","tomcat")  axis x1y1

#set datafile separator ","
#do for [i=1:words(tiers)] {
#    f(x) = system("sed -n '1p' ".timespan.'_'.word(tiers, 1).'_inout_wl'.wl.'-50ms-ALL.csv'."|cut -d',' -f".x)
       # set title word(tiers, i)." ALL"
#        stats timespan.'_'.word(tiers, i).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($3*20) name "col" nooutput
#}
#        plot timespan.'_'.word(tiers, 2).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($3*20) w l lw 2 title sprintf("%s","apache"),timespan.'_'.word(tiers, 3).'_inout_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($3*20) w l lw 2 title sprintf("%s","tomcat") axis x1y1

#set datafile separator ","
#do for [i=1:words(tiers)] {
#    f(x) = system("sed -n '1p' ".timespan.'_'.word(tiers, 1).'_inout_wl'.wl.'-50ms-ALL.csv'."|cut -d',' -f".x)
       # set title word(tiers, i)." ALL"
#stats timespan.'_'.word(tiers, i).'_multiplicity_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) name "col" nooutput
#}
#	set arrow from 0,150 to 180,150 nohead linestyle 0 lw 5 linecolor 'red'
#        set ylabel "QL [/s]"
#        plot timespan.'_'.word(tiers, 2).'_multiplicity_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) w l lw 2 title sprintf("%s","apache"), timespan.'_'.word(tiers, 3).'_multiplicity_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) w l lw 2 title sprintf("%s","tomcat") axis x1y1
#	unset arrow

#set datafile separator ","
#do for [i=1:words(tiers)] {
#    f(x) = system("sed -n '1p' ".timespan.'_'.word(tiers, 1).'_inout_wl'.wl.'-50ms-ALL.csv'."|cut -d',' -f".x)
        #set title word(tiers, i)." ALL"
#stats timespan.'_'.word(tiers, i).'_responsetime_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) name "col" nooutput
#}
#        set ylabel "RT [s]"
#        plot timespan.'_'.word(tiers, 2).'_responsetime_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) w l lw 2 title sprintf("%s","apache"), timespan.'_'.word(tiers, 3).'_responsetime_wl'.wl.'-50ms-ALL.csv' using ($1-timestamp_offset):($2) w l lw 2 title sprintf("%s","tomcat") axis x1y1

set key bottom horizontal outside center

## test for CPU ##
set datafile separator " "
stats word(collectls, 1) using ($1-timestamp_offset):10 name "col_core0" nooutput
stats word(collectls, 1) using ($1-timestamp_offset):22 name "col_core1" nooutput
stats word(collectls, 1) using ($1-timestamp_offset):34 name "col_core2" nooutput
stats word(collectls, 1) using ($1-timestamp_offset):46 name "col_core3" nooutput
stats word(collectls, 1) using ($1-timestamp_offset):58 name "col_core4" nooutput
stats word(collectls, 1) using ($1-timestamp_offset):70 name "col_core5" nooutput
stats word(collectls, 1) using ($1-timestamp_offset):82 name "col_core6" nooutput
stats word(collectls, 1) using ($1-timestamp_offset):94 name "col_core7" nooutput

    set ylabel "VM0-CPU [%]"
    set yrange [0:110] 
    plot word(collectls, 1) using ($1-timestamp_offset):10 w l lw 2 title sprintf("%s mean=%.4f", "core0", col_core0_mean_y), word(collectls, 1) using ($1-timestamp_offset):22 w l lw 2 title sprintf("%s mean=%.4f", "core1", col_core1_mean_y), word(collectls, 1) using ($1-timestamp_offset):34 w l lw 2 title sprintf("%s mean=%.4f", "core2", col_core2_mean_y),  word(collectls, 1) using ($1-timestamp_offset):46 w l lw 2 title sprintf("%s mean=%.4f", "core3", col_core3_mean_y), word(collectls, 1) using ($1-timestamp_offset):58 w l lw 2 title sprintf("%s mean=%.4f", "core4", col_core4_mean_y), word(collectls, 1) using ($1-timestamp_offset):70 w l lw 2 title sprintf("%s mean=%.4f", "core5", col_core5_mean_y), word(collectls, 1) using ($1-timestamp_offset):82 w l lw 2 title sprintf("%s mean=%.4f", "core6", col_core6_mean_y), word(collectls, 1) using ($1-timestamp_offset):94 w l lw 2 title sprintf("%s mean=%.4f", "core7", col_core7_mean_y) axis x1y1




set datafile separator " "
stats word(collectls, 2) using ($1-timestamp_offset):10 name "col_core0" nooutput
stats word(collectls, 2) using ($1-timestamp_offset):22 name "col_core1" nooutput
stats word(collectls, 2) using ($1-timestamp_offset):34 name "col_core2" nooutput
stats word(collectls, 2) using ($1-timestamp_offset):46 name "col_core3" nooutput
stats word(collectls, 2) using ($1-timestamp_offset):58 name "col_core4" nooutput
stats word(collectls, 2) using ($1-timestamp_offset):70 name "col_core5" nooutput
stats word(collectls, 2) using ($1-timestamp_offset):82 name "col_core6" nooutput
stats word(collectls, 2) using ($1-timestamp_offset):94 name "col_core7" nooutput


    set ylabel "VM1-CPU [%]"
    set yrange [0:110]
    plot word(collectls, 2) using ($1-timestamp_offset):10 w l lw 2 title sprintf("%s mean=%.4f", "core0", col_core0_mean_y), word(collectls, 2) using ($1-timestamp_offset):22 w l lw 2 title sprintf("%s mean=%.4f", "core1", col_core1_mean_y), word(collectls, 2) using ($1-timestamp_offset):34 w l lw 2 title sprintf("%s mean=%.4f", "core2", col_core2_mean_y),  word(collectls, 2) using ($1-timestamp_offset):46 w l lw 2 title sprintf("%s mean=%.4f", "core3", col_core3_mean_y), word(collectls, 2) using ($1-timestamp_offset):58 w l lw 2 title sprintf("%s mean=%.4f", "core4", col_core4_mean_y), word(collectls, 2) using ($1-timestamp_offset):70 w l lw 2 title sprintf("%s mean=%.4f", "core5", col_core5_mean_y), word(collectls, 2) using ($1-timestamp_offset):82 w l lw 2 title sprintf("%s mean=%.4f", "core6", col_core6_mean_y), word(collectls, 2) using ($1-timestamp_offset):94 w l lw 2 title sprintf("%s mean=%.4f", "core7", col_core7_mean_y) axis x1y1




set datafile separator " "
stats word(collectls, 3) using ($1-timestamp_offset):10 name "col_core0" nooutput
stats word(collectls, 3) using ($1-timestamp_offset):22 name "col_core1" nooutput
stats word(collectls, 3) using ($1-timestamp_offset):34 name "col_core2" nooutput
stats word(collectls, 3) using ($1-timestamp_offset):46 name "col_core3" nooutput
stats word(collectls, 3) using ($1-timestamp_offset):58 name "col_core4" nooutput
stats word(collectls, 3) using ($1-timestamp_offset):70 name "col_core5" nooutput
stats word(collectls, 3) using ($1-timestamp_offset):82 name "col_core6" nooutput
stats word(collectls, 3) using ($1-timestamp_offset):94 name "col_core7" nooutput


    set ylabel "VM2-CPU [%]"
    set yrange [0:110]
    plot word(collectls, 3) using ($1-timestamp_offset):10 w l lw 2 title sprintf("%s mean=%.4f", "core0", col_core0_mean_y), word(collectls, 3) using ($1-timestamp_offset):22 w l lw 2 title sprintf("%s mean=%.4f", "core1", col_core1_mean_y), word(collectls, 3) using ($1-timestamp_offset):34 w l lw 2 title sprintf("%s mean=%.4f", "core2", col_core2_mean_y),  word(collectls, 3) using ($1-timestamp_offset):46 w l lw 2 title sprintf("%s mean=%.4f", "core3", col_core3_mean_y), word(collectls, 3) using ($1-timestamp_offset):58 w l lw 2 title sprintf("%s mean=%.4f", "core4", col_core4_mean_y), word(collectls, 3) using ($1-timestamp_offset):70 w l lw 2 title sprintf("%s mean=%.4f", "core5", col_core5_mean_y), word(collectls, 3) using ($1-timestamp_offset):82 w l lw 2 title sprintf("%s mean=%.4f", "core6", col_core6_mean_y), word(collectls, 3) using ($1-timestamp_offset):94 w l lw 2 title sprintf("%s mean=%.4f", "core7", col_core7_mean_y) axis x1y1



set datafile separator " "
stats word(collectls, 4) using ($1-timestamp_offset):10 name "col_core0" nooutput
stats word(collectls, 4) using ($1-timestamp_offset):22 name "col_core1" nooutput
stats word(collectls, 4) using ($1-timestamp_offset):34 name "col_core2" nooutput
stats word(collectls, 4) using ($1-timestamp_offset):46 name "col_core3" nooutput
stats word(collectls, 4) using ($1-timestamp_offset):58 name "col_core4" nooutput
stats word(collectls, 4) using ($1-timestamp_offset):70 name "col_core5" nooutput
stats word(collectls, 4) using ($1-timestamp_offset):82 name "col_core6" nooutput
stats word(collectls, 4) using ($1-timestamp_offset):94 name "col_core7" nooutput


    set ylabel "VM3-CPU [%]"
    set yrange [0:110]
    plot word(collectls, 4) using ($1-timestamp_offset):10 w l lw 2 title sprintf("%s mean=%.4f", "core0", col_core0_mean_y), word(collectls, 4) using ($1-timestamp_offset):22 w l lw 2 title sprintf("%s mean=%.4f", "core1", col_core1_mean_y), word(collectls, 4) using ($1-timestamp_offset):34 w l lw 2 title sprintf("%s mean=%.4f", "core2", col_core2_mean_y),  word(collectls, 4) using ($1-timestamp_offset):46 w l lw 2 title sprintf("%s mean=%.4f", "core3", col_core3_mean_y), word(collectls, 4) using ($1-timestamp_offset):58 w l lw 2 title sprintf("%s mean=%.4f", "core4", col_core4_mean_y), word(collectls, 4) using ($1-timestamp_offset):70 w l lw 2 title sprintf("%s mean=%.4f", "core5", col_core5_mean_y), word(collectls, 4) using ($1-timestamp_offset):82 w l lw 2 title sprintf("%s mean=%.4f", "core6", col_core6_mean_y), word(collectls, 4) using ($1-timestamp_offset):94 w l lw 2 title sprintf("%s mean=%.4f", "core7", col_core7_mean_y) axis x1y1



set datafile separator " "
stats word(collectls, 5) using ($1-timestamp_offset):10 name "col_core0" nooutput
stats word(collectls, 5) using ($1-timestamp_offset):22 name "col_core1" nooutput
stats word(collectls, 5) using ($1-timestamp_offset):34 name "col_core2" nooutput
stats word(collectls, 5) using ($1-timestamp_offset):46 name "col_core3" nooutput
stats word(collectls, 5) using ($1-timestamp_offset):58 name "col_core4" nooutput
stats word(collectls, 5) using ($1-timestamp_offset):70 name "col_core5" nooutput
stats word(collectls, 5) using ($1-timestamp_offset):82 name "col_core6" nooutput
stats word(collectls, 5) using ($1-timestamp_offset):94 name "col_core7" nooutput


    set ylabel "VM4-CPU [%]"
    set yrange [0:110]
    plot word(collectls, 5) using ($1-timestamp_offset):10 w l lw 2 title sprintf("%s mean=%.4f", "core0", col_core0_mean_y), word(collectls, 5) using ($1-timestamp_offset):22 w l lw 2 title sprintf("%s mean=%.4f", "core1", col_core1_mean_y), word(collectls, 5) using ($1-timestamp_offset):34 w l lw 2 title sprintf("%s mean=%.4f", "core2", col_core2_mean_y),  word(collectls, 5) using ($1-timestamp_offset):46 w l lw 2 title sprintf("%s mean=%.4f", "core3", col_core3_mean_y), word(collectls, 5) using ($1-timestamp_offset):58 w l lw 2 title sprintf("%s mean=%.4f", "core4", col_core4_mean_y), word(collectls, 5) using ($1-timestamp_offset):70 w l lw 2 title sprintf("%s mean=%.4f", "core5", col_core5_mean_y), word(collectls, 5) using ($1-timestamp_offset):82 w l lw 2 title sprintf("%s mean=%.4f", "core6", col_core6_mean_y), word(collectls, 5) using ($1-timestamp_offset):94 w l lw 2 title sprintf("%s mean=%.4f", "core7", col_core7_mean_y) axis x1y1


set datafile separator " "
stats word(collectls, 6) using ($1-timestamp_offset):10 name "col_core0" nooutput
stats word(collectls, 6) using ($1-timestamp_offset):22 name "col_core1" nooutput
stats word(collectls, 6) using ($1-timestamp_offset):34 name "col_core2" nooutput
stats word(collectls, 6) using ($1-timestamp_offset):46 name "col_core3" nooutput
stats word(collectls, 6) using ($1-timestamp_offset):58 name "col_core4" nooutput
stats word(collectls, 6) using ($1-timestamp_offset):70 name "col_core5" nooutput
stats word(collectls, 6) using ($1-timestamp_offset):82 name "col_core6" nooutput
stats word(collectls, 6) using ($1-timestamp_offset):94 name "col_core7" nooutput


    set ylabel "VM5-CPU [%]"
    set yrange [0:110]
    plot word(collectls, 6) using ($1-timestamp_offset):10 w l lw 2 title sprintf("%s mean=%.4f", "core0", col_core0_mean_y), word(collectls, 6) using ($1-timestamp_offset):22 w l lw 2 title sprintf("%s mean=%.4f", "core1", col_core1_mean_y), word(collectls, 6) using ($1-timestamp_offset):34 w l lw 2 title sprintf("%s mean=%.4f", "core2", col_core2_mean_y),  word(collectls, 6) using ($1-timestamp_offset):46 w l lw 2 title sprintf("%s mean=%.4f", "core3", col_core3_mean_y), word(collectls, 6) using ($1-timestamp_offset):58 w l lw 2 title sprintf("%s mean=%.4f", "core4", col_core4_mean_y), word(collectls, 6) using ($1-timestamp_offset):70 w l lw 2 title sprintf("%s mean=%.4f", "core5", col_core5_mean_y), word(collectls, 6) using ($1-timestamp_offset):82 w l lw 2 title sprintf("%s mean=%.4f", "core6", col_core6_mean_y), word(collectls, 6) using ($1-timestamp_offset):94 w l lw 2 title sprintf("%s mean=%.4f", "core7", col_core7_mean_y) axis x1y1

# set datafile separator " "
# stats word(collectls, 7) using ($1-timestamp_offset):10 name "col_core0" nooutput
# stats word(collectls, 7) using ($1-timestamp_offset):22 name "col_core1" nooutput
# stats word(collectls, 7) using ($1-timestamp_offset):34 name "col_core2" nooutput
# stats word(collectls, 7) using ($1-timestamp_offset):46 name "col_core3" nooutput
# stats word(collectls, 7) using ($1-timestamp_offset):58 name "col_core4" nooutput
# stats word(collectls, 7) using ($1-timestamp_offset):70 name "col_core5" nooutput
# stats word(collectls, 7) using ($1-timestamp_offset):82 name "col_core6" nooutput
# stats word(collectls, 7) using ($1-timestamp_offset):94 name "col_core7" nooutput
# 
# 
#     set ylabel "VM6-CPU [%]"
#     set yrange [0:110]
#     plot word(collectls, 7) using ($1-timestamp_offset):10 w l lw 2 title sprintf("%s mean=%.4f", "core0", col_core0_mean_y), word(collectls, 7) using ($1-timestamp_offset):22 w l lw 2 title sprintf("%s mean=%.4f", "core1", col_core1_mean_y), word(collectls, 7) using ($1-timestamp_offset):34 w l lw 2 title sprintf("%s mean=%.4f", "core2", col_core2_mean_y),  word(collectls, 7) using ($1-timestamp_offset):46 w l lw 2 title sprintf("%s mean=%.4f", "core3", col_core3_mean_y), word(collectls, 7) using ($1-timestamp_offset):58 w l lw 2 title sprintf("%s mean=%.4f", "core4", col_core4_mean_y), word(collectls, 7) using ($1-timestamp_offset):70 w l lw 2 title sprintf("%s mean=%.4f", "core5", col_core5_mean_y), word(collectls, 7) using ($1-timestamp_offset):82 w l lw 2 title sprintf("%s mean=%.4f", "core6", col_core6_mean_y), word(collectls, 7) using ($1-timestamp_offset):94 w l lw 2 title sprintf("%s mean=%.4f", "core7", col_core7_mean_y) axis x1y1
# 
# 
# set datafile separator ","
# 
# stats word(procs, 1) using ($1-timestamp_offset):2 name "col2" nooutput
# stats word(procs, 1) using ($1-timestamp_offset):3 name "col3" nooutput
# 
#     set ylabel "CPU [%]"
#     set yrange [0:110]
#     plot word(procs, 1) using ($1-timestamp_offset):2 w l lw 2 title sprintf("%s mean=%.4f", "userMongodb", col2_mean_y), word(procs, 1) using ($1-timestamp_offset):3 w l lw 2 title sprintf("%s mean=%.4f", "homeTimelineService", col3_mean_y) axis x1y1
# 
# 
# set datafile separator ","
# 
# stats word(procs, 2) using ($1-timestamp_offset):2 name "col2" nooutput
# stats word(procs, 2) using ($1-timestamp_offset):3 name "col3" nooutput
# stats word(procs, 2) using ($1-timestamp_offset):4 name "col4" nooutput
# 
#     set ylabel "CPU [%]"
#     set yrange [0:110]
#     plot word(procs, 2) using ($1-timestamp_offset):2 w l lw 2 title sprintf("%s mean=%.4f", "postStorageMongodb", col2_mean_y), word(procs, 2) using ($1-timestamp_offset):3 w l lw 2 title sprintf("%s mean=%.4f", "postStorageService", col3_mean_y), word(procs, 2) using ($1-timestamp_offset):4 w l lw 2 title sprintf("%s mean=%.4f", "mediaMemcached", col4_mean_y) axis x1y1
# 
# 
# 
# set datafile separator ","
# 
# stats word(procs, 3) using ($1-timestamp_offset):2 name "col2" nooutput
# stats word(procs, 3) using ($1-timestamp_offset):3 name "col3" nooutput
# stats word(procs, 3) using ($1-timestamp_offset):4 name "col4" nooutput
# stats word(procs, 3) using ($1-timestamp_offset):5 name "col5" nooutput
# stats word(procs, 3) using ($1-timestamp_offset):6 name "col6" nooutput
# stats word(procs, 3) using ($1-timestamp_offset):7 name "col7" nooutput
# stats word(procs, 3) using ($1-timestamp_offset):8 name "col8" nooutput
# 
#     set ylabel "CPU [%]"
#     set yrange [0:110]
#     plot word(procs, 3) using ($1-timestamp_offset):2 w l lw 2 title sprintf("%s mean=%.4f", "postStorageMemcached", col2_mean_y), word(procs, 3) using ($1-timestamp_offset):3 w l lw 2 title sprintf("%s mean=%.4f", "mediaService", col3_mean_y), word(procs, 3) using ($1-timestamp_offset):4 w l lw 2 title sprintf("%s mean=%.4f", "composePostService", col4_mean_y), word(procs, 3) using ($1-timestamp_offset):5 w l lw 2 title sprintf("%s mean=%.4f", "homeTimelineRedis", col5_mean_y), word(procs, 3) using ($1-timestamp_offset):6 w l lw 2 title sprintf("%s mean=%.4f", "userMentionService", col6_mean_y), word(procs, 3) using ($1-timestamp_offset):7 w l lw 2 title sprintf("%s mean=%.4f", "socialGraphMongodb", col7_mean_y), word(procs, 3) using ($1-timestamp_offset):8 w l lw 2 title sprintf("%s mean=%.4f", "urlShortenService", col8_mean_y) axis x1y1
# 
# 
# 
# set datafile separator ","
# 
# stats word(procs, 4) using ($1-timestamp_offset):2 name "col2" nooutput
# stats word(procs, 4) using ($1-timestamp_offset):3 name "col3" nooutput
# stats word(procs, 4) using ($1-timestamp_offset):4 name "col4" nooutput
# stats word(procs, 4) using ($1-timestamp_offset):5 name "col5" nooutput
# stats word(procs, 4) using ($1-timestamp_offset):6 name "col6" nooutput
# 
#     set ylabel "CPU [%]"
#     set yrange [0:110]
#     plot word(procs, 4) using ($1-timestamp_offset):2 w l lw 2 title sprintf("%s mean=%.4f", "textService", col2_mean_y), word(procs, 4) using ($1-timestamp_offset):3 w l lw 2 title sprintf("%s mean=%.4f", "urlShortenMemcached", col3_mean_y), word(procs, 4) using ($1-timestamp_offset):4 w l lw 2 title sprintf("%s mean=%.4f", "mediaMongodb", col4_mean_y), word(procs, 4) using ($1-timestamp_offset):5 w l lw 2 title sprintf("%s mean=%.4f", "socialGraphService", col5_mean_y), word(procs, 4) using ($1-timestamp_offset):6 w l lw 2 title sprintf("%s mean=%.4f", "userTimelineRedis", col6_mean_y) axis x1y1
# 
# 
# set datafile separator ","
# 
# stats word(procs, 5) using ($1-timestamp_offset):2 name "col2" nooutput
# stats word(procs, 5) using ($1-timestamp_offset):3 name "col3" nooutput
# stats word(procs, 5) using ($1-timestamp_offset):4 name "col4" nooutput
# stats word(procs, 5) using ($1-timestamp_offset):5 name "col5" nooutput
# stats word(procs, 5) using ($1-timestamp_offset):6 name "col6" nooutput
# stats word(procs, 5) using ($1-timestamp_offset):7 name "col7" nooutput
# 
#     set ylabel "CPU [%]"
#     set yrange [0:110]
#     plot word(procs, 5) using ($1-timestamp_offset):2 w l lw 2 title sprintf("%s mean=%.4f", "userMemcached", col2_mean_y), word(procs, 5) using ($1-timestamp_offset):3 w l lw 2 title sprintf("%s mean=%.4f", "socialGraphRedis", col3_mean_y), word(procs, 5) using ($1-timestamp_offset):4 w l lw 2 title sprintf("%s mean=%.4f", "userService", col4_mean_y), word(procs, 5) using ($1-timestamp_offset):5 w l lw 2 title sprintf("%s mean=%.4f", "userTimelineMongodb", col5_mean_y), word(procs, 5) using ($1-timestamp_offset):6 w l lw 2 title sprintf("%s mean=%.4f", "userTimelineService", col6_mean_y), word(procs, 5) using ($1-timestamp_offset):7 w l lw 2 title sprintf("%s mean=%.4f", "uniqueIdService", col7_mean_y) axis x1y1
# 
# 
# 
# set datafile separator ","
# 
# stats word(procs, 6) using ($1-timestamp_offset):2 name "col2" nooutput
# stats word(procs, 6) using ($1-timestamp_offset):3 name "col3" nooutput
# 
#     set ylabel "CPU [%]"
#     set yrange [0:110]
#     plot word(procs, 6) using ($1-timestamp_offset):2 w l lw 2 title sprintf("%s mean=%.4f", "urlShortenMongodb", col2_mean_y), word(procs, 6) using ($1-timestamp_offset):3 w l lw 2 title sprintf("%s mean=%.4f", "nginxWebServer", col3_mean_y) axis x1y1
# 
# 
# 