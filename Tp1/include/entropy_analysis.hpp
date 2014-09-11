#include<iostream>
#include<fstream>
#include<string>
#include<unordered_map>
#include<tuple>
#include<limits>

typedef struct arp_counters{
	unsigned long src_counter;
	unsigned long dst_counter;
	unsigned long src_eq_dst_counter;
} arp_counters_t;

typedef float probability;
typedef float entropy;
//typedef char ip[16];
typedef std::string ip;
