//
//  ApiManagerHelper+VPNExtensionHelper.swift
//  ConsumerVPN
//
//  Created by Jaydeep Vyas on 28/05/24.
//  Copyright © 2024 WLVPN. All rights reserved.
//

import Foundation
import VPNKit

//MARK: VPN Helper status Reporting
extension ApiManagerHelper: VPNHelperStatusReporting {
    
    func getCurrentHelperStatus() -> VPNConnectionStatus {
        return self.apiManager.connectionStatus
    }

    func statusHelperInstallSuccess(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        // Note: Success handled at ConnectionManager
        DispatchQueue.main.async { [weak self] in
            guard let self  else { return }
            if let vpnConfiguration = self.vpnConfiguration {
                switch vpnConfiguration.selectedProtocol {
                case .wireGuard:
                    self.installedStatusForWG = .installed
                case .openVPN:
                    self.installedStatusForOpenVPN = .installed
                default: break
                }
            }
            self.finishPendingSystemExtensionConnection(installationSucceeded: true)
        }
        
    }
    
    func statusHelperInstallPending(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        guard let vpnConfiguration = vpnConfiguration else {return}
        
        if vpnConfiguration.selectedProtocol == .openVPN {
            self.installedStatusForOpenVPN = .pending
            
        }
        
        if vpnConfiguration.selectedProtocol == .wireGuard {
            self.installedStatusForWG = .pending
        }
    }
    
    func statusHelperInstallFailed(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        finishPendingSystemExtensionConnection(installationSucceeded: false)

        guard let vpnConfiguration = vpnConfiguration else {return}
        
        if vpnConfiguration.selectedProtocol == .openVPN {
            self.installedStatusForOpenVPN = .failed
        }
        
        if vpnConfiguration.selectedProtocol == .wireGuard {
            self.installedStatusForWG = .failed
        }
    }
}
