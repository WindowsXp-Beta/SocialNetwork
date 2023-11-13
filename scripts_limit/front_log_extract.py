# !/usr/bin
# -*- coding:utf-8 -*-
# Copyright (c) June 08 - Xuhang Gu <xgu5@lsu.edu>
from datetime import datetime
import sys,re,time,csv,commands
from subprocess import call,check_output

pwd = check_output('pwd')
hfile = pwd[:-1] + "/node6_sysdig.log"

########## Get the workload number ######################
results = commands.getstatusoutput('grep \'Total number of clients for this experiment\' index.html')
if results[0] != 0:
	print "Error: %s" % results[1]
aaa1 = results[1].split(': ')
aaa2 = aaa1[1].split('<')
workload = aaa2[0]
print workload
#########################################################

########## Get the running timestamp ####################
runtime = commands.getstatusoutput("cat Experiments_timestamp.log")

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
#########################################################
output =  pwd[:-1] + "/front_req.csv"
nameList = []

time_filter = r"\d+-\d+\d+-\d+\s+\d+:\d+:\d+.\d+"
up_filter = r"\s<\s[A-Za-z]+="

with open(hfile) as f, open(output, "w") as w:
	for line in f:		
		if (len(line.split(' ')) != 8):
			continue
		if not "wrk2-api" in line:
			continue
		#if not "8000" in line:
		#	continue

		time_matches = re.findall(time_filter, str(line))
		up_matches = re.findall(up_filter, str(line))
		response_filter = r"\d+"

		ts,ms = time_matches[0].split('.')
		ms = ms[:3]
		dt = datetime.strptime(ts, '%Y-%m-%d %H:%M:%S')
		endtime = int(time.mktime(dt.timetuple())*1000 + int(ms))
		typeStr = line.split()[4]

		if up_matches: 
			type_filter = r"/[A-Za-z]+"
			reqType = re.findall(type_filter, typeStr)
			if reqType:
				reqType = reqType[0][1:]
			up_responseStr = line.split()[6]
			up_response = int(re.findall(response_filter, str(up_responseStr))[0])
			starttime = endtime - up_response
			fieldnames = ['starttime', 'endtime', 'reqType', 'response', 'real_type']
			
			if reqType == 'wrk':
				writer = csv.DictWriter(w, fieldnames=fieldnames)
				if starttime >= runtime_start and starttime <= runtime_end :
					writer.writerow({'starttime':starttime, 'endtime':endtime, 'reqType':"StoriesOfTheDay", 'response':up_response, 'real_type':reqType})
				else:
					print reqType
		else:
			typeStr = typeStr[4:]
			reqName = typeStr.split('/')[0]
			nameList.append(reqName)

nameList = list(set(nameList))
down_filter = r"\s>\s[A-Za-z]+="
	
for name in nameList:
	outFile = 'csv-Front2' + name + '.csv'
	with open(hfile) as f, open(outFile, "w") as w:
		for line in f:
			if (len(line.split(' ')) != 8):
				continue
			if not "wrk2-api" in line:
				continue
			if not name in line:
				continue
		
			time_matches = re.findall(time_filter, str(line))
			down_matches = re.findall(up_filter, str(line))
			response_filter = r"\d+"
			
			ts,ms = time_matches[0].split('.')
			ms = ms[:3]
			dt = datetime.strptime(ts, '%Y-%m-%d %H:%M:%S')
			endtime = int(time.mktime(dt.timetuple())*1000 + int(ms))
			typeStr = line.split()[4]
                        #print(line)
                        if ">" in line:
                                #print(line)
				type_filter = r"/[A-Za-z]+"
				reqType = re.findall(type_filter, typeStr)
				if reqType:
					reqType = reqType[0][1:]
				down_responseStr = line.split()[6]
				down_response = int(re.findall(response_filter, str(down_responseStr))[0])
				starttime = endtime - down_response
				fieldnames = ['starttime', 'endtime', 'reqType', 'response']
				
				if reqType == 'wrk':
					writer = csv.DictWriter(w, fieldnames=fieldnames)
					if starttime >= runtime_start and starttime <= runtime_end :
						writer.writerow({'starttime':starttime, 'endtime':endtime, 'reqType':"StoriesOfTheDay", 'response':down_response})
					else:
						print reqType
