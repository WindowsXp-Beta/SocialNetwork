# !/usr/bin
# -*- coding:utf-8 -*-
# Copyright (c) Apr,24 2017 - Shungeng Zhang <szhan45@lsu.edu>
import sys,re,time,csv,commands
from subprocess import call,check_output
from datetime import datetime

pwd = check_output('pwd')
hfile = pwd[:-1] + "/result.jtl"

results = commands.getstatusoutput('grep \'Total number of clients for this experiment\' index.html')
if results[0] != 0:
	print "Error: %s" % results[1]
aaa1 = results[1].split(': ')
aaa2 = aaa1[1].split('<')
workload = aaa2[0]
print workload

output = pwd[:-1] + "/detailRT-client_wl" + workload + ".csv"

runtime = commands.getstatusoutput("cat Experiments_timestamp.log")

runtime_start_human = runtime[1].split()[0]
runtime_end_human = runtime[1].split()[1]
print runtime_start_human
print runtime_end_human


def human_to_epoch(human_time):
	dt = datetime.strptime(human_time, '%Y%m%d%H%M%S')
	epoch_time = time.mktime(dt.timetuple())*1000
	return epoch_time
	
runtime_start = int(human_to_epoch(runtime_start_human))
runtime_end = int(human_to_epoch(runtime_end_human))


with open(pwd[:-1] + "/Experiments_timestamp.log", 'a') as timeFile:
	timeFile.write(str(runtime_start) + '\n' + str(runtime_end) + '\n')

print "%13d %13d" % (int(runtime_start), int(runtime_end))

filter = r"\d+\s\d+\s+[A-Za-z]+"
with open(hfile) as f, open(output, "w") as w:
	w.write("start_time,end_time,request_type,response_time\n")
	for line in f:
		matches = re.findall(filter, str(line))
		if matches:
			endtime = int(line.split()[0]) 
			starttime   = int(line.split()[0]) - int(line.split()[1])
			response  = int(line.split()[1])

			typeStr = line.split()[2]
			type_filter = r"[A-Za-z]+"
			reqType = re.findall(type_filter, typeStr)[0]
			fieldnames = ['start_time', 'end_time', 'request_type', 'response_time']
			writer = csv.DictWriter(w, fieldnames=fieldnames)
			if starttime >= runtime_start and starttime <= runtime_end :
				writer.writerow({'start_time':starttime, 'end_time':endtime, 'request_type':reqType, 'response_time':response})
