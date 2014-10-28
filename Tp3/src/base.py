# -*- coding: utf-8 -*-

##########################################################
#                 Trabajo Práctico 3                     #
#         Programación de protocolos end-to-end          #
#                                                        #
#              Teoría de las Comunicaciones              #
#                       FCEN - UBA                       #
#              Segundo cuatrimestre de 2014              #
##########################################################


import sys, time, os
try:
    from ptc import Socket, SHUT_WR
except:
    sys.path.append('./')
    from ptc import Socket, SHUT_WR


class FileTransferBase(object):

    CHUNK_SIZE = 500
    DEFAULT_IP = '127.0.0.1'
    DEFAULT_PORT = 6677
    DEFAULT_EXPERIMENT_TIME = 5

    def __init__(self):
        self.received_bytes = str()
        self._initialize_address()

    def _initialize_address(self):
        # La dirección y el puerto pueden venir como opciones de línea de
        # comando.
        if len(sys.argv) >= 4:
            self.server_ip = sys.argv[1]
            self.server_port = int(sys.argv[2])
            self.experiment_timeout = int(sys.argv[3])
        elif len(sys.argv) == 3:
            self.server_ip = sys.argv[1]
            self.server_port = int(sys.argv[2])
            self.experiment_timeout = self.DEFAULT_EXPERIMENT_TIME
        elif len(sys.argv) == 2:
            self.server_ip = sys.argv[1]
            self.server_port = self.DEFAULT_PORT
            self.experiment_timeout = self.DEFAULT_EXPERIMENT_TIME
        else:
            self.server_ip = self.DEFAULT_IP
            self.server_port = self.DEFAULT_PORT
            self.experiment_timeout = self.DEFAULT_EXPERIMENT_TIME

    def transferReceive(self):
        to_send = open(self.outgoing_filename).read()
        expected_size = len(open(self.incoming_filename).read())
        with Socket() as sock:
            # La conexión del socket queda definida por cada subclase.
            # El cliente se conecta activamente mientras que el servidor se
            # ligará a una dirección determinada y escuchará allí.
            self._connect_socket(sock)
            i = 0
            # Para recibir el archivo, iterar hasta que el tamaño deseado
            # queda totalmente cubierto.
            while len(self.received_bytes) < expected_size:
                # Siendo PTC un protocolo full-duplex, al mismo tiempo también
                # podemos mandar datos a nuestro interlocutor.
                sock.send(to_send[i:i+self.CHUNK_SIZE])
                chunk = sock.recv(self.CHUNK_SIZE)
                self.received_bytes += chunk
                i += self.CHUNK_SIZE
            # Por último, enviar todos los bytes remanentes.
            if i < len(to_send):
                sock.send(to_send[i:])
        self._write_file()

    def transfer(self):
        with Socket() as sock:
            self._connect_socket(sock)
            start = time.time()
            while time.time()-start < self.experiment_timeout:
                to_send = str(os.urandom(self.CHUNK_SIZE))
                sock.send(to_send)
            sock.close()

    def receive(self):
        with Socket() as sock:
            self._connect_socket(sock)
            sock.shutdown(SHUT_WR)
            start = time.time()
            i=0
            while time.time()-start < self.experiment_timeout:
                sock.recv(self.CHUNK_SIZE)
                i+=1
            print i
            sock.close()

    def _write_file(self):
        incoming_filename = 'filesReceived/recvd_%s' % self.incoming_filename.rpartition('/')[2]
        out_file = open(incoming_filename, 'w')
        out_file.write(self.received_bytes)
        out_file.close()

    def _connect_socket(self, sock):
        raise NotImplementedError
