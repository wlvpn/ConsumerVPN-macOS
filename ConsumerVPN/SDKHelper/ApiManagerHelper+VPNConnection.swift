//
//  ApiManagerHelper+VPNConnection.swift
//  ConsumerVPN
//
//  Created by Jaydeep Vyas on 28/05/24.
//  Copyright © 2024 WLVPN. All rights reserved.
//

import Foundation

//MARK: VPN Connection
extension ApiManagerHelper {
    
    func isConnectedToVPN() -> Bool {
        return apiManager.isConnectedToVPN()
    }
    
    func isVPNConnectionInProgress() -> Bool {
        return apiManager.isConnectingToVPN() || apiManager.isDisconnectingFromVPN()
    }
    
    func isDisconnectingFromVPN() -> Bool {
        return apiManager.isDisconnectingFromVPN()
    }
    
    func isConnectingToVPN() -> Bool {
        return apiManager.isConnectingToVPN()
    }
    
    func getVPNConnectionStatus() -> VPNConnectionStatus {
        return apiManager.connectionStatus
    }
    
    func connect() {
        if isVPNConnectionInProgress()  {
            debugPrint("[ConsumerVPN] Connection in progresss")
            
        } else {
            apiManager.connect()
        }
        
    }
    
    func disconnect() {
        if isVPNConnectionInProgress()  {
            debugPrint("[ConsumerVPN] Connection in progresss")
            
        } else {
            apiManager.disconnect()
        }
    }
    
    func disconnectOnAppTerminate() {
        if !apiManager.vpnConfiguration.stayConnectedOnQuit {
            if apiManager.isConnectedToVPN() {
                if let ondemandConfiguration = vpnConfiguration?.onDemandConfiguration,
                    ondemandConfiguration.enabled {
                    ondemandConfiguration.enabled = false
                }
                
                apiManager.disconnect()
            }
            
            apiManager.cleanup()
        }
    }
    
}

//MARK: VpnConnection Status Reporting
extension ApiManagerHelper: VPNConnectionStatusReporting {
    
    func statusConnectionSucceeded(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function): \(notification)")
        guard let vpnConfiguration = vpnConfiguration else {
            return
        }
        
        /*// if autobalancing is on, reset the vpn config to nil in those areas
        if vpnConfiguration.usingAutoselectedCity {
            vpnConfiguration.city = nil
        }*/
    }
    
    func statusConnectionDidDisconnect(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function): \(notification)")
    }
    
    func statusConnectionFailed(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function): \(notification)")
        
        if let error = notification.object as? NSError {
            debugPrint("[ConsumerVPN] Connection Failed with Error - \(error.localizedDescription)")
            if error.code == VPNKitConfigurationRuntimeError.systemExtensionNotInstalled.rawValue {
                self.apiManager.installSystemExtension()
                
            }
        }
    }
    
    func statusConnectionWillBegin(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function): \(notification)")
    }
    
    func statusConnectionWillDisconnect(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function): \(notification)")
    }
    
}
