# !/usr/bin
# -*- coding:utf-8 -*-
# Copyright (c) June 27 - Xuhang Gu <xgu5@lsu.edu>

from datetime import datetime
import sys,re,time,csv,commands
from subprocess import call,check_output

pwd = check_output('pwd')
hfile = pwd[:-1] + "/tcpFront.log"

output_up = pwd[:-1] + "/tcpUp2Front.csv"
output_down = pwd[:-1] + "/tcpFront2Down.csv"

timeStamp = 0.0

################# Down TCP ######################
num_down_total = 0
num_down_established = 0
num_down_syn_sent = 0
num_down_time_wait = 0

num_down_home_total = 0
num_down_home_established = 0
num_down_home_syn_sent = 0
num_down_home_time_wait = 0

num_down_user_total = 0
num_down_user_established = 0
num_down_user_syn_sent = 0
num_down_user_time_wait = 0
#################################################

############## Up TCP ###########################
num_up_total = 0
num_up_established = 0
num_up_syn_sent = 0
num_up_time_wait = 0

num_up_attacker_total = 0
num_up_attacker_established = 0
num_up_attacker_syn_sent = 0
num_up_attacker_time_wait = 0

num_up_benchmark_total = 0
num_up_benchmark_established = 0
num_up_benchmark_syn_sent = 0
num_up_benchmark_time_wait = 0

num_up_client_total = 0
num_up_client_established = 0
num_up_client_syn_sent = 0
num_up_client_time_wait = 0

num_up_client1_total = 0
num_up_client1_established = 0
num_up_client1_syn_sent = 0
num_up_client1_time_wait = 0

num_up_client2_total = 0
num_up_client2_established = 0
num_up_client2_syn_sent = 0
num_up_client2_time_wait = 0

num_up_client3_total = 0
num_up_client3_established = 0
num_up_client3_syn_sent = 0
num_up_client3_time_wait = 0

num_up_client4_total = 0
num_up_client4_established = 0
num_up_client4_syn_sent = 0
num_up_client4_time_wait = 0
#################################################

with open(hfile) as f, open(output_up, "w") as w_up, open(output_down, "w") as w_down:
    for line in f:
        results = line.split()
        length = len(results)
        if length == 1:
            w_down.write("{:.3f} {} {} {} {} {} {} {} {} {} {} {} {}\n".format(timeStamp, num_down_total, num_down_established, num_down_syn_sent, num_down_time_wait, num_down_home_total, num_down_home_established, num_down_home_syn_sent, num_down_home_time_wait, num_down_user_total, num_down_user_established, num_down_user_syn_sent, num_down_user_time_wait))

            num_down_total = 0
            num_down_established = 0
            num_down_syn_sent = 0
            num_down_time_wait = 0

            num_down_home_total = 0
            num_down_home_established = 0
            num_down_home_syn_sent = 0
            num_down_home_time_wait = 0

            num_down_user_total = 0
            num_down_user_established = 0
            num_down_user_syn_sent = 0
            num_down_user_time_wait = 0

            w_up.write("{:.3f} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {}\n".format(timeStamp, num_up_total, num_up_established, num_up_syn_sent, num_up_time_wait, num_up_attacker_total, num_up_attacker_established, num_up_attacker_syn_sent, num_up_attacker_time_wait, num_up_client_total, num_up_client_established, num_up_client_syn_sent, num_up_client_time_wait, num_up_benchmark_total, num_up_benchmark_established, num_up_benchmark_syn_sent, num_up_benchmark_time_wait, num_up_client1_total, num_up_client1_established, num_up_client1_syn_sent, num_up_client1_time_wait, num_up_client2_total, num_up_client2_established, num_up_client2_syn_sent, num_up_client2_time_wait, num_up_client3_total, num_up_client3_established, num_up_client3_syn_sent, num_up_client3_time_wait, num_up_client4_total, num_up_client4_established, num_up_client4_syn_sent, num_up_client4_time_wait))

            num_up_total = 0
            num_up_established = 0
            num_up_syn_sent = 0
            num_up_time_wait = 0

            num_up_attacker_total = 0
            num_up_attacker_established = 0
            num_up_attacker_syn_sent = 0
            num_up_attacker_time_wait = 0

            num_up_client_total = 0
            num_up_client_established = 0
            num_up_client_syn_sent = 0
            num_up_client_time_wait = 0

            num_up_benchmark_total = 0
            num_up_benchmark_established = 0
            num_up_benchmark_syn_sent = 0
            num_up_benchmark_time_wait = 0

            num_up_client1_total = 0
            num_up_client1_established = 0
            num_up_client1_syn_sent = 0
            num_up_client1_time_wait = 0

            num_up_client2_total = 0
            num_up_client2_established = 0
            num_up_client2_syn_sent = 0
            num_up_client2_time_wait = 0

            num_up_client3_total = 0
            num_up_client3_established = 0
            num_up_client3_syn_sent = 0
            num_up_client3_time_wait = 0

            num_up_client4_total = 0
            num_up_client4_established = 0
            num_up_client4_syn_sent = 0
            num_up_client4_time_wait = 0
            
            timeStamp = float(results[0])/1000

        if length == 6:
            if "9090" in line or "9000" in line:
                state = results[5]

                if "9090" in line: # home
                    if state == "ESTABLISHED":
                        num_down_home_established = num_down_home_established + 1
                    if state == "TIME_WAIT":
                        num_down_home_time_wait = num_down_home_time_wait + 1
                    if state == "SYN_SENT":
                        num_down_home_syn_sent = num_down_home_syn_sent + 1
                    num_down_home_total = num_down_home_total + 1
                if "9000" in line: # user
                    if state == "ESTABLISHED":
                        num_down_user_established = num_down_user_established + 1
                    if state == "TIME_WAIT":
                        num_down_user_time_wait = num_down_user_time_wait + 1
                    if state == "SYN_SENT":
                        num_down_user_syn_sent = num_down_user_syn_sent + 1
                    num_down_user_total = num_down_user_total + 1
                if state == "ESTABLISHED":
                    num_down_established = num_down_established + 1
                if state == "TIME_WAIT":
                    num_down_time_wait = num_down_time_wait + 1
                if state == "SYN_SENT":
                    num_down_syn_sent = num_down_syn_sent + 1
                num_down_total = num_down_total + 1

            if "8000" in line: 
                state = results[5]

                if "attacker" in line or "192.168.1.13" in line:
                    if state == "ESTABLISHED":
                        num_up_attacker_established = num_up_attacker_established + 1
                    if state == "TIME_WAIT":
                        num_up_attacker_time_wait = num_up_attacker_time_wait + 1
                    if state == "SYN_SENT":
                        num_up_attacker_syn_sent = num_up_attacker_syn_sent + 1
                    num_up_attacker_total = num_up_attacker_total + 1
                else:

                    if state == "ESTABLISHED":
                        num_up_client_established = num_up_client_established + 1
                    if state == "TIME_WAIT":
                        num_up_client_time_wait = num_up_client_time_wait + 1
                    if state == "SYN_SENT":
                        num_up_client_syn_sent = num_up_client_syn_sent + 1
                    num_up_client_total = num_up_client_total + 1

                    if "benchmark" in line or "192.168.1.8" in line:
                        if state == "ESTABLISHED":
                            num_up_benchmark_established = num_up_benchmark_established + 1
                        if state == "TIME_WAIT":
                            num_up_benchmark_time_wait = num_up_benchmark_time_wait + 1
                        if state == "SYN_SENT":
                            num_up_benchmark_syn_sent = num_up_benchmark_syn_sent + 1
                        num_up_benchmark_total = num_up_benchmark_total + 1

                    elif "client1" in line or "192.168.1.9" in line:
                        if state == "ESTABLISHED":
                            num_up_client1_established = num_up_client1_established + 1
                        if state == "TIME_WAIT":
                            num_up_client1_time_wait = num_up_client1_time_wait + 1
                        if state == "SYN_SENT":
                            num_up_client1_syn_sent = num_up_client1_syn_sent + 1
                        num_up_client1_total = num_up_client1_total + 1

                    if "client2" in line or "192.168.1.10" in line:
                        if state == "ESTABLISHED":
                            num_up_client2_established = num_up_client2_established + 1
                        if state == "TIME_WAIT":
                            num_up_client2_time_wait = num_up_client2_time_wait + 1
                        if state == "SYN_SENT":
                            num_up_client2_syn_sent = num_up_client2_syn_sent + 1
                        num_up_client2_total = num_up_client2_total + 1

                    if "client3" in line or "192.168.1.11" in line:
                        if state == "ESTABLISHED":
                            num_up_client3_established = num_up_client3_established + 1
                        if state == "TIME_WAIT":
                            num_up_client3_time_wait = num_up_client3_time_wait + 1
                        if state == "SYN_SENT":
                            num_up_client3_syn_sent = num_up_client3_syn_sent + 1
                        num_up_client3_total = num_up_client3_total + 1

                    if "client4" in line or "192.168.1.12" in line:
                        if state == "ESTABLISHED":
                            num_up_client4_established = num_up_client4_established + 1
                        if state == "TIME_WAIT":
                            num_up_client4_time_wait = num_up_client4_time_wait + 1
                        if state == "SYN_SENT":
                            num_up_client4_syn_sent = num_up_client4_syn_sent + 1
                        num_up_client4_total = num_up_client4_total + 1


                if state == "ESTABLISHED":
                    num_up_established = num_up_established + 1
                if state == "TIME_WAIT":
                    num_up_time_wait = num_up_time_wait + 1
                if state == "SYN_SENT":
                    num_up_syn_sent = num_up_syn_sent + 1
                num_up_total = num_up_total + 1
