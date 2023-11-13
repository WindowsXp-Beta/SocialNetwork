set terminal postscript enhanced color "Helvetica" 26
#set size 1,0.70
mag=15
strcat1(x)=x.".ps"
strcat2(x)=x.".csv"

n=200 #number of intervals
max=3000 #max value
min=0 #min value
width=(max-min)/n #interval width
#function used to map a value to the intervals
hist(x,width)=width*floor(x/width)+width/2.0
#set term png #output terminal and file
set output strcat1(datasource)
set xrange [min:max]
set yrange [1:]
#to put an empty boundary around the
#data inside an autoscaled graph.
#set offset graph 0.05,0.05,0.05,0.0
set xtics min,(max-min)/4,max
set boxwidth width*0.6
set style fill solid 0.5 #fillstyle
set tics out nomirror
set xlabel "Response time [ms]" font "Helvetica, 30" offset 0.0,0.2 
set ylabel "Frequency [#]"  font "Helvetica,30" offset 1.5,0.0


set datafile  separator ','
set table 'tablefilename'
#count and plot
# take the filename from terminal
plot strcat2(datasource) using (hist($4,width)):(1.0) smooth freq w boxes lc rgb"green" notitle

unset table

set logscale y
#set logscale x
set datafile  separator whitespace

plot 'tablefilename' using 1:2 w boxes lc rgb"green" notitle
