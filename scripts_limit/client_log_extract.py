# !/usr/bin
# -*- coding:utf-8 -*-
# Copyright (c) Apr,24 2017 - Shungeng Zhang <szhan45@lsu.edu>
import sys,re,time,csv,commands
from subprocess import call,check_output
from datetime import datetime

pwd = check_output('pwd')
hfile = pwd[:-1] + "/result.jtl"
#output = pwd[:-1] + "/client_req.csv"

results = commands.getstatusoutput('grep \'Total number of clients for this experiment\' index.html')
if results[0] != 0:
	print "Error: %s" % results[1]
aaa1 = results[1].split(': ')
aaa2 = aaa1[1].split('<')
workload = aaa2[0]
print workload

output = pwd[:-1] + "/detailRT-client_wl" + workload + ".csv"
#print output

runtime = commands.getstatusoutput("cat Experiments_timestamp.log")
#print runtime_start[1].split()[0]

runtime_start_human = runtime[1].split()[0]
runtime_end_human = runtime[1].split()[1]
print runtime_start_human
print runtime_end_human

#human_to_epoch(runtime_start_human)

def human_to_epoch(human_time):
	dt = datetime.strptime(human_time, '%Y%m%d%H%M%S')
	epoch_time = time.mktime(dt.timetuple())*1000
	return epoch_time
	
#human_to_epoch(runtime_start_human)
runtime_start = int(human_to_epoch(runtime_start_human))
runtime_end = int(human_to_epoch(runtime_end_human))


with open(pwd[:-1] + "/Experiments_timestamp.log", 'a') as timeFile:
	timeFile.write(str(runtime_start) + '\n' + str(runtime_end) + '\n')

#runtime = pwd[:-1] + "/VMrhl-142-*_collectl_*.csv"
#runtime_start = float(commands.getstatusoutput("cat ../EXPERIMENTS_RUNTIME_START.csv| egrep '^"+workload+"'|cut -d',' -f4")[1])#/1000
#runtime_end = float(commands.getstatusoutput("cat ../EXPERIMENTS_RUNTIME_START.csv| egrep '^"+workload+"'|cut -d',' -f5")[1])#/1000
#print str(runtime_start), str(runtime_end)
print "%13d %13d" % (int(runtime_start), int(runtime_end))

#filter  = r"\d+/\w+/\d+ \d+:\d+:\d+|(?<=\d{2}:\d{2}:\d{2}\.)\d+|\d+$"
filter = r"\d+\s\d+\s+[A-Za-z]+"
#page_type = r"(?<=edu.rice.rubbos.servlets.)\w+"
with open(hfile) as f, open(output, "w") as w:
    for line in f:
        #print line
        matches = re.findall(filter, str(line))
        #print matches
	#flag = re.findall(page_type, str(line))
        # starttime = int(time.mktime(time.strptime(matches[0], '%d/%b/%Y %H:%M:%S')))*1000 + int(matches[1])/1000
        if matches:
		#print matches[0][0]
		#print line
		endtime = int(line.split()[0]) 
        	starttime   = int(line.split()[0]) - int(line.split()[1])
        	#reqType   = "StoriesOfTheDay"
        	response  = int(line.split()[1])

		typeStr = line.split()[3]
		#print typeStr
		type_filter = r"/[A-Za-z]+"
		reqType = re.findall(type_filter, typeStr)
		if reqType:
                        reqType = reqType[0][1:]
			#print reqType
		#print "%i %i %i" % (starttime, endtime, response)
        	fieldnames = ['starttime', 'endtime', 'reqType', 'response']
        	writer = csv.DictWriter(w, fieldnames=fieldnames)
        	if starttime >= runtime_start and starttime <= runtime_end :
			#print "Hello"
        		writer.writerow({'starttime':starttime, 'endtime':endtime, 'reqType':"StoriesOfTheDay", 'response':response})
