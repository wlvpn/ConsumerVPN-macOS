//
//  OpenVPNController.swift
//  ConsumerVPN
//
//  Created by Jyoti Gawali Katkar on 15/09/23.
//  Copyright © 2023 WLVPN. All rights reserved.
//

import Foundation

enum SystemExtensionStatus {
    case unknown
    case installed
    case pending
    case disabled
    case uninstalled
    case failed
}

class OpenVPNController : BaseWindowController, VPNStatusReporting {
    
    @IBOutlet weak var dropDownPort: NSPopUpButton!
    @IBOutlet weak var dropDownProtocol: NSPopUpButton!
    @IBOutlet weak var btnScramble: NSButton?
    @IBOutlet weak var btnIPV6Leakprotect: NSButton?
    
    var openVpnPort : String = ""
    var vpnProtocol: VPNProtocol? = nil
    var installedStatusForOpenVpn: SystemExtensionStatus = .unknown
   
    override func windowDidLoad() {
        super.windowDidLoad()
        self.configureOpenVPNOptionsOnVPNConfiguration()
    }
     
    //MARK: - OpenVPN Settings
    /**
     Configures OpenVPN options for port and protocol and keeps track of this in NSUserDefaults
  
     */
    private func configureOpenVPNOptionsOnVPNConfiguration() {
        
        self.dropDownPort.autoenablesItems = false
        self.dropDownProtocol.autoenablesItems = false

        // Get available ports from SDK instead of hard-coding
        if let availablePorts = ApiManagerHelper.shared.vpnConfiguration?.openVPNSettings.availablePorts() {
            for port in availablePorts {
                dropDownPort?.addItem(withTitle: port.stringValue)
            }
        }

        dropDownProtocol?.addItem(withTitle: "TCP")
        dropDownProtocol?.addItem(withTitle: "UDP")
        
       
        dropDownPort.title = ApiManagerHelper.shared.getOpenVPNPort()
        dropDownProtocol.title = ApiManagerHelper.shared.getOpenVPNType().uppercased()
        btnScramble?.state = NSControl.StateValue(ApiManagerHelper.shared.getOpenVPNScrambled())
        btnIPV6Leakprotect?.state = NSControl.StateValue(ApiManagerHelper.shared.getOpenVPNIPLeakProtection())
        
        UserDefaults.standard.synchronize()
    }
    
    //MARK: IBAction methods
    
    @IBAction func btnPortClicked(_ sender: NSPopUpButton) {
        if let portString = sender.selectedItem?.title,
           let portValue = UInt(portString) {
            ApiManagerHelper.shared.updateOpenVPNPort(portValue)
            ApiManagerHelper.shared.synchronizeConfiguration()
        }
    }
    
    @IBAction func btnProtocolClicked(_ sender: NSPopUpButton) {
        ApiManagerHelper.shared.setOpenVPNType(sender.selectedItem?.title)
    }
    
    @IBAction func btnScrambleClicked(_ sender: NSButton) {
        ApiManagerHelper.shared.setOpenVPNScrambled(sender.state.rawValue)
        dropDownPort.removeAllItems()
        if let availablePorts = ApiManagerHelper.shared.vpnConfiguration?.openVPNSettings.availablePorts() {
            for port in availablePorts {
                dropDownPort.addItem(withTitle: port.stringValue)
            }
        }
    }
    
    @IBAction func btnIPV6LeakProtectionClicked(_ sender: NSButton) {
        ApiManagerHelper.shared.setOpenVPNIPLeakProtection(sender.state.rawValue)
    }
    
    //MARK: User defined Functions
    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        if let window = self.window {
            alert.beginSheetModal(for: window, completionHandler: nil)
        }
    }
    
    deinit {
        print("Deinit \(#function)")
        
    }
     
}
