#include <tool.hpp>

using namespace std;

pcap_t* pcap_handle;
ofstream of;

int main(int argc, char** args) {
	if(argc < 2 || argc > 3) {
		cout << "Usages: " << endl;
		cout << args[0] << " [interface]" << endl;
		cout << args[0] << " [interface] [output_file_name]" << endl;
		exit(1);
	}

	signal(SIGINT, interruption);	
	signal(SIGTERM, interruption);

	char errbuf[PCAP_ERRBUF_SIZE];
	pcap_handle = pcap_open_live(args[1], 4096, 1, 0, errbuf);

	if(pcap_handle == NULL)
		pcap_fatal("pcap_open_live", errbuf);

	bpf_program filter;

	if(pcap_compile(pcap_handle, &filter, "arp", 0, 0) == -1) {
		cerr << "Failed compilation of filter \'arp\'" << endl;
		pcap_fatal("pcap_compile", errbuf);
	}

	if(pcap_setfilter(pcap_handle, &filter) == -1) {
		cerr << "Failed set of filter \'arp\'" << endl;
		pcap_fatal("pcap_setfilter", errbuf);
	}

	auto buf = cout.rdbuf();

	if(argc == 3) {
		of.open(args[2], ofstream::out | ofstream::app);

		buf = of.rdbuf();
	}

	pcap_loop(pcap_handle, -1, caught_packet, (u_char*)buf);	

	return 0;
}

void pcap_fatal(const char* failed_in, const char* errbuf) {
	cerr << "Fatal Error in " << failed_in << ": " << errbuf << endl;

	exit(1);
}

void interruption(int signal) {
	if (of.is_open())
		of.close();

	pcap_close(pcap_handle);
	
	exit(3);
}

void caught_packet(u_char* buf, const pcap_pkthdr* cap_header, const u_char* packet) {
	auto eth_hdr = (ethernet*)packet;

	if(ntohs(eth_hdr->eth_type) == ETH_P_ARP) {
		time_t rawtime;
		time(&rawtime);
		auto timeinfo = localtime (&rawtime);
		char buffer[18];
		strftime(buffer, 18, "%Y%m%d%H%M%S", timeinfo);

		ostream out((streambuf*)buf);
		out << buffer << ";";

		auto arp_hdr = (arp*)(packet + sizeof(ethernet));
		
		switch(ntohs(arp_hdr->oper)) {
			case 0x0001:
				out << "Request;";
				break;
			case 0x0002:
				out << "Response;";
				break;
			default:
				out << ";";
				break;
		}

		out << static_cast<int>(arp_hdr->proto_source_addr[0]) << "."
		<< static_cast<int>(arp_hdr->proto_source_addr[1]) << "."
		<< static_cast<int>(arp_hdr->proto_source_addr[2]) << "."
		<< static_cast<int>(arp_hdr->proto_source_addr[3]) << ";";

		out << static_cast<int>(arp_hdr->proto_target_addr[0]) << "."
		<< static_cast<int>(arp_hdr->proto_target_addr[1]) << "."
		<< static_cast<int>(arp_hdr->proto_target_addr[2]) << "."
		<< static_cast<int>(arp_hdr->proto_target_addr[3]);

		out << endl;
	}
}