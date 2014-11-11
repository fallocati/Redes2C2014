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

CHUNK_SIZE = 500
SERVER_IP = '127.0.0.1'

if(len(sys.argv) == 6):
    SERVER_PORT = int(sys.argv[5])
else:
    SERVER_PORT = 6677

alpha = float(sys.argv[1])
beta = float(sys.argv[2])
delay = float(sys.argv[3])
prob = float(sys.argv[4])

#while True:
with Socket(alpha,
            beta,
            delay,
            prob) as server_sock:
    try:
        server_sock.bind((SERVER_IP, SERVER_PORT))
        server_sock.listen()
        print 'listen'
        server_sock.accept(timeout=1000)
        print 'accepted'
        while server_sock.recv(CHUNK_SIZE).find("FINEXPERIMENTO") == -1:
            pass

        print 'recv FINEXPERIMENTO'
        server_sock.send("FINEXPERIMENTO")
        print 'sent FINEXPERIMENTO'
        server_sock.close(WAIT)
        print 'socket closed'
    except Exception,e:
        print str(e)
        pass
