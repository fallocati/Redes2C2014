#ifndef ENTROPY_ANALISYS_H
#define ENTROPY_ANALISYS_H

#include<string>
#include<unordered_map>

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

#endif//ENTROPY_ANALISYS_H
