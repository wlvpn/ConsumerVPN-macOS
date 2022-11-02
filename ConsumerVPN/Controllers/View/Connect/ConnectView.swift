//
//  ConnectView.swift
//  Consumer VPN
//
//  Created by Jonathan Fuentes on 8/15/19.
//  Copyright © 2019 WLVPN. All rights reserved.
//

import Cocoa

protocol ConnectViewDelegate : AnyObject {
    func didSelectConnect()
    func didSelectChooseLocation()
}

class ConnectView: ColorView, UIViewFadeAnimation, VPNStatusReporting {

    @objc var apiManager : VPNAPIManager!
    @objc var vpnConfiguration : VPNConfiguration?
	
    @IBOutlet weak var shieldView: ShieldView!
    @IBOutlet weak var locationTitleLabel: NSTextField!
    @IBOutlet weak var locationNameLabel: NSTextField!
    @IBOutlet weak var contentView: GradientView!
    @IBOutlet weak var vpnConnectButton: CustomButton!
    @IBOutlet weak var serverLocationButton: CustomButton!
    
    fileprivate var shouldConnectAtStartUp = false

    weak var delegate: ConnectViewDelegate?
    var animatableViews: [NSView] = []
    
    class func newInstance() -> ConnectView {
        var connectView:ConnectView?
        var topLevelObjects : NSArray?
        if Bundle.main.loadNibNamed("ConnectView", owner: self, topLevelObjects: &topLevelObjects) {
            connectView = topLevelObjects!.first(where: { $0 is ConnectView }) as? ConnectView
        }
        
        connectView!.animatableViews = [connectView!.vpnConnectButton, connectView!.serverLocationButton]
		
		NotificationCenter.default.addObserver(for: connectView!)
        
        return connectView!
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        themeView()
        setTouchBarItems()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(for: self)
    }
    
    /// Prepares the view properties for initial load.
    fileprivate func themeView() {
        
        //Views we are going to perform alpha/opacity animations on.
        animatableViews = [vpnConnectButton, serverLocationButton]
        
        contentView.topColor    = NSColor.connectViewBackground
        contentView.bottomColor = NSColor.connectViewBackground
        
        // Server Select Button
        locationTitleLabel.textColor  = NSColor.connectViewText
        locationNameLabel.textColor   = NSColor.serverSelectText
        locationTitleLabel.stringValue = NSLocalizedString("LocationSelected", comment: "")
        
        // Connect Button
        vpnConnectButton.backgroundColor = NSColor.connectButton
        vpnConnectButton.borderColor     = NSColor.connectButton
        vpnConnectButton.textColor       = NSColor.connectButtonText
        vpnConnectButton.setAccessibilityIdentifier("Connect Button")
        
        // Server Location Button
        serverLocationButton.backgroundColor    = NSColor.serverLocationButton
        serverLocationButton.borderColor        = NSColor.serverLocationButton
        serverLocationButton.textColor          = NSColor.connectButtonText
        serverLocationButton.buttonText         = NSLocalizedString("ServerLocations", comment: "Server Locations")
        serverLocationButton.setAccessibilityIdentifier("Server Locations")
    }
    
    /// Locks or disables various UI elements or changes the appearance to
    /// look like they are disabled.
    ///
    /// - Parameter isEnabled: true if if the controls should be user interactable
    /// false if they should not be interacted with.
    func toggleUIForEnabledState(isEnabled : Bool) {
		
		serverLocationButton.isClickable = isEnabled
        vpnConnectButton.isClickable = isEnabled
    }
    
    // MARK: - IBOutlets
    
    @IBAction func didSelectConnectButton(_ sender: Any) {
        delegate?.didSelectConnect()
    }
    
    @IBAction func didSelectChooseLocation(_ sender: Any) {
        delegate?.didSelectChooseLocation()
    }
    
    func setTouchBarItems() {
        if #available(OSX 10.12.2, *) {
            customBarItems = [NSTouchBarItem.Identifier.flexibleSpace,
                              NSTouchBarItem.Identifier.preferencesItem,
                              NSTouchBarItem.Identifier.fixedSpaceSmall,
                              NSTouchBarItem.Identifier.serverSelectionItem,
                              NSTouchBarItem.Identifier.fixedSpaceSmall,
                              NSTouchBarItem.Identifier.connectItem,
                              NSTouchBarItem.Identifier.flexibleSpace]
        }
    }
}


//MARK: - VPN Server Status Reporting Conformance

extension ConnectView : VPNServerStatusReporting {
    
    func statusServerUpdateWillBegin(_ notification: Notification) {
        toggleUIForEnabledState(isEnabled: false)
        vpnConnectButton.buttonText = NSLocalizedString("UpdatingServers", comment: "UpdatingServers")
    }
    
    func statusServerUpdateFailed(_ notification: Notification) {
        toggleUIForEnabledState(isEnabled: true)
        vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
    }
    
    func statusServerUpdateSucceeded(_ notification: Notification) {
        toggleUIForEnabledState(isEnabled: true)
        vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
    }
    
    func statusInitialServerUpdateWillBegin(_ notification: Notification) {
        toggleUIForEnabledState(isEnabled: false)
        vpnConnectButton.buttonText = NSLocalizedString("LoadingInitialServers", comment: "LoadingInitialServers")
    }
    
    func statusInitialServerUpdateFailed(_ notification: Notification) {
        vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
        toggleUIForEnabledState(isEnabled: true)
    }
    
    func statusInitialServerUpdateSucceeded(_ notification: Notification) {
        if let servers = notification.object as? [Server] {
            
            //Sorts by country name descending and by city name ascending.
            let sortedServers = servers.sorted {
                if $0.countryName == $1.countryName {
                    return $0.cityName! < $1.cityName!
                } else {
                    return $0.countryName! > $1.countryName!
                }
            }
            
            if let selectedServer = sortedServers.filter({$0.countryName == "US"}).first {
				self.vpnConfiguration?.setCityAndCountry(selectedServer.city)
            } else {
                //Couldn't find US, just set to whatever is first in the sorted servers array.
                self.vpnConfiguration?.setCityAndCountry(sortedServers.first?.city)
            }
            
            self.vpnConfiguration?.selectedProtocol = VPNProtocol.ikEv2
            
            self.apiManager.updateServerList()
            
            //Slight intentional delay here purely for UX reasons.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
                self.toggleUIForEnabledState(isEnabled: true)
            }
        }
    }
}

extension ConnectView: VPNAccountStatusReporting {
    func statusLoginServerUpdateWillBegin(_ notification: Notification) {
        toggleUIForEnabledState(isEnabled: false)
        vpnConnectButton.buttonText = NSLocalizedString("UpdatingServers", comment: "UpdatingServers")
    }
    
    func statusLoginServerUpdateSucceeded(_ notification: Notification) {
        if let servers = notification.object as? [Server] {
            
            //Sorts by country name descending and by city name ascending.
            let sortedServers = servers.sorted {
                if $0.countryName == $1.countryName {
                    return $0.cityName! < $1.cityName!
                } else {
                    return $0.countryName! > $1.countryName!
                }
            }
            
            if let selectedServer = sortedServers.filter({$0.countryName == "US"}).first {
                self.vpnConfiguration?.setCityAndCountry(selectedServer.city)
            } else {
                //Couldn't find US, just set to whatever is first in the sorted servers array.
                self.vpnConfiguration?.setCityAndCountry(sortedServers.first?.city)
            }
            
            self.vpnConfiguration?.selectedProtocol = VPNProtocol.ikEv2
            
            self.apiManager.updateServerList()
            
            //Slight intentional delay here purely for UX reasons.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
                self.toggleUIForEnabledState(isEnabled: true)
            }
        }
    }
    
    func statusLoginServerUpdateFailed(_ notification: Notification) {
        toggleUIForEnabledState(isEnabled: true)
        vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
    }
}
