//
//  main.swift
//  OpenVPNNetworkExtension
//
//  Created by Javier Hernandez on 10/10/25.
//  Copyright © 2025 WLVPN. All rights reserved.
//

import Foundation
import NetworkExtension

autoreleasepool {
    NEProvider.startSystemExtensionMode()
}

dispatchMain()
