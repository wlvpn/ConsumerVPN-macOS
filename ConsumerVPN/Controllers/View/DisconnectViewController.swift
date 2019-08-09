//
//  DisconnectViewController.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/14/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import AppKit

class DisconnectViewController : BaseViewController {
    
    //MARK: - Properties

    
    @IBOutlet weak var locationTitleLabel: NSTextField!
    @IBOutlet weak var locationLabel: NSTextField!
    @IBOutlet weak var connectedTitleLabel: NSTextField!
    @IBOutlet weak var publicIpTitleLabel: NSTextField!
    @IBOutlet weak var publicIpLabel: NSTextField!
    @IBOutlet weak var locationImage    : NSImageView!
    @IBOutlet weak var ipAddressImage   : NSImageView!
    @IBOutlet weak var disconnectButton : CustomButton!
	
    fileprivate var animatableSubviews : [NSView] = []
    
    class func newWith(apiManager: VPNAPIManager) -> DisconnectViewController {
        let disconnectStoryboard = NSStoryboard(name: "Disconnect", bundle: nil)
        let disconnectViewController = disconnectStoryboard.instantiateController(withIdentifier: "DisconnectViewController") as! DisconnectViewController
        disconnectViewController.apiManager = apiManager
        disconnectViewController.vpnConfiguration = apiManager.vpnConfiguration

        return disconnectViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTitleLabel.stringValue = NSLocalizedString("Visible Location", comment: "")
        
        publicIpTitleLabel.stringValue = NSLocalizedString("Public IP", comment: "")
    }

    //MARK: - View Management
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        NotificationCenter.default.addObserver(for: self)
        themeView()


        //Update the label for the city we are connected to.
        
        guard let cityName = vpnConfiguration?.city?.name, let countryId = vpnConfiguration?.country?.countryID else {
            //The city name is nil when it should not be.
            return
        }
        
        locationLabel.stringValue = "\(cityName), \(countryId)"
        
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
    
    //MARK: - View Styling
    
    /// Configures and initializes all user interface elements.
    fileprivate func themeView() {
        
        //Views we are going to perform alpha/opacity animations on.
        animatableSubviews = [disconnectButton, locationImage, publicIpLabel, locationLabel, publicIpTitleLabel]
        
        //Style the text color.
        publicIpTitleLabel.textColor = NSColor.primaryText
        publicIpLabel.textColor = NSColor.disconnectViewText
        
        locationTitleLabel.textColor = NSColor.primaryText
        locationLabel.textColor = NSColor.disconnectViewText
        
        if #available(OSX 10.14, *) {
            locationImage.contentTintColor = NSColor.disconnectViewText
        }
        
        if #available(OSX 10.14, *) {
            ipAddressImage.contentTintColor = NSColor.disconnectViewText
        }
        
        connectedTitleLabel.textColor = NSColor.disconnectViewText
        
        //Style the disconnect button
        disconnectButton.backgroundColor = NSColor.disconnectButton
        disconnectButton.borderColor = NSColor.disconnectButton
        disconnectButton.styleButtonText(textColor: NSColor.disconnectButtonText)
        disconnectButton.setAccessibilityIdentifier("Disconnect Button")
    }

    /// Initiates VPN Disconnect logic. If on demand option is enabled, confirm
    /// with the user before disconnecting.
    fileprivate func disconnectFromVPN() {
        if isOnDemandOptionsEnabled() == true {
            confirmVPNDisconnect()
        } else {
            apiManager.disconnect()
        }
    }
    
    /// Begins disconnect logic.
    ///
    /// - Parameter sender: the CustomButton
    @IBAction func disconnectActionHandler(_ sender: Any) {
        disconnectFromVPN()
    }
    
    //MARK: - OnDemand Management
    
    /// Checks the VPN Configuration to see if the On Demand option has been 
    /// enabled.
    ///
    /// - Returns: Returns true if the On Demand option is currently enabled.
    fileprivate func isOnDemandOptionsEnabled() -> Bool {
        
        var isOnDemandEnabled = false
        
        if let onDemandOption = vpnConfiguration?.getOptionForKey(kOnDemandAlwaysOnKey) as? Int, onDemandOption == 1 {
            isOnDemandEnabled = true
        }
        
        return isOnDemandEnabled
    }
    
    /// Display an alert window to the user confirming that they wish to disconnect.
    /// Attempts to disconnect if the user confirms they wish to disconnect.
    fileprivate func confirmVPNDisconnect() {
        
        if let window = view.window {
            
            let alert = NSAlert()
            alert.addButton(withTitle: NSLocalizedString("Disconnect", comment: "Disconnect"))
            alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel"))
            alert.informativeText = NSLocalizedString("OnDemandConfirm", comment: "OnDemandConfirm")
            alert.alertStyle = NSAlert.Style.informational
            
            alert.beginSheetModal(for: window) { (selectedResponseCode) in
                if selectedResponseCode == NSApplication.ModalResponse.alertFirstButtonReturn {
                    self.manageOnDemandDisconnect()
                }
            }
        }
    }
    
    /// When a user has confirmed that they wish to disconnect when OnDemand has
    /// been enabled, we disconnect from the VPN, turn off the OnDemand option
    /// on the VPNConfiguration and then install a new VPN helper that will reflect
    /// these OnDemand updated changes. This function also posts a app specific notification
    /// so that the preferences window can update it's UI to reflect this preference 
    /// being turned off automatically.
    fileprivate func manageOnDemandDisconnect() {
        apiManager.disconnect()
        vpnConfiguration?.setOption(0, forKey: kOnDemandAlwaysOnKey)
        apiManager.installHelperAndConnect(onInstall: false)
        NotificationCenter.default.post(name: Notification.Name(WLOnDemandOptionChangedNotification), object: nil, userInfo: nil)
    }
}

//MARK: - VPNConfiguration Status Reporting Conformance

extension DisconnectViewController : VPNConfigurationStatusReporting {
    
    func statusCurrentLocationDidChange(_ notification: Notification) {
        
        if let assignedIpAddress = vpnConfiguration?.currentLocation?.ipAddress {
            publicIpLabel.stringValue = assignedIpAddress
        } else {
            publicIpLabel.stringValue = NSLocalizedString("IPAddressError", comment: "IP Address Error")
        }
    }
}
