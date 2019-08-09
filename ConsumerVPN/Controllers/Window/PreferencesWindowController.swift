//
//  PreferencesWindowController.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/29/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation

class PreferencesWindowController : BaseWindowController {
    
    //MARK: - Properties 
	
    @IBOutlet weak var startupTextField: NSTextField!
    @IBOutlet weak var hideOnStartup: NSButton!
    
	@IBOutlet weak var onDemand: NSButton!
    @IBOutlet weak var doNotAutomaticallyConnect : NSButton!
    @IBOutlet weak var connectToLastConnectedServer : NSButton!
    @IBOutlet weak var connectToFastestServer : NSButton!
    @IBOutlet weak var fastestServerInCountry : NSButton!
    
    @IBOutlet weak var countryDropDown: NSPopUpButton!
    
    fileprivate enum OnDemandOption : Int {
        case notSelected
        case selected
    }
    
    //MARK: - Window Management 
    
    override func windowDidLoad() {
        super.windowDidLoad()

        startupTextField.stringValue = "\(Theme.brandName) Startup:"
        
        //Subscribe to any OnDemand changes.
        NotificationCenter.default.addObserver(self, selector: #selector(PreferencesWindowController.onDemandOptionChanged
            ), name: Notification.Name(WLOnDemandOptionChangedNotification), object: nil)
        
        //Reads the values from user defaults and appropriately set the controls.
        configureUIForSelectedState()

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
            if apiManager.isConnectedToVPN() == true, sender.state.rawValue == OnDemandOption.notSelected.rawValue {
                confirmOnDemandDisconnect()
            } else {
                managedOnDemandSelection(isSelected: sender.state.rawValue)
            }
		}
    }
    
    //MARK: - OnDemand Management
    
    /// Confirms that the user wishes to uncheck the OnDemand option which will
    /// disconnect them from the VPN if they have an active VPN connection ongoing.
    fileprivate func confirmOnDemandDisconnect() {
        
        if let unwrappedWindow = window {
            let alert = NSAlert()
            alert.addButton(withTitle: NSLocalizedString("Disconnect", comment: "Disconnect"))
            alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel"))
            alert.informativeText = NSLocalizedString("OnDemandDisconnect", comment: "OnDemandDisconnect")
            alert.alertStyle = NSAlert.Style.informational
            
            alert.beginSheetModal(for: unwrappedWindow) { (selectedResponseCode) in
                if selectedResponseCode == NSApplication.ModalResponse.alertFirstButtonReturn {
                    self.managedOnDemandSelection(isSelected: OnDemandOption.notSelected.rawValue)
                } else  {
                    //The user cancled the confirmation, make sure onDemand stays checked.
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
        
        //Update the vpn configuration preference.
        apiManager.vpnConfiguration.setOption(isSelected, forKey: kOnDemandAlwaysOnKey)
        
        switch isSelected {
            
        case OnDemandOption.notSelected.rawValue:
            
            //We were previously connected, and this option has been unselected
            //disconnect and install the new helper.
            if apiManager.isConnectedToVPN() == true {
                apiManager.disconnect()
            }
            
            //Install the updated helper but do not connect.
            apiManager.installHelperAndConnect(onInstall: false)
            break
            
        case OnDemandOption.selected.rawValue:
            //Install the updated helper AND connect on helper install.
            apiManager.installHelperAndConnect(onInstall: true)
            break
            
        default: break
        }
    }
    
    /// Looks up the OnDemand preference selection from the VPN Configuration and
    /// updates the checkbox button state to reflect the current value of this 
    /// option.
    ///
    /// - parameter notification: The notification payload that was posted.
    @objc func onDemandOptionChanged(notification : Notification) {
        guard let onDemandOption = vpnConfiguration?.getOptionForKey(kOnDemandAlwaysOnKey) as? Int else {
            return
        }
  
        onDemand.state = NSControl.StateValue(rawValue: onDemandOption)
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
        hideOnStartup.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: WLHideOnSystemStartup))
        
        //Radio button starting state.
        doNotAutomaticallyConnect.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: WLDoNotAutomaticallyConnect))
        connectToLastConnectedServer.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: WLConnectToLastConnectedServer))
        connectToFastestServer.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: WLConnectToFastestServer))
        fastestServerInCountry.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: WLConnectToFastestServerInCountry))
        
        //If the on-demand option has been set, make sure the checkbox reflects this.
        if let onDemandOption = vpnConfiguration?.getOptionForKey(kOnDemandAlwaysOnKey) as? Int {
            onDemand.state = NSControl.StateValue(rawValue: onDemandOption)
        }
       
        //Load the country selection dropdown.
        configureCountryDropdown()
    }
    
    /// Extracts the countries and loads them into the country dropdown. Performs
    /// nil checks.
    fileprivate func configureCountryDropdown() {
        
        guard let countries = apiManager.fetchAllCountries() as? [Country], countries.count > 0 else {
            return
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
    
    /// Toggle the user defaults value to true/false based on the click state of
    /// the check box. Posts a client side notification for any interested observers
    /// to hide or show any application windows in response to this preference
    /// selection.
    ///
    /// - parameter sender: The selected checkbox.
    @IBAction func hideOnStartupHandler(_ sender: NSButton) {
        UserDefaults.standard.set(sender.state, forKey: WLHideOnSystemStartup)
        NotificationCenter.default.post(name: Notification.Name(rawValue: WLHideOnSystemStartup), object: nil)
    }
    
    /// Will save the selected country in User Defaults the the user picked
    /// from the dropdown.
    ///
    /// - parameter sender: The dropdown item selection.
    @IBAction func selectedCountryHandler(_ sender: NSPopUpButton) {
        UserDefaults.standard.setValue(sender.title, forKey: WLSelectedCountry)
    }
 }
