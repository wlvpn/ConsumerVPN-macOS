//
//  ConnectViewController.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/13/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import AppKit


//MARK: - Connect View Controller Delegate

internal protocol ConnectViewControllerDelegate {
    func shouldDisplayServerViewController()
}

class ConnectViewController : BaseViewController {
    
    //MARK: - Properties
    
    internal var delegate : ConnectViewControllerDelegate?

    @IBOutlet weak var contentView : GradientView!
    @IBOutlet weak var vpnConnectButton :CustomButton!
    @IBOutlet weak var serverLocationButton: CustomButton!
    @IBOutlet weak var locationTitleLabel: NSTextField!
    @IBOutlet weak var locationNameLabel: NSTextField!
    
    fileprivate var animatableSubviews : [NSView] = []
    fileprivate var shouldConnectAtStartUp = false

    class func newWith(apiManager: VPNAPIManager) -> ConnectViewController {
        let connectStoryboard = NSStoryboard(name: "Connect", bundle: nil)
        let connectViewController = connectStoryboard.instantiateController(withIdentifier: "ConnectViewController") as! ConnectViewController

        connectViewController.apiManager = apiManager
        connectViewController.vpnConfiguration = apiManager.vpnConfiguration

        return connectViewController
    }
    
    //MARK: - View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(for: self)
        themeView()


        // Set the Server Select Text
        if let assignedCity = vpnConfiguration?.city {
            locationNameLabel.stringValue = assignedCity.locationString()
        } else {
            locationNameLabel.stringValue = NSLocalizedString("FastestAvailable", comment: "Fastest Available Text")
        }

        //Starts off disabled until initial server list and server updates succeed.
        toggleUIForEnabledState(isEnabled: false)

        evaluateGeneralPreferences()
		
        if shouldConnectAtStartUp == true {
            shouldConnectAtStartUp = false
			apiManager.connect()
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        revealUI(subviewsToAnimate: animatableSubviews)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        hideUI(viewsToHide: animatableSubviews)
    }
    
    //MARK: - Utility Methods
    
    /// Applies a fade animation to each view in the collection
    ///
    /// - Parameter subviewsToAnimate: A collection of views to perform animations on.
    fileprivate func revealUI(subviewsToAnimate : [NSView]) {
        
        let fadeInAnimation = Animations.opacityFadeAnimation(startingAlphaValue: 0.0, endingAlphaValue: 1.0, animationDuration: 0.3, animationName: "fadeIn")
        
        for subView in subviewsToAnimate {
            applyFadeAnimationTo(view: subView, endingOpacity:1.0, fadeAnimation: fadeInAnimation, animationName: "fadeIn")
        }
    }
    
    /// Hides each view in the collection
    ///
    /// - Parameter viewsToHide: A collection of views to hide.
    fileprivate func hideUI(viewsToHide : [NSView]) {
        for subView in viewsToHide {
            hideView(view: subView)
        }
    }

    /// Locks or disables various UI elements or changes the appearance to 
    /// look like they are disabled.
    ///
    /// - Parameter isEnabled: true if if the controls should be user interactable
    /// false if they should not be interacted with.
    fileprivate func toggleUIForEnabledState(isEnabled : Bool) {
        vpnConnectButton.isClickable = isEnabled
    }
    
    /// Prepares the view properties for initial load.
    fileprivate func themeView() {
        
        //Views we are going to perform alpha/opacity animations on.
        animatableSubviews = [vpnConnectButton]

        contentView.topColor    = NSColor.connectViewBackground
        contentView.bottomColor = NSColor.connectViewBackground

//        // Server Select Button
        locationNameLabel.textColor   = NSColor.serverSelectText

        // Connect Button
        vpnConnectButton.backgroundColor = NSColor.connectButton
        vpnConnectButton.borderColor     = NSColor.connectButton
        vpnConnectButton.textColor       = NSColor.connectButtonText
        vpnConnectButton.setAccessibilityIdentifier("Connect Button")
        
        // Server Location Button
        serverLocationButton.backgroundColor    = NSColor.serverLocationButton
        serverLocationButton.borderColor        = NSColor.serverLocationButton
        serverLocationButton.textColor          = NSColor.connectButtonText
        serverLocationButton.buttonText         = NSLocalizedString("Server Locations", comment: "Server Locations")
        serverLocationButton.setAccessibilityIdentifier("Server Locations")
    }
    
    /// Looks through the general preferences determining if a connection should
    /// be made at startup and modify the vpn configuration accordingly for selected
    /// preferences.
    fileprivate func evaluateGeneralPreferences() {
        
        if UserDefaults.standard.bool(forKey: WLDoNotAutomaticallyConnect) == true {
            shouldConnectAtStartUp = false
        } else {
            shouldConnectAtStartUp = true
        }
        
        if UserDefaults.standard.bool(forKey: WLConnectToFastestServer) == true {
            //Should just load balance to the fastest server for the currently assigned
            //city on the vpn configuration.
            vpnConfiguration?.server = nil
            
        } else if UserDefaults.standard.bool(forKey: WLConnectToFastestServerInCountry) == true {
            
            guard let countries = apiManager.fetchAllCountries() as? [Country] else {
                return
            }
            
            guard let selectedCountryNamePreference = UserDefaults.standard.value(forKey: WLSelectedCountry) as? String else {
                return
            }
            
            if let selectedCountryPreference = countries.filter({ $0.name?.lowercased() == selectedCountryNamePreference.lowercased() }).first {
                vpnConfiguration?.country = selectedCountryPreference
                vpnConfiguration?.city = nil
                vpnConfiguration?.server = nil
            }
        }
    }
    
    //MARK: - Connect To VPN Management
    
    /// Invokes necessary logic to make VPN connection.
    ///
    /// - Parameter sender: The CustomButton
    @IBAction func connectToVPNActionHandler(_ sender: Any) {
        connectToVPN()
    }
    
    /// Disables the connect button and attempts to make a connection to the VPN.
    fileprivate func connectToVPN() {
        vpnConnectButton.isClickable = false
        apiManager.connect()
    }
    
    //MARK: - Server List Presentation Management 
    
    /// Invokes the necessary logic to open the server list.
    ///
    /// - Parameter sender: The CustomButton
    @IBAction func didSelectServers(_ sender: Any) {
        openServerList()
    }
    
    /// Informs the main window controller to present the server list.
    fileprivate func openServerList() {
        delegate?.shouldDisplayServerViewController()
    }
	
	/// Displays an alert controller window dialog with the supplied message and
	/// title.
	///
	/// - parameter informativeText: The alert informative text.
	/// - parameter messageText: The alert message text.
	fileprivate func displayAlert(informativeText : String, messageText : String) {
		let alert = NSAlert()
		alert.informativeText = informativeText
		alert.messageText = messageText
		
		if let window = view.window {
			alert.beginSheetModal(for: window, completionHandler: nil)
		}
	}
}

//MARK: - VPN Connection Status Reporting Conformance

extension ConnectViewController : VPNConnectionStatusReporting {
    
    func statusConnectionFailed(_ notification: Notification) {
        toggleUIForEnabledState(isEnabled: true)
        vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
    }
    
    func statusConnectionDidDisconnect() {
        toggleUIForEnabledState(isEnabled: true)
        vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
    }
    
    func statusConnectionWillBegin() {
        toggleUIForEnabledState(isEnabled: false)
        vpnConnectButton.buttonText = NSLocalizedString("Connecting", comment: "Connecting...")
    }
    
    func statusConnectionSucceeded() {
        toggleUIForEnabledState(isEnabled: true)
        vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
    }
}

//MARK: - VPN Configuration Status Reporting Conformance

extension ConnectViewController : VPNConfigurationStatusReporting {
    
    func statusCurrentCityDidChange(_ notification: Notification) {
        if let currentCity = vpnConfiguration?.city {
            locationNameLabel.stringValue = currentCity.locationString()
        } else {
            locationNameLabel.stringValue = NSLocalizedString("FastestAvailable", comment: "Fastest Available Text")
        }
    }
}

//MARK: - VPN Account Status Reporting Conformance

extension ConnectViewController : VPNAccountStatusReporting {
    
    func statusLogoutWillBegin() {
        vpnConnectButton.isClickable = false
    }
    
    /// Displays an alert dialog informing the user the the login failed.
    ///
    /// - parameter notification: The vpn notification.
    func statusLoginFailed(_ notification: Notification) {
        vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
        displayAlert(informativeText: NSLocalizedString("LoginFailedGeneral", comment: "LoginFailedGeneral"), messageText: NSLocalizedString("LoginFailedTitle", comment: "LoginFailedTitle"))
    }
    
    /// Updates the button of the login button text to indicate login status.
    func statusLoginWillBegin() {
        vpnConnectButton.buttonText =  NSLocalizedString("LoggingIn", comment: "LoggingIn")
    }
    
    /// Clears the user name and password text fields so there are
    /// no previous credentials saved in the fields.
    ///
    /// - parameter notification: The vpn notification.
    func statusLoginSucceeded(_ notification: Notification) {
        vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
    }
}

//MARK: - VPN Helper Status Reporting Conformance

extension ConnectViewController : VPNHelperStatusReporting {
    
    func statusHelperDidInstall() {
        vpnConnectButton.isClickable = true
    }
    
    func statusHelperInstallFailed(_ notification: Notification) {
        vpnConnectButton.isClickable = true
        vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
    }
}

//MARK: - VPN Server Status Reporting Conformance

extension ConnectViewController : VPNServerStatusReporting {
    
    func statusServerUpdateWillBegin() {
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
    
    func statusInitialServerUpdateWillBegin() {
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
                vpnConfiguration?.setCityAndCountry(selectedServer.city)
            } else {
                //Couldn't find US, just set to whatever is first in the sorted servers array.
                vpnConfiguration?.setCityAndCountry(sortedServers.first?.city)
            }
            
            vpnConfiguration?.selectedProtocol = VPNProtocol.ikEv2
            
            apiManager.updateServerList()
        
            //Slight intentional delay here purely for UX reasons.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
                self.toggleUIForEnabledState(isEnabled: true)
            }
        }
    }
}
