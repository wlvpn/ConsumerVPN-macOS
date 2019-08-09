//
//  LoadingViewController.swift
//  Consumer VPN
//
//  Created by Jonathan Fuentes on 3/20/19.
//  Copyright © 2019 WLVPN. All rights reserved.
//

import Cocoa

class LoadingViewController: BaseViewController {
    
    @IBOutlet weak var cancelButton: CustomButton!
    
    class func newWith(apiManager: VPNAPIManager) -> LoadingViewController {
        let loadingStoryboard = NSStoryboard(name: "Loading", bundle: nil)
        let loadingViewController = loadingStoryboard.instantiateController(withIdentifier: "LoadingViewController") as! LoadingViewController
        loadingViewController.apiManager = apiManager
        loadingViewController.vpnConfiguration = apiManager.vpnConfiguration
        
        return loadingViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        themeView()
    }
    
    fileprivate func themeView() {
        cancelButton.backgroundColor    = NSColor.cancelButton
        cancelButton.borderColor        = NSColor.cancelButton
        cancelButton.textColor          = NSColor.cancelButtonText
        cancelButton.buttonText         = NSLocalizedString("Cancel", comment: "Cancel")
        cancelButton.setAccessibilityIdentifier("Cancel Button")
    }
    
    @IBAction func cancelConnect(_ sender: Any) {
	        apiManager.disconnect()
    }
}
