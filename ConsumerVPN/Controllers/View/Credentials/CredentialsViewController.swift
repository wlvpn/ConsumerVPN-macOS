//
//  CredentialsViewController.swift
//  ConsumerVPN
//
//  Created by Fernando Olivares on 10/9/20.
//  Copyright © 2020 WLVPN. All rights reserved.
//

import Foundation

public enum FieldType : UInt {
	case user = 0
	case password = 1
}

protocol CredentialsViewToggleDelegate {
	func switchToSignup()
	func switchToLogin()
}

class CredentialsViewController : BaseViewController {
	
	var toggleDelegate: CredentialsViewToggleDelegate!
	
	//MARK: - Properties
	@IBOutlet weak var userImage: NSImageView! {
		didSet {
			userImage.themed()
		}
	}
	@IBOutlet weak var passwordImage: NSImageView! {
		didSet {
			passwordImage.themed()
		}
	}
	
	@IBOutlet weak var gradientContainerView: NSView! {
		didSet {
			gradientContainerView.wantsLayer = true
			
			// Color layer
			let gradient = CAGradientLayer()
			gradient.frame = view.frame
			gradient.colors = [NSColor.loginViewGradientTop.cgColor,
							   NSColor.loginViewGradientMid.cgColor,
							   NSColor.loginViewGradientBottom.cgColor]
			gradient.locations = [0.0, 0.55, 1.0]
			gradient.startPoint = CGPoint(x: 0.9, y: 0)
			gradient.endPoint = CGPoint(x: 0, y: 0.9)
			gradientContainerView.layer?.insertSublayer(gradient, at: 0)
			
			// Taller triangle
			let startX: CGFloat = 0
			let startY: CGFloat = 0
			var maxX: CGFloat = gradientContainerView.frame.size.width * 0.7
			var maxY: CGFloat = gradientContainerView.frame.size.height * 0.4
			let tallTrianglePath = NSBezierPath()
			tallTrianglePath.move(to: CGPoint(x: startX, y: startY))
			tallTrianglePath.line(to: CGPoint(x: startX, y: maxY))
			tallTrianglePath.line(to: CGPoint(x: maxX, y: startY))
			tallTrianglePath.line(to: CGPoint(x: startX, y: startY))
			tallTrianglePath.close()
			let tallTriangleLayer = CAShapeLayer()
			tallTriangleLayer.path = tallTrianglePath.cgPath
			tallTriangleLayer.fillColor = NSColor.loginViewTallTriangleBg.cgColor
			tallTriangleLayer.shadowColor = NSColor.loginViewTallTriangleShadow.cgColor
			tallTriangleLayer.shadowOffset = CGSize(width: 0.0, height: -10.0)
			tallTriangleLayer.shadowRadius = 16.0
			tallTriangleLayer.shadowOpacity = 0.6
			gradientContainerView.layer?.insertSublayer(tallTriangleLayer, at: 1)

			// Short, wide triangle
			maxY = gradientContainerView.frame.size.height * 0.2
			maxX = gradientContainerView.frame.size.width * 0.95
			let shortTrianglePath = NSBezierPath()
			shortTrianglePath.move(to: CGPoint(x: startX, y: startY))
			shortTrianglePath.line(to: CGPoint(x: startX, y: maxY))
			shortTrianglePath.line(to: CGPoint(x: maxX, y: startY))
			shortTrianglePath.line(to: CGPoint(x: startX, y: startY))
			shortTrianglePath.close()
			let shortTriangleLayer = CAShapeLayer()
			shortTriangleLayer.path = shortTrianglePath.cgPath
			shortTriangleLayer.fillColor = NSColor.loginViewShortTriangleBg.cgColor
			shortTriangleLayer.shadowColor = NSColor.loginViewShortTriangleShadow.cgColor
			shortTriangleLayer.shadowOffset = CGSize(width: 0.0, height: -10.0)
			shortTriangleLayer.shadowRadius = 16.0
			shortTriangleLayer.shadowOpacity = 0.6
			gradientContainerView.layer?.insertSublayer(shortTriangleLayer, at: 2)
		}
	}
	@IBOutlet weak var usernameTextField : WLCustomTextField! {
		didSet {
			usernameTextField.setColor(NSColor.loginViewText)
			usernameTextField.placeholderString = "Username"
			usernameTextField.setAccessibilityIdentifier("Username Field")
		}
	}
	@IBOutlet weak var passwordTextField : WLCustomSecureTextField! {
		didSet {
			passwordTextField.setColor(NSColor.loginViewText)
			passwordTextField.placeholderString = "Password"
			passwordTextField.setAccessibilityIdentifier("Password Field")
		}
	}
	@IBOutlet weak var userNameUnderlineView : ColorView! {
		didSet {
			userNameUnderlineView.backgroundColor  = NSColor.loginViewUsernameAccent
		}
	}
	@IBOutlet weak var passwordUnderlineView : ColorView! {
		didSet {
			passwordUnderlineView.backgroundColor  = NSColor.loginViewPasswordAccent
		}
	}
	@IBOutlet weak var submitButton : CustomButton! {
		didSet {
			submitButton.textColor       = NSColor.loginButtonText
			submitButton.backgroundColor = NSColor.loginButton
			submitButton.borderColor     = NSColor.loginButton
		}
	}
	@IBOutlet weak var toggleLoginSignupButton : CustomButton! {
		didSet {
			toggleLoginSignupButton.isHidden = (Theme.signupURL.count == 0)
			toggleLoginSignupButton.textColor = NSColor.forgotPasswordButtonText
			toggleLoginSignupButton.setAccessibilityIdentifier("Signup Button")
		}
	}
	@IBOutlet weak var credentialsTitleLabel: NSTextField! {
		didSet {
			credentialsTitleLabel.textColor = NSColor.loginViewText
			credentialsTitleLabel.stringValue = NSLocalizedString("Login", comment: "Login title")
		}
	}
		
	//MARK: - View Management
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setTouchBarItems()

		NotificationCenter.default.addObserver(self,
											   selector: #selector(self.updateTextFields),
											   name: NSNotification.Name(rawValue: WLLoginFieldSelectionNotification),
											   object: nil)
		
		backgroundColor = NSColor.loginViewBackground
		colorView.backgroundColor = backgroundColor
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()

		//Animated in in on view did appear.
		usernameTextField.alphaValue = 0
		passwordTextField.alphaValue = 0
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		usernameTextField.becomeFirstResponder()
		textFieldsValidation()
		
		animate(textField: usernameTextField)
		animate(textField: passwordTextField)
	}
	
	override func viewDidDisappear() {
		super.viewDidDisappear()

		//This should be reset back to the original starting values.
		submitButton.buttonText =  NSLocalizedString("LoginGeneral", comment: "Starting login state")

		if Theme.signupURL.count > 0 {
			toggleLoginSignupButton.isHidden = false
		}
	}
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: WLLoginFieldSelectionNotification),
                                                  object: nil)
    }
	
	//MARK: - Signup/Login Click Handlers
	
	/// Begins the account signup logic.
	///
	/// - Parameter sender: The CustomButton
	@IBAction func toggleLoginSignup(_ sender: Any) { }
	
	/// Begins the accoung login logic
	///
	/// - Parameter sender: The CustomButton
	@IBAction func submit(_ sender: Any) { }
   
	/// Routes the user to the account signup URL in the web browser.
	fileprivate func signup() {
		NSWorkspace.shared.open(URL(string: Theme.signupURL)!)
	}
	
	/// Validates the user credentials and attempts to login if the credentials
	/// are valid.
	func login() {
		
		let userName = usernameTextField.stringValue
		let password = passwordTextField.stringValue
		
		if userName.isEmpty || password.isEmpty {
			displayAlert(informativeText: NSLocalizedString("InvalidCredentials", comment: "InvalidCredentials"), messageText: NSLocalizedString("InvalidCredentialsTitle", comment: "InvalidCredentialsTitle"))
			
		} else {
            ApiManagerHelper.shared.loginWith(forUsername: userName, password: password)
		}
	}
	
	/// Animates the width constraint of the login button to increase the width
	/// of the button to stretch accross the view and hide the signup button.
	///
	/// - Parameters:
	///   - animationDuration: The amount of time for the animation to be performed in.
	///   - shouldHideSignupButton: Flag indicating if the signup button should be hidden or not.
	///   - loginButtonText: The text to display in the login button.
	func animateSubmitButtonTransition(animationDuration : CGFloat,
									   shouldHideSignupButton : Bool,
									   loginButtonText : String) {

		if Theme.signupURL.count > 0 {
			toggleLoginSignupButton.isHidden = shouldHideSignupButton
		}

		NSAnimationContext.runAnimationGroup({ (animationContext) in
			animationContext.duration = TimeInterval(animationDuration)
			animationContext.allowsImplicitAnimation = true
			submitButton.buttonText = loginButtonText
			view.layoutSubtreeIfNeeded()
		}){}
	}

	
	@objc func updateTextFields(notification:NSNotification) {
		if notification.userInfo!["type"] as! String == "User" {
			swapFieldsColors(with: .user)
		} else {
			swapFieldsColors(with: .password)
		}
	}
	
	func swapFieldsColors(with type: FieldType) {
		var userColor = NSColor.loginViewUsernameAccent
		var passColor = NSColor.loginViewPasswordAccent
		switch type {
		case .user:
			userColor = NSColor.loginViewUsernameHighlight
			break
		case .password:
			passColor = NSColor.loginViewPasswordHighlight
			break
		}
		
		userImage.tinted(withTintColor: userColor)
		userNameUnderlineView.backgroundColor = userColor
		passwordImage.tinted(withTintColor: passColor)
		passwordUnderlineView.backgroundColor = passColor
	}
	
	// MARK: - Used by subclasses
	
	func animate(textField: NSTextField) {
		let opacityFadeAnimation = Animations.opacityFadeAnimation(startingAlphaValue: 0,
																   endingAlphaValue: 1,
																   animationDuration: 0.7,
																   animationName: "opacityFade")
		
		textField.layer?.add(opacityFadeAnimation, forKey: "opacityFade")
		
		textField.alphaValue = 1.0
	}
	
	func setTouchBarItems() { }
	
	func textFieldsValidation() { }
	
	/// Displays an alert controller window dialog with the supplied message and
	/// title.
	///
	/// - parameter informativeText: The alert informative text.
	/// - parameter messageText: The alert message text.
	func displayAlert(informativeText : String, messageText : String) {
		
		let alert = NSAlert()
		alert.informativeText = informativeText
		alert.messageText = messageText
		
		if let window = view.window {
			alert.beginSheetModal(for: window, completionHandler: nil)
		}
		
	}
}

extension CredentialsViewController: NSTextFieldDelegate {
	func controlTextDidChange(_ obj: Notification) {
		textFieldsValidation()
	}
}

