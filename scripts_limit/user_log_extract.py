# !/usr/bin
# -*- coding:utf-8 -*-
# Copyright (c) Air,24 2017 - Shungeng Zhang <szhan45@lsu.edu>
from datetime import datetime
import sys,re,time,csv,commands
from subprocess import call,check_output

pwd = check_output('pwd')
hfile = pwd[:-1] + "/user.log"
output =  pwd[:-1] + "/user_req.csv"

results = commands.getstatusoutput('grep \'Total number of clients for this experiment\' index.html')
if results[0] != 0:
	print "Error: %s" % results[1]
aaa1 = results[1].split(': ')
aaa2 = aaa1[1].split('<')
workload = aaa2[0]
print workload

runtime = commands.getstatusoutput("cat Experiments_timestamp.log")
#print runtime_start[1].split()[0]

runtime_start_human = runtime[1].split()[0]
runtime_end_human = runtime[1].split()[1]
print runtime_start_human
print runtime_end_human

def human_to_epoch(human_time):
	dt = datetime.strptime(human_time, '%Y%m%d%H%M%S')
	epoch_time = time.mktime(dt.timetuple())*1000
	return epoch_time
	
#human_to_epoch(runtime_start_human)
runtime_start = human_to_epoch(runtime_start_human)
runtime_end = human_to_epoch(runtime_end_human)


print "%13d %13d" % (int(runtime_start), int(runtime_end))

#filter  = r"\d+/\w+/\d+ \d+:\d+:\d+|(?<=\d{2}:\d{2}:\d{2}\.)\d+|\d+$"
#filter = r"\d+\s\d+\s+[A-Za-z]+"
time_filter = r"\d+-\d+\d+-\d+\s+\d+:\d+:\d+.\d+"
up_filter = r"\s<\s[A-Za-z]+="
#myDate = "2020-09-10 22:04:13.270111"
#ts,ms = myDate.split('.')
#ms = int(ms)/1000
#print ts
#print ms
#dt = datetime.strptime(ts, '%Y-%m-%d %H:%M:%S')
#print time.mktime(dt.timetuple())*1000 + int(ms)
#print ts
#print(datetime.datetime.strptime(myDate, "%Y-%m-%d %H:%M:%S.%f").timestamp())

#page_type = r"(?<=edu.rice.rubbos.servlets.)\w+"
with open(hfile) as f, open(output, "w") as w:
    for line in f:
        #print line
	time_matches = re.findall(time_filter, str(line))
	up_matches = re.findall(up_filter, str(line))
	response_filter = r"\d+"
	
	#print time_matches[0]
	ts,ms = time_matches[0].split('.')
	#print ts
	#print ms
	ms = ms[:3]
	#print ms
	dt = datetime.strptime(ts, '%Y-%m-%d %H:%M:%S')
	endtime = int(time.mktime(dt.timetuple())*1000 + int(ms))
	#print endtime

	if up_matches:
		typeStr = line.split()[4]
		#print typeStr
		type_filter = r"/[A-Za-z]+"
		reqType = re.findall(type_filter, typeStr)
                if reqType:
                        reqType = reqType[0][1:]
			#print reqType
		up_responseStr = line.split()[6]
		#print up_responseStr	
		up_response = int(re.findall(response_filter, str(up_responseStr))[0])
		starttime = endtime - up_response
		fieldnames = ['starttime', 'endtime', 'reqType', 'response', 'real_type']
		
		if reqType == 'card' or reqType == 'cards':
                        #print reqType
                        writer = csv.DictWriter(w, fieldnames=fieldnames)
                        if starttime >= runtime_start and starttime <= runtime_end :
                                writer.writerow({'starttime':starttime, 'endtime':endtime, 'reqType':"StoriesOfTheDay", 'response':up_response, 'real_type':reqType})
		else:
			print reqType
		#print up_response
        #print matches
	#flag = re.findall(page_type, str(line))
        # starttime = int(time.mktime(time.strptime(matches[0], '%d/%b/%Y %H:%M:%S')))*1000 + int(matches[1])/1000
        #if matches:
#		#print matches[0][0]
#		starttime = int(line.split()[0]) 
 #       	endtime   = int(line.split()[0]) + int(line.split()[1])
  #      	reqType   = "StoriesOfTheDay"
   #     	response  = int(line.split()[1])
#
		#print "%i %i %i" % (starttime, endtime, response)
  #      	fieldnames = ['starttime', 'endtime', 'reqType', 'response']
 #       	writer = csv.DictWriter(w, fieldnames=fieldnames)
   #     	if starttime >= runtime_start and starttime <= runtime_end :
    #    		writer.writerow({'starttime':starttime, 'endtime':endtime, 'reqType':reqType, 'response':response})
     #   	print "%i,%i,%s,%i" % (starttime, endtime, reqType, response)
        #print line.strip()[0]
