#include<iostream>
#include<string>
#include<crafter.h>
#include<vector>

#include<rastrearutas.hpp>
using namespace std;
using namespace Crafter;

int main(int argc, char* argv[]) {

    int result = 0;
    if(argc < 3) {
        cout << "Numero incorrecto de parametros. " << endl;
        cout << argv[0] << " interface destino [max_hops] [pkgs_por_hop]" << endl;
        cout << "Ejemplo: " << endl;
        result = 1;

    }else{
        string iface = argv[1];
        string dst_ip = argv[2];

        int max_hops = 30;
        if(argc >= 4)
            max_hops = std::stoi(argv[3],nullptr);

        int pks_per_hop = 10;
        if(argc >= 5)
            pks_per_hop = std::stoi(argv[4],nullptr);

        /* Create an IP header */
        IP ip_header;
        ip_header.SetSourceIP(GetMyIP(iface));
        ip_header.SetDestinationIP(dst_ip);

        ICMP icmp_header;
        icmp_header.SetType(ICMP::EchoRequest);

        vector<Packet*> pings_packets;
        /* Create a packet for each TTL */
        for(int ttl=0;ttl<=max_hops;++ttl) {
            ip_header.SetTTL(ttl);
            for(int pk=0;pk<pks_per_hop;++pk){
                ip_header.SetIdentification(RNG16()); //Set a random ID for the IP header
                pings_packets.push_back(new Packet(ip_header/icmp_header));
            }
        }

        for(auto it = pings_packets.cbegin();it<pings_packets.cend();++it){
            (*it)->Print();
            cout << endl;
        }


        cout << "ESOS SON LOS PAQUETES" << endl;

        /*
         * At this point, we have all the packets into the
         * pings_packets container. Now we can Send 'Em All.
         *
         * 48 (nthreads) -> Number of threads for distributing the packets
         *                  (tunable, the best value depends on your
         *                   network an processor).
         * 1 (timeout) -> Timeout in seconds for waiting an answer
         * 3  (retry)    -> Number of times we send a packet until a response is received
         */
        vector<Packet*> pongs_packets(pings_packets.size());
        cout << "[@] Sending the ICMP echoes. Wait..." << endl;
        SendRecv(pings_packets.begin(),pings_packets.end(),pongs_packets.begin(),iface,1,3,48);

        /*
         * pongs_packets is a pointer to a PacketContainer with the same size
         * of pings_packets (first argument). So, at this point, (after
         * the SendRecv functions returns) we can iterate over each
         * reply packet, if any.
         */
        for(auto it_pk_ptr = pongs_packets.begin();it_pk_ptr<pongs_packets.end();++it_pk_ptr) {
            /* Check if the pointer is not NULL */
            if(*it_pk_ptr) {
                /* Get the ICMP layer */
                ICMP* icmp_layer = (*it_pk_ptr)->GetLayer<ICMP>();
                if(icmp_layer->GetType() == ICMP::TimeExceeded || icmp_layer->GetType() == ICMP::EchoReply) {
                            /* Get the IP layer of the replied packet */
                            //IP* ip_layer = (*it_pk_ptr)->GetLayer<IP>();
                            /* Print the Source IP */
                            //cout << "[@] Host " << ip_layer->GetSourceIP() << " up." << endl;
                            //counter++;
                            (*it_pk_ptr)->Print();
                            cout << endl;
                }
            }
        }

        for(auto it_pk_ptr = pings_packets.begin();it_pk_ptr<pings_packets.end();++it_pk_ptr)
            delete (*it_pk_ptr);

        for(auto it_pk_ptr = pongs_packets.begin();it_pk_ptr<pongs_packets.end();++it_pk_ptr)
            delete (*it_pk_ptr);
    }

    return result;
}
