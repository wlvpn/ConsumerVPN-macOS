//
//  BaseWindowController.swift
//  WhiteLabelVPN
//
//  Created by Zephaniah Cohen on 9/8/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import AppKit
import VPNKit

class BaseWindowController : NSWindowController {
    var customBarItems: [Any] = []
    
    //MARK: - Properties
    
    @objc internal var apiManager : VPNAPIManager!
    @objc internal var vpnConfiguration : VPNConfiguration?
}

extension BaseWindowController: TouchBarComponents {
    func getCustomBarItems() -> [Any] {
        return customBarItems
    }
}
