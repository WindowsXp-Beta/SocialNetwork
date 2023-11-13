from __future__ import generators # needed for Python
import sys
import os, stat, types, re, time, math, csv, string,commands

#path = 'D:\\opentaps-1.0.0-common_tables\\opentaps-1.0.0\\applications\\ecommerce'
#path = 'D:\\workspace/SysVizResultAnalysis/src/datapreparation'
path = os.getcwd()

print '******************current path****************'
print path
#print path
#pdb.set_trace()

print path

global LogFileRW
global LogFileBO
global entities

LogFileRW = []
LogFileBO = []
entities = set([])


def processLogBO(startPatternStr):
    global LogFileBO
    LogFileBO = []
    workloadArray = []
    hostArray = []
    powerAveArray = []
    with open('Experiments_timestamp.log','r') as f:
         j=0
         for line in f:
             if (j==0):
                starttime = line.strip()
                j=1
             else:
                endtime = line.strip()
    str_list = list(str(starttime))
    str_list.insert(8,":")
    str_list.insert(11,":")
    str_list.insert(14,":")
    starttime_new = ''.join(str_list)
    #print starttime_new

    str_list = list(str(endtime))
    str_list.insert(8,":")
    str_list.insert(11,":")
    str_list.insert(14,":")
    endtime_new = ''.join(str_list)
    #print endtime_new
    
    print makeHTMLpage(top, startPatternStr)

    LogFileBO.sort(cmp=None, key=None, reverse=False)
    for file in LogFileBO:
        print '**************************' + file + '******************'
        
        localPath = os.path.dirname(file)       
        ##get the starting time and ending time of runtime experiments
        stime_epoch = 0.0
        etime_epoch = 0.0
        totalPowerUsage = 0.0
        powerRecordCounter = 0
    
        ##extract power data at runtime period  
        (dirName, fileName) = os.path.split(file)
        (ShortName, Extension) = os.path.splitext(fileName)
        #collectLTimeFormatStart = "20200209:14:17:31"
        #collectLTimeFormatEnd = "20200209:14:25:39"
        collectLTimeFormatStart = starttime_new
        collectLTimeFormatEnd = endtime_new
        print 'file '+str(file)
        print 'dirName '+str(dirName)
        print 'collectlTimeFormStart ' + str(collectLTimeFormatStart)
        print "collectlTimeFormEnd " + str(collectLTimeFormatEnd)
        #results = commands.getstatusoutput("collectl -sCdn -p %s  -P -f %s -oUmz --from %s-%s" % (file,dirName,collectLTimeFormatStart,collectLTimeFormatEnd))         
   	#results = commands.getstatusoutput("rm %s/VM*_collectl_*.csv" % (dirName))         
   	#results = commands.getstatusoutput("rm %s/VM*.tab" % (dirName))         
   	results = commands.getstatusoutput("collectl -sCcdnms -p %s  -P -f %s -oUmz --from %s-%s" % (file,dirName,collectLTimeFormatStart,collectLTimeFormatEnd))  # add by shungeng
        results = commands.getstatusoutput("collectl -sZ -p %s  -P -f %s -oTmza --from %s-%s" % (file,dirName,collectLTimeFormatStart,collectLTimeFormatEnd))
        print results
        if results[0] != 0:
	    print "code: %s  failure to execute the commond: collectl -sCdnZ -p %s  -P -f %s -oUmz --from %s-%s" % (results[0], file,dirName,collectLTimeFormatStart,collectLTimeFormatEnd)
            sys.exit(0)
        #results1 = commands.getstatusoutput("collectl -sZ -p %s  -P -f %s -oUmz --from %s-%s" % (file,dirName,collectLTimeFormatStart,collectLTimeFormatEnd))  # add by shungeng
        #print results1
        #if results1[0] != 0:
        #    print "code: %s  failure to execute the commond: collectl -sZ -p %s  -P -f %s -oUmz --from %s-%s" % (results[0], file,dirName,collectLTimeFormatStart,collectLTimeFormatEnd)
        #    sys.exit(0)
	 
def my_split(s, seps):
    res = [s]
    for sep in seps:
        s, res = res, []
        for seq in s:
            res += seq.split(sep)
    return res  



def walktree(top, depthfirst=True):
    """Walk the directory tree, starting from top. Credit to Noah Spurrier and Doug Fort."""
    names = os.listdir(top)
    if not depthfirst:
        yield top, names
    for name in names:
        try:
            st = os.lstat(os.path.join(top, name))
        except os.error:
            continue
        if stat.S_ISDIR(st.st_mode):
            for (newtop, children) in walktree (os.path.join(top, name), depthfirst):
                yield newtop, children
    if depthfirst:
        yield top, names

def makeHTMLtable(top,strPattern, depthfirst=False):
    for top, names in walktree(top):
        for name in names:
#           print name
            (ShortName, Extension) = os.path.splitext(name)
            if (ShortName.startswith(strPattern) and 'raw' in ShortName and 'gz' in Extension):
                print top;
                print "\n #########come here\n"
                LogFileBO.append(top + '/' + name)

def makeHTMLpage(top, strPattern, depthfirst=False):
    return makeHTMLtable(top,strPattern, depthfirst)





if __name__ == '__main__':
    if len(sys.argv) == 2:
        top = sys.argv[1]
    else: top = path


    #processLogBO_processInfo()
    processLogBO('node');


