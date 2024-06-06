//
//  OpenVPNController.swift
//  ConsumerVPN
//
//  Created by Jyoti Gawali Katkar on 15/09/23.
//  Copyright © 2023 WLVPN. All rights reserved.
//

import Foundation
import VPNHelperAdapter

enum OpenVPNHelperInstallStatus {
    case unknown
    case installing
    case installed
    case uninstalled
    case failed
}

class OpenVPNController : BaseWindowController, VPNStatusReporting {
    
    @IBOutlet weak var dropDownPort: NSPopUpButton!
    @IBOutlet weak var dropDownProtocol: NSPopUpButton!
    @IBOutlet weak var btnScramble: NSButton?
    @IBOutlet weak var btnIPV6Leakprotect: NSButton?
    @IBOutlet weak var btnUninstall: NSButton?
    @IBOutlet weak var btnRepair: NSButton?
    @IBOutlet weak var btnFixOpenVPN: NSButton?

    var openVpnPort : String = ""
    var vpnProtocol: VPNProtocol? = nil
    var installedStatusForOpenVpn: OpenVPNHelperInstallStatus = .unknown
    var privilegedHelperManager: VPNPrivilegedHelperManager?
   
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
        
        dropDownPort?.addItem(withTitle: "443")
        dropDownPort?.addItem(withTitle: "1194")
        dropDownProtocol?.addItem(withTitle: "TCP")
        dropDownProtocol?.addItem(withTitle: "UDP")
        
       
        dropDownPort.title = ApiManagerHelper.shared.getOpenVPNPort()
        dropDownProtocol.title = ApiManagerHelper.shared.getOpenVPNType().uppercased()
        btnScramble?.state = NSControl.StateValue(ApiManagerHelper.shared.getOpenVPNScrambled())
        btnIPV6Leakprotect?.state = NSControl.StateValue(ApiManagerHelper.shared.getOpenVPNIPLeackPrototection())
        
        UserDefaults.standard.synchronize()
    }
    
    //MARK: IBAction methods
    
    @IBAction func btnPortClicked(_ sender: NSPopUpButton) {
        ApiManagerHelper.shared.setOpenVPNPort(sender.selectedItem?.title)
        ApiManagerHelper.shared.synchronizeConfiguration()
    }
    
    @IBAction func btnProtocolClicked(_ sender: NSPopUpButton) {
        ApiManagerHelper.shared.setOpenVPNType(sender.selectedItem?.title)
    }
    
    @IBAction func btnScrambleClicked(_ sender: NSButton) {
        ApiManagerHelper.shared.setOpenVPNScrambled(sender.state.rawValue)
    }
    
    @IBAction func btnIPV6LeakProtectionClicked(_ sender: NSButton) {
        ApiManagerHelper.shared.setOpenVPNIPLeackPrototection(sender.state.rawValue)
    }
    
    @IBAction func btnFixOpenVPNDNSClicked(_ sender: NSButton) {
        ApiManagerHelper.shared.resetDns()
        self.showAlert(message: NSLocalizedString("OpenVpnFixDnsSuccessMessage", comment: ""))
    }
    
    @IBAction func btnRepairClicked(_ sender: NSButton) {
        self.repairOpenVpnDrivers {
            let msg = ApiManagerHelper.shared.isOpenVPNHelperInstalled() ? NSLocalizedString("OpenVPNDriversuccess", comment: "") : NSLocalizedString("OpenVPNDriverfail", comment: "")
            self.showAlert(message: msg)
        }
        self.loadSettings()
    }
    
    @IBAction func btnUninstallClicked(_ sender: NSButton) {
        self.callRunscriptForUninstallOpenVPNDriver { result in
            self.installedStatusForOpenVpn = .uninstalled
            self.loadSettings()
            let msg = result ?
            NSLocalizedString("OpenVpnDriverUninstallSuccessMessage", comment: "") : NSLocalizedString("OpenVpnDriverUninstallFailMessage", comment: "")
            self.showAlert(message: msg)
        }
    }
    
    //MARK: User defined Functions
    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        if let window = self.window {
            alert.beginSheetModal(for: window, completionHandler: nil)
        }
    }
    
    func repairOpenVpnDrivers(completion: @escaping ()->()) {
        if self.runUninstallHelperScript() {
            ApiManagerHelper.shared.installPrivilegedHelper()
        } else {
            debugPrint("Failed to uninstall the helper")
        }
        completion()
    }
    
    func callRunscriptForUninstallOpenVPNDriver(completion: ((Bool)->())) {
        if self.runUninstallHelperScript() {
            completion(true)
            debugPrint("Successfully uninstalled the helper")
        } else {
            completion(false)
            debugPrint("Failed to uninstall the helper")
        }
    }
    
    private func runUninstallHelperScript() -> Bool {
        var uninstallSucceeded = true
        var errorDictionary: NSDictionary?
        
        if let scriptPath = Bundle.main.path(forResource: "RemoveOpenVPNHelper", ofType: "scpt"),
           let uninstallScript = NSAppleScript(contentsOf: URL(fileURLWithPath: scriptPath), error: &errorDictionary) {
            if let error = errorDictionary {
                uninstallSucceeded = false
                debugPrint("Error running uninstall script: ", error)
            } else {
                uninstallScript.executeAndReturnError(&errorDictionary)
                if let error = errorDictionary {
                    uninstallSucceeded = false
                    debugPrint("Error running uninstall script: ", error)
                }
            }
        }
        
        return uninstallSucceeded
    }
    
    func loadSettings() {
        self.btnUninstall?.isEnabled = ApiManagerHelper.shared.isOpenVPNHelperInstalled()
        self.btnRepair?.isEnabled = ApiManagerHelper.shared.isOpenVPNHelperInstalled()
    }
    
    
    deinit {
        print("Deinit \(#function)")
        
    }
     
}
