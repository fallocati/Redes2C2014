#traceroute.py

from scapy.all import *
import sys

def main():
    host = sys.argv[1]
    print 'Tracroute ', host

    flag = True
    ttl=1
    hops = []
    while flag:
        ans, unans = sr(IP(dst=host,ttl=ttl)/ICMP())
        if ans.res[0][1].type == 0: # checking for  ICMP echo-reply
            flag = False
        else:
            hops.append(ans.res[0][1].src) # storing the src ip from ICMP error message
            ttl +=1
    i = 1
    for hop in hops:
        print i, ' ' + hop
        i+=1

main()
