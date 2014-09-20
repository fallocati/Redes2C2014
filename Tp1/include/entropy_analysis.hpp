#ifndef ENTROPY_ANALISYS_H
#define ENTROPY_ANALISYS_H

#include<string>
#include<array>
#include<unordered_map>
#include<map>

#include<cmath>

#include<iostream>
#include<fstream>
#include<limits>

struct arp_counters {
    unsigned long src_counter;
    unsigned long dst_counter;
    unsigned long src_eq_dst_counter;
};

typedef long double probability;
typedef long double entropy;

struct map_file{
    std::multimap<probability,std::string,std::greater<probability> > const *ips_by_probability;
    std::ofstream* output;
};

#endif//ENTROPY_ANALISYS_H
