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
    from ptc import Socket, SHUT_WR,ABORT
except:
    import sys
    sys.path.append('../../')
    from ptc import Socket, SHUT_WR,ABORT

import time

CHUNK_SIZE = 500
SERVER_IP = '0.0.0.0'
SERVER_PORT = 6677
EXPERIMENT_TIME = 5

delays = [50]
probs = [0,10,50]

for delay in delays:
    for prob in probs:
    # Usar sockets PTC dentro de bloques with. Esto nos asegura que los recursos
    # subyacentes serán liberados de forma adecuada una vez que el socket ya no
    # se necesite.
        with Socket(delay, prob) as server_sock:
            print 'Delay: {} ticks - Probabilidad de dropeo: {}'.format(delay, prob)
            try:
                # Ligar el socket a una interfaz local a través de la tupla (IP, PORT).
                server_sock.bind((SERVER_IP, SERVER_PORT))

                # Pasar al estado LISTEN.
                server_sock.listen()

                #print 'listen'
                # Esta llamada se bloqueará hasta que otro PTC intente conectarse. No
                # obstante, luego de diez segundos de no recibir hagonexiones, PTC se
                # dará por vencido.
                server_sock.accept(timeout=100)
                #print 'accepted'
                #server_sock.shutdown(SHUT_WR)

                start = time.time()
                #while server_sock.is_connected() and time.time() - start < EXPERIMENT_TIME:
                pkg = "2"
                while (pkg.find("LACONCHADETUHERMANA") == -1):
                    pkg = server_sock.recv(CHUNK_SIZE)

                server_sock.send("LACONCHADETUHERMANA")
                server_sock.close(ABORT)

                #print 'experiment end'
            except Exception,e:
                print str(e)
                pass