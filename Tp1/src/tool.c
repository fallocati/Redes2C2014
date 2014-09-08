#include <arpa/inet.h>
#include <linux/if_ether.h>
#include <pcap.h>
#include <stdlib.h>
#include <time.h>

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

void pcap_fatal(const char *failed_in, const char *errbuf) {
	printf("Fatal Error in %s: %s\n", failed_in, errbuf);
	exit(1);
}

void caught_packet(u_char *user_args, const struct pcap_pkthdr *cap_header, const u_char* packet) {
	struct ethernet *eth_hdr = NULL;
    	struct arp *arp_hdr = NULL;

	time_t rawtime;
	struct tm * timeinfo;
	char buffer [18];

	eth_hdr = (struct ethernet *)packet;

        if(ntohs(eth_hdr->eth_type) == ETH_P_ARP) {
		arp_hdr = (struct arp *)(packet + sizeof(struct ethernet));

		time(&rawtime);
		timeinfo = localtime (&rawtime);
		strftime(buffer,18,"%Y%m%d%H%M%S",timeinfo);
		printf("%s;",buffer);
		
		
		// El ntohs es para cambiar de Network Byte Order a Host Byte Order
		switch(ntohs(arp_hdr->oper)) {
			case 0x0001:
				printf("Request;");
				break;
			case 0x0002:
				printf("Response;");
				break;
			default:
				printf(";");
				break;
		}

		printf("%d.%d.%d.%d;", arp_hdr->proto_source_addr[0],arp_hdr->proto_source_addr[1], 
			arp_hdr->proto_source_addr[2], arp_hdr->proto_source_addr[3]);
		printf("%d.%d.%d.%d\n", arp_hdr->proto_target_addr[0], arp_hdr->proto_target_addr[1], 
			arp_hdr->proto_target_addr[2], arp_hdr->proto_target_addr[3]);
	}
}

int main(int argc, char** args) {
	char errbuf[PCAP_ERRBUF_SIZE];
	pcap_t *pcap_handle;
	
	struct bpf_program filter;
	char filter_string[] = "arp";

	if (argc < 2) {
		printf("Usage: %s [interface]\n", args[0]);
		exit(1);
	}

	pcap_handle = pcap_open_live(args[1], 4096, 1, 0, errbuf);

	if(pcap_handle == NULL)
		pcap_fatal("pcap_open_live", errbuf);

	if(pcap_compile(pcap_handle, &filter, filter_string, 0, 0) == -1) {
		sprintf(errbuf, "Failed compilation of filter \'%s\'", filter_string);
		pcap_fatal("pcap_compile", errbuf);
	}

	if(pcap_setfilter(pcap_handle, &filter) == -1) {
		sprintf(errbuf, "Failed set of filter \'%s\'", filter_string);
		pcap_fatal("pcap_setfilter", errbuf);
	}

	pcap_loop(pcap_handle, -1, caught_packet, NULL);

	pcap_close(pcap_handle);
}


