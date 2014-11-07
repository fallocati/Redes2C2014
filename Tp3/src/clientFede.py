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
    from ptc import Socket, WAIT
except:
    import sys
    sys.path.append('../../')
    from ptc import Socket, WAIT

import time, os

CHUNK_SIZE = 500
SERVER_IP = '127.0.0.1'
SERVER_PORT = 6677
EXPERIMENT_PACKETS = 100

alphas = [0.5]
betas = [0.5]
delays = [1, 2]
probs = [0, 10, 50]
for alpha in alphas:
    for beta in betas:        
        for delay in delays:
            for prob in probs:
                print '#Alpha: {} - Beta: {} - Delay: {} ticks - Probabilidad de dropeo: {}'.format(alpha, beta, delay, prob)
                with Socket(alpha, beta, delay, prob, True) as client_sock:
                    try:
                        time.sleep(2)
                        
                        client_sock.connect((SERVER_IP, SERVER_PORT), timeout=1000)
                        
                        for i in range(EXPERIMENT_PACKETS):
                            to_send = str(os.urandom(CHUNK_SIZE))
                            client_sock.send(to_send)

                        client_sock.send("FINEXPERIMENTO")
                        client_sock.recv(14)
                        
                        client_sock.close(WAIT)                
                    except Exception,e: 
                        print str(e)  
                        try:
                            client_sock.send("FINEXPERIMENTO")
                        except:
                            pass
                        time.sleep(5)
                        pass        
