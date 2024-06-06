//
//  ApiManagerHelper.swift
//  ConsumerVPN
//
//  Created by Jaydeep Vyas on 23/05/24.
//  Copyright © 2024 NetProtect. All rights reserved.
//

import Foundation
import VPNKit
import VPNHelperAdapter

/// `ApiManagerHelper` is a singleton class responsible for managing VPN API operations such as login, checking network reachability, refreshing location, handling VPN disconnection, and setting encryption.
class ApiManagerHelper: NSObject {
    
    var installedStatusForOpenVPN: OpenVPNHelperInstallStatus = .unknown
    var installedStatusForWG: OpenVPNHelperInstallStatus = .unknown
    
    /// The instance of `VPNAPIManager` used to perform API operations.
    var apiManager: VPNAPIManager
    
    var vpnConfiguration: VPNConfiguration?
    
    /// The shared singleton instance of `ApiManagerHelper`.
    static let shared = ApiManagerHelper()
    let privilegedHelperManager = VPNPrivilegedHelperManager(helperName: Theme.openVPNToolBundleId, andBrandName: Theme.brandName)
    /// Private initializer to ensure the singleton pattern.
    private override init() {
        self.apiManager =  SDKInitializer().initializeAPIManager(
            withBrandName: Theme.brandName,
            configName: Theme.configurationName,
            apiKey: Theme.apiKey,
            suffix: Theme.usernameSuffix,
            priviligedHelper: privilegedHelperManager!
        )
        self.vpnConfiguration = self.apiManager.vpnConfiguration
        super.init()
        NotificationCenter.default.addObserver(for: self)
    }
    
    /// Sets the default encryption to 256-bit AES if no encryption is already set.
    func setDefaultEncryption() {
        if vpnConfiguration?.hasOption(forKey: kIKEv2Encryption) == false {
            vpnConfiguration?.setOption(kVPNEncryptionAES256, forKey: kIKEv2Encryption)
        }
    }
    
    func loginWithRetry(forUsername: String, password: String) {
        apiManager.loginWithRetry(forUsername: forUsername, password: password)
    }
    
    func loginWith(forUsername username: String, password: String) {
        apiManager.login(withUsername: username, password: password)
    }
    
    func loginWith(accessToken: String, refreshToken: String) {
        apiManager.login(withAccessToken: accessToken, refeshToken: refreshToken)
    }
    
    func isUserLogin() -> Bool {
        return apiManager.isLoggedIn()
    }
    
    func isUserActive() -> Bool {
        return apiManager.isActiveUser
    }
    
    //Check if valid user, but password is nil, log them out.
    func checkValidPassword() {
        
        if let _ = vpnConfiguration?.user , vpnConfiguration?.user?.password == nil {
            apiManager.logout()
        }
    }
    
    func isNetworkReachable() -> Bool {
        return apiManager.networkIsReachable
    }
    
    func logout() {
        self.resetOnLogout()
        apiManager.logout()
    }
    
    func refreshLocation() async throws {
        do {
            let location = try await apiManager.refreshLocation()
            // Process location if needed
        } catch {
            throw error
        }
    }

    func refreshServer() async -> Bool {
        guard apiManager.networkIsReachable else {
            return false
        }
        let success =  await apiManager.updateServerList()
        return success
    }
    
    /// Refreshes the location and calls the completion handler with the result.
    /// - Parameter completion: A closure called with a boolean indicating success or failure.
    func refreshLocation(_ completion: ((_ success: Bool) -> Void)? = nil) {
        apiManager.refreshLocation(completion: { location, error in
            completion?(error == nil)
        })
    }

    
    func refreshServer(_ completion: ((Bool, Error?) -> Void)? = nil) {
        // Refresh Servers
        // 1) If the network is reachable,
        // a) Refresh the servers if it has been more than 5 minutes since the last successful update OR
        // b) Inform the user the servers are already up to date, otherwise
        // 2) Tell the user to change their network settings
        if apiManager.networkIsReachable {
            // Has it been more than 5 minutes (300 seconds) since the last successful update?
            apiManager.updateServerList { success in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return  }
                    if success {
                        completion?(true,nil)
                    } else {
                        if apiManager.networkIsReachable { // Contact Support
                            let error = NSError(domain: "com.consumervpn.ios", code: 0 , userInfo: [
                                NSLocalizedDescriptionKey: "Server Update Failed"
                            ])
                            completion?(false,error)
                        } else {
                            completion?(false,nil)
                        }
                    }
                }
            }
        } else {
            completion?(false,nil)
        }
    }
    
    private func resetOnLogout() {
        UserDefaults.standard.set(false, forKey: WLDoNotAutomaticallyConnect)
        UserDefaults.standard.set(false, forKey: WLConnectToLastConnectedServer)
        UserDefaults.standard.set(false, forKey: WLConnectToFastestServer)
        UserDefaults.standard.set(false, forKey: WLConnectToFastestServerInCountry)
        UserDefaults.standard.set(false, forKey: WLHideOnAppLaunch)
        UserDefaults.standard.synchronize()
    }
}
