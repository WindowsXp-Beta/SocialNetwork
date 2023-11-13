#set terminal pdfcairo enhanced font '/usr/share/fonts/liberation/LiberationSans-Regular.ttf, 12'
set terminal pdfcairo size 6in,3in
set output "average.pdf"
set title "***Througput and Response Time***"
#set label "--- 111-AP150-TP50-DP10!" at screen 0.65,0.93 tc lt 4
set key left top
set datafile separator ","
set ytics nomirror
set xlabel 'Workload [# of users]'
#set tmargin 3
set ylabel 'Througput [req/s]'
set yrange [0:]
set y2label 'Response Time [s]'
set y2tics auto

plot "average_performance.csv" using 1:2 lw 2 with lp title 'throughput' axis x1y1,	"average_performance.csv" using 1:3 lw 2 with lp title 'response time' axis x1y2

#######################################################

set title "***average cpu usage***"
set datafile separator ','
set xlabel 'Workload [# of users]'
#set tmargin 3
set ylabel 'CPU Usage [%]'
set yrange [0:110]
set grid ytics lc rgb '#bbbbbb' lw 1 lt 1 
unset y2label
unset y2tics
plot "<(sed -n '2,$p' average_resource_utilization.csv)" using 1:2 lw 2 with lp title 'home\_timeline\_service' axis x1y1,\
	'' using 1:3 lw 2 with lp title 'user\_mongodb' axis x1y1,\

##################################################

set title "***average cpu usage***"
set datafile separator ','
set xlabel 'Workload [# of users]'
#set tmargin 3
set ylabel 'CPU Usage [%]'
set yrange [0:110]
set grid ytics lc rgb '#bbbbbb' lw 1 lt 1
unset y2label
unset y2tics
plot "<(sed -n '2,$p' average_resource_utilization.csv)" using 1:4 lw 2 with lp title 'post\_storage\_service' axis x1y1,\
	'' using 1:5 lw 2 with lp title 'post\_storage\_mongodb' axis x1y1,\
	'' using 1:6 lw 2 with lp title 'media\_memcached' axis x1y1,\


###################################################

set title "***average cpu usage***"
set datafile separator ','
set xlabel 'Workload [# of users]'
#set tmargin 3
set ylabel 'CPU Usage [%]'
set yrange [0:110]
set grid ytics lc rgb '#bbbbbb' lw 1 lt 1
unset y2label
unset y2tics

plot "<(sed -n '2,$p' average_resource_utilization.csv)" using 1:7 lw 2 with lp title 'post\_storage\_memcached' axis x1y1,\
        '' using 1:8 lw 2 with lp title 'compose\_post\_service' axis x1y1,\
        '' using 1:9 lw 2 with lp title 'media\_service' axis x1y1,\
        '' using 1:10 lw 2 with lp title 'user\_mention\_service' axis x1y1,\
        '' using 1:11 lw 2 with lp title 'home\_timeline\_redis' axis x1y1,\
        '' using 1:12 lw 2 with lp title 'social\_graph\_mongodb' axis x1y1,\
	'' using 1:13 lw 2 with lp title 'url\_shorten\_service' axis x1y1,\

###################################################

set title "***average cpu usage***"
set datafile separator ','
set xlabel 'Workload [# of users]'
#set tmargin 3
set ylabel 'CPU Usage [%]'
set yrange [0:110]
set grid ytics lc rgb '#bbbbbb' lw 1 lt 1
unset y2label
unset y2tics

plot "<(sed -n '2,$p' average_resource_utilization.csv)" using 1:14 lw 2 with lp title 'user\_timeline\_redis' axis x1y1,\
        '' using 1:15 lw 2 with lp title 'text\_service' axis x1y1,\
        '' using 1:16 lw 2 with lp title 'media\_mongodb' axis x1y1,\
        '' using 1:17 lw 2 with lp title 'social\_graph\_service' axis x1y1,\
        '' using 1:18 lw 2 with lp title 'url\_shorten\_memcached' axis x1y1,\
	'' using 1:19 lw 2 with lp title 'media\_frontend' axis x1y1,\

####################################################

set title "***average cpu usage***"
set datafile separator ','
set xlabel 'Workload [# of users]'
#set tmargin 3
set ylabel 'CPU Usage [%]'
set yrange [0:110]
set grid ytics lc rgb '#bbbbbb' lw 1 lt 1
unset y2label
unset y2tics


plot "<(sed -n '2,$p' average_resource_utilization.csv)" using 1:20 lw 2 with lp title 'unique\_id\_service' axis x1y1,\
        '' using 1:21 lw 2 with lp title 'user\_timeline\_service' axis x1y1,\
        '' using 1:22 lw 2 with lp title 'user\_memcached' axis x1y1,\
        '' using 1:23 lw 2 with lp title 'user\_timeline\_mongodb' axis x1y1,\
        '' using 1:24 lw 2 with lp title 'user\_service' axis x1y1,\
        '' using 1:25 lw 2 with lp title 'social\_graph\_redis' axis x1y1,\

#######################################################

set title "***average cpu usage***"
set datafile separator ','
set xlabel 'Workload [# of users]'
#set tmargin 3
set ylabel 'CPU Usage [%]'
#set yrange [0:110]
unset yrange
set grid ytics lc rgb '#bbbbbb' lw 1 lt 1
unset y2label
unset y2tics

plot "<(sed -n '2,$p' average_resource_utilization.csv)" using 1:26 lw 2 with lp title 'url\_shorten\_mongodb' axis x1y1,\
        '' using 1:27 lw 2 with lp title 'nginx\_web\_server' axis x1y1,\

#######################################################

set title "***average cpu usage***"
set datafile separator ','
set xlabel 'Workload [# of users]'
#set tmargin 3
set ylabel 'CPU Usage [%]'
set yrange [0:110]
set grid ytics lc rgb '#bbbbbb' lw 1 lt 1
unset y2label
unset y2tics

plot "<(sed -n '2,$p' average_resource_utilization.csv)" using 1:28 lw 2 with lp title 'nginx\_frontend' axis x1y1,\


