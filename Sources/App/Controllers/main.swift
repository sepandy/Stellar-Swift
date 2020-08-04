//
//  main.swift
//  Stellar
//
//  Created by Sepand Yadollahifar on 7/22/20.
//  Copyright © 2020 Its3p. All rights reserved.
//

import Foundation

let quorum0 = Quorum(threshold: 80, validators: [])
let quorum1 = Quorum(threshold: 80, validators: [])

let client0 = Node(name: "client 0 ", endpoint: URL(string: "sock://memory:0"), quorum: quorum0)
let client1 = Node(name: "client 1 ", endpoint: URL(string: "sock://memory:1"), quorum: quorum1)

let nodes = [client0.name: client0, client1.name: client1]

quorum0.validators.append(client1)
quorum1.validators.append(client0)





let quorums = [client0.name: quorum0, client1.name: quorum1]

let consensus0 = Consensus(name: "consensus0", node: client0, quorum: quorum0)
let consensus1 = Consensus(name: "consensus1", node: client1, quorum: quorum1)
//    nodes = dict()
//    transports = dict()
//    consensuses = dict()
//    servers = dict()
//
//    loop = asyncio.get_event_loop()
//
//    for name, config in nodes_config.items():
//        nodes[name] = Node(name, config.endpoint, quorums[name])
//        log.main.debug('nodes created: %s', nodes)
//
//        transports[name] = LocalTransport(name, config.endpoint, loop)
//        log.main.debug('transports created: %s', transports)
//
//
//        consensuses[name] = TestConsensus(nodes[name], quorums[name], transports[name])
//        log.main.debug('consensuses created: %s', consensuses)
//
//        servers[name] = Server(nodes[name], consensuses[name], name, transport=transports[name])
//        log.main.debug('servers created: %s', servers)
//
//    for server in servers.values():
//        server.start()
//
//    # send message to `server0`
//    MESSAGE = Message.new(uuid1().hex)
//    servers['n0'].transport.send(nodes['n0'].endpoint, MESSAGE.serialize(client0_node))
//    log.main.info('inject message %s -> n0: %s', client0_node.name, MESSAGE)
//
//    try:
//        loop.run_forever()
//    except (KeyboardInterrupt, SystemExit):
//        log.main.debug('goodbye~')
//        sys.exit(1)
//    finally:
//        loop.close()
