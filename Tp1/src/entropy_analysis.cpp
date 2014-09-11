#include<entropy_analysis.hpp>

using namespace std;

int main(int argc, char* argv[]){
	ofstream output_file;
	ifstream input_file;
	unsigned long long requests_count = 0;
	int result = 0;
	ip ip_src,ip_dst;
	entropy entropy_src = 0, entropy_dst = 0;
	probability ip_probability;
	unordered_map<string,arp_counters_t> ip_appareances;


	if(argc != 3){
		std::cout << "Se requieren 2 parametros: archivo_entrada archivo_salida" << std::endl;
		result = 1;
	} else {
		input_file.open(argv[1],ios::in);
		output_file.open(argv[2],ios::out);
		
		while(input_file.good()){
			input_file.ignore(numeric_limits<streamsize>::max(),';'); //timestamp
			input_file.ignore(numeric_limits<streamsize>::max(),';'); //type
			getline(input_file,ip_src,';');
			getline(input_file,ip_dst,'\n');

			++ip_appareances[ip_src].src_counter;
			++ip_appareances[ip_dst].dst_counter;

			if(ip_src == ip_dst){
				++ip_appareances[ip_src].src_eq_dst_counter;
				++ip_appareances[ip_dst].src_eq_dst_counter;
			}
			
			++requests_count;
		}

		for(auto it = ip_appareances.cbegin();it != ip_appareances.cend();++it){
			ip_probability = (float)it->second.src_counter/requests_count;
			
			output_file << it->first << ' ';
			output_file << ip_probability << ' ';
			output_file << (float)it->second.dst_counter/requests_count << ' ';
			output_file << it->second.src_eq_dst_counter << endl;
		}

		output_file.close();
		input_file.close();

	}
	
	return result;
}
