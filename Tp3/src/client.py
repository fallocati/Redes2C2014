# -*- coding: utf-8 -*-

##########################################################
#                 Trabajo Práctico 3                     #
#         Programación de protocolos end-to-end          #
#                                                        #
#              Teoría de las Comunicaciones              #
#                       FCEN - UBA                       #
#              Segundo cuatrimestre de 2014              #
##########################################################


try:
    import sys
    from ptc import Socket, WAIT
except:
    import sys
    sys.path.append('../../')
    from ptc import Socket, WAIT

import time, os

CHUNK_SIZE = 500
SERVER_IP = '127.0.0.1'
EXPERIMENT_PACKETS = 1000

if(len(sys.argv) == 6):
    SERVER_PORT = int(sys.argv[5])
else:
    SERVER_PORT = 6677

#alphas = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
#betas = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
#delays = [0, 0.5, 1, 5, 10, 25, 50]
#probs = [0, 1, 5, 10, 30]

orig_stdout = sys.stdout
#for alpha in alphas:
#    for beta in betas:
#        for delay in delays:
#            for prob in probs:

alpha = float(sys.argv[1])
beta = float(sys.argv[2])
delay = float(sys.argv[3])
prob = float(sys.argv[4])

filename = open("prob"+str(prob)+"_delay"+str(delay*10)+"ms"+"_beta"+str(beta)+"_alpha"+str(alpha)+".csv",'at',1)
print '#Alpha: {} - Beta: {} - Delay: {} ticks - Probabilidad de dropeo: {}'.format(alpha, beta, delay, prob)
sys.stdout = filename
print 'timestamp;delay;dropChance;alpha;beta;rto;sampled_rtt'
with Socket(alpha,
            beta,
            delay,
            prob) as client_sock:
    try:
        time.sleep(2)

        start_time = time.time()
        client_sock.connect((SERVER_IP, SERVER_PORT), timeout=1000)

        for i in range(EXPERIMENT_PACKETS):
            to_send = str(os.urandom(CHUNK_SIZE)).replace("FINEXPERIMENTO","fuera_repetido")
            client_sock.send(to_send)

        client_sock.send("FINEXPERIMENTO")
        client_sock.recv(14)
        client_sock.close(WAIT)

        experiment_time = time.time() - start_time
        filename.close()

        filename = open("prob"+str(prob)+"_delay"+str(delay*10)+"ms"+"_beta"+str(beta)+"_alpha"+str(alpha)+"_throughput.csv",'at',1)
        sys.stdout = filename
        print 'TotalTime;#Sent;#Drop;#Retransmitted'
        print '%s;%i;%i;%i' % (str(experiment_time),client_sock.protocol.sent,client_sock.protocol.drop,client_sock.protocol.retransmitted)
        filename.close()
        sys.stdout = orig_stdout

    except Exception,e:
        print str(e)
        try:
            client_sock.send("FINEXPERIMENTO")
        except:
            pass
        time.sleep(5)
        pass

#print "Pasamos al siguiente experimento"
