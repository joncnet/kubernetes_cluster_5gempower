#!/usr/bin/env python3

import tornado.escape
import tornado.ioloop
import tornado.web

from os import path
from os import system
from time import sleep

import subprocess
import logging
import json
from signal import signal, SIGTERM


def run_command(*command):

    logging.info('running command: %s' % command)

    result = subprocess.run(command,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            shell=True)

    err = result.stderr.decode('utf-8')

    if err != '':
        logging.error('error from command: %s' % err)
        raise ValueError(err)

    return result.stdout.decode('utf-8')


class Tunnel:

    def __init__(self, local_ip, remote_ip, tunnel_ip, br_name, id, port_no, mec_port_no):

        self.local_ip = local_ip
        self.remote_ip = remote_ip
        self.tunnel_ip = tunnel_ip
        self.target_tunnel = None
        self.br_name = br_name
        self.if_name = id
        self.port_no = port_no
        self.mec_port_no = mec_port_no

        self._create()

    def _create(self):

        run_command('ip link add %s type gretap local %s remote %s'
                    % (self.if_name,self.local_ip, self.remote_ip))
        run_command('ifconfig %s up' % self.if_name)

        run_command('ovs-vsctl add-port %s %s -- set interface %s ofport_request=%s'
                    % (self.br_name, self.if_name, self.if_name, self.port_no))

    def _setup_OFrule(self, match, priority, out_port):

        command = 'ovs-ofctl add-flow %s \"' % self.br_name

        command += 'priority=%s,' % priority

        for key, value in match.items():

            command += '%s=%s,' % (key, value)

        command = command[:-1]
        command += 'action=output:%s\"' % out_port

        run_command(command)

    def setup_OFrules(self):

        arp_match = {'in_port': self.port_no,
                     'dl_type': 0x0806,
                     'arp_spa': self.tunnel_ip,
                     'arp_tpa': self.target_tunnel.tunnel_ip}
        self._setup_OFrule(arp_match, 20, self.target_tunnel.port_no)

        ip_match = {'in_port': self.port_no,
                    'dl_type': 0x0800,
                    'nw_src': self.tunnel_ip,
                    'nw_dst': self.target_tunnel.tunnel_ip}
        self._setup_OFrule(ip_match, 20, self.target_tunnel.port_no)

        sctp_match1 = {'in_port': self.port_no,
                      'dl_type': 0x0800,
                      'nw_proto': 132}
        self._setup_OFrule(sctp_match1, 50, self.mec_port_no)

        sctp_match2 = {'in_port': self.mec_port_no,
                      'dl_type': 0x0800,
                      'nw_proto': 132,
                      'nw_dst': self.tunnel_ip}
        self._setup_OFrule(sctp_match2, 50, self.port_no)

        gtp_match1 = {'in_port': self.port_no,
                      'dl_type': 0x0800,
                      'nw_proto': 17,
                      'tp_dst': 2152}
        self._setup_OFrule(gtp_match1, 50, self.mec_port_no)

        gtp_match2 = {'in_port': self.mec_port_no,
                      'dl_type': 0x0800,
                      'nw_proto': 17,
                      'nw_dst': self.tunnel_ip,
                      'tp_dst': 2152}
        self._setup_OFrule(gtp_match2, 50, self.port_no)

    def remove(self):

        d=3

    def __str__(self):

        out = dict()

        out['local_ip'] = self.local_ip
        out['remote_ip'] = self.remote_ip
        out['tunnel_ip'] = self.tunnel_ip
        if self.target_tunnel:
            out['target_tunnel_ip'] = self.target_tunnel.local_ip
        else:
            out['target_tunnel_ip'] = None
        out['br_name'] = self.br_name
        out['if_name'] = self.if_name
        out['port_no'] = self.port_no

        return json.dumps(out, indent=4)

    def __repr__(self):

        return str(self)


class PodIPHandler(tornado.web.RequestHandler):

    def initialize(self, server):
        self.server = server

    def get(self):

        self.write(self.server.local_ip)


class TunnelHandler(tornado.web.RequestHandler):

    def initialize(self, server):
        self.server = server

    def get(self, id=None):

        try:

            if id is None:
                self.write(str(self.server.tunnels))
            else:
                self.write(str(self.server.tunnels[id]))

        except KeyError as ex:
            self.set_status(404)
            self.write(str(ex))

    def put(self, id):

        try:

            tunnels = self.server.tunnels

            if id in tunnels:
                tunnels[id].remove()
                del tunnels[id]  # use getter / setter

            remote_ip = self.get_argument('local_ip')
            tunnel = Tunnel(self.server.local_ip,
                            remote_ip,
                            '%s.%s' % (self.server.tunnel_ip_root, self.server.tunnel_ip_host),
                            self.server.sniff_br_name,
                            id,
                            self.server.tunnel_ip_host + 10,
                            self.server.sniff_if_port_no)

            tunnels[id] = tunnel

            #data = {'local_tunnel_ip': self.server.tunnel_ip_counter}
            self.server.tunnel_ip_host += 1
            self.write(str(tunnel))

            self.set_status(201)

        except ValueError as ex:
            self.set_status(400)
            logging.error(ex)
            self.write(str(ex))

class TunnelChainsHandler(tornado.web.RequestHandler):

    def initialize(self, server):
        self.server = server

    def put(self, id):

        try:

            tunnels = self.server.tunnels

            if id not in tunnels:
                self.set_status(404)
                return

            next = self.get_argument('next')
            if next not in tunnels:
                self.set_status(404)
                return

            src_tunnel = tunnels[id]
            next_tunnel = tunnels[next]

            src_tunnel.target_tunnel = next_tunnel
            src_tunnel.setup_OFrules()

            self.set_status(201)

        except ValueError as ex:
            self.set_status(400)
            logging.error(ex)
            self.write(str(ex))


class MECAgent:

    def __init__(self):

        self.stop = False

        self.tunnels = {}
        self.local_ip = None
        self.sniff_br_name = 'sniff-br'
        self.sniff_if_name = 'sniff-if'
        self.sniff_if_port_no = 100
        self.tunnel_ip_root = '10.0.0'
        self.tunnel_ip_host = 1

        logging.basicConfig(level=logging.INFO)

        try:

            self.initialize()

            signal(SIGTERM, self.sigterm_handler)
            tornado.ioloop.PeriodicCallback(self.periodic_callback, 2000).start()

            application = tornado.web.Application([
                (r"/podip/?", PodIPHandler, dict(server=self)),
                (r"/tunnels/?", TunnelHandler, dict(server=self)),
                (r"/tunnels/([a-zA-Z0-9:-]*)", TunnelHandler, dict(server=self)),
                (r"/chains/([a-zA-Z0-9:-]*)", TunnelChainsHandler, dict(server=self))
            ])

            logging.info("Ready")

            application.listen(8000)
            self.ioloop_instance = tornado.ioloop.IOLoop.instance()
            self.ioloop_instance.start()

        except ValueError as ex:
            logging.error(ex)

    def periodic_callback(self):

        if self.stop:
            logging.info('Terminating Tornado')
            self.ioloop_instance.stop()

    def sigterm_handler(self, signum, frame):

        logging.info('Sigterm received, waiting for Tornado to quit')
        self.stop = True

    def initialize(self):

        # get local ip
        self.local_ip = run_command('ip route get 1 | awk \'{print $(NF-2);exit}\'')[:-1]
        logging.info('Local ip is %s' % self.local_ip)

        # create ovs bridge
        run_command('ovs-vsctl add-br %s' % self.sniff_br_name)
        run_command('ovs-vsctl set-controller %s tcp:127.0.0.1:6633' % self.sniff_br_name)
        run_command('ovs-vsctl set-fail-mode %s secure' % self.sniff_br_name)
        run_command('ifconfig %s up' % self.sniff_br_name)

        # add internal port for mec server
        run_command('ovs-vsctl add-port %s %s -- set interface %s type=internal ofport_request=%s'
                    % (self.sniff_br_name, self.sniff_if_name, self.sniff_if_name, self.sniff_if_port_no))
        run_command('ifconfig %s up' % self.sniff_if_name)


if __name__ == "__main__":

    MECAgent()
