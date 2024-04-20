#! /usr/bin/env python

import math, time, sys, os



# process options
if len(sys.argv) >= 6:
    timeSpan = sys.argv[1]
    startTime = sys.argv[2]
    endTime = sys.argv[3]
    workload = sys.argv[4]
    plist_file = sys.argv[5]
else:
    # print "the input parameters for aggregateResponseTime is not correct"
    exit(0)

# Adjust this part to your data
#--------------------------------------------------------------------------------
# Input file
# plist_file = timeSpan + ".plist"
# plist_file = "detailRT-" + workload + ".csv"
def init(tier):
    global stime_epoch, etime_epoch, HTTP_multi, AJP_multi, CJDBC_multi, MYSQL_multi, HTTP_multi_1sec, AJP_multi_1sec, CJDBC_multi_1sec
    global MYSQL_multi_10ms, multi_count_in_sec, HTTP_input, HTTP_output, HTTP_multi_longReqs
    global HTTP_in, HTTP_out_rs, plist_file, output_file, output_file2, output_file3

    #plist_file = tier + "_wl" + workload + ".csv"
    #plist_file = "sdata.txt"
    # print plist_file
    # Output files

    # The number of time windows in 1 sec.
    multi_count_in_sec = 20
    time_window = 1000/multi_count_in_sec
    filename_subfix = "-" + str(time_window) + "ms-LongReq1"
    
    # output_file =  timeSpan + "_Clienthttp_multiplicity_wl" + workload + "-50ms.csv"
    output_file = timeSpan + "_" + tier + "_multiplicity_wl" + workload + filename_subfix + ".csv"
    output_file2 = timeSpan + "_" + tier + "_responsetime_wl" + workload + filename_subfix + ".csv"
    output_file3 = timeSpan + "_" + tier + "_inout_wl" + workload + filename_subfix + ".csv"

    #output_file = "multiplicity_" + timeSpan +"_wl"+ workload + filename_subfix + ".csv"
    #output_file2 = "responsetime_" + timeSpan +"_wl"+ workload + filename_subfix + ".csv"
    #output_file3 = "inout_" + timeSpan +"_wl"+ workload + filename_subfix + ".csv"

    # print output_file
    # print output_file2
    # print output_file3
    # print 'timeSpan ', timeSpan
    # print 'start', startTime
    # print 'end ', endTime
    # Start-time and End-time to be processed
    # 201602211741
    #stime_epoch = time.mktime(time.strptime(startTime, '%Y%m%d%H%M'))
    #etime_epoch = time.mktime(time.strptime(endTime, '%Y%m%d%H%M')) + 59.999999

    stime_epoch = time.mktime(time.strptime(startTime, '%Y%m%d%H%M%S'))
    etime_epoch = time.mktime(time.strptime(endTime, '%Y%m%d%H%M%S'))
    # print 'stime_epoch:', stime_epoch
    # print 'etime_epoch:', etime_epoch
    #--------------------------------------------------------------------------------

    # initialize dictionaries
    HTTP_multi = {}
    HTTP_multi_1sec = {}
    HTTP_multi_longReqs = {}
    AJP_multi = {}
    AJP_multi_1sec = {}
    CJDBC_multi = {}
    CJDBC_multi_1sec = {}
    MYSQL_multi = {}

    HTTP_input = {}
    HTTP_output = {}
    # response time
    HTTP_in = {}
    HTTP_out_rs = {}



def main():
    set_of_models = set()
    with open(plist_file) as f:
        for line in f:
            if "start_time" in line:
                continue

            parts = line.split(',')
            set_of_models.add(parts[2])
    
    list_of_models = list(set_of_models)
    list_of_models.sort()
    list_of_models.insert(0, "total")
    
    models = list_of_models 
    models_title = list_of_models
    for model in models:
        HTTP_input[model] = {}
        HTTP_output[model] = {}
        HTTP_multi[model] = {}
        HTTP_multi_longReqs[model] = {}
        HTTP_in[model] = {}
        HTTP_out_rs[model] = {}
        for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
            for ms in range(0, multi_count_in_sec):
                ms_time = target_time * multi_count_in_sec + ms
                HTTP_input[model][ms_time] = 0
                HTTP_output[model][ms_time] = 0
                HTTP_multi[model][ms_time] = 0
                HTTP_multi_longReqs[model][ms_time] = 0
                HTTP_in[model][ms_time] = [[], [], [], [], []]
                HTTP_in[model][ms_time][0] = 0
                HTTP_in[model][ms_time][1] = 0.0
                HTTP_in[model][ms_time][2] = 0
                HTTP_in[model][ms_time][3] = 0
                HTTP_in[model][ms_time][4] = 0

                HTTP_out_rs[model][ms_time] = [[], [], [], [], []]
                HTTP_out_rs[model][ms_time][0] = 0
                HTTP_out_rs[model][ms_time][1] = 0.0
                HTTP_out_rs[model][ms_time][2] = 0
                HTTP_out_rs[model][ms_time][3] = 0
                HTTP_out_rs[model][ms_time][4] = 0

    ##print os.getcwd()
    for line in open(plist_file):
        try:
            if "start_time" in line:
                continue
            parts = line.split(',')
            if len(parts) < 2:
                break

            #print parts
            stime_str = parts[0].replace(' ','').replace('[','').replace('\'','')
            etime_str = parts[1].replace(' ','').replace('[','').replace('\'','')
            reqType_str = parts[2].replace(' ','').replace('[','').replace('\'','')
            # print reqType_str

            # reqID = parts[0]
            #print stime_str
            reqType = reqType_str
            stime = float(stime_str)/1000
            etime = float(etime_str)/1000
            #stime = float(stime_str)
            #etime = float(etime_str)
            reqRS = etime - stime
            #reqRS_tmp = float(parts[3])

            protocol = "client"

            # ## BrowseStoriesByCategory and BrowseStoriesInCategory are the same, some code use BrowseStoriesByCategory, for consistency, we transform all the BrowseStoriesByCategory to BrowseStoriesInCategory
            model = reqType.strip()
            if (model == "BrowseStoriesByCategory"):
                model = "BrowseStoriesInCategory"

            if protocol == 'client':
                if reqRS < 0:
                    # print line
                    pass
                elif reqRS > 1.0:
                    incInOutRS(stime, reqRS, stime_epoch, etime_epoch, model, multi_count_in_sec, HTTP_in, True)
                    incInOutRS(etime, reqRS, stime_epoch, etime_epoch, model, multi_count_in_sec, HTTP_out_rs, True)
                    incInOut(stime, model, HTTP_input)
                    incInOut(etime, model, HTTP_output)
                    addMulti2(stime, etime, stime_epoch, etime_epoch, model, multi_count_in_sec, HTTP_multi)
        except:
            # print  line
            # print  parts
            pass

    # open files for output
    OUTFILE3 = open("%s" % output_file3, 'w')
    # write headers on output files
    OUTFILE3.write("date_time")
    for model in models_title:
        OUTFILE3.write(",%s_http_start,%s_http_end" %
                      (model, model))
    OUTFILE3.write("\n")

    for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
        for ms in range(0, multi_count_in_sec):
            ms_time = target_time * multi_count_in_sec + ms
            ms_time_f = float(ms_time) / multi_count_in_sec
            OUTFILE3.write("%f" % ms_time_f)
            for model in models:
                OUTFILE3.write(",%d,%d" %
                               (HTTP_input[model][ms_time], HTTP_output[model][ms_time]))
            OUTFILE3.write("\n")
    OUTFILE3.close()

        # open files for output
    OUTFILE4 = open("%s" % output_file, 'w')
    # write headers on output files
    OUTFILE4.write("date_time")
    for model in models_title:
        OUTFILE4.write(",%s_http" %
                      (model))
    OUTFILE4.write(",http_total_longReq")
    OUTFILE4.write(",http_adjustLoad")
    OUTFILE4.write("\n")

    for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
        for ms in range(0, multi_count_in_sec):
            ms_time = target_time * multi_count_in_sec + ms
            ms_time_f = float(ms_time) / multi_count_in_sec
            OUTFILE4.write("%f" % ms_time_f)
            for model in models:
                OUTFILE4.write(",%f" %
                               (HTTP_multi[model][ms_time]))
            OUTFILE4.write(",%f,%f" % (HTTP_multi_longReqs["total"][ms_time], (HTTP_multi["total"][ms_time] - HTTP_multi_longReqs["total"][ms_time])))
            OUTFILE4.write("\n")
    OUTFILE4.close()

    # open files for output Response time
    OUTFILE2 = open("%s" % output_file2, 'w')
    # write headers on output files
    OUTFILE2.write("date_time")
    for model in models_title:
        OUTFILE2.write(",%s_http" %
                      (model))
    for model in models_title:
        OUTFILE2.write(",%s_http_out_rs" %
                      (model))
    OUTFILE2.write("\n")

    for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
        for ms in range(0, multi_count_in_sec):
            ms_time = target_time * multi_count_in_sec + ms
            ms_time_f = float(ms_time) / multi_count_in_sec
            # OUTFILE1.write("%s" % time.strftime("%Y/%m/%d %H:%M:%S"  ,time.localtime(ms_time_f)))
            for model in models:
                if (HTTP_in[model][ms_time][0] == 0):
                    HTTP_in[model][ms_time][1] = 0
                else:
                    HTTP_in[model][ms_time][1] = HTTP_in[model][ms_time][1] / HTTP_in[model][ms_time][0]
                # ## the response time average using etime
                if (HTTP_out_rs[model][ms_time][0] == 0):
                    HTTP_out_rs[model][ms_time][1] = 0
                else:
                    HTTP_out_rs[model][ms_time][1] = HTTP_out_rs[model][ms_time][1] / HTTP_out_rs[model][ms_time][0]
            OUTFILE2.write("%f" % ms_time_f)
            for model in models:
                OUTFILE2.write(",%f" %
                               (HTTP_in[model][ms_time][1]))
            for model in models:
                OUTFILE2.write(",%f" %
                               (HTTP_out_rs[model][ms_time][1]))
            OUTFILE2.write("\n")
    OUTFILE2.close()


def incInOut(inc_time, model, dic_multi):
    inc_time2 = int(math.floor(inc_time * multi_count_in_sec))
    if inc_time2 < stime_epoch * multi_count_in_sec:
        #print 'err1'
        #print model
        #print  inc_time2, stime_epoch * multi_count_in_sec
        #os._exit(0)
        return
    if inc_time2 > etime_epoch * multi_count_in_sec:
        #print inc_time2
        #print etime_epoch * 20
        #print 'err2'
        return
    #print   inc_time2, stime_epoch * multi_count_in_sec,  etime_epoch * multi_count_in_sec
    #os._exit(0)
    dic_multi['total'][inc_time2] += 1
    dic_multi[model][inc_time2] += 1
    #print "YES"
    return


def addMulti2(add_from, add_to, stime_epoch, etime_epoch, model,
              multi_count_in_sec, dic_multi):
    if model == 0:
        # print 'come here  **********************'
        pass
    if (add_to < stime_epoch):
        return
    elif (add_from < stime_epoch):
        add_from = stime_epoch
    if (add_from > etime_epoch):
        return
    elif (add_to > etime_epoch):
        add_to = etime_epoch

    add_from2 = int(math.ceil(add_from * multi_count_in_sec))
    add_to2 = int(math.floor(add_to * multi_count_in_sec))
    if (add_from2 <= add_to2):
        if (add_from2 - 1 >= stime_epoch * multi_count_in_sec):
            add_prev = math.ceil(add_from * multi_count_in_sec) - (add_from * multi_count_in_sec)
            dic_multi['total'][add_from2 - 1] += add_prev
            dic_multi[model][add_from2 - 1] += add_prev
        add_post = (add_to * multi_count_in_sec) - math.floor(add_to * multi_count_in_sec)
        # print "post: index = %d, add amount = %f" % (add_to2, add_post)
        dic_multi['total'][add_to2] += add_post
        dic_multi[model][add_to2] += add_post

        mycounter = 0;

        while (add_from2 < add_to2):
            dic_multi['total'][add_from2] += 1.0
            dic_multi[model][add_from2] += 1.0
            add_from2 += 1
            mycounter += 1
    else:
        res_time2 = (add_to - add_from) * multi_count_in_sec
        # print "whole: index = %d, add amount = %f" % (add_to2, res_time2)
        dic_multi['total'][add_to2] += res_time2
        dic_multi[model][add_to2] += res_time2
    return


def incInOutRS(inc_time, rs, stime_epoch, etime_epoch, model,
             multi_count_in_sec, dic_multi, switch):
    inc_time2 = int(math.floor(inc_time * multi_count_in_sec))
    if inc_time2 < stime_epoch * multi_count_in_sec:
        return
    if inc_time2 > etime_epoch * multi_count_in_sec:
        return
    if(switch):
        dic_multi['total'][inc_time2][0] += 1
        dic_multi['total'][inc_time2][1] += rs
        dic_multi[model][inc_time2][0] += 1
        dic_multi[model][inc_time2][1] += rs
        if(0.01 <= rs):
            dic_multi['total'][inc_time2][2] += 1
            dic_multi[model][inc_time2][2] += 1
        if(0.1 <= rs):
            dic_multi['total'][inc_time2][3] += 1
            dic_multi[model][inc_time2][3] += 1
        if(1 <= rs):
            dic_multi['total'][inc_time2][4] += 1
            dic_multi[model][inc_time2][4] += 1
    else:
        dic_multi['total'][inc_time2] += 1
        dic_multi[model][inc_time2] += 1
    return





if __name__ == "__main__":
    print("*********** tier-->%s" % sys.argv[6])
    init(sys.argv[6])
    main()
#    init("QueueLength2-Apache")
#    main()
#    init("QueueLength-CJDBC1")
#    main()
#    init("QueueLength-Tomcat")
#    main()
