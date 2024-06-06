//
//  PacketTunnelProvider.swift
//  WireGuardNetworkExtension
//
//  Created by Javier Hernández on 11/11/22.
//  Copyright © 2022 WLVPN. All rights reserved.
//

import NetworkExtension
import VPKWireGuardExtension

class PacketTunnelProvider: WGPacketTunnelProvider {
    
    override init() {
        super.init()
        /*
         Uncomment the following code block to enable traffic monitoring:
         
         // Enable reading packets, must override vpnDidReceiveTrafficDataCounter method if it is enabled.
         self.allowReadPackets = true
         
         // Set the threshold for monitoring downloaded bytes during each interval
         self.readThreshold = UInt64(6_000_000)  // Value in bytes
         
         // Set the threshold for monitoring uploaded bytes during each interval
         self.writeThreshold = UInt64(3_000_000)  // Value in bytes
         
         // Set the time interval in minutes; invoke vpnDidReceiveTrafficDataCounter every interval if the given threshold matches
         self.readPacketTimeInterval = 2  // Value in minutes
         */

    }
    
    override func vpnDidReceiveTrafficDataCounter(_ counter: TrafficCounter) {
        debugPrint("\(#function) Read: \(counter.read) and Write:\(counter.write)")
    }
    
}
