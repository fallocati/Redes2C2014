#!/usr/bin/env python

import sys
import os
from scapy.all import *

if len(sys.argv) < 4 or len(sys.argv) > 5:
    sys.exit('Usage: rastrearutas.py <remote host> <max_hops> <runs quantity> [<output file>]')

if len(sys.argv) == 5:
    output_file = open(sys.argv[4],"a")
    output_file.write(time.strftime("%Y%m%d%H%M"))

for i in range(0,int(sys.argv[3])):
    if len(sys.argv) == 5 and i > 0:
        output_file.write(time.strftime("\n%Y%m%d%H%M"))

    print
    print "Run ",i,":"
    for ttl in range(0,int(sys.argv[2])+1):
        pk=IP(dst=sys.argv[1],ttl=ttl)/ICMP(id=os.getpid())
        begin = time.time()
        #reply=sr1(IP(dst=sys.argv[1],ttl=ttl)/ICMP(id=os.getpid()),verbose=0,retry=0,timeout=1)
        reply=sr1(pk,verbose=0,retry=0,timeout=1)
        end = time.time()
        if not (reply is None):
            rtt = (end-begin) * 1000
            if (reply[ICMP].type == 11 and reply[ICMP].code == 0) or (reply[ICMP].type == 0):
                if len(sys.argv) == 5:
                    output_file.write(";%s;%s" %(reply.src,rtt))

                print ttl, '->', reply.src, ' ', rtt,'ms'

            if reply[ICMP].type == 0:
                break

        else:
            if len(sys.argv) == 5:
                output_file.write(";*;*")
            print ttl, '-> *'

if len(sys.argv) == 5:
    output_file.write("\n")
    output_file.close()
