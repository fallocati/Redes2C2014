import threading
import datetime

from constants import INITIAL_RTO, MAX_RTO, K
from seqnum import SequenceNumber


# RTO estimation following RFC 6298, but naively implemented.
class RTOEstimator(object):

    def __init__(self, protocol, alpha, beta, delay, dropChance):
        self.srtt = 0
        self.rttvar = 0
        self.rto = INITIAL_RTO
        self.protocol = protocol
        self.alpha = alpha
        self.beta = beta
        self.delay = delay
        self.dropChance = dropChance
        self.tracking = False
        self.lock = threading.RLock()

    def get_current_rto(self):
        with self.lock:
            return self.rto

    def get_tracked_packet(self):
        with self.lock:
            return self.tracked_packet

    def is_tracking_packets(self):
        with self.lock:
            return self.tracking

    def track(self, packet):
        with self.lock:
            self.tracked_packet = packet
            self.rtt_start_time = self.protocol.get_ticks()
            self.tracking = True

    def untrack(self):
        with self.lock:
            self.tracking = False

    def back_off_rto(self):
        with self.lock:
            self.rto = min(MAX_RTO, 2 * self.rto)

    def clear_rtt(self):
        with self.lock:
            # Keep current retransmit times until new estimates can be done.
            self.rttvar += self.srtt
            self.srtt = 0

    def process_ack(self, ack_packet):
        with self.lock:
            if not self.tracking:
                return
            if self.ack_covers_tracked_packet(ack_packet.get_ack_number()):
                sampled_rtt = self.protocol.get_ticks() - self.rtt_start_time
                print '{};{};{};{};{};{};{}'.format(\
                    datetime.datetime.now().strftime('%Y%m%d%H%M%S%f')[:-3],\
                    self.delay,\
                    self.dropChance,\
                    self.alpha,\
                    self.beta,\
                    self.rto * 10,\
                    sampled_rtt * 10\
                )
                self.update_rtt_estimation_with(sampled_rtt)
                self.update_rto()
                self.untrack()

    def update_rtt_estimation_with(self, sampled_rtt):
        if self.srtt == 0:
            # First sample. Update values according to step 2.1 of the RFC.
            self.srtt = sampled_rtt
            self.rttvar = sampled_rtt / 2
        else:
            # We have at least one sample. Thus, update values as suggested
            # by step 2.2 of the RFC.
            deviation = abs(self.srtt - sampled_rtt)
            self.rttvar = (1 - self.beta) * self.rttvar + self.beta * deviation
            self.srtt = (1 - self.alpha ) * self.srtt + self.alpha  * sampled_rtt

    def update_rto(self):
        self.rto = self.srtt + max(1, K * self.rttvar)

    def ack_covers_tracked_packet(self, ack_number):
        iss = self.protocol.iss
        seq_number = self.tracked_packet.get_seq_number()
        return SequenceNumber.a_leq_b_leq_c(iss, seq_number, ack_number)
