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
    from ptc import Socket, SHUT_WR, ABORT
except:
    import sys
    sys.path.append('../../')
    from ptc import Socket, SHUT_WR

import time
import os

CHUNK_SIZE = 500
SERVER_IP = '127.0.0.1'
SERVER_PORT = 6677
EXPERIMENT_TIME = 60

delays = [10, 25, 50, 100, 200]
probs = [0, 10, 25, 50, 75]

for delay in delays:
    for prob in probs:
        print 'Delay: {} ticks - Probabilidad de dropeo: {}'.format(delay, prob)      
        # Usar sockets PTC dentro de bloques with. Esto nos asegura que los recursos
        # subyacentes serán liberados de forma adecuada una vez que el socket ya no
        # se necesite.
        with Socket(0, 0) as client_sock:
            try:
                time.sleep(2)
                # Establecer una conexión al PTC corriendo en el puerto SERVER_PORT en
                # el host con dirección SERVER_IP. Esta llamada es bloqueante, aunque
                # en este caso se declara un timeout de 10 segundos. Pasado este tiempo,
                # el protocolo se dará por vencido y la conexión no se establecerá.
                #print 'connect'
                client_sock.connect((SERVER_IP, SERVER_PORT), timeout=100)
                # Una vez aquí, la conexión queda establecida exitosamente. Podemos enviar
                # y recibir datos arbitrarios.
                #print 'connected'

                start = time.time()
                while time.time() - start < EXPERIMENT_TIME:
                    to_send = str(os.urandom(CHUNK_SIZE))
                    #print 'sending'
                    client_sock.send(to_send)
                    #print 'sent'
                client_sock.close(ABORT)
                #print 'experiment end'
            except Exception,e: 
                print str(e)  
                pass        