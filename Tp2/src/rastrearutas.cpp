#include<iostream>
#include<fstream>
#include<string>
#include<vector>
#include<chrono>
#include<iomanip>

#include<crafter.h>
#include<rastrearutas.hpp>
using namespace std;
using namespace Crafter;

void search_replace(string& String,
                    string searchString,
                    string replaceString,
                    string::size_type pos = 0)
    {

    while((pos = String.find(searchString,pos)) != string::npos){
        String.replace(pos,searchString.size(),replaceString);
        pos+=replaceString.size();
    }
}

int main(int argc, char* argv[]) {

    int result = 0;
    if(argc < 3) {
        cout << "Numero incorrecto de parametros. " << endl;
        cout << argv[0] << " interface destino [max_hops] [cantidad_experimentos] [archivo_salida]" << endl;
        cout << "Ejemplo: " << endl;
        result = 1;

    }else{
        string iface = argv[1];
        string dst_ip = argv[2];
        //ofstream of;

        int max_hops = 30;
        if(argc > 3)
            max_hops = std::stoi(argv[3],nullptr);

        int quant_rounds= 10;
        if(argc > 4)
            quant_rounds = std::stoi(argv[4],nullptr);

        /*
        auto buf = cout.rdbuf();
        if(argc > 5) {
            of.open(argv[5], ofstream::out | ofstream::app);
            buf = of.rdbuf();
        }
        */
        bool gotThere = false;
        for(int round=0;round<quant_rounds;++round){
            for(int ttl=1;ttl<=max_hops && !gotThere;++ttl) {
                /* Create an IP header */
                IP ip_header;
                ip_header.SetSourceIP(GetMyIP(iface));
                ip_header.SetDestinationIP(dst_ip);
                ip_header.SetTTL(ttl);
                ip_header.SetIdentification(RNG16()); //Set a random ID for the IP header

                ICMP icmp_header;
                icmp_header.SetType(ICMP::EchoRequest);
                icmp_header.SetIdentifier(RNG16());
                //icmp_header.SetPayload("ThisIsThePayloadOfAPing\n");

                Packet ping(ip_header/icmp_header);
                ping.RawString(); //Complete automatically the remaining fields

                stringstream tcpdump_filter;
                tcpdump_filter << "(icmp[icmptype] = icmp-timxceed";

                /*
                byte* buffer = new byte[ping.GetLayer<IPLayer>()->GetSize()];
                ping.GetLayer<IPLayer>()->GetRawData(buffer);
                for(unsigned int byte = 0;byte<ping.GetLayer<IPLayer>()->GetSize();++byte){
                    tcpdump_filter << " and icmp[" << dec << 8+byte << "] = 0x";
                    tcpdump_filter << hex << (unsigned int)buffer[byte];
                }

                ping.GetLayer<ICMPLayer>()->GetRawData(buffer);
                for(unsigned int byte = 0;byte<8;++byte){
                    tcpdump_filter << " and icmp[" << dec << 8+ping.GetLayer<IPLayer>()->GetSize()+byte << "] = 0x";
                    tcpdump_filter << hex << (unsigned int)buffer[byte];
                }
                delete[] buffer;
                */

                tcpdump_filter << ") or ";

                tcpdump_filter << "(icmp[icmptype] = 0 and icmp[4:2] = 0x" << std::hex << icmp_header.GetIdentifier() << ")";
                cout << endl << tcpdump_filter.str() << ' ' << icmp_header.GetIdentifier() << ' ' << RNG16() << endl;
                cout << endl;
                cout << "[#] ICMP request: " << endl;
                ping.Print();
                cout << endl;
                chrono::high_resolution_clock::time_point rtt_begin = chrono::high_resolution_clock::now();
                Packet* rcv_pck = ping.SendRecv(iface,1,3,tcpdump_filter.str());
                chrono::high_resolution_clock::time_point rtt_end = chrono::high_resolution_clock::now();
                //Packet* rcv_pck = ping.SendRecv(iface);
                if(rcv_pck) {
                    ping.RawString(); //Complete automatically the remaining fields
                    cout << endl;
                    cout << "[#] ICMP reply : " << endl;
                    rcv_pck->Print();
                    /* Get type of ICMP layer */
                    ICMPLayer* icmp = rcv_pck->GetLayer<ICMPLayer>();
                    cout << "[#] ICMP type : " << dec << (int)icmp->GetType() << endl;
                    cout << "[#] ICMP ID : " << hex << icmp->GetIdentifier() << endl;
                    cout << "RTT : " << dec << chrono::duration_cast<chrono::duration<double> >(rtt_end-rtt_begin).count() << endl;
                    if(icmp->GetIdentifier() == icmp_header.GetIdentifier())
                        gotThere = true;
                    delete rcv_pck;
                } else
                    cout << "[#] No response... " << endl;

                cout << "------------------------------------" << endl;
            }
        }
    }

    return result;
}
