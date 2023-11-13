# !/usr/bin
# -*- coding:utf-8 -*-
# Copyright (c) Jun.01 2022 - Xuhang Gu <xgu5@lsu.edu>

from datetime import datetime
import sys,re,time,csv,commands,os

pwd = os.getcwd()
commands.getstatusoutput("find . -type f -empty -iname 'log*' -delete")
hfiles = commands.getstatusoutput('ls log_*')

# Find the runtime #######################
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
##########################################

if hfiles[0] == 0:
    hfiles = hfiles[1].split('\n')
    for hfile in hfiles:
        with open(hfile) as f:
            if not f.readline():
                continue
            
            # Find the file name
            outFile = 'csv-' + hfile.split('.')[0][4:] + '.csv'
            nameList = []
            with open(outFile, "w") as w:
                for line in f:

                    if len(line.split(' ')) != 7 and len(line.split(' ')) != 8:
                        continue
                    if (line.split(' ')[2] != '<info>:'):
                        continue
                    if (line.split(' ')[4] == 'Conn'):
                        reqName = line.split(' ')[5]  
                        nameList.append(reqName)              
                    else:
                        typeStr = line.split(' ')[4]
                        nameList.append(typeStr)     
                        starttime = int(line.split(' ')[5][10:])
                        endtime = int(line.split(' ')[6][8:])
                        response = endtime - starttime
                        fieldnames = ['starttime', 'endtime', 'reqType', 'response', 'realType']
                        writer = csv.DictWriter(w, fieldnames=fieldnames)
                        if starttime >= runtime_start and starttime <= runtime_end :
                            #print("Hello")
                            writer.writerow({'starttime':starttime, 'endtime':endtime, 'reqType':"StoriesOfTheDay", 'response':response, 'realType':typeStr})
            nameList = list(set(nameList))
        #print(nameList)
        
        for name in nameList:
            outFile = 'csv-' + name + '.csv'
            with open(hfile) as f, open(outFile, "w") as w:
                for line in f:
                    if len(line.split(' ')) != 7 and len(line.split(' ')) != 8:                            
                        continue
                    if (line.split(' ')[2] != '<info>:'):
                        continue

                    if (line.split(' ')[4] == 'Conn'):
                        if name != line.split(' ')[5]:
                            #print(name, line.split(' ')[5])
                            continue  
                        starttime = int(line.split(' ')[6][15:])
                        endtime = int(line.split(' ')[7][13:]) 
                    else:
                        if name != line.split(' ')[4]:
                            continue
                        starttime = int(line.split(' ')[5][10:])
                        endtime = int(line.split(' ')[6][8:])

                    response = endtime - starttime
                    fieldnames = ['starttime', 'endtime', 'reqType', 'response']
                    writer = csv.DictWriter(w, fieldnames=fieldnames)
                    if starttime >= runtime_start and starttime <= runtime_end :
                        writer.writerow({'starttime':starttime, 'endtime':endtime, 'reqType':"StoriesOfTheDay", 'response':response})

commands.getstatusoutput("find . -type f -empty -iname 'csv*' -delete")
