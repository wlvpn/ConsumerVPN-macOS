//
//  SignupViewController.swift
//  ConsumerVPN
//
//  Created by Fernando Olivares on 10/9/20.
//  Copyright © 2020 WLVPN. All rights reserved.
//

import Foundation

class SignupViewController : CredentialsViewController {
	
	@IBOutlet weak var confirmPasswordImage: NSImageView! {
		didSet {
			confirmPasswordImage.themed()
		}
	}
	@IBOutlet weak var confirmPasswordTextField : WLCustomSecureTextField! {
		didSet {
			confirmPasswordTextField.setColor(NSColor.loginViewText)
			confirmPasswordTextField.placeholderString = "Confirm Password"
			confirmPasswordTextField.setAccessibilityIdentifier("Confirm Password Field")
		}
	}
	@IBOutlet weak var confirmPasswordUnderlineView : ColorView! {
		didSet {
			// FO: For some reason this doesn't work?
			// I've set the background color in viewDidLoad but would really like to have ith ere.
			confirmPasswordUnderlineView.backgroundColor  = NSColor.loginViewPasswordAccent
		}
	}
	
	fileprivate var purchaseCoordinator: PurchaseCoordinator!
	
	//MARK: - View Management
	class func newWith(apiManager: VPNAPIManager, toggleDelegate: CredentialsViewToggleDelegate, purchaseCoordinator: PurchaseCoordinator) -> SignupViewController {
		let signupStoryboard = NSStoryboard(name: "Signup", bundle: nil)
		let signupViewController = signupStoryboard.instantiateController(withIdentifier: "SignupViewController") as! SignupViewController
		signupViewController.apiManager = apiManager
		signupViewController.vpnConfiguration = apiManager.vpnConfiguration
		signupViewController.toggleDelegate = toggleDelegate
		signupViewController.purchaseCoordinator = purchaseCoordinator
		
		return signupViewController
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		credentialsTitleLabel.stringValue = NSLocalizedString("Sign Up", comment: "")
		
		submitButton.buttonText = NSLocalizedString("Sign Up", comment: "")
		submitButton.setAccessibilityIdentifier("Signup Button")
		
		toggleLoginSignupButton.buttonText = NSLocalizedString("Already have an account? LOG IN", comment: "")
		
		confirmPasswordUnderlineView.backgroundColor  = NSColor.loginViewPasswordAccent
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		confirmPasswordTextField.alphaValue = 0.0
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		// We clear just to be safe and make sure we have the latest info if cancelled
		purchaseCoordinator.cachedEmail = nil
		purchaseCoordinator.cachedPassword = nil
		
		animate(textField: confirmPasswordTextField)
	}
	
	override func viewDidDisappear() {
		super.viewDidDisappear()
		
		// This should be reset back to the original starting values.
		submitButton.buttonText =  NSLocalizedString("Sign Up", comment: "")
	}
	
	@IBAction override func submit(_ sender: Any) {
		let username = usernameTextField.stringValue
		let password = passwordTextField.stringValue
		let confirmPassword = confirmPasswordTextField.stringValue
		
		if username.isEmpty || password.isEmpty || confirmPassword.isEmpty || (password != confirmPassword) {
			displayAlert(informativeText: NSLocalizedString("InvalidCredentials", comment: "InvalidCredentials"), messageText: NSLocalizedString("InvalidCredentialsTitle", comment: "InvalidCredentialsTitle"))
		}
		else {
			purchaseCoordinator.cachedEmail = username
			purchaseCoordinator.cachedPassword = password
			NotificationCenter.default.post(name: NSNotification.Name("UserDidSignUp"), object: nil)
		}
	}
	
	@IBAction override func toggleLoginSignup(_ sender: Any) {
		toggleDelegate.switchToLogin()
	}
	
	override func textFieldsValidation() {
		submitButton.isClickable = (usernameTextField.stringValue != "" &&
										passwordTextField.stringValue != "" &&
										confirmPasswordTextField.stringValue != "")
	}
}
