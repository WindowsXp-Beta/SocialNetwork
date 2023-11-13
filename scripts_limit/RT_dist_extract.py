# !/usr/bin
# -*- coding:utf-8 -*-
# Copyright (c) Dec.31 2018 - Jianshu Liu <jliu96@lsu.edu>
from datetime import datetime
import sys,re,time,csv,commands,math
from subprocess import call,check_output
import numpy as np

pwd = check_output('pwd')

client_file=commands.getstatusoutput("ls |egrep 'detailRT-client\w+.csv$'")
#print client_file

runtime = commands.getstatusoutput("cat Experiments_timestamp.log")

runtime_start_human = runtime[1].split()[0]
runtime_end_human = runtime[1].split()[1]

def human_to_epoch(human_time):
        dt = datetime.strptime(human_time, '%Y%m%d%H%M%S')
        epoch_time = time.mktime(dt.timetuple())*1000
        return epoch_time

#human_to_epoch(runtime_start_human)
runtime_start = human_to_epoch(runtime_start_human)
#runtime_start = runtime_start + 240*1000
runtime_start = runtime_start + 100*1000
runtime_end = runtime_start + 200*1000
print int(runtime_start)
print int(runtime_end)


hfile = pwd[:-1] + "/"+client_file[1]
output = pwd[:-1] + "/RT_client_dist.csv"
j=0
response=[]
with open(hfile) as f, open(output, "w") as w:
	for line in f:
		if (int(line.split(',')[0]) > int(runtime_start) and int(line.split(',')[0]) < int(runtime_end)):
			#print int(line.split(',')[0])
                	if (j!=0):
                	   response.append(float(line.split(',')[3]))
                	j=1
        length=len(response)
        res_arr=np.array(response)
        for i in range(0,100):
            fieldnames = ['Percentile', 'RT']
            writer = csv.DictWriter(w, fieldnames=fieldnames)
            writer.writerow({'Percentile':i, 'RT':np.percentile(res_arr,i)})
        writer = csv.DictWriter(w, fieldnames=fieldnames)
        writer.writerow({'Percentile':100, 'RT':np.percentile(res_arr,99.995)})
