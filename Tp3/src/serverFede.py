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

import time

CHUNK_SIZE = 500
SERVER_IP = '0.0.0.0'
SERVER_PORT = 6677

alphas = [0.5]
betas = [0.5]
delays = [10]
probs = [0,10,50]

for alpha in alphas:    
    for beta in betas:        
        for delay in delays:
            for prob in probs:    	
                with Socket(alpha, beta, delay, prob) as server_sock:
                    print '#Alpha: {} - Beta: {} - Delay: {} ticks - Probabilidad de dropeo: {}'.format(alpha, beta, delay, prob)
                    try:
                        server_sock.bind((SERVER_IP, SERVER_PORT))
                        server_sock.listen()                
                        server_sock.accept(timeout=100)

                        while server_sock.recv(CHUNK_SIZE).find("FINEXPERIMENTO") == -1:
                            pass

                        server_sock.send("FINEXPERIMENTO")
                        
                        server_sock.close(WAIT)
                    except Exception,e:
                        print str(e)
                        pass
