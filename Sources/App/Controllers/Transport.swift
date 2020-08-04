//
//  Transport.swift
//  
//
//  Created by Sepand Yadollahifar on 8/4/20.
//

import Foundation
import Vapor


let LOCAL_TRANSPORT_LIST = [String: String]()

class LocalTransport {
    
//    var name: String
//    var endpoint: URL
//    var websocket: WebSocket
//
////    loop = None
////    protocol = None
////
////    buf = None
////    data_delimeter = list('\r\n\r\n')
//
//    init(name: String, endpoint: URL) {
//
//        self.name = name
//        self.endpoint = endpoint
//
//        self.websocket = WebSocket
//
////        self.loop = loop
////        self.buf = list()
////        LOCAL_TRANSPORT_LIST[self.endpoint.uri] = self
//    }
//
//    func start(self, *a, **kw) {
//        super(LocalTransport, self).start(*a, **kw)
//
//        self.rsock, self.wsock = socketpair()
//
//        conn = self.loop.create_connection(LocalTransportProtocol, sock=self.rsock)
//        _, self.protocol = self.loop.run_until_complete(conn)
//        self.protocol.data_received = self.data_receive
//
//        return
//    }
//
//    func data_receive(self, data) {
//        self.receive(data.decode())
//
//        return
//    }
//
//    func receive(self, data) {
//        log.transport.debug('%s: received: %s', self.name, data.encode())
//
//        if '\r\n\r\n' not in data:
//            self.buf.append(data)
//
//            return
//
//        messages = list()
//        cr = list()
//        sl = self.buf
//        self.buf = list()
//        for s in data:
//            if s == self.data_delimeter[len(cr)]:
//                cr.append(s)
//
//                if self.data_delimeter == cr:
//                    messages.append(''.join(sl))
//                    cr = list()
//                    sl = list()
//
//                continue
//
//            if len(cr) > 0 and s != self.data_delimeter[len(cr)]:
//                s = ''.join(cr) + s
//                cr = list()
//
//            sl.append(s)
//
//        if len(sl) > 0:
//            self.buf.extend(sl)
//
//        self.message_received_callback(messages)
//
//        return
//    }
//
//    func write(self, data) {
//        log.transport.debug('%s: wrote: %s', self.name, data.encode())
//
//        return self.wsock.send(data.encode())
//    }
//
//    func send(self, endpoint, data) {
//        assert isinstance(endpoint, Endpoint)
//
//        log.transport.debug('%s: send: %s', self.name, data.strip().encode())
//
//        LOCAL_TRANSPORT_LIST[endpoint.uri].write(data)
//
//        return
//    }
}
//
//class BaseServer:
//    name = None
//    transport_class = None
//    transport = None
//
//    func __init__(self, name, transport):
//        self.name = name
//        self.transport = transport
//
//    func __str__(self):
//        return '<Server: name=%(name)s>' % self.__dict__
//
//    func start(self):
//        log.server.debug('%s: trying to start server', self.name)
//
//        self.transport.start(
//            message_received_callback=self.message_receive,
//        )
//
//        log.server.debug('%s: server started', self.name)
//
//        return
//
//    func message_receive(self, data_list):
//        log.server.debug('%s: received: %s', self.name, data_list)
