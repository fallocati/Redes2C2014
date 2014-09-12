#ifndef ENTROPY_ANALISYS_H
#define ENTROPY_ANALISYS_H

#include<iostream>
#include<fstream>
#include<string>
#include<unordered_map>
#include<tuple>
#include<limits>
#include<cmath>
//#include<boost/multiprecision/mpfr.hpp>

typedef struct arp_counters{
	unsigned long src_counter;
	unsigned long dst_counter;
	unsigned long src_eq_dst_counter;
} arp_counters_t;

//typedef boost::multiprecision::mpfr_float probability;
//typedef boost::multiprecision::mpfr_float entropy;
typedef long double probability;
typedef long double entropy;
typedef std::string ip;

#endif//ENTROPY_ANALISYS_H
