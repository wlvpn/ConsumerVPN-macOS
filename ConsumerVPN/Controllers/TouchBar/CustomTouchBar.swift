//
//  CustomTouchBar.swift
//  ConsumerVPN
//
//  Created by Javier Hernández on 10/06/20.
//  Copyright © 2020 WLVPN. All rights reserved.
//

import AppKit

@available(OSX 10.12.2, *)
extension NSTouchBarItem.Identifier {
    static let escapeItem = NSTouchBarItem.Identifier("escapeButton")
    // Main TouchBar Elements
    static let connectItem = NSTouchBarItem.Identifier("connectButton")
    static let disconnectItem = NSTouchBarItem.Identifier("disconnectButton")
    static let signUpItem = NSTouchBarItem.Identifier("signUpItem")
    static let loginItem = NSTouchBarItem.Identifier("loginItem")
    static let forgotPasswordItem = NSTouchBarItem.Identifier("forgotPasswordItem")
    static let preferencesItem = NSTouchBarItem.Identifier("preferencesItem")
    static let cancelItem = NSTouchBarItem.Identifier("cancelItem")
    static let onDemandItem = NSTouchBarItem.Identifier("onDemandItem")
    static let startUpItem = NSTouchBarItem.Identifier("startUpItem")
    
    // Server List TouchBar Elements
    static let fastestAvailableItem = NSTouchBarItem.Identifier("fastestAvailableButton")
    static let serverSelectionItem = NSTouchBarItem.Identifier("serverSelectionItem")
    static let serversScrubber = NSTouchBarItem.Identifier("serverScrubber")
}

@available(OSX 10.12.2, *)
extension NSTouchBar.CustomizationIdentifier {
    static let mainBar = NSTouchBar.CustomizationIdentifier("MainViewController")
    static let serverListBar = NSTouchBar.CustomizationIdentifier("ServerViewController")
    static let settingsBar = NSTouchBar.CustomizationIdentifier("PreferencesWindowController")
}

protocol TouchBarComponents {
    var customBarItems: [Any] { get }
    func getCustomBarItems() -> [Any]
}
