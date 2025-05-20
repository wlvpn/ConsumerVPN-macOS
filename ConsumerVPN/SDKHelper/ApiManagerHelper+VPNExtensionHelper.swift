//
//  ApiManagerHelper+VPNExtensionHelper.swift
//  ConsumerVPN
//
//  Created by Jaydeep Vyas on 28/05/24.
//  Copyright © 2024 WLVPN. All rights reserved.
//

import Foundation
import VPNKit
import VPNHelperAdapter

//MARK: VPN Helper status Reporting
extension ApiManagerHelper: VPNHelperStatusReporting {
    
    func uninstallSystemExtension() {
        apiManager.uninstallSystemExtension()
    }
    
    func installSystemExtension() {
        apiManager.installSystemExtension()
    }
    
    func installPrivilegedHelper() {
        apiManager.installPrivilegedHelper()
    }
    
    func getCurrentHelperStatus() -> VPNConnectionStatus {
        return self.apiManager.helperStatus
    }
    
    func installWgSystemExtensionIfRequired(pendingForApproval:(Bool) -> Void) {
        
        if !apiManager.systemExtensionInstalled() {
            installSystemExtension()
            pendingForApproval(false)
            return
        }
        
        if apiManager.systemExtensionApprovalPending() {
            // Show alert that user has to approve system extension from Settings mac app
            pendingForApproval(true)
            return
        }
        
        pendingForApproval(false)
    }
    
    
    
    func statusHelperInstallSuccess(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        // Note: Success handled at ConnectionManager
        guard let vpnConfiguration = vpnConfiguration else {return}
        
        if vpnConfiguration.selectedProtocol == .openVPN_TCP
            || vpnConfiguration.selectedProtocol == .openVPN_UDP {
            self.installedStatusForOpenVPN = .installed
        }
        
        if vpnConfiguration.selectedProtocol == .wireGuard {
            self.installedStatusForWG = .installed
        }
    }
    
    func statusHelperInstallPending(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        guard let vpnConfiguration = vpnConfiguration else {return}
        
        if vpnConfiguration.selectedProtocol == .openVPN_TCP
            || vpnConfiguration.selectedProtocol == .openVPN_UDP {
            self.installedStatusForOpenVPN = .installing
            
        }
        
        if vpnConfiguration.selectedProtocol == .wireGuard {
            self.installedStatusForWG = .installing
        }
    }
    
    func statusHelperInstallFailed(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        guard let vpnConfiguration = vpnConfiguration else {return}
        
        if vpnConfiguration.selectedProtocol == .openVPN_TCP
            || vpnConfiguration.selectedProtocol == .openVPN_UDP {
            self.installedStatusForOpenVPN = .failed
        }
        
        if vpnConfiguration.selectedProtocol == .wireGuard {
            self.installedStatusForWG = .failed
        }
    }
}
