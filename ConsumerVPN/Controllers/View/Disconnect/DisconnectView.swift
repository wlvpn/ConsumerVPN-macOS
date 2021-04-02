//
//  DisconnectView.swift
//  Consumer VPN
//
//  Created by Jonathan Fuentes on 8/13/19.
//  Copyright © 2019 WLVPN. All rights reserved.
//

import Cocoa

protocol DisconnectViewDelegate: class {
    func didSelectDisconnect()
}

class DisconnectView: ColorView, UIViewFadeAnimation {
    
	@IBOutlet weak var shieldView: ShieldView!
	@IBOutlet weak var connectedTitleLabel: NSTextField!
    
    //Location
    @IBOutlet weak var locationImage: NSImageView!
    @IBOutlet weak var locationTitleLabel: NSTextField!
    @IBOutlet weak var locationLabel: NSTextField!
    
    //Ip address
    @IBOutlet weak var ipAddressImage: NSImageView!
    @IBOutlet weak var ipAddressTitleLabel: NSTextField!
    @IBOutlet weak var ipAddressLabel: NSTextField!
    
    @IBOutlet weak var disconnectButton: CustomButton!
    
    //DisconnectViewDelegate protocol delegate
    weak var delegate:DisconnectViewDelegate?
    
    //UIViewFadeAnimation protocol
    var animatableViews: [NSView] = []
    
    class func newInstance() -> DisconnectView {
        var disconnectView:DisconnectView?
        var topLevelObjects : NSArray?
        if Bundle.main.loadNibNamed("DisconnectView", owner: self, topLevelObjects: &topLevelObjects) {
            disconnectView = topLevelObjects!.first(where: { $0 is DisconnectView }) as? DisconnectView
        }
        
        return disconnectView!
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        locationTitleLabel.stringValue = NSLocalizedString("Visible Location", comment: "")
        ipAddressTitleLabel.stringValue = NSLocalizedString("Public IP", comment: "")
        
        animatableViews = [shieldView, connectedTitleLabel, locationImage, locationTitleLabel, locationLabel, ipAddressImage, ipAddressTitleLabel, ipAddressLabel, disconnectButton]
        
        themeView()
    }
    
    //MARK: - View Styling
    
    /// Configures and initializes all user interface elements.
    fileprivate func themeView() {
        
        //Style the text color.
        ipAddressTitleLabel.textColor = NSColor.disconnectLabelText
        ipAddressLabel.textColor = NSColor.disconnectViewText
        
        locationTitleLabel.textColor = NSColor.disconnectLabelText
        locationLabel.textColor = NSColor.disconnectViewText
        
        locationImage.tinted(withTintColor: NSColor.disconnectViewIcons)
        ipAddressImage.tinted(withTintColor: NSColor.disconnectViewIcons)
        
        connectedTitleLabel.textColor = NSColor.disconnectViewText
        
        //Style the disconnect button
        disconnectButton.backgroundColor = NSColor.cancelButton
        disconnectButton.borderColor = NSColor.disconnectButton
        disconnectButton.styleButtonText(textColor: NSColor.disconnectButtonText)
        disconnectButton.setAccessibilityIdentifier("Disconnect Button")
    }
    
    @IBAction func didSelectConnect(_ sender: Any) {
        delegate?.didSelectDisconnect()
    }
}
