# -*- coding: utf-8 -*-

##########################################################
#                 Trabajo Práctico 3                     #
#         Programación de protocolos end-to-end          #
#                                                        #
#              Teoría de las Comunicaciones              #
#                       FCEN - UBA                       #
#              Segundo cuatrimestre de 2014              #
##########################################################


import threading
import random
import time

from cblock import PTCControlBlock
from constants import CLOSED, ESTABLISHED, SYN_SENT,\
                      LISTEN, FIN_WAIT1, FIN_WAIT2,\
                      CLOSE_WAIT, LAST_ACK, CLOSING,\
                      SHUT_RD, SHUT_WR, SHUT_RDWR,\
                      NO_WAIT,\
                      MSS, MAX_SEQ, RECEIVE_BUFFER_SIZE,\
                      MAX_RETRANSMISSION_ATTEMPTS,\
                      BOGUS_RTT_RETRANSMISSIONS, CLOCK_TICK
from exceptions import PTCError
from handler import IncomingPacketHandler
from packet import ACKFlag, FINFlag, SYNFlag
from packet_utils import PacketBuilder
from rqueue import RetransmissionQueue
from rto import RTOEstimator
from seqnum import SequenceNumber
from soquete import Soquete
from thread import Clock, PacketSender, PacketReceiver
from timer import RetransmissionTimer


class PTCProtocol(object):

    def __init__(self, alpha, beta, delay, dropChance, wait):
        self.state = CLOSED
        self.control_block = None
        self.packet_builder = PacketBuilder()
        self.socket = Soquete()
        self.rcv_wnd = RECEIVE_BUFFER_SIZE
        self.iss = self.compute_iss()
        self.rqueue = RetransmissionQueue()
        self.read_stream_open = True
        self.write_stream_open = True
        self.rto_estimator = RTOEstimator(self, alpha, beta, delay, dropChance)
        self.packet_handler = IncomingPacketHandler(self)
        self.delay = delay
        self.dropChance = dropChance
        self.wait = wait
        self.ticks = 0
        self.retransmissions = 0
        self.close_mode = NO_WAIT
        self.close_event = threading.Event()
        self.initialize_threads()
        self.initialize_timers()

    def initialize_threads(self):
        self.packet_sender = PacketSender(self)
        self.packet_receiver = PacketReceiver(self)
        self.clock = Clock(self)

    def initialize_timers(self):
        self.retransmission_timer = RetransmissionTimer(self)

    def start_threads(self):
        self.packet_receiver.start()
        self.packet_sender.start()
        self.clock.start()

    def stop_threads(self):
        self.packet_receiver.stop()
        self.packet_sender.stop()
        self.packet_sender.notify()
        self.clock.stop()

    def join_threads(self):
        self.packet_receiver.join()
        self.packet_sender.join()
        self.clock.join()

    def set_state(self, state):
        self.state = state
        if state == CLOSED or\
           (self.close_mode == NO_WAIT and state == FIN_WAIT2):
            # Señalizar este evento cuando la conexión queda completamente
            # cerrada o bien cuando el usuario del socket explícitamente
            # eligió esperar a que el interlocutor también cierre. Por
            # defecto, el comportamiento es similar al de TCP (i.e., cierre
            # asimétrico).
            self.close_event.set()
        if state == ESTABLISHED:
            self.connected_event.set()

    def compute_iss(self):
        value = random.randint(0, MAX_SEQ/2)
        return SequenceNumber(value)

    def initialize_control_block_from(self, packet):
        # +1 dado que el SYN se secuencia.
        receive_seq = 1 + packet.get_seq_number()
        send_seq = 1 + self.iss
        send_window = packet.get_window_size()
        receive_window = self.rcv_wnd
        self.control_block = PTCControlBlock(send_seq, receive_seq,
                                             send_window, receive_window)

    def is_connected(self):
        connected_states = [ESTABLISHED, FIN_WAIT1, FIN_WAIT2, CLOSE_WAIT,
                            CLOSING, LAST_ACK]
        return self.state in connected_states

    def build_packet(self, seq=None, ack=None, payload=None, flags=None,
                     window=None):
        if seq is None:
            seq = self.control_block.get_snd_nxt()
        if flags is None:
            flags = [ACKFlag]
        if ack is None and ACKFlag in flags:
            ack = self.control_block.get_rcv_nxt()
        if window is None:
            window = self.control_block.get_rcv_wnd()
        packet = self.packet_builder.build(payload=payload, flags=flags,
                                           seq=seq, ack=ack, window=window)
        return packet

    def send_and_queue(self, packet, is_retransmission=False):
        if is_retransmission:
            # Algoritmo de Karn: no usar paquetes retransmitidos para
            # actualizar las estimaciones del RTO.
            if self.rto_estimator.is_tracking_packets():
                tracked_packet = self.rto_estimator.get_tracked_packet()
                tracked_seq = tracked_packet.get_seq_number()
                if tracked_seq == packet.get_seq_number():
                    self.rto_estimator.untrack()
        else:
            # Sólo se hará seguimiento de paquetes frescos para estimar el
            # RTT (otra vez por el algoritmo de Karn).
            if not self.rto_estimator.is_tracking_packets():
                self.rto_estimator.track(packet)
            # Encolar este paquete fresco para eventuales retransmisiones.
            # Las retransmisiones no se reencolan pues quedan al principio de
            # la cola hasta que son correctamente reconocidas.
            self.rqueue.put(packet)

        if not self.retransmission_timer.is_running():
            # Usar la estimación actual del RTO para medir este paquete.
            current_rto = self.rto_estimator.get_current_rto()
            self.retransmission_timer.start(current_rto)

        if self.wait and self.state == ESTABLISHED:
            if random.randint(0, 100) >= self.dropChance:
                time.sleep(self.delay * CLOCK_TICK)
                self.socket.send(packet)
            else:
                print '#DROP!'
        else:
            self.socket.send(packet)

    def set_destination_on_packet_builder(self, address, port):
        self.packet_builder.set_destination_address(address)
        self.packet_builder.set_destination_port(port)

    def bind(self, address, port):
        self.socket.bind(address, port)
        self.packet_builder.set_source_address(address)
        self.packet_builder.set_source_port(port)

    def listen(self):
        self.set_state(LISTEN)

    def connect_to(self, address, port):
        self.connected_event = threading.Event()
        self.set_destination_on_packet_builder(address, port)
        self.start_threads()

        syn_packet = self.build_packet(seq=self.iss, flags=[SYNFlag],
                                       window=self.rcv_wnd)
        self.set_state(SYN_SENT)
        self.send_and_queue(syn_packet)

        self.connected_event.wait()

    def accept(self):
        if self.state != LISTEN:
            raise PTCError('should listen first')
        self.connected_event = threading.Event()
        self.start_threads()
        # Esperar hasta que un cliente desee conectarse.
        self.connected_event.wait()

    def send(self, data):
        with self.control_block:
            if not self.write_stream_open:
                raise PTCError('write stream is closed')
            self.control_block.to_out_buffer(data)
            self.packet_sender.notify()

    def receive(self, size):
        data = self.control_block.from_in_buffer(size)
        updated_rcv_wnd = self.control_block.get_rcv_wnd()
        if updated_rcv_wnd > 0:
            wnd_packet = self.build_packet(window=updated_rcv_wnd)

            if self.wait:
                time.sleep(self.delay * CLOCK_TICK)

            self.socket.send(wnd_packet)
        return data

    def get_ticks(self):
        return self.ticks

    def tick(self):
        self.ticks += 1
        self.retransmission_timer.tick()

    def acknowledge_packets_and_update_timers_with(self, packet):
        ack_number = packet.get_ack_number()
        if self.control_block.ack_is_accepted(ack_number):
            # Primero, pasar este paquete al estimador de RTO para que pueda
            # actualizar sus valores si corresponde (esto es, si el paquete
            # está reconociendo el paquete al que está haciendo seguimiento).
            self.rto_estimator.process_ack(packet)
            # Luego, desencolar paquetes para retransmitir y parar/reiniciar
            # el timer de retransmisiones según corresponda.
            self.remove_from_retransmission_queue_packets_acked_by(packet)

    def remove_from_retransmission_queue_packets_acked_by(self, packet):
        # Sólo ACKs mayores que SND_UNA y menores que SND_NXT son válidos
        # en este punto.
        with self.rqueue:
            snd_una = self.control_block.get_snd_una()
            snd_nxt = self.control_block.get_snd_nxt()
            # Ver qué paquetes encolados son totalmente reconocidos por
            # este paquete. Necesitamos SND_UNA y SND_NXT para poder
            # comparar correctamente los SEQs y ACKs.
            removed_packets = self.rqueue.remove_acknowledged_by(packet,
                                                                 snd_una,
                                                                 snd_nxt)

            if len(removed_packets) > 0:
                # Algunos paquetes se reconocieron, por lo que debemos
                # actualizar el timer de retransmisiones.
                self.adjust_retransmission_timer()

    def adjust_retransmission_timer(self):
        # Comenzar con cero retransmisiones para el próximo paquete.
        self.retransmissions = 0
        if self.rqueue.empty():
            # Todos los datos salientes quedaron reconocidos. Detener el timer.
            self.retransmission_timer.stop()
        else:
            # Algunos datos se reconocieron pero otros aún quedan.
            # Reiniciar el timer usando la estimación actual del RTO.
            current_rto = self.rto_estimator.get_current_rto()
            self.retransmission_timer.restart(current_rto)

    def handle_outgoing(self):
        if self.control_block is None:
            # Cuando la conexión todavía no fue establecida, no tenemos nada
            # para enviar.
            return
        with self.control_block:
            # Analizar primero si tenemos un timeout de un paquete enviado.
            if self.retransmission_timer.has_expired() and\
               not self.rqueue.empty():
                # Si alcanzamos el máximo número permitido de retransmisiones,
                # liberar la conexión.
                if self.retransmissions >= MAX_RETRANSMISSION_ATTEMPTS:
                    self.free()
                    return
                # Limpiar la estimación del RTT si se hizo back-off reiteradas
                # veces. Posiblemente ya no represente el RTT real.
                if self.retransmissions > BOGUS_RTT_RETRANSMISSIONS:
                    self.rto_estimator.clear_rtt()
                self.retransmissions += 1
                # Hacer back-off del RTO y luego retransmitir el paquete más
                # viejo que aún no fue reconocido.
                self.rto_estimator.back_off_rto()
                packet = self.rqueue.head()
                self.send_and_queue(packet, is_retransmission=True)

            if self.write_stream_open or \
               self.control_block.has_data_to_send():
                self.attempt_to_send_data()
            else:
                # Mandar FIN cuando:
                #   * El stream de escritura está cerrado,
                #   * El estado es ESTABLISHED/CLOSE_WAIT
                #     (i.e., todavía no se ha enviado un FIN), y
                #   * Todo byte saliente fue exitosamente reconocido.
                self.attempt_to_send_FIN()

    def attempt_to_send_data(self):
        window_closed = False
        while self.control_block.has_data_to_send() and not window_closed:
            seq_number = self.control_block.get_snd_nxt()
            to_send = self.control_block.extract_from_out_buffer(MSS)
            if not to_send:
                # El bloque de control no devolvió nada, lo cual es un indicio
                # de que la ventana está cerrada. Luego, no tenemos nada más
                # por hacer hasta que lleguen los próximos ACKs.
                window_closed = True
            else:
                packet = self.build_packet(payload=to_send, seq=seq_number)
                self.send_and_queue(packet)

    def attempt_to_send_FIN(self):
        state_allows_closing = self.state in [ESTABLISHED, CLOSE_WAIT]
        if state_allows_closing and self.rqueue.empty():
            fin_packet = self.build_packet(flags=[ACKFlag, FINFlag])
            # Estamos enviando un FIN, y este flag se secuencia. Incrementar el
            # siguiente byte a enviar.
            self.control_block.increment_snd_nxt()
            new_state = FIN_WAIT1 if self.state == ESTABLISHED else LAST_ACK
            self.set_state(new_state)
            self.send_and_queue(fin_packet)

    def handle_incoming(self, packet):
        self.packet_handler.handle(packet)
        self.packet_sender.notify()

    def shutdown(self, how):
        if how == SHUT_RD:
            self.shutdown_read_stream()
        elif how == SHUT_WR:
            self.shutdown_write_stream()
        else:
            self.shutdown_read_stream()
            self.shutdown_write_stream()

    def shutdown_read_stream(self):
        self.read_stream_open = False

    def shutdown_write_stream(self):
        self.write_stream_open = False
        self.packet_sender.notify()

    def close(self, mode=NO_WAIT):
        self.close_mode = mode
        if self.state != CLOSED:
            self.shutdown(SHUT_RDWR)
            self.close_event.wait()
        self.free()
        self.join_threads()

    def free(self):
        if self.control_block is not None:
            self.control_block.flush_buffers()
        self.stop_threads()
        # En caso de que el establecimiento de conexión haya fallado, esto
        # destrabará al thread principal de la aplicación.
        self.connected_event.set()
        # Y, análogamente, esto destrabará al thread principal si se llama a
        # close y free es luego invocada por algún otro thread.
        self.close_event.set()
        self.set_state(CLOSED)
