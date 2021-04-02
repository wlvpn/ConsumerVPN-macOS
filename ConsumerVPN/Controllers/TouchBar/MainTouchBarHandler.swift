//
//  MainTouchBarHandler.swift
//  ConsumerVPN
//
//  Created by Javier Hernández on 10/06/20.
//  Copyright © 2020 WLVPN. All rights reserved.
//

import Foundation

protocol MainTouchBarProtocol {
    var disconnectViewController : DisconnectView { mutating get }
    var connectViewController : ConnectView { mutating get }
    var loginViewController : LoginViewController { mutating get }
    var serverViewController : ServerViewController { mutating get }
}

@available(OSX 10.12.2, *)
extension MainWindowController : NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .mainBar
        touchBar.defaultItemIdentifiers = customBarItems as! [NSTouchBarItem.Identifier]
        touchBar.customizationAllowedItemIdentifiers = customBarItems as! [NSTouchBarItem.Identifier]
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let customViewItem = NSCustomTouchBarItem(identifier: identifier)
        switch identifier {
        case .connectItem:
            let button = NSButton(title: NSLocalizedString("Connect", comment: ""), target: self, action: #selector(connect))
            button.bezelColor = NSColor.connectButton
            customViewItem.view = button
        case .disconnectItem:
            let button = NSButton(title: NSLocalizedString("Disconnect", comment: ""), target: self, action: #selector(connect))
            button.bezelColor = NSColor.disconnectButton
            customViewItem.view = button
        case .preferencesItem:
            let button = NSButton(title: NSLocalizedString("Preferences", comment: ""), target: self, action: #selector(showPreferences(sender:)))
            customViewItem.view = button
        case .signUpItem:
            let button = NSButton(title: NSLocalizedString("Signup", comment: "Starting sign up state"), target: self, action: #selector(signUp))
            customViewItem.view = button
        case .loginItem:
            let button = NSButton(title: NSLocalizedString("Login", comment: "Starting login state"), target: self, action: #selector(login))
            button.bezelColor = NSColor.connectButton
            customViewItem.view = button
        case .forgotPasswordItem:
            let button = NSButton(title: NSLocalizedString("Forgot Login", comment: "Starting forgot message"), target: self, action: #selector(forgotPassword))
            customViewItem.view = button
        case .serverSelectionItem:
            var selectedCity = NSLocalizedString("FastestAvailable", comment: "")
            if let city = vpnConfiguration?.city, let cityName = city.name {
                selectedCity = cityName
            }
            let button = NSButton(title: selectedCity, target: self, action: #selector(showServerList))
            customViewItem.view = button
        default:
            return nil
        }
        return customViewItem
    }
    
    @objc func connect() {
        didSelectConnect()
    }
    
    @objc func showPreferences(sender:NSButton) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.preferencesClicked(sender)
    }
    
    @objc func showServerList() {
        didSelectChooseLocation()
    }
    
    @objc func signUp() {
        NSWorkspace.shared.open(URL(string: Theme.signupURL)!)
    }
    
    @objc func login() {
        touchBarLoginHelper()
    }
    
    @objc func forgotPassword() {
        NSWorkspace.shared.open(NSURL(string: Theme.forgotPasswordURL)! as URL)
    }
}
