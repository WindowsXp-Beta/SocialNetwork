#!/bin/bash
# shungeng
# plot each collectl info by server
#


# user-defined variables
datasource=
x_range="620:800"
output_name=collectl.pdf
title_name=
timestamp_offset=0

# cli options
while getopts x: opt
do
    case "$opt" in
        x)  x_range="$OPTARG";;
        \?)       # unknown flag
            echo >&2 \
                "invalid options"
            exit 1;;
    esac
done
shift `expr $OPTIND - 1`

# realwork
declare -A dict
for i in $( ls -d */ )
do
	echo -e "\e[33m\tgenerate Collectl plot for $i\e[0m"
	cd $i
	# gnuplot template file
	template_file=collectl_tmp.gnuplot
	cp ../../scripts_limit/collectl_fig.gnuplot ./collectl_tmp.gnuplot

    con_file=$(ls detailRT-client_*.csv)
    concurrency=$(echo $con_file | egrep -o '[0-9]+')
    #timestamp=$(cat $BONN_RUBBOS_RESULTS_DIR_BASE/$RUBBOS_RESULTS_DIR_NAME/EXPERIMENTS_RUNTIME_START.csv| egrep "^$concurrency"|cut -d',' -f4)
    timestamp=`head -3 Experiments_timestamp.log | tail -1`
    # translate timestamp to sec-level
    timestamp_offset=`expr $timestamp / 1000`
	#echo $timestamp_offset
  
    # different servers info
    for j in $(ls | egrep '[0-9]_collectl+.csv')
	do
		#echo $(echo $j | cut -c 1-6)
		#name=$(echo $(echo $j | egrep -oEi1 '[0-9]+')|cut -f1 -d" ")
		name=$(echo $j | cut -c 1-6)
		#host=$(grep "\.$name" $BONN_RUBBOS_RESULTS_DIR_BASE/$RUBBOS_RESULTS_DIR_NAME/set_elba_env.sh | cut -f1 -d"=")
		#host=$(echo "$host" | sed 's/_/\\_/g')
       		host=$(echo $j | cut -c4-8)
		echo $name
		case $name in 
			"node-0") 
				host="Front-end"
				;;
			"node-1")
				host="catalogue"
				;;
			"node-2")
				host="catalogueDB"
				;;
			"node-3")
				host="cart"
				;;
			"node-4")
				host="cartDB"
				;;
			"node-5")
				host="user"
                                ;;
			"node-6")
                                host="userDB"
                                ;;
		esac
	
        	output_name=${j%.*}".pdf"
        	title_name=${host}"-WL"${concurrency}
        	datasource=$j
		#echo $j | cut -c4-8
        	x2=${x_range#*:}
        	x1=${x_range%:*}
		echo $title_name
        	gnuplot -e "plot_file='${datasource}'; x1='${x1}'; x2='${x2}'; output_name='${output_name}'; title_name='${title_name}'; timestamp_offset='${timestamp_offset}'" $template_file
	done
	cd ..
done
