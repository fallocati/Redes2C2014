#include<entropy_analysis.hpp>

using namespace std;

int main(int argc, char* argv[]){
	ofstream output_file;
	ifstream input_file;
	unsigned long long requests_count = 0;
	int result = 0,entropy_src = 0, entropy_dst = 0;
	ip ip_src,ip_dst;
	unordered_map<string,std::pair<src_counter,dst_counter> > ip_appareances;


	if(argc != 3){
		std::cout << "Se requieren 2 parametros: archivo_entrada archivo_salida" << std::endl;
		result = 1;
	} else {
		input_file.open(argv[1],ios::in);
		output_file.open(argv[2],ios::out);
		
		while(input_file.good()){
			input_file.ignore(numeric_limits<streamsize>::max(),';'); //timestamp
			input_file.ignore(numeric_limits<streamsize>::max(),';'); //type
			input_file.getline(ip_src,16,';');
			input_file.getline(ip_dst,16,'\n');

			++get<0>(ip_appareances[ip_src]);
			++get<1>(ip_appareances[ip_dst]);
			
			++requests_count;
		}

		cout << "IP: #SRC #DST" << endl;
		for(auto it = ip_appareances.cbegin();it != ip_appareances.cend();++it){
			cout << it->first << ": " << it->second.first << ' ' << it->second.second << endl;
		}

		output_file.close();
		input_file.close();

	}
	
	return result;
}
