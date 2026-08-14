//
//  PacketTunnelProvider.swift
//  OpenVPNNetworkExtension
//
//  Created by Javier Hernandez on 10/10/25.
//  Copyright © 2025 WLVPN. All rights reserved.
//

import NetworkExtension
import VPKOpenVPNNetworkExtension

class PacketTunnelProvider: OVPacketTunnelProvider {
    
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
    
    public override func vpnHandshakeUpdateDetected(_ error: Error?) {
        debugPrint("[OpenVPN-NE] \(#function): \(error?.localizedDescription ?? "no error")")
        debugPrint("[OpenVPN-NE] Internet Status: \(self.isInternetAvailable) Last Handshake Date: \(self.lastHandshakeDate)")
        debugPrint("[OpenVPN-NE] isKillSwitchEnabled: \(self.isKillSwitchEnabled) isOnDemandEnabled:\(self.isOnDemandEnabled)")
    }
}
