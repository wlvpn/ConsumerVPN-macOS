//
//  SettingsTouchBar.swift
//  ConsumerVPN
//
//  Created by Javier Hernández on 15/06/20.
//  Copyright © 2020 WLVPN. All rights reserved.
//

import Foundation

@available(OSX 10.12.2, *)
extension PreferencesWindowController: NSTouchBarDelegate {
    
    func setTouchBarItems() {
        customBarItems = [NSTouchBarItem.Identifier.flexibleSpace ,NSTouchBarItem.Identifier.onDemandItem, NSTouchBarItem.Identifier.fixedSpaceSmall, NSTouchBarItem.Identifier.startUpItem, NSTouchBarItem.Identifier.flexibleSpace]
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .settingsBar
        touchBar.defaultItemIdentifiers = customBarItems as! [NSTouchBarItem.Identifier]
        touchBar.customizationAllowedItemIdentifiers = customBarItems as! [NSTouchBarItem.Identifier]
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let customViewItem = NSCustomTouchBarItem(identifier: identifier)
        touchBar.escapeKeyReplacementItemIdentifier = .escapeItem
        switch identifier {
        case .onDemandItem:
            let button = NSButton(title: NSLocalizedString("OnDemand", comment: ""), target: self, action: #selector(toggleOndemand))
            if onDemand.state == .on {
                button.bezelColor = NSColor.connectButton
            }
            customViewItem.view = button
        case .startUpItem:
            let button = NSButton(title: NSLocalizedString("SystemStartup", comment: ""), target: self, action: #selector(toggleStartUp))
            if hideOnStartup.state == .on {
                button.bezelColor = NSColor.connectButton
            }
            customViewItem.view = button
        case .escapeItem:
            let button = NSButton(title: NSLocalizedString("Cancel", comment: ""), target: self, action: #selector(closeServerList))
            customViewItem.view = button
        default:
            return nil
        }
        return customViewItem
    }
    
    @objc func toggleOndemand() {
        onDemand.state = onDemand.state == .on ? .off : .on
        self.touchBar = makeTouchBar()
    }
    
    @objc func toggleStartUp() {
        hideOnStartup.state = hideOnStartup.state == .on ? .off : .on
        self.touchBar = makeTouchBar()
    }
    
    @objc func closeServerList() {
        close()
    }
}
