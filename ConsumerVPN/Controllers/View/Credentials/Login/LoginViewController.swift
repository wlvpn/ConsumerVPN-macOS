//
//  LoginViewController.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/12/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation

class LoginViewController : CredentialsViewController {
    
    //MARK: - Properties
	@IBOutlet weak var forgotUserNameTextField : ClickableTextField! {
		didSet {
			forgotUserNameTextField.textColor = NSColor.forgotPasswordButtonText
			forgotUserNameTextField.action = #selector(self.forgotUsernameClicked(_:))
			forgotUserNameTextField.target = self
		}
	}
    
    //MARK: - View Management
	class func newWith(apiManager: VPNAPIManager, toggleDelegate: CredentialsViewToggleDelegate) -> LoginViewController {
		let loginStoryboard = NSStoryboard(name: "Login", bundle: nil)
		let loginViewController = loginStoryboard.instantiateController(withIdentifier: "LoginViewController") as! LoginViewController
		loginViewController.apiManager = apiManager
		loginViewController.toggleDelegate = toggleDelegate
		NotificationCenter.default.addObserver(for: loginViewController)
		
		return loginViewController
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		submitButton.setAccessibilityIdentifier("Login Button")
	}
	
    override func viewDidDisappear() {
        super.viewDidDisappear()

        // This should be reset back to the original starting values.
        submitButton.buttonText =  NSLocalizedString("LoginGeneral", comment: "Starting login state")
    }
	
	override func setTouchBarItems() {
		if #available(OSX 10.12.2, *) {
			colorView.customBarItems = [NSTouchBarItem.Identifier.flexibleSpace, NSTouchBarItem.Identifier.forgotPasswordItem, NSTouchBarItem.Identifier.fixedSpaceLarge, NSTouchBarItem.Identifier.signUpItem, NSTouchBarItem.Identifier.fixedSpaceLarge, NSTouchBarItem.Identifier.loginItem, NSTouchBarItem.Identifier.flexibleSpace]
		}
	}
    
    deinit {
        NotificationCenter.default.removeObserver(for: self)
    }
    
    //MARK: - Signup/Login Click Handlers
	@IBAction override func submit(_ sender: Any) {
        CommonSpinnerManager.shared.showSpinner(on: self.view)
        
        let userName = usernameTextField.stringValue
		let password = passwordTextField.stringValue
		
		if userName.isEmpty || password.isEmpty {
            CommonSpinnerManager.shared.hideSpinner()
			displayAlert(informativeText: NSLocalizedString("InvalidCredentials", comment: "InvalidCredentials"),
						 messageText: NSLocalizedString("InvalidCredentialsTitle", comment: "InvalidCredentialsTitle"))
			
		} else {
            ApiManagerHelper.shared.loginWith(forUsername: userName, password: password)
		}
        
	}
	
	@IBAction override func toggleLoginSignup(_ sender: Any) {
		toggleDelegate.switchToSignup()
	}
    
	@IBAction func forgotUsernameClicked(_ sender: Any) {
		NSWorkspace.shared.open(NSURL(string: Theme.forgotPasswordURL)! as URL)
	}
	
	override func textFieldsValidation() {
		submitButton.isClickable = (usernameTextField.stringValue != "" && passwordTextField.stringValue != "")
	}
}

//MARK: - VPN Account Status Reporting
extension LoginViewController : VPNAccountStatusReporting {
	
	/// Displays an alert dialog informing the user the the login failed. Also
	/// enables the login button so the user can try again.
	///
	/// - parameter notification: The vpn notification.
	func statusLoginFailed(_ notification: Notification) {
        CommonSpinnerManager.shared.hideSpinner()
		displayAlert(informativeText: NSLocalizedString("LoginFailedGeneral", comment: "LoginFailedGeneral"), messageText: NSLocalizedString("LoginFailedTitle", comment: "LoginFailedTitle"))
		submitButton.isClickable = true
		toggleLoginSignupButton.isClickable = true
		
		animateSubmitButtonTransition(animationDuration: 0.3,
									  shouldHideSignupButton: false,
									  loginButtonText: NSLocalizedString("LoginGeneral", comment: "Starting login state"))
	}
	
	/// Disables the login and signup buttons.
	func statusLoginWillBegin() {
		submitButton.isClickable = false
		toggleLoginSignupButton.isClickable = false
		
		animateSubmitButtonTransition(animationDuration: 0.3,
									  shouldHideSignupButton: true,
									  loginButtonText: NSLocalizedString("LoggingIn", comment: "Indicates active login."))
	}
	
	/// Clears the user name and password text fields so there are
	/// no previous credentials saved in the fields.
	///
	/// - parameter notification: The vpn notification.
	func statusLoginSucceeded(_ notification: Notification) {
        onLogin()
	}
    
    func statusAutomaticLoginSuceeded(_ notification: Notification) {
        onLogin()
    }
    
    func onLogin() {
        CommonSpinnerManager.shared.hideSpinner()
        usernameTextField.stringValue = ""
        passwordTextField.stringValue = ""
        submitButton.isClickable = true
        toggleLoginSignupButton.isClickable = true
    }
}
