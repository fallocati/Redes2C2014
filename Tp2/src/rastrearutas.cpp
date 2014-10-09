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

                stringstream id;
                //id << "(icmp[0] = 11)";
                id << "(icmp[0] = 11) or (icmp[0] = 0 and icmp[4:2] = 0x" << std::hex << icmp_header.GetIdentifier() << ")";
                cout << id.str() << ' ' << icmp_header.GetIdentifier() << ' ' << RNG16() << endl;
                Packet* rcv_pck = ping.SendRecv(iface,1,3,id.str());
                //Packet* rcv_pck = ping.SendRecv(iface);
                if(rcv_pck) {
                    cout << "[#] ICMP request: " << endl;
                    ping.Print();
                    cout << endl;
                    cout << "[#] ICMP reply : " << endl;
                    rcv_pck->Print();
                    /* Get type of ICMP layer */
                    ICMPLayer* icmp = rcv_pck->GetLayer<ICMPLayer>();
                    cout << "[#] ICMP type : " << dec << (int)icmp->GetType() << endl;
                    cout << "[#] ICMP ID : " << hex << icmp->GetIdentifier() << endl;
                    if(icmp->GetIdentifier() == icmp_header.GetIdentifier())
                        gotThere = true;
                    delete rcv_pck;
                } else
                    cout << "[#] No response... " << endl;

                cout << "------------------------------------" << endl;
                sleep(2);

                /* From Headers
                 * Packet* SendRecv(const std::string& iface = "",double timeout = 1, int retry = 3, const std::string& user_filter = " ");
                 */
                //chrono::high_resolution_clock::time_point rtt_begin = chrono::high_resolution_clock::now();
                //Packet *pong = ping.SendRecv(iface);
                //chrono::high_resolution_clock::time_point rtt_end = chrono::high_resolution_clock::now();
                /*
                if(pong){
                    ICMP* icmp_layer = pong->GetLayer<ICMP>();
                    //if(icmp_layer->GetType() == ICMP::TimeExceeded || icmp_layer->GetType() == ICMP::EchoReply) {
                        IP* ip_layer = pong->GetLayer<IP>();
                        //cout << ';' << ip_layer->GetSourceIP() << ';' << chrono::duration_cast<chrono::milliseconds>(rtt_end-rtt_begin).count();
                        cout << ';' << ttl << ';' << ip_layer->GetSourceIP() << ';' << pong->GetTimestamp().tv_sec  << ';' << pong->GetTimestamp().tv_usec << endl;
                    //}
                    pong->Print();
                    cout << endl;
                    cout << "------------------------"<< endl;
                    delete pong;

                }else{
                    cout << ';' << ttl << ";*;*" << endl;
                }
                */
            }
        }
    }

    return result;
}
