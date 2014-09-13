#include<entropy_analysis.hpp>

using namespace std;

int main(int argc, char** args) {	
	if(argc < 3) {
		cout << "Usages: " << endl;
		cout << args[0] << " [input_file_name] [output_file_name]" << endl;
		exit(1);
	}
	
	uint64_t requests_count = 0;	
	unordered_map<string, arp_counters> counters;

	ifstream input_file(args[1], ios::in);	

	while(input_file.good() && input_file.peek() != EOF) {		
		input_file.ignore(numeric_limits<streamsize>::max(), ';'); //timestamp

		string type;
		getline(input_file, type, ';');		

		string ip_src, ip_dst;
		getline(input_file, ip_src, ';');
		getline(input_file, ip_dst, '\n');

		if (type != "Request")
			continue;	

		++counters[ip_src].src_counter;
		++counters[ip_dst].dst_counter;

		if(ip_src == ip_dst) {
			++counters[ip_src].src_eq_dst_counter;
		}
		
		++requests_count;
	}

	input_file.close();

	ofstream output_file(args[2], ios::out);
	output_file << "IP;Psrc;Pdst;src_eq_dst" << endl;

	entropy entropy_src = 0, entropy_dst = 0;

	for(auto const& ip : counters) {
		probability src = (probability)ip.second.src_counter / requests_count;
		probability dst = (probability)ip.second.dst_counter / requests_count;

		output_file << ip.first << ";" << src << ";" << dst << ";"
		<< ip.second.src_eq_dst_counter << endl;	

		if(isnormal(src))		
			entropy_src -= src * log2(src);

		if(isnormal(dst))
			entropy_dst -= dst * log2(dst);
	}

	output_file.close();

	cout << "Entropia de la Fuente SRC: " << entropy_src << endl;
	cout << "Entropia de la fuente DST: " << entropy_dst << endl;		
	
	return 0;
}
