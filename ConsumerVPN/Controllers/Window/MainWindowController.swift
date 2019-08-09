//
//  MainWindowController.swift
//  WhiteLabelVPN
//
//  Created by Zephaniah Cohen on 9/8/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import AppKit

class MainWindowController : BaseWindowController {
    
    //MARK: - Properties
    
    @IBOutlet weak var backgroundView: ColorView!
    @IBOutlet weak var contentView: NSView!

    fileprivate var currentViewController : NSViewController!
    
    fileprivate lazy var disconnectViewController : DisconnectViewController = {
        
        let disconnectViewController = DisconnectViewController.newWith(apiManager: apiManager)
        
        return disconnectViewController
    }()
    
    fileprivate lazy var connectViewController : ConnectViewController = {
        let connectViewController = ConnectViewController.newWith(apiManager: apiManager)
        
        return connectViewController
    }()
    
    fileprivate lazy var loginViewController : LoginViewController = {
		let loginViewController = LoginViewController.newWith(apiManager: apiManager)
        
        return loginViewController
    }()
    
    fileprivate lazy var serverViewController : ServerViewController = {
        let serverViewController = serverWindowController
        return serverViewController.contentViewController as! ServerViewController
    }()
    
    fileprivate lazy var serverWindowController : ServerWindowController = {
        let serverWindowController = ServerWindowController.newWith(apiManager: apiManager)
        return serverWindowController
    }()
    
    
    
    fileprivate lazy var loadingViewController : LoadingViewController = {
        let loadingViewController = LoadingViewController.newWith(apiManager: apiManager)
        return loadingViewController
    }()
    
    //MARK: - Window Management
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        NotificationCenter.default.addObserver(for: self)
        
        themeWindow()
        
        //headerView.delegate = self
        connectViewController.delegate = self
        
        if vpnConfiguration?.user == nil {
            showLoginView()
        } else {
            manageConnectionViews()
        }
    }
    
    /// Shows the appropriate view controller view based upon active VPN connection
    /// state.
    fileprivate func manageConnectionViews() {
        if apiManager.isConnectedToVPN() == false {
            showConnectView()
        } else {
            showDisconnectView()
        }
    }
    
    /// Swaps back to the connect view controller only if we are on the disconnect
    /// view controller and not on the server list.
    fileprivate func updateAppliedViewForDisconnectOrFailure() {
        if currentViewController is DisconnectViewController || currentViewController is LoadingViewController {
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
    
    //MARK: - View Swap Functions
    
    /// Shows the loginViewController, presenting it with the correct animation.
    internal func showLoginView() {
        swapViewController(currentViewController: loginViewController)
    }
    
    /// Shows the connectViewController, presenting it with the correct animation.
    internal func showConnectView() {
        swapViewController(currentViewController: connectViewController)
    }
    
    /// Shows the connectViewController, presenting it with the correct animation.
    internal func showLoadingView() {
        swapViewController(currentViewController: loadingViewController)
    }
    
    /// Shows the disconnectViewController, presenting it with the correct animation.
    internal func showDisconnectView() {
        swapViewController(currentViewController: disconnectViewController)
    }
    
    /// Swaps the currentViewController with the provided viewController.Applies
    /// a fade transition animation when swapping view controllers.
    ///
    /// - parameter viewController: The view controller to swap in.
    fileprivate func swapViewController(currentViewController viewController : NSViewController)  {
        
        if let _ = currentViewController {
            contentView.replaceSubview(currentViewController.view, with: viewController.view)
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0).isActive = true
            viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0).isActive = true
            viewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0.0).isActive = true
            viewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0.0).isActive = true
            contentView.layoutSubtreeIfNeeded()
        } else {
            
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(viewController.view)

            viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0).isActive = true
            viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0).isActive = true
            viewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0.0).isActive = true
            viewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0.0).isActive = true
        }
        
        currentViewController = viewController
    }
    
    @IBAction func didSelectServers(_ sender: Any) {
        shouldDisplayServerViewController()
    }
}

//MARK: - Connect View Controller Delegate

extension MainWindowController : ConnectViewControllerDelegate {
    func shouldDisplayServerViewController() {
        serverViewController.delegate = self
        serverViewController.view.window?.windowController?.showWindow(self)
    }
}

//MARK: - Main Window Header View Delegate

extension MainWindowController : ServerListViewDelegate {
    func didClickBackButton() {
        serverWindowController.close()
    }
}

//MARK: - VPN Account Status Reporting Conformance

extension MainWindowController : VPNAccountStatusReporting {
    
    /// Shows the appropriate screen after a successful login. Will show the 
    /// dashboard or the connected screen if an OnDemand connection is 
    /// currently underway.
    ///
    /// - parameter notification: The vpn notification.
    func statusLoginSucceeded(_ notification: Notification) {
        manageConnectionViews()
    }
    
    /// Resets the title of the header view and displays the write header view
    /// UI when the user successfully logs out.
    func statusLogoutSucceeded() {
		showLoginView()
    }
}

//MARK: - Connection Status Reporting Conformance

extension MainWindowController : VPNConnectionStatusReporting {
    func statusConnectionFailed(_ notification: Notification) {
        updateAppliedViewForDisconnectOrFailure()
    }
    
    func statusConnectionWillBegin() {
        if currentViewController is ConnectViewController {
            showLoadingView()
        }
    }
    
    func statusConnectionSucceeded() {
        //If we also connect from the Server List then just stay there and don't
        //swap.
        if currentViewController is LoadingViewController {
            showDisconnectView()
        }
    }
    
    func statusConnectionDidDisconnect() {
        updateAppliedViewForDisconnectOrFailure()
    }
}

//MARK: - VPN Helper Status Reporting Conformance

extension MainWindowController : VPNHelperStatusReporting {

    func statusHelperShouldInstall(_ notification: Notification) {
        if vpnConfiguration?.getSelectedProtocolName() == kVPNProtocolIKEv2 {
            //Should install the helper silently since a password won't be required for IKEV2 helper.
            apiManager.installHelperAndConnect(onInstall: true)
            self.connectViewController.vpnConnectButton.isClickable = true
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
}
