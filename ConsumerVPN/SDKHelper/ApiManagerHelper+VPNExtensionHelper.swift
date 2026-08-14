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
        
        
        
        apiManager.synchronizeConfiguration() { [weak self] success in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async { [weak strongSelf] in
                
                guard let strongSelf = strongSelf, let vpnConfiguration =  strongSelf.vpnConfiguration else {
                    return
                }
               
                switch vpnConfiguration.selectedProtocol {
                case .wireGuard:
                    strongSelf.installedStatusForWG = .installed
                    
                case .openVPN:
                    strongSelf.installedStatusForOpenVPN = .installed
                    
                default: break
                }
            }
            
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
        guard let vpnConfiguration = vpnConfiguration else {return}
        
        if vpnConfiguration.selectedProtocol == .openVPN {
            self.installedStatusForOpenVPN = .failed
        }
        
        if vpnConfiguration.selectedProtocol == .wireGuard {
            self.installedStatusForWG = .failed
        }
    }
}
