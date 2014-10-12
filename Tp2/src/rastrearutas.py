#!/usr/bin/env python

import sys
import os
from scapy.all import *

if len(sys.argv) != 2:
    sys.exit('Usage: rastrearutas.py <remote host>')

ttl = 1
while True:
    reply=sr1(IP(dst=sys.argv[1],ttl=ttl)/ICMP(id=os.getpid()),verbose=0,retry=3,timeout=1)
    if not (reply is None):
        if reply[ICMP].type == 11 and reply[ICMP].code == 0:
            print ttl, '->', reply.src
        elif reply[ICMP].type == 0:
            print ttl, '->', reply.src
            break

    else:
        print ttl, '-> *'

    ttl+=1
