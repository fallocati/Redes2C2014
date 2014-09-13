INCLUDE=-I../include/

CXX=g++
CXXFLAGS=-Wall -O2 -std=c++11 $(INCLUDE)
EXTRACXXFLAGS=

CC=gcc
CFLAGS=-Wall -O2 $(INCLUDE) -D_GNU_SOURCE
EXTRACFLAGS=

LDFLAGS=-lpcap

#SOURCES=entropy_analysis.cpp tool.c
#OBJECTS=$(SOURCES:.cpp=.o)

ENTROPY=entropy
TOOL=tool
EXECUTABLES=$(ENTROPY) $(TOOL)

#Rules
all: $(EXECUTABLES)

#Archivos ejecutables
$(ENTROPY): entropy_analysis.cpp
		$(CXX) $(CXXFLAGS) $(EXTRACXXFLAGS) -o $@ $<

$(TOOL): tool.c
		$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRACFLAGS) -o $@ $<

clean:
		@$(RM) $(EXECUTABLES)
