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

    multimap<probability,string,greater<probability> > ips_by_probability_src,ips_by_probability_dst;
    multimap<unsigned long,string,greater<unsigned long> > ips_by_eq;
    entropy entropy_src = 0, entropy_dst = 0;
    ofstream output_file(args[2], ios::out);
    output_file << "IP;Psrc;Pdst;src_eq_dst" << endl;

    for(auto const& ip : counters) {
        probability src = (probability)ip.second.src_counter / requests_count;
        probability dst = (probability)ip.second.dst_counter / requests_count;

        output_file << ip.first << ";" << src << ";" << dst << ";"
        << ip.second.src_eq_dst_counter << endl;

        ips_by_probability_src.emplace(src,ip.first);
        ips_by_probability_dst.emplace(dst,ip.first);
        ips_by_eq.emplace(ip.second.dst_counter,ip.first);

        if(isnormal(src))
            entropy_src -= src * log2(src);

        if(isnormal(dst))
            entropy_dst -= dst * log2(dst);
    }

    output_file.close();

    ofstream output_file_src(string(args[2])+"_src", ios::out);
    ofstream output_file_dst(string(args[2])+"_dst", ios::out);

    map_file src,dst;
    src.ips_by_probability = &ips_by_probability_src;
    src.output = &output_file_src;
    dst.ips_by_probability = &ips_by_probability_dst;
    dst.output = &output_file_dst;

    array<map_file,2> probability_maps {src,dst};

    for(unsigned int i=0; i<probability_maps.size();++i){
        *probability_maps[i].output << "Pos;IP;Probabilidad;Probabilidad Acumulada" << endl;
        unsigned long long pos = 1;
        probability prob_accum = 0;
        for(auto const& ip_by_probability : *probability_maps[i].ips_by_probability){
            prob_accum += ip_by_probability.first;
            *probability_maps[i].output << pos << ';'<< ip_by_probability.second << ';';
            *probability_maps[i].output << ip_by_probability.first << ';' << prob_accum << endl;
            ++pos;
        }
    }

    output_file_src.close();
    output_file_dst.close();

    ofstream output_file_eq(string(args[2])+"_eq", ios::out);
    output_file_eq << "Pos;IP;Paquetes Src=Dst" << endl;
    unsigned long long pos = 1;
    for(auto const& ip_by_eq : ips_by_eq){
        output_file_eq << pos << ';' << ip_by_eq.second << ';';
        output_file_eq << ip_by_eq.first << endl;
        ++pos;
    }

    output_file_eq.close();

    cout << "Entropia de la Fuente SRC: " << entropy_src << endl;
    cout << "Entropia de la fuente DST: " << entropy_dst << endl;

    return 0;
}
