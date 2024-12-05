//
//  PreferencesWindowController.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/29/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import VPNHelperAdapter

class PreferencesWindowController : BaseWindowController, NSWindowDelegate {
    
    //MARK: - Properties
    
    @IBOutlet weak var onDemandTextField: NSTextField!
    @IBOutlet weak var onDemand: NSButton!
    
    @IBOutlet weak var protocolTextField: NSTextField!
    @IBOutlet weak var protocolSegmentControl: NSSegmentedControl!
    
    @IBOutlet weak var killSwitchTextField: NSTextField!
    @IBOutlet weak var btnKillSwitch: NSButton!
    
    @IBOutlet weak var hideOnStartupTextField: NSTextField!
    @IBOutlet weak var hideOnStartup: NSButton!
    
    @IBOutlet weak var launchOnSystemStartupTextField: NSTextField!
    @IBOutlet weak var launchOnSystemStartup: NSButton!
    
    @IBOutlet weak var startupTextField: NSTextField!
    @IBOutlet weak var doNotAutomaticallyConnect : NSButton!
    @IBOutlet weak var connectToLastConnectedServer : NSButton!
    @IBOutlet weak var connectToFastestServer : NSButton!
    @IBOutlet weak var fastestServerInCountry : NSButton!
    
    @IBOutlet weak var countryDropDown: NSPopUpButton!
    
    fileprivate enum OnDemandOption : Int {
        case notSelected = 0
        case selected
    }
    
    fileprivate var openVPNController : OpenVPNController? = nil
    
    //MARK: - Window Management
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.title = NSLocalizedString("Preferences", comment: "")
        onDemandTextField.stringValue = "\(NSLocalizedString("OnDemand", comment: "")):"
        onDemand.title = NSLocalizedString("Enabled", comment: "")
        killSwitchTextField.stringValue = "\(NSLocalizedString("KillSwitch", comment: "")):"
        btnKillSwitch.title = NSLocalizedString("Enabled", comment: "")
        hideOnStartupTextField.stringValue = "\(NSLocalizedString("HideOnStartup", comment: "")):"
        hideOnStartup.title = NSLocalizedString("HideOnStartupDesc", comment: "")
        launchOnSystemStartupTextField.stringValue = "\(NSLocalizedString("SystemStartup", comment: "")):"
        launchOnSystemStartup.title = "\(NSLocalizedString("Launch", comment: "")) \(Theme.brandName) \(NSLocalizedString("LaunchOnSystemStarup", comment: ""))"
        startupTextField.stringValue = "\(Theme.brandName) \(NSLocalizedString("Startup", comment: ""))"
        doNotAutomaticallyConnect.title = NSLocalizedString("DoNotAutomaticallyConnect", comment: "")
        connectToLastConnectedServer.title = NSLocalizedString("ConnectToLastConnected", comment: "")
        connectToFastestServer.title = NSLocalizedString("ConnectToFastest", comment: "")
        fastestServerInCountry.title = NSLocalizedString("ConnectToFastestInCountry", comment: "")
        protocolTextField.stringValue = "\(NSLocalizedString("Protocol", comment: "")):"
        
        //Subscribe to any OnDemand changes.
        NotificationCenter.default.addObserver(self, selector: #selector(PreferencesWindowController.onDemandOptionChanged
            ), name: Notification.Name(WLOnDemandOptionChangedNotification), object: nil)
        
        //Subscribe to connection status changes.
        NotificationCenter.default.addObserver(for: self)
        
        //Reads the values from user defaults and appropriately set the controls.
        configureUIForSelectedState()

        if #available(OSX 10.12.2, *) {
            setTouchBarItems()
            self.touchBar = makeTouchBar()
        }
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        updateUIForSelectedState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(WLOnDemandOptionChangedNotification),
                                                  object: nil)
        NotificationCenter.default.removeObserver(for: self)
    }
    
    //MARK: - Radio Button Action Handler
    
    /// Clears out previous radio button selection and the evalutates the
    /// currently selected option and toggles that option to true in User
    /// Defaults.
    ///
    /// - parameter sender: The selected radio button.
    @IBAction func radioButtonHandler(_ sender: NSButton) {
        
        clearPreviousRadioButtonSelection()
        
        if sender == doNotAutomaticallyConnect {
            UserDefaults.standard.set(true, forKey: WLDoNotAutomaticallyConnect)
        } else if sender == connectToLastConnectedServer {
            UserDefaults.standard.set(true, forKey: WLConnectToLastConnectedServer)
        } else if sender == connectToFastestServer {
            UserDefaults.standard.set(true, forKey: WLConnectToFastestServer)
        } else if sender == fastestServerInCountry {
            UserDefaults.standard.set(true, forKey: WLConnectToFastestServerInCountry)
        } else if sender == onDemand {
            //If we are connected and we just unchecked the box, confirm this is
            //what the user wants to do.
            sender.isEnabled = false
            managedOnDemandSelection(isSelected: sender.state.rawValue)
            
        }
    }
    
    //MARK: - KillSwitch Button Action Handler
    @IBAction func btnKillSwitchClicked(_ sender: NSButton) {
        let isKillSwitchEnabled = sender.state == .on
        toggleKillSwitch(enabled: isKillSwitchEnabled)
    }
    
    private func toggleKillSwitch(enabled: Bool) {
        ApiManagerHelper.shared.toggleKillSwitch(enable: enabled)
    }
    
    
    private func updateUIForSelectedState() {
        btnKillSwitch?.state = ApiManagerHelper.shared.isKillSwitchOn ? .on : .off
        btnKillSwitch?.isEnabled = ApiManagerHelper.shared.isSafeToChangeConfiguration()
        onDemand.isEnabled = !ApiManagerHelper.shared.isVPNConnectionInProgress() && ApiManagerHelper.shared.selectedProtocol != .openVPN_TCP && ApiManagerHelper.shared.selectedProtocol != .openVPN_UDP
        protocolSegmentControl.isEnabled = ApiManagerHelper.shared.isSafeToChangeConfiguration()
    }
    
    //MARK: - OnDemand Management
    
    /// Confirms that the user wishes to uncheck the OnDemand option which will
    /// disconnect them from the VPN if they have an active VPN connection ongoing.
    fileprivate func confirmOnDemandDisconnect(enable:Bool) {
        
        // Define the reconnect action
        func reconnectAction() {
            ApiManagerHelper.shared.setOnDemand(enable: false)
            ApiManagerHelper.shared.disconnect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                if enable {
                    ApiManagerHelper.shared.setOnDemand(enable: true)
                    ApiManagerHelper.shared.synchronizeConfiguration()
                } else {
                    ApiManagerHelper.shared.setOnDemand(enable: false)
                    ApiManagerHelper.shared.connect()
                }
                guard let self = self else { return }
                self.onDemand.isEnabled = true
            }
        }

        // Define the disconnect action
        func disconnectAction() {
            ApiManagerHelper.shared.disconnect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                ApiManagerHelper.shared.setOnDemand(enable: false)
                ApiManagerHelper.shared.synchronizeConfiguration()
                guard let self = self else {return}
                self.onDemand.isEnabled = true
            }
        }
        
        if let unwrappedWindow = window {
            let alert = NSAlert()
            alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel"))
            alert.addButton(withTitle: NSLocalizedString("Reconnect", comment: "Reconnect"))
            if !enable {
                alert.addButton(withTitle: NSLocalizedString("Disconnect", comment: "Disconnect"))
            }
            
            if enable {
                alert.informativeText = NSLocalizedString("EnableOnDemandDisconnect", comment: "EnableOnDemandDisconnect")
            } else {
                alert.informativeText = NSLocalizedString("DisableOnDemandDisconnect", comment: "DisableOnDemandDisconnect")
            }
            
            alert.alertStyle = NSAlert.Style.informational

            alert.beginSheetModal(for: unwrappedWindow) { (response) in
                switch response {
                case .alertFirstButtonReturn:
                    // Handle Cancel button click
                    self.onDemand.state = NSControl.StateValue(rawValue: enable ? OnDemandOption.notSelected.rawValue : OnDemandOption.selected.rawValue)
                case .alertSecondButtonReturn:
                    // Handle Reconnect button click
                    self.onDemand.isEnabled = true
                    reconnectAction()
                case .alertThirdButtonReturn:
                    // Handle Disconnect button click (only if enabled)
                    if !enable {
                        disconnectAction()
                    }
                default:
                    // The user canceled the confirmation, make sure onDemand stays checked.
                    self.onDemand.state = NSControl.StateValue(rawValue: OnDemandOption.selected.rawValue)
                }
            }
            
        }
        
    }
    
    /// Evaluates the user selected option and does one of two things. If the
    /// option is selected a new helper is installed and we attempt to connect
    /// upon successful helper installation. If the OnDemand option has been
    /// unselected we disconnect from the VPN if we were previously connected and
    /// install a new helper but we don't connect upon helper installation.
    ///
    /// - parameter isSelected: The integer value representing the selected
    /// state of the OnDemand checkbox.
    fileprivate func managedOnDemandSelection(isSelected : Int) {
        if (ApiManagerHelper.shared.isConnectedToVPN()) {
            confirmOnDemandDisconnect(enable: (isSelected > 0))
        } else {
            //Update the vpn configuration preference.
            ApiManagerHelper.shared.setOnDemand(enable:(isSelected > 0) )
            //Sync the config but do not connect.
            ApiManagerHelper.shared.synchronizeConfiguration { [weak self] success in
                guard let self = self else {return }
                self.onDemand.isEnabled = true
            }
        }
        
    }
    
    /// Looks up the OnDemand preference selection from the VPN Configuration and
    /// updates the checkbox button state to reflect the current value of this
    /// option.
    ///
    /// - parameter notification: The notification payload that was posted.
    @objc func onDemandOptionChanged(notification : Notification) {
        onDemand.state = NSControl.StateValue(rawValue:ApiManagerHelper.shared.isOnDemandEnabled ? 1 : 0)
    }
    
    //MARK: - Control State Management
    
    /// Clears all previous key values for radio button selection in User Defaults
    fileprivate func clearPreviousRadioButtonSelection() {
        UserDefaults.standard.set(false, forKey: WLDoNotAutomaticallyConnect)
        UserDefaults.standard.set(false, forKey: WLConnectToLastConnectedServer)
        UserDefaults.standard.set(false, forKey: WLConnectToFastestServer)
        UserDefaults.standard.set(false, forKey: WLConnectToFastestServerInCountry)
    }
    
    /// Sets the Control UI to the correct state from User Defaults
    fileprivate func configureUIForSelectedState() {
        
        //Checkbox starting state
        hideOnStartup.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: WLHideOnAppLaunch))
        
        //Checkbox initial state
        launchOnSystemStartup.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: WLLaunchOnSystemStartup))
        
        //Radio button starting state.
        doNotAutomaticallyConnect.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: WLDoNotAutomaticallyConnect))
        connectToLastConnectedServer.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: WLConnectToLastConnectedServer))
        connectToFastestServer.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: WLConnectToFastestServer))
        fastestServerInCountry.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: WLConnectToFastestServerInCountry))
        
        //If the on-demand option has been set, make sure the checkbox reflects this.
        onDemand.state = NSControl.StateValue(rawValue:ApiManagerHelper.shared.isOnDemandEnabled ? 1 : 0)
        
        //Load the country selection dropdown.
        configureCountryDropdown()
        
        switch ApiManagerHelper.shared.selectedProtocol {
        case .wireGuard:
            protocolSegmentControl.selectedSegment = 0
            if ApiManagerHelper.shared.installedStatusForWG != .installed {
                ApiManagerHelper.shared.installSystemExtension()
            }
        case .ikEv2:
            protocolSegmentControl.selectedSegment = 1
        case .ipSec:
            protocolSegmentControl.selectedSegment = 2
        case .openVPN_TCP, .openVPN_UDP:
            protocolSegmentControl.selectedSegment = 3
            if ApiManagerHelper.shared.installedStatusForOpenVPN == .installed {
                self.openOpenVPNConrollerWindow()
            } else {
                ApiManagerHelper.shared.installPrivilegedHelper()
            }
        default:
            protocolSegmentControl.selectedSegment = 0
        }
        
        protocolSegmentControl.isEnabled = ApiManagerHelper.shared.isSafeToChangeConfiguration()
    }
    
    /// Extracts the countries and loads them into the country dropdown. Performs
    /// nil checks.
    fileprivate func configureCountryDropdown() {
        
        let countries = ApiManagerHelper.shared.fetchCountries()
        if countries.isEmpty {
            return;
        }
        
        //Load up the country dropdown ane make sure we are binding options that
        //have non nil names.
        for country in countries {
            
            guard let countryName = country.name else {
                continue
            }
            
            countryDropDown.addItem(withTitle: countryName)
            
        }
        
        if let previouslySelectecCountry = UserDefaults.standard.value(forKey: WLSelectedCountry) as? String {
            countryDropDown.selectItem(withTitle: previouslySelectecCountry)
        } else {
            UserDefaults.standard.setValue(countries[0].name, forKey: WLSelectedCountry)
        }
    }
    
    @IBAction func protocolSegmentValueChanged(_ sender: NSSegmentedControl) {
        // Set protocol based on user selection
        ApiManagerHelper.shared.switchProtocol(index: sender.selectedSegment)
    }
    
    
    /// Toggle the user defaults value to true/false based on the click state of
    /// the check box. Posts a client side notification for any interested observers
    /// to hide or show any application windows in response to this preference
    /// selection.
    ///
    /// - parameter sender: The selected checkbox.
    @IBAction func hideOnStartupHandler(_ sender: NSButton) {
        UserDefaults.standard.set(sender.state, forKey: WLHideOnAppLaunch)
        NotificationCenter.default.post(name: Notification.Name(rawValue: WLHideOnAppLaunch), object: nil)
    }
    
    
    /// Toggle the user default value to true/false based on the clicked state of
    /// the checkbox. Posts a client side notification for any interested observers
    /// to lauch or remove from launch items of system in response to this preference selection
    ///
    /// - Parameter sender: The selected checkbox
    @IBAction func launchOnSystemStartupHandler(_ sender: NSButton) {
        UserDefaults.standard.set(sender.state, forKey: WLLaunchOnSystemStartup)
        NotificationCenter.default.post(name: Notification.Name(rawValue: WLLaunchOnSystemStartup), object: nil)
    }
    
    /// Will save the selected country in User Defaults the the user picked
    /// from the dropdown.
    ///
    /// - parameter sender: The dropdown item selection.
    @IBAction func selectedCountryHandler(_ sender: NSPopUpButton) {
        UserDefaults.standard.setValue(sender.title, forKey: WLSelectedCountry)
    }
   
    func openOpenVPNConrollerWindow() {
            if openVPNController != nil {
                openVPNController?.close()
                self.openVPNController = nil
            }
            
            self.openVPNController = OpenVPNController(windowNibName: "OpenVPNController")
            openVPNController?.apiManager = self.apiManager
            openVPNController?.showWindow(self)
    }
    
 }

extension PreferencesWindowController : VPNHelperStatusReporting {
    func statusHelperInstallSuccess(_ notification: Notification) {
        if ApiManagerHelper.shared.selectedProtocol == .openVPN_TCP
            || ApiManagerHelper.shared.selectedProtocol == .openVPN_UDP {
            self.openOpenVPNConrollerWindow()
        }
    }
}

extension PreferencesWindowController: VPNConfigurationStatusReporting {
    
    func statusCurrentProtocolDidChange(_ notification: Notification) {
        if (ApiManagerHelper.shared.selectedProtocol == .openVPN_TCP || ApiManagerHelper.shared.selectedProtocol == .openVPN_UDP) {
            if ApiManagerHelper.shared.installedStatusForOpenVPN == .installed {
                self.openOpenVPNConrollerWindow()
            }
        }
        
        updateUIForSelectedState()
    }
    
    func updateConfigurationBegin(_ notification: Notification) {
        guard let window = window, let windowView = window.contentView else { return  }
        CommonSpinnerManager.shared.showSpinner(on: windowView)
    }
    
    func updateConfigurationFailed(_ notification: Notification) {
        CommonSpinnerManager.shared.hideSpinner()
    }
    
    func updateConfigurationSucceeded(_ notification: Notification) {
        CommonSpinnerManager.shared.hideSpinner()
    }
    
}

extension PreferencesWindowController: VPNConnectionStatusReporting {
    
    func statusConnectionFailed(_ notification: Notification) {
        self.protocolSegmentControl.isEnabled = true
        updateUIForSelectedState()
        CommonSpinnerManager.shared.hideSpinner()
    }
    
    func statusConnectionWillBegin(_ notification: Notification) {
        self.protocolSegmentControl.isEnabled = false
        updateUIForSelectedState()
        guard let window = window, let windowView = window.contentView else { return  }
        CommonSpinnerManager.shared.showSpinner(on: windowView)
    }
    
    func statusConnectionDidDisconnect(_ notification: Notification) {
        self.protocolSegmentControl.isEnabled = true
        updateUIForSelectedState()
        CommonSpinnerManager.shared.hideSpinner()
    }
    
    func statusConnectionWillDisconnect(_ notification: Notification) {
        self.protocolSegmentControl.isEnabled = false
        updateUIForSelectedState()
        guard let window = window, let windowView = window.contentView else { return  }
        CommonSpinnerManager.shared.showSpinner(on: windowView)
    }
    
    func statusConnectionSucceeded(_ notification: Notification) {
        updateUIForSelectedState()
        CommonSpinnerManager.shared.hideSpinner()
    }
    
}


extension PreferencesWindowController: VPNAccountStatusReporting {
    
    func statusLogoutWillBegin(_ notification: Notification) {
        openVPNController?.close()
        self.close()
    }
    
}

