//
//  ApiManagerHelper+VPNConfiguration.swift
//  ConsumerVPN
//
//  Created by Jaydeep Vyas on 28/05/24.
//  Copyright © 2024 WLVPN. All rights reserved.
//

import Foundation
import VPNKit

//MARK: VPN Configuration Update

extension ApiManagerHelper {
    
    var selectedProtocol: VPNProtocol { vpnConfiguration?.selectedProtocol ?? .wireGuard   }
    
    var isOnDemandEnabled: Bool { vpnConfiguration?.onDemandConfiguration?.enabled ?? false }
    
    var isKillSwitchOn: Bool { return vpnConfiguration?.isKillSwitchEnabled ?? false }
    
    func synchronizeConfiguration(completion: ((_ success: Bool) -> Void)? = nil) {
        guard apiManager.isActiveUser else {
            completion?(false)
            return
        }
        
        var error:NSError? = nil
        if apiManager.canSynchronizeConfiguration(&error) {
            apiManager.synchronizeConfiguration { success in
                completion?(success)
            }
        } else  {
            debugPrint("Failed to synchronize configuration: \(error?.localizedDescription ?? "")")
            completion?(false)
        }
    }
    
    func synchronizeConfiguration() async -> Bool {
        guard apiManager.isActiveUser else {
            return false
        }
        var error:NSError? = nil
        if apiManager.canSynchronizeConfiguration(&error) {
            return await apiManager.synchronizeConfiguration()
        } else  {
            debugPrint("Failed to synchronize configuration: \(error?.localizedDescription ?? "")")
            return false
        }
        
    }

    
    func isSafeToChangeConfiguration() -> Bool {
        return !(apiManager.isConnectedToVPN() || apiManager.isConnectingToVPN() || apiManager.isDisconnectingFromVPN())
    }
    
    func switchProtocol(index:Int) {
        guard let vpnConfiguration = vpnConfiguration else { return }
        if isSafeToChangeConfiguration() {
            switch index {
            case 0:
                vpnConfiguration.selectedProtocol = VPNProtocol.wireGuard
                
                break
            case 1:
                vpnConfiguration.selectedProtocol = VPNProtocol.ikEv2
                break
            case 2:
                vpnConfiguration.selectedProtocol = VPNProtocol.ipSec
                break
            case 3:
                vpnConfiguration.selectedProtocol = VPNProtocol.openVPN
                break
            default:
                break
            }
            
        } else {
            debugPrint("[ConsumerVPN] VPN Is connected, you can't change kill switch")
        }
    }
    
    func toggleKillSwitch(enable:Bool) {
        guard let vpnConfiguration = vpnConfiguration else { return }
        if isSafeToChangeConfiguration() {
            vpnConfiguration.isKillSwitchEnabled = enable
            if vpnConfiguration.selectedProtocol == .openVPN {
                self.synchronizeConfiguration()
            }
        } else {
            debugPrint("[ConsumerVPN]  VPN Is connected, you can't change kill switch")
        }
    }
    
    //Update ondemand configuration without calling synchronization
    func setOnDemand(enable:Bool) {
        
        if (!self.isVPNConnectionInProgress()) {
            guard let onDemand = vpnConfiguration?.onDemandConfiguration else {
                return
            }
            onDemand.enabled = enable
        }
        
    }
    
    func toggleOnDemand(enable:Bool, reconnect:Bool = false) {
        
        if (!self.isVPNConnectionInProgress()) {
            guard let onDemand = vpnConfiguration?.onDemandConfiguration else {
                if reconnect {
                    self.connect()
                }
                return
            }
            onDemand.enabled = enable
            if reconnect {
                if enable {
                    self.synchronizeConfiguration()
                } else {
                    self.connect()
                }
            } else {
                self.synchronizeConfiguration()
            }
        }
    }
    
    func getCurrentLocationString() -> String {
        return vpnConfiguration?.currentLocation?.location() ?? NSLocalizedString("IPAddressError", comment: "IP Address Error")
    }
    
    func getCurrentIPLocationString() -> String {
        
        if let assignedIpAddress = vpnConfiguration?.currentLocation?.ipAddress {
            return assignedIpAddress
        } else {
            var ipAddress = NSLocalizedString("IPAddressError", comment: "IP Address Error")
            if let serverIpAddress = vpnConfiguration?.server?.ipAddress, apiManager.isConnectedToVPN() {
                ipAddress =  serverIpAddress
            }
            return  ipAddress
        }
    }
    
    func getCityLocationString() -> String {
        if let assignedCity = vpnConfiguration?.city {
            return  assignedCity.locationString()
        } else {
            return  NSLocalizedString("FastestAvailable", comment: "Fastest Available Text")
        }
    }
    
    func selectServerWith(country: Country?) {
        if let country = country {
            self.vpnConfiguration?.server = nil
            self.vpnConfiguration?.city = nil
            self.vpnConfiguration?.country = country
        } else {
            resetServer()
        }
    }
    
    func selectServerWith(city: City?) {
        if let city = city {
            self.vpnConfiguration?.server = nil
            self.vpnConfiguration?.setCityAndCountry(city)
        } else {
            resetServer()
        }
    }
    
    func setServer(_ server:Server?) {
        vpnConfiguration?.server = server
    }
    
    func setCoutnry(_ country:Country?) {
        vpnConfiguration?.country = country
    }
    
    func setCity(_ city: City?) {
        vpnConfiguration?.city = city
    }
    
    func getCity() -> City? {
        return vpnConfiguration?.city
    }
    
    func resetServer() {
        self.vpnConfiguration?.server = nil
        self.vpnConfiguration?.city = nil
        self.vpnConfiguration?.country = nil
    }
    
    func getCityDisplayString() -> String {
        var displayString = ""
        
        if let vpnConfiguration = vpnConfiguration {
            if let city = vpnConfiguration.city,
               let cityName = city.name {
                displayString.append(cityName + ", ")
            }
            if let country = vpnConfiguration.country,
               let countryName = country.name {
                displayString.append(countryName)
            }
            if vpnConfiguration.city == nil,
               vpnConfiguration.country == nil {
                displayString = NSLocalizedString("FastestAvailable", comment: "")
            }
        }
        
        return displayString
    }
    
    //MARK: OpenVPN configuration setup
    
    func getOpenVPNPort() -> String {
        return vpnConfiguration?.openVPNSettings.port.description ?? "443"
    }

    func updateOpenVPNPort(_ port: UInt) {
        vpnConfiguration?.openVPNSettings.port = port
    }
    
    func setOpenVPNType(_ type: String?) {
        guard let vpnConfiguration = vpnConfiguration else {return}
        switch type {
        case "UDP":
            vpnConfiguration.openVPNSettings.protocol = .UDP
        case "TCP":
            vpnConfiguration.openVPNSettings.protocol = .TCP
        default:
            break
        }
        vpnConfiguration.selectedProtocol = .openVPN
        self.synchronizeConfiguration()
    }
    
    func getOpenVPNType() -> String {
        return (vpnConfiguration?.openVPNSettings.protocol == .UDP) ? "udp" : "tcp"
    }
    
    func getOpenVPNScrambled() -> Int {
        vpnConfiguration?.openVPNSettings.scramble == true ? 1 : 0
    }
    
    func setOpenVPNScrambled(_ scramble: Int?) {
        vpnConfiguration?.openVPNSettings.scramble = scramble ?? 0 == 1
    }
    
    func getOpenVPNIPLeakProtection() -> Int {
        vpnConfiguration?.openVPNSettings.ipv6LeakProtection == true ? 1 : 0
    }
    
    func setOpenVPNIPLeakProtection(_ enabled: Int?) {
        vpnConfiguration?.openVPNSettings.ipv6LeakProtection = enabled ?? 0 == 1
    }
    
    func fetchCities() -> [City] {
        guard let cities = apiManager.fetchAllCities() as? [City], cities.count > 0 else {
            return []
        }
        return cities
    }
    
    func fetchCountries() -> [Country] {
        guard let countries = apiManager.fetchAllCountries() as? [Country], countries.count > 0 else {
            return []
        }
        return countries
    }
    
}

extension ApiManagerHelper: VPNConfigurationStatusReporting {
    
    func statusCurrentProtocolDidChange(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        self.synchronizeConfiguration  { [weak self] success in
            guard let self = self else {return}
            if self.selectedProtocol == .wireGuard ||  self.selectedProtocol == .openVPN {
                if #available(macOS 15.1, *) {
                    let status = systemExtensionStatus()

                    // If not installed or failed, try to install
                    if status == .uninstalled || status == .failed || status == .unknown {
                        ApiManagerHelper.shared.installSystemExtension()
                        return
                    }

                   
                } else {
                    // Fallback for earlier macOS versions
                    if !systemExtensionInstalled() {
                        installSystemExtension()
                        return
                    }
                }
            }
        }
        
    }

    func isOpenVPNHelperInstalled() -> Bool {
        if #available(macOS 15.1, *) {
            return systemExtensionStatus() == .installed
        } else {
            return systemExtensionInstalled()
        }
    }
    
    func updateConfigurationBegin(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
    }
    
    func updateConfigurationFailed(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
    }
    
    func updateConfigurationSucceeded(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
    }
    
}
