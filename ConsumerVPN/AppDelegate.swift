//
//  AppDelegate.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/7/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import Cocoa

@NSApplicationMain
class AppDelegate : NSObject, NSApplicationDelegate {
    
    //MARK: - Properties
    fileprivate var apiManager : VPNAPIManager!
    fileprivate var mainWindowController : MainWindowController!
	
	fileprivate var purchaseCoordinator: PurchaseCoordinator = {
		return RevenueCatCoordinator(apiKey: Theme.revenueCatAPIKey,
									 debug: true,
									 productIdentifiers: Theme.iapProductIdentifiers)
	}()
    
    fileprivate lazy var preferencesWindowController : PreferencesWindowController = {
        let preferencesWindowController = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        preferencesWindowController.apiManager = self.apiManager
        preferencesWindowController.vpnConfiguration = apiManager.vpnConfiguration
        return preferencesWindowController
    }()
    
    fileprivate lazy var aboutWindowController : AboutWindowController = {
        let aboutWindowController = AboutWindowController(windowNibName: "AboutWindowController")

        aboutWindowController.apiManager = self.apiManager
        aboutWindowController.vpnConfiguration = apiManager.vpnConfiguration

        return aboutWindowController
    }()
    
    @IBOutlet weak var aboutMenuItem: NSMenuItem!
    @IBOutlet weak var applicationMenuItem: NSMenuItem!
    @IBOutlet weak var quitMenuItem: NSMenuItem!
    @IBOutlet weak var hideMenuItem: NSMenuItem!
    @IBOutlet weak var preferencesMenuItem: NSMenuItem!
    @IBOutlet weak var updateServersMenuItem: NSMenuItem!
    @IBOutlet weak var logoutMenuItem: NSMenuItem!
    
    //MARK: - App Life Cycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
		
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions" : true])

        apiManager = SDKInitializer.initializeAPIManager(
            withBrandName: Theme.brandName,
            configName: Theme.configurationName,
            apiKey: Theme.apiKey,
            andSuffix: Theme.usernameSuffix
        )

        NotificationCenter.default.addObserver(self,
            selector: #selector(AppDelegate.hideApplicationWindowOnStartupPreferenceChanged(_:)),
            name: Notification.Name(rawValue: WLHideOnSystemStartup),
            object: nil
        )
		
        //Check if valid user, but password is nil, log them out.
        if let _ = apiManager.vpnConfiguration.user , apiManager.vpnConfiguration.user?.password == nil {
            apiManager.logout()
        }
        
        //Configure a default protocol if not already saved.
        if apiManager.vpnConfiguration.selectedProtocol == VPNProtocol.invalid {
            apiManager.vpnConfiguration.selectedProtocol = VPNProtocol.ikEv2
        }
        
        if shouldApplyDefaultStartupConnectionOption() == true {
            UserDefaults.standard.set(true, forKey: WLDoNotAutomaticallyConnect)
        }
        
        //Initialize the MenuBar
        setupMenuBarWithBrandName(appName: Theme.brandName)
        
        mainWindowController = MainWindowController(windowNibName: "MainWindowController")
        mainWindowController.apiManager = apiManager
        mainWindowController.vpnConfiguration = apiManager.vpnConfiguration
		mainWindowController.purchaseCoordinator = purchaseCoordinator
		
        if UserDefaults.standard.bool(forKey: WLHideOnSystemStartup) == false {
            mainWindowController.showWindow(nil)
        }
        
        if #available(OSX 10.12.2, *) {
            NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(rawValue: WLHideOnSystemStartup),
                                                  object: nil)
        
        if let onDemandPreference = apiManager.vpnConfiguration.onDemandConfiguration {
            if apiManager.isConnectedToVPN(), !onDemandPreference.enabled {
                apiManager.disconnect()
            }
        } else if apiManager.isConnectedToVPN() {
            apiManager.disconnect()
        }
        
        apiManager.cleanup()
    }
    
    /// Updates the menu bar items to use the appName from the Customization.plist
    ///
    /// - parameter appName: The name of the app to update menu items with.
    private func setupMenuBarWithBrandName(appName : String) {
        applicationMenuItem.title = appName
		
        aboutMenuItem.title = "\(NSLocalizedString("About", comment:"About text")) \(appName)"
        hideMenuItem.title = "\(NSLocalizedString("Hide", comment:"Hide text")) \(appName)"
        quitMenuItem.title = "\(NSLocalizedString("Quit", comment:"Quit text")) \(appName)"
        preferencesMenuItem.title = NSLocalizedString("Preferences", comment:"Preferences text")
        updateServersMenuItem.title = NSLocalizedString("UpdateServersNow", comment:"Update Servers text")
        logoutMenuItem.title = NSLocalizedString("Logout", comment:"Logout text")
    }
    
    //MARK: - Logout Management
    
    /// Disconnect the user from the VPN and logout the current user (remove all data from
    /// CoreData and Keychain
    ///
    /// - parameter sender: The sending control.
    @IBAction func logoutMenuAction(_ sender: AnyObject) {
        apiManager.logout()
    }
    
    /// Opens the about window controller
    ///
    /// - parameter sender: The NSMenuItem
    @IBAction func aboutMenuAction(_ sender: AnyObject) {
        aboutWindowController.showWindow(nil)
    }
    
    /// Opens up the preferences window controller
    ///
    /// - parameter sender: NSMenuItem
    @IBAction func preferencesClicked(_ sender: AnyObject) {
		// Don't allow access to preferences before login
        guard let _ = apiManager.vpnConfiguration.user else {
            return
        }
        
        preferencesWindowController.showWindow(nil)
    }
    
    /// Evalutes the previous connection radio button options in gen preferences.
    /// If no options have ever been selected, then this function will return TRUE
    /// indicating that 'Do Not Automatically Connect' should be selected by default.
    ///
    /// - returns: True if no other connection option has been selected. Otherwise
    /// returns false.
    fileprivate func shouldApplyDefaultStartupConnectionOption() -> Bool {
        
        var shouldSelectDoNotConnect = false
        
        if UserDefaults.standard.bool(forKey: WLConnectToLastConnectedServer) == false &&
            UserDefaults.standard.bool(forKey: WLConnectToFastestServer) == false &&
            UserDefaults.standard.bool(forKey: WLConnectToFastestServerInCountry) == false {
            
            shouldSelectDoNotConnect = true
        }
        
        return shouldSelectDoNotConnect
    }
    
    //MARK: - Server Update Management
    
    
    /// Tells the api manager to update all of the servers.
    ///
    /// - parameter sender: The selected NSMenuItem
    @IBAction func updateServers(_ sender: NSMenuItem) {
        apiManager.updateServerList()
    }
    
    //MARK: - Window Show / Close Management
    
    internal func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        mainWindowController?.window?.makeKeyAndOrderFront(self)
		
        return true
    }
    
    /// Notification observer handler that is triggered when the general preference
    /// has been changed in the preferences window.
    ///
    /// - parameter notification: The client side notification payload.
    @objc internal func hideApplicationWindowOnStartupPreferenceChanged(_ notification : Notification) {
        if UserDefaults.standard.bool(forKey: WLHideOnSystemStartup) == true {
            //Hide the main application window.
            mainWindowController.close()
        } else {
            //Otherwise reveal it.
            mainWindowController.showWindow(nil)
        }
    }
}
