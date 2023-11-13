# !/usr/bin
# -*- coding:utf-8 -*-
# Copyright (c) Dec.31 2018 - Jianshu Liu <jliu96@lsu.edu>
import sys,re,time,csv,commands,math
from subprocess import call,check_output
import numpy as np
import datetime
import time 

pwd = check_output('pwd')

client_file=commands.getstatusoutput("ls |egrep 'client-+\w+.log'")
#print client_file

hfile = pwd[:-1] + "/"+client_file[1]
output = pwd[:-1] + "/client_req.csv"

with open(hfile) as f, open(output, "w") as w:
        for line in f:
                starttime = (int(time.mktime(time.strptime(((line.split(' | ')[0]).split(',')[0]), "%Y-%m-%d %H:%M:%S")))-21600)*1000+int((line.split(' | ')[0]).split(',')[1])
                #print starttime
                reqMethod = line.split(' | ')[1]
                reqName = line.split(' | ')[2]
                response = int(float((line.split(' | ')[3]).split('\n')[0]))
                endtime = starttime + response
                reqType = reqName
                if (reqMethod == 'POST'):
                   reqType += "_add-item"
                if (reqMethod == 'DELETE'):
                   reqType += "_delete-item"
                fieldnames = ['starttime', 'endtime', 'reqType', 'RT']
                writer = csv.DictWriter(w, fieldnames=fieldnames)
                writer.writerow({'starttime':starttime, 'endtime':endtime, 'reqType':reqType, 'RT':response})

