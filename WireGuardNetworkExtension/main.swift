//
//  main.swift
//  WireGuardNetworkExtension
//
//  Created by Javier Hernández on 11/11/22.
//  Copyright © 2022 WLVPN. All rights reserved.
//

import Foundation
import NetworkExtension

autoreleasepool {
    NEProvider.startSystemExtensionMode()
}

dispatchMain()
