//
//  ServersTouchBar.swift
//  ConsumerVPN
//
//  Created by Javier Hernández on 15/06/20.
//  Copyright © 2020 WLVPN. All rights reserved.
//

import Foundation

@available(OSX 10.12.2, *)
extension ServerViewController: NSTouchBarDelegate {
    
    func setTouchBarItems() {
        customBarItems = [NSTouchBarItem.Identifier.flexibleSpace ,NSTouchBarItem.Identifier.fastestAvailableItem, NSTouchBarItem.Identifier.fixedSpaceSmall, NSTouchBarItem.Identifier.serversScrubber, NSTouchBarItem.Identifier.flexibleSpace]
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .serverListBar
        touchBar.defaultItemIdentifiers = customBarItems as! [NSTouchBarItem.Identifier]
        touchBar.customizationAllowedItemIdentifiers = customBarItems as! [NSTouchBarItem.Identifier]
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let customViewItem = NSCustomTouchBarItem(identifier: identifier)
        touchBar.escapeKeyReplacementItemIdentifier = .escapeItem
        switch identifier {
        case .fastestAvailableItem:
            let button = NSButton(title: NSLocalizedString("FastestAvailable", comment: ""), target: self, action: #selector(fastestAvailable))
            customViewItem.view = button
        case .escapeItem:
            let button = NSButton(title: NSLocalizedString("Cancel", comment: ""), target: self, action: #selector(closeServerList))
            customViewItem.view = button
        case .serversScrubber:
            let scrubber = NSScrubber()
            scrubber.scrubberLayout = NSScrubberFlowLayout()
            scrubber.register(NSScrubberTextItemView.self, forItemIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ServerScrubberItemIdentifier"))
            scrubber.mode = .free
            scrubber.selectionBackgroundStyle = .roundedBackground
            scrubber.delegate = self
            scrubber.dataSource = self
            customViewItem.view = scrubber
        default:
            return nil
        }
        return customViewItem
    }
    
    @objc func fastestAvailable() {
        apiManager.vpnConfiguration.country = nil
        apiManager.vpnConfiguration.city = nil
        apiManager.vpnConfiguration.server = nil
        self.view.window?.close()
    }
    
    @objc func showServersList() {
        setTouchBarItems()
        touchBar = makeTouchBar()
    }
    
    @objc func closeServerList() {
        self.view.window?.close()
    }
}

@available(OSX 10.12.2, *)
extension ServerViewController: NSScrubberDelegate {
    func scrubber(_ scrubber: NSScrubber, didSelectItemAt selectedIndex: Int) {
        apiManager.vpnConfiguration.server = nil
        apiManager.vpnConfiguration.setCityAndCountry(presentedTableData[selectedIndex])
    }
}

@available(OSX 10.12.2, *)
extension ServerViewController: NSScrubberDataSource {
    func numberOfItems(for scrubber: NSScrubber) -> Int {
        return presentedTableData.count
    }
    
    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        let customServerView = NSScrubberItemView()
        
        let serverName = NSTextField(labelWithString: "\(presentedTableData[index].name!)")
        let flag  = NSImageView(image: presentedTableData[index].country!.flagImage)
        
        serverName.font = NSFont.systemFont(ofSize: 16)
        
        customServerView.addSubview(flag)
        customServerView.addSubview(serverName)
        
        customServerView.translatesAutoresizingMaskIntoConstraints = false
        flag.translatesAutoresizingMaskIntoConstraints = false
        serverName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            flag.leftAnchor.constraint(equalTo: customServerView.leftAnchor, constant: 5),
            flag.topAnchor.constraint(equalTo: customServerView.topAnchor),
            flag.bottomAnchor.constraint(equalTo: customServerView.bottomAnchor),
            flag.rightAnchor.constraint(equalTo: serverName.leftAnchor, constant: -2),
            flag.widthAnchor.constraint(equalToConstant: 20),
            serverName.centerYAnchor.constraint(equalTo: customServerView.centerYAnchor),
            serverName.rightAnchor.constraint(equalTo: customServerView.rightAnchor, constant: -5)
        ])
        return customServerView
    }
}

@available(OSX 10.12.2, *)
extension ServerViewController: NSScrubberFlowLayoutDelegate {
    func scrubber(_ scrubber: NSScrubber, layout: NSScrubberFlowLayout, sizeForItemAt itemIndex: Int) -> NSSize {
        if let cityName = presentedTableData[itemIndex].name {
            let size = cityName.size(withAttributes: [.font: NSFont.systemFont(ofSize: 18)])
            // Calculated label content size plus the added widht of the flagImage plus it's left and right spacing
            return NSSize(width: (size.width + 30), height: size.height)
        }
        return NSSize()
    }
}
