#ifndef TOOL_H
#define TOOL_H

#include <arpa/inet.h>
#include <linux/if_ether.h>
#include <pcap.h>
#include <stdlib.h>
#include <time.h>
#include <signal.h>

struct ethernet {
    unsigned char dest[6];
    unsigned char source[6];
    uint16_t eth_type;
};

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
};


void pcap_fatal(const char *failed_in, const char *errbuf);
void caught_packet(u_char *output_file, const struct pcap_pkthdr *cap_header, const u_char* packet);
void close_file_on_interrupt(int signal);

#endif//TOOL_H
