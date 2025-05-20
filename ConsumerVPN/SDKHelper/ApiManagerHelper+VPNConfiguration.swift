//
//  ApiManagerHelper+VPNConfiguration.swift
//  ConsumerVPN
//
//  Created by Jaydeep Vyas on 28/05/24.
//  Copyright © 2024 WLVPN. All rights reserved.
//

import Foundation
import VPNKit
import VPNHelperAdapter

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
                vpnConfiguration.selectedProtocol = VPNProtocol.openVPN_TCP
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
            if vpnConfiguration.selectedProtocol == .openVPN_TCP
                || vpnConfiguration.selectedProtocol == .openVPN_UDP {
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
    
    func setOpenVPNPort(_ port: String?) {
        vpnConfiguration?.setOption(port, forKey: kOpenVPNPort)
    }
    
    func getOpenVPNPort() -> String {
        return (vpnConfiguration?.getOptionForKey(kOpenVPNPort) as? String) ?? "443"
    }
    
    func setOpenVPNType(_ type: String?) {
        guard let vpnConfiguration = vpnConfiguration else {return}
        switch type {
        case "UDP":
            vpnConfiguration.selectedProtocol = .openVPN_UDP
            vpnConfiguration.setOption("udp", forKey: kOpenVPNProtocol)
        case "TCP":
            vpnConfiguration.selectedProtocol = .openVPN_TCP
            vpnConfiguration.setOption("tcp", forKey: kOpenVPNProtocol)
        default:
            break
        }
        self.synchronizeConfiguration()
    }
    
    func getOpenVPNType() -> String {
        return (vpnConfiguration?.getOptionForKey(kOpenVPNProtocol) as? String) ?? "udp"
    }
    
    func getOpenVPNScrambled() -> Int {
        return (vpnConfiguration?.getOptionForKey(kOpenVPNScrambleEnabled) as? Int) ?? 0
    }
    
    func setOpenVPNScrambled(_ scramble: Int?) {
        vpnConfiguration?.setOption(scramble, forKey: kOpenVPNScrambleEnabled)
        self.synchronizeConfiguration()
    }
    
    func getOpenVPNIPLeackPrototection() -> Int {
        return (vpnConfiguration?.getOptionForKey(kVPNHelperIPV6LeakProtection) as? Int) ?? 0
        
    }
    
    func setOpenVPNIPLeackPrototection(_ enabled: Int?) {
        vpnConfiguration?.setOption(enabled, forKey: kVPNHelperIPV6LeakProtection)
        self.synchronizeConfiguration()
    }
    
    func resetDns() {
        ApiManagerHelper.shared.privilegedHelperManager?.resetOpenVPNDNS(with: vpnConfiguration)
    }
    
    func isOpenVPNHelperInstalled() -> Bool {
        return privilegedHelperManager?.isHelperInstalled() ?? false
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
            if self.selectedProtocol == .wireGuard &&  installedStatusForWG != .installed {
                installSystemExtension()
            } else if (self.selectedProtocol == .openVPN_TCP || self.selectedProtocol == .openVPN_UDP) &&  self.installedStatusForOpenVPN != .installed{
                installPrivilegedHelper()
            }
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
