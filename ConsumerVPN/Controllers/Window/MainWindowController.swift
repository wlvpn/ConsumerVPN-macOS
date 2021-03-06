//
//  MainWindowController.swift
//  WhiteLabelVPN
//
//  Created by Zephaniah Cohen on 9/8/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import AppKit

protocol UIViewFadeAnimation {
    func revealViewsAnimation()
    var animatableViews: [NSView] { get set }
}

extension UIViewFadeAnimation {
    /// Applies a fade animation to each view in the subviewsToAnimate array
    func revealViewsAnimation() {
        
        for subView in self.animatableViews {
            subView.layer?.opacity = 0
        }
        
        DispatchQueue.main.async {
            let fadeInAnimation = Animations.opacityFadeAnimation(startingAlphaValue: 0.0, endingAlphaValue: 1.0, animationDuration: 2, animationName: "fadeIn")
            for subView in self.animatableViews {
                subView.layer?.add(fadeInAnimation, forKey: "fadeIn")
                subView.layer?.opacity = 1.0
            }
        }
    }
}

class MainWindowController : BaseWindowController {
    
    //MARK: - Properties
    
    @IBOutlet weak var backgroundView: ColorView!
    @IBOutlet weak var contentView: NSView!

    fileprivate var currentView : NSView!
    fileprivate var shouldConnectAtStartUp = false

    fileprivate lazy var disconnectView : DisconnectView = {
        let disconnectView = DisconnectView.newInstance()
        disconnectView.delegate = self
        return disconnectView
    }()
    
    fileprivate lazy var connectView : ConnectView = {
        let connectView = ConnectView.newInstance()
        connectView.setTouchBarItems()
        connectView.delegate = self
        return connectView
    }()
    
    fileprivate lazy var loginViewController : LoginViewController = {
		let loginViewController = LoginViewController.newWith(apiManager: apiManager, toggleDelegate: self)
        loginViewController.setTouchBarItems()
        return loginViewController
    }()
	
	fileprivate lazy var signupViewController : SignupViewController = {
		let signupViewController = SignupViewController.newWith(apiManager: apiManager, toggleDelegate: self, purchaseCoordinator: purchaseCoordinator)
		signupViewController.setTouchBarItems()
		return signupViewController
	}()
    
    fileprivate lazy var serverViewController : ServerViewController = {
        let serverViewController = serverWindowController
        return serverViewController.contentViewController as! ServerViewController
    }()
    
    fileprivate lazy var serverWindowController : ServerWindowController = {
        let serverWindowController = ServerWindowController.newWith(apiManager: apiManager)
        return serverWindowController
    }()
	
	fileprivate lazy var productsViewController : ProductsViewController = {
		return ProductsViewController.newWith(apiManager: apiManager, purchaseCoordinator: purchaseCoordinator)
	}()
	
	fileprivate lazy var purchaseViewController : PurchaseViewController = {
		return PurchaseViewController.newWith(apiManager: apiManager, purchaseCoordinator: purchaseCoordinator)
	}()
    
    fileprivate lazy var loadingView : LoadingView = {
        let loadingView = LoadingView.newInstance()
        loadingView.delegate = self
        return loadingView
    }()
    
    var currentCities: [City] = []
	
	var purchaseCoordinator: PurchaseCoordinator!
    
    //MARK: - Window Management
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        NotificationCenter.default.addObserver(for: self)
        
        themeWindow()
        
		if let loggedUser = vpnConfiguration?.user {
			
			if loggedUser.accountType == 0 {
				swapView(to: purchaseViewController.colorView)
			} else {
				manageConnectionViews()
			}

		} else {
			customBarItems = loginViewController.getCustomBarItems()
			showLoginView()
		}
        
        // Set the Server Select Text
        if let assignedCity = vpnConfiguration?.city {
            connectView.locationNameLabel.stringValue = assignedCity.locationString()
        } else {
            connectView.locationNameLabel.stringValue = NSLocalizedString("FastestAvailable", comment: "Fastest Available Text")
        }
        
        //Starts off disabled until initial server list and server updates succeed.
        connectView.toggleUIForEnabledState(isEnabled: false)
        
        evaluateGeneralPreferences()
        applySelectedEncryption()
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(userDidSelectPlan(notification:)),
											   name: NSNotification.Name("Selected Plan"),
											   object: nil)
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(userDidSignup),
											   name: NSNotification.Name("CancelPurchase"),
											   object: nil)
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(userDidSignup),
											   name: NSNotification.Name("UserDidSignUp"),
											   object: nil)
    }
    
    /// Shows the appropriate view controller view based upon active VPN connection
    /// state.
    fileprivate func manageConnectionViews() {
        if apiManager.isConnectedToVPN() == false {
            customBarItems = connectView.getCustomBarItems()
            showConnectView()
        } else {
            customBarItems = disconnectView.getCustomBarItems()
            showDisconnectView()
        }
    }
    
    /// Swaps back to the connect view only if we are on the disconnect
    /// view and not on the server list.
    fileprivate func updateAppliedViewForDisconnectOrFailure() {
        if currentView is DisconnectView || currentView is LoadingView {
            showConnectView()
        }
    }
    
    //MARK: - Utility Methods
    
    /// Prepares the window properties for initial load.
    private func themeWindow() {
        window!.title = Theme.brandName
        
        window?.titleVisibility = .hidden
        
        backgroundView.backgroundColor = NSColor.primaryBackground
    }
    
    /// Displays an alert controller window dialog with the supplied message and
    /// title.
    ///
    /// - parameter informativeText: The alert informative text.
    /// - parameter messageText: The alert message text.
    fileprivate func displayAlert(informativeText : String, messageText : String) {
        
        let alert = NSAlert()
        alert.informativeText = informativeText
        alert.messageText = messageText
        
        if let window = window {
            alert.beginSheetModal(for: window, completionHandler: nil)
        }
    }
    
    //MARK: - View Swap Functions
    
    /// Shows the loginViewController, presenting it with the correct animation.
    internal func showLoginView() {
        swapView(to: loginViewController.colorView)
    }
    
    /// Shows the connectViewController, presenting it with the correct animation.
    internal func showConnectView() {
        swapView(to: connectView)
    }
    
    /// Shows the connectViewController, presenting it with the correct animation.
    internal func showLoadingView() {
        swapView(to: loadingView)
    }
    
    /// Shows the disconnectViewController, presenting it with the correct animation.
    internal func showDisconnectView() {
        if let cityName = vpnConfiguration?.city?.name,
            let countryId = vpnConfiguration?.country?.countryID {
            disconnectView.locationLabel.stringValue = "\(cityName), \(countryId)"
            disconnectView.locationLabel.isHidden = false
        }

        swapView(to: disconnectView)
    }
    
    /// Swaps the currentView with the provided view.Applies
    /// a fade transition animation when swapping view controllers.
    ///
    /// - parameter newView: The view to swap in.
    fileprivate func swapView(to newView: TouchBarComponents)  {
        let helperView = newView as! NSView
        customBarItems = newView.getCustomBarItems()
        
        if let _ = currentView {
            contentView.replaceSubview(currentView, with: newView as! NSView)
            
            if let animatableView = newView as? UIViewFadeAnimation {
                animatableView.revealViewsAnimation()
            }
            
            helperView.translatesAutoresizingMaskIntoConstraints = false
            helperView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0).isActive = true
            helperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0).isActive = true
            helperView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0.0).isActive = true
            helperView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0.0).isActive = true
            contentView.layoutSubtreeIfNeeded()
        } else {
            helperView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(helperView)
            
            helperView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0).isActive = true
            helperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0).isActive = true
            helperView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0.0).isActive = true
            helperView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0.0).isActive = true
        }
        updateTouchBar()
        
        currentView = helperView
    }
    
    /// Looks through the general preferences determining if a connection should
    /// be made at startup and modify the vpn configuration accordingly for selected
    /// preferences.
    fileprivate func evaluateGeneralPreferences() {
        
        if UserDefaults.standard.bool(forKey: WLDoNotAutomaticallyConnect) == true {
            shouldConnectAtStartUp = false
        } else {
            shouldConnectAtStartUp = true
        }
        
        if UserDefaults.standard.bool(forKey: WLConnectToFastestServer) == true {
            //Should just load balance to the fastest server for the currently assigned
            //city on the vpn configuration.
            vpnConfiguration?.server = nil
            
        } else if UserDefaults.standard.bool(forKey: WLConnectToFastestServerInCountry) == true {
            
            guard let countries = apiManager.fetchAllCountries() as? [Country] else {
                return
            }
            
            guard let selectedCountryNamePreference = UserDefaults.standard.value(forKey: WLSelectedCountry) as? String else {
                return
            }
            
            if let selectedCountryPreference = countries.filter({ $0.name?.lowercased() == selectedCountryNamePreference.lowercased() }).first {
                vpnConfiguration?.country = selectedCountryPreference
                vpnConfiguration?.city = nil
                vpnConfiguration?.server = nil
            }
        }
    }
    
    /// Updates the encryption preference view with the saved value of encryption
    /// from the vpn configuration. Defaults to AES-256 if no previous option was
    /// saved to the VPN configuration.
    fileprivate func applySelectedEncryption() {
        
        if let savedEncryption = vpnConfiguration?.getOptionForKey(kIKEv2Encryption) as? String {
            
            switch savedEncryption {
                
            case kVPNEncryptionAES256:
                break
                
            case kVPNEncryptionAES128:
                break
                
            default: break
            }
            
        } else {
            
            //If this is nil, it's never been set or preferences have been cleared, we should
            //default to 256 and save this to the vpn configuration.
            vpnConfiguration?.setOption(kVPNEncryptionAES256, forKey: kIKEv2Encryption)
        }
    }
    
    func touchBarLoginHelper() {
        loginViewController.login()
    }
    
    fileprivate func updateTouchBar() {
        if #available(OSX 10.12.2, *) {
            self.touchBar = nil
            self.touchBar = makeTouchBar()
        }
    }
    /// Evaluate preferences connection options.
    /// If any option besides "do not automatically connect", configure and attempt connection
    ///
    fileprivate func evaluateInitialConnectionToServer() {
        if UserDefaults.standard.bool(forKey: WLConnectToFastestServerInCountry) == true {
            if let countries = self.apiManager.fetchAllCountries() as? [Country],
                let selectedCountryName = UserDefaults.standard.value(forKey: WLSelectedCountry) as? String,
                let selectedCountry = countries.filter({$0.name == selectedCountryName}).first {
                self.apiManager.vpnConfiguration.country = selectedCountry
                self.apiManager.vpnConfiguration.server = nil
            }
        } else if UserDefaults.standard.bool(forKey: WLConnectToFastestServer) == true {
            self.apiManager.vpnConfiguration.country = nil
            self.apiManager.vpnConfiguration.server = nil
        }
        shouldConnectAtStartUp = false
        self.apiManager.connect()
    }
}

//MARK: - VPN Account Status Reporting Conformance

extension MainWindowController : VPNAccountStatusReporting {
    
    func statusLogoutWillBegin(_ notification: Notification) {
        connectView.vpnConnectButton.isClickable = false
    }
    
    /// Displays an alert dialog informing the user the the login failed.
    ///
    /// - parameter notification: The vpn notification.
    func statusLoginFailed(_ notification: Notification) {
        connectView.vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
        
        if currentView != loginViewController.view {
            displayAlert(informativeText: NSLocalizedString("LoginFailedGeneral", comment: "LoginFailedGeneral"), messageText: NSLocalizedString("LoginFailedTitle", comment: "LoginFailedTitle"))
        }
    }
    
    /// Updates the button of the login button text to indicate login status.
    func statusLoginWillBegin(_ notification: Notification) {
        connectView.vpnConnectButton.buttonText =  NSLocalizedString("LoggingIn", comment: "LoggingIn")
    }
    
    /// Shows the appropriate screen after a successful login. Will show the 
    /// dashboard or the connected screen if an OnDemand connection is 
    /// currently underway.
    ///
    /// - parameter notification: The vpn notification.
    func statusLoginSucceeded(_ notification: Notification) {
        if currentView is ConnectView {
            connectView.vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
        }
        manageConnectionViews()
    }
    
    /// Resets the title of the header view and displays the write header view
    /// UI when the user successfully logs out.
    func statusLogoutSucceeded(_ notification: Notification) {
		showLoginView()
    }
}

//MARK: - Connection Status Reporting Conformance

extension MainWindowController : VPNConnectionStatusReporting {
    func statusConnectionFailed(_ notification: Notification) {
        updateAppliedViewForDisconnectOrFailure()
        
        //connectionView
        connectView.toggleUIForEnabledState(isEnabled: true)
        connectView.vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
    }
    
    func statusConnectionWillBegin(_ notification: Notification) {
        if currentView is ConnectView {
            showLoadingView()
        }
        
        connectView.toggleUIForEnabledState(isEnabled: false)
        connectView.vpnConnectButton.buttonText = NSLocalizedString("Connecting", comment: "Connecting...")
    }
    
    func statusConnectionSucceeded(_ notification: Notification) {
        //If we also connect from the Server List then just stay there and don't
        //swap.
        if currentView is LoadingView {
            showDisconnectView()
        }
        
        //connectionView
        connectView.toggleUIForEnabledState(isEnabled: true)
        connectView.vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
    }
    
    func statusConnectionDidDisconnect(_ notification: Notification) {
        updateAppliedViewForDisconnectOrFailure()
        
        //connectionView
        connectView.toggleUIForEnabledState(isEnabled: true)
        connectView.vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
    }
}

//MARK: - VPN Helper Status Reporting Conformance

extension MainWindowController : VPNHelperStatusReporting {

    func statusHelperShouldInstall(_ notification: Notification) {
        if vpnConfiguration?.getSelectedProtocolName() == kVPNProtocolIKEv2 {
            //Should install the helper silently since a password won't be required for IKEV2 helper.
            apiManager.installHelperAndConnect(onInstall: true)
            connectView.vpnConnectButton.isClickable = true
        }
    }

    func statusHelperDidInstall(_ notification: Notification) {
        //IKEV2 helper will be installed silently and should never require an
        //explicit helper dialog from the user. OpenVPN should connect after a
        //successful helper installation.
        if vpnConfiguration?.getSelectedProtocolName() != kVPNProtocolIKEv2 {
            apiManager.connect()
        }
    }
    
    func statusHelperInstallFailed(_ notification: Notification) {
        connectView.vpnConnectButton.isClickable = true
        connectView.vpnConnectButton.buttonText = NSLocalizedString("Connect", comment: "Connect")
    }
}

//MARK: - VPNConfiguration Status Reporting Conformance

extension MainWindowController : VPNConfigurationStatusReporting {
    
    func statusCurrentLocationDidChange(_ notification: Notification) {
        
        if let assignedIpAddress = vpnConfiguration?.currentLocation?.ipAddress {
            disconnectView.ipAddressLabel.stringValue = assignedIpAddress
        } else {
            disconnectView.ipAddressLabel.stringValue = NSLocalizedString("IPAddressError", comment: "IP Address Error")
        }        
    }
    
    func statusCurrentCityDidChange(_ notification: Notification) {
        if let currentCity = vpnConfiguration?.city {
            connectView.locationNameLabel.stringValue = currentCity.locationString()
        } else {
            connectView.locationNameLabel.stringValue = NSLocalizedString("FastestAvailable", comment: "Fastest Available Text")
        }
        updateTouchBar()
    }
}

extension MainWindowController : ConnectViewDelegate {
    func didSelectConnect() {
        connectView.vpnConnectButton.isClickable = false
        apiManager.connect()
    }
    
    func didSelectChooseLocation() {
		serverViewController.vpnConfiguration = self.vpnConfiguration
        serverViewController.view.window?.title = NSLocalizedString("Servers", comment: "")
        serverViewController.view.window?.windowController?.showWindow(self)
    }
}

extension MainWindowController : LoadingViewDelegate {
    func didSelectCancelConnect() {
        apiManager.disconnect()
    }
    
}

extension MainWindowController : DisconnectViewDelegate {
    
    //MARK: - OnDemand Management
    
    /// Checks the VPN Configuration to see if the On Demand option has been
    /// enabled.
    ///
    /// - Returns: Returns true if the On Demand option is currently enabled.
    fileprivate func isOnDemandOptionsEnabled() -> Bool {
        
        var isOnDemandEnabled = false
        
        if let onDemandOption = vpnConfiguration?.getOptionForKey(kOnDemandAlwaysOnKey) as? Int, onDemandOption == 1 {
            isOnDemandEnabled = true
        }
        
        return isOnDemandEnabled
    }
    
    func didSelectDisconnect() {
        if isOnDemandOptionsEnabled() == true {
            confirmVPNDisconnect()
        } else {
            apiManager.disconnect()
        }
    }
    
    // Display an alert window to the user confirming that they wish to disconnect.
    /// Attempts to disconnect if the user confirms they wish to disconnect.
    fileprivate func confirmVPNDisconnect() {
        guard let window = self.window else { return }
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("Disconnect", comment: "Disconnect"))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel"))
        alert.informativeText = NSLocalizedString("OnDemandConfirm", comment: "OnDemandConfirm")
        alert.alertStyle = NSAlert.Style.informational
        
        alert.beginSheetModal(for: window) { (selectedResponseCode) in
            if selectedResponseCode == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.manageOnDemandDisconnect()
            }
        }
    }
    
    /// When a user has confirmed that they wish to disconnect when OnDemand has
    /// been enabled, we disconnect from the VPN, turn off the OnDemand option
    /// on the VPNConfiguration and then install a new VPN helper that will reflect
    /// these OnDemand updated changes. This function also posts a app specific notification
    /// so that the preferences window can update it's UI to reflect this preference
    /// being turned off automatically.
    fileprivate func manageOnDemandDisconnect() {
        apiManager.disconnect()
        vpnConfiguration?.setOption(0, forKey: kOnDemandAlwaysOnKey)
        apiManager.installHelperAndConnect(onInstall: false)
        NotificationCenter.default.post(name: Notification.Name(WLOnDemandOptionChangedNotification), object: nil, userInfo: nil)
    }
}

extension MainWindowController: VPNServerStatusReporting {
    func statusServerUpdateSucceeded(_ notification: Notification) {
        if shouldConnectAtStartUp == true {
            evaluateInitialConnectionToServer()
        }
    }
}

extension MainWindowController : CredentialsViewToggleDelegate {
	func switchToSignup() {
        if Theme.enableIAP {
            swapView(to: signupViewController.colorView)
        } else {
            NSWorkspace.shared.open(URL(string: Theme.signupURL)!)
        }
	}
	
	func switchToLogin() {
		swapView(to: loginViewController.colorView)
	}
}

extension MainWindowController {
	
	@objc func userDidSignup() {
		swapView(to: productsViewController.colorView)
	}
}

extension MainWindowController {
	@objc func userDidSelectPlan(notification: Notification) {
		purchaseViewController.selectedPlan = notification.object as? Plan
		swapView(to: purchaseViewController.colorView)
	}
}
