# !/usr/bin
# -*- coding:utf-8 -*-
# Copyright (c) Mar.22 2022 - Xuhang Gu <xgu5@lsu.edu>

import sys,re,time,csv,commands,os

pwd = os.getcwd()
hfiles = commands.getstatusoutput('ls *.prc')

if hfiles[0] == 0:
    hfiles = hfiles[1].split('\n')

    for hfile in hfiles:
        
        ## create a folder for each node file
        dirName = hfile[:6] + '-PID'
        if not os.path.exists(dirName):
            os.mkdir(dirName)

        ## begin to poser data
        UTC = []
        PID = []
        User = []
        PR = []
        S = []
        CPU = []
        SysT = []
        UsrT = []
        Pct = []
        Command = []

        node = hfile[:6]
        #print node

        with open(hfile) as f:
            for line in f:
                date_str = line.split(" ")[0]
                #print ("45245".isdigit())
                try:
                    date = int(date_str)
                except ValueError:
                    #print "Not a float"
                    continue
                sec,mil = line.split(" ")[1].split('.')
                humanTime = date_str + " " + sec
                utc = int(time.mktime(time.strptime(humanTime, "%Y%m%d %H:%M:%S")))*1000 + int(mil)
                
                
                UTC.append(float(utc)/1000)
                #PID extraction
                PID.append(int(line.split(" ")[2]))
                #User extraction
                User.append(line.split(" ")[3])
                #PR extraction
                PR.append(line.split(" ")[4])
                #Status extraction
                S.append(line.split(" ")[7])
                #The process run on which CPU core
                CPU.append(int(line.split(" ")[15]))
                #SysTime extraction
                SysT.append(float(line.split(" ")[16]))
                #UserTime extraction
                UsrT.append(float(line.split(" ")[17]))
                #Percentage of the current interval taken up by this task
                Pct.append(int(line.split(" ")[18]))
                #Command extraction
                Command.append(node + "-" +line.split(" ")[29].strip())

            PID_unique = list(set(PID))
            for el in PID_unique:
                output = pwd + "/" + dirName +"/PID"+ str(el) + ".log"
                print output
                with open(output,'w') as w:
                    fieldnames = ['Timestamp','User','Status','CPU','SysT','UsrT','PCT','PID','Command']
                    for i in range(0, len(PID)):
                        if (PID[i] == el):
                            writer = csv.DictWriter(w, fieldnames=fieldnames)
                            writer.writerow({'Timestamp':UTC[i],'User':User[i],'Status':S[i],'CPU':CPU[i],'SysT':SysT[i],'UsrT':UsrT[i],'PCT':Pct[i],'PID':PID[i],'Command':Command[i]})


