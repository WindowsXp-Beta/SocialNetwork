from __future__ import generators # needed for Python
import sys
import os, stat, types, re, time, math, csv, string, commands

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


    print makeHTMLpage(top, startPatternStr)

    LogFileBO.sort(cmp=None, key=None, reverse=False)
    for file in LogFileBO:
        print '**************************' + file + '******************'

        localPath = os.path.dirname(file)

        ##get the number of clients in this experiment
        localPath = os.path.dirname(file)
        ##extract collectl CPU data at runtime period
        (dirName, fileName) = os.path.split(file)
        (ShortName, Extension) = os.path.splitext(fileName)

        collectResultName = ShortName + '_collectl'+ '.csv'
        collectlLogfile = open(dirName + '/' + collectResultName, 'w')
        infile = open(file, "r")

        tmpSwitch = 0
        for line in infile.readlines():
            if 'UTC' not in line and tmpSwitch == 0:
                continue
        tmpSwitch = 1
        collectlLogfile.write("%s" % (line))
        infile.close()
        collectlLogfile.close()


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
            (ShortName, Extension) = os.path.splitext(name)
            if (ShortName.startswith(strPattern) and 'tab' in Extension):
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