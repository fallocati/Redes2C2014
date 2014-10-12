#!/usr/bin/env python

import sys
import os
from scapy.all import *

if len(sys.argv) != 2:
    sys.exit('Usage: rastrearutas.py <remote host>')

ttl = 1
while True:
    begin = time.time()
    reply=sr1(IP(dst=sys.argv[1],ttl=ttl)/ICMP(id=os.getpid()),verbose=0,retry=0,timeout=1)
    end = time.time()
    if not (reply is None):
        rtt = (end-begin) * 1000
        if reply[ICMP].type == 11 and reply[ICMP].code == 0:
            print ttl, '->', reply.src, ' ', rtt,'ms'
        elif reply[ICMP].type == 0:
            print ttl, '->', reply.src, ' ', rtt,'ms'
            break

    else:
        print ttl, '-> *'

    ttl+=1
