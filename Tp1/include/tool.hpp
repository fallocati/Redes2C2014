#ifndef TOOL_H
#define TOOL_H

#include <cstdint>
#include <linux/if_ether.h>
#include <netinet/in.h>
#include <pcap.h>

#include <csignal>
#include <cstdlib>

#include <ctime>

#include <iostream>
#include <fstream>

struct ethernet {
    unsigned char dest[6];
    unsigned char source[6];
    uint16_t eth_type;
} __attribute__((__packed__));

struct arp {
    uint16_t hw_type;
    uint16_t proto_type;
    unsigned char hw_len;
    unsigned char proto_len;
    uint16_t oper;
    unsigned char eth_source_addr[6];
    unsigned char proto_source_addr[4];
    unsigned char eth_target_addr[6];
    unsigned char proto_target_addr[4];
} __attribute__((__packed__));

void pcap_fatal(const char* failed_in, const char* errbuf);
void caught_packet(u_char* buf, const pcap_pkthdr* cap_header, const u_char* packet);
void interruption(int signal);

#endif//TOOL_H
