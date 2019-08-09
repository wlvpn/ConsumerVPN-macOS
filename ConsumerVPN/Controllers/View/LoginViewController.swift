//
//  LoginViewController.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/12/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation

class LoginViewController : BaseViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var gradientContainerView: NSView!
    @IBOutlet weak var usernameTextField : WLCustomTextField!
    @IBOutlet weak var passwordTextField : WLCustomSecureTextField!
    @IBOutlet weak var userNameUnderlineView : ColorView!
    @IBOutlet weak var passwordUnderlineView : ColorView!
    @IBOutlet weak var loginButton : CustomButton!
    @IBOutlet weak var signupButton : CustomButton!
    @IBOutlet weak var forgotUserNameTextField : ClickableTextField!
    @IBOutlet weak var loginTitleLabel: NSTextField!
    
    fileprivate var loginButtonStartingWidth : CGFloat!
    fileprivate var loginViewTextColor: NSColor!
    
    class func newWith(apiManager: VPNAPIManager) -> LoginViewController {
        let loginStoryboard = NSStoryboard(name: "Login", bundle: nil)
        let loginViewController = loginStoryboard.instantiateController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController.apiManager = apiManager
        loginViewController.vpnConfiguration = apiManager.vpnConfiguration
        
        return loginViewController
    }
    
    //MARK: - View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradientContainerView.wantsLayer = true

        NotificationCenter.default.addObserver(for: self)
        themeView()
        
        drawGradient()
        drawTriangles()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()

        //Animated in in on view did appear.
        usernameTextField.alphaValue = 0
        passwordTextField.alphaValue = 0
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()

        //This should be reset back to the original starting values.
        loginButton.buttonText =  NSLocalizedString("LoginGeneral", comment: "Starting login state")

        if Theme.signupURL.count > 0 {
            signupButton.isHidden = false
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        usernameTextField.becomeFirstResponder()
        
        let opacityFadeAnimation = Animations.opacityFadeAnimation(startingAlphaValue: 0, endingAlphaValue: 1, animationDuration: 0.7, animationName: "opacityFade")
        
        usernameTextField.layer?.add(opacityFadeAnimation, forKey: "opacityFade")
        passwordTextField.layer?.add(opacityFadeAnimation, forKey: "opacityFade")
        
        usernameTextField.alphaValue = 1.0
        passwordTextField.alphaValue = 1.0
    }
    
    func drawGradient() {
        // Background gradient layer
        let gradient = CAGradientLayer()
        gradient.frame = view.frame
        gradient.colors = [NSColor.loginViewGradientTop.cgColor, NSColor.loginViewGradientMid.cgColor, NSColor.loginViewGradientBottom.cgColor]
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x: 0.15, y: 0.9)
        gradientContainerView.layer?.insertSublayer(gradient, at: 0)
    }
    
    func drawTriangles() {
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
        tallTriangleLayer.shadowColor = NSColor.black.cgColor
        tallTriangleLayer.shadowOffset = CGSize(width: 0.0, height: -10.0)
        tallTriangleLayer.shadowRadius = 16.0
        tallTriangleLayer.shadowOpacity = 0.6
        gradientContainerView.layer?.insertSublayer(tallTriangleLayer, at: 1)

//        // Short, wide triangle
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
        shortTriangleLayer.shadowColor = NSColor(white: 0.08, alpha: 1.0).cgColor
        shortTriangleLayer.shadowOffset = CGSize(width: 0.0, height: -10.0)
        shortTriangleLayer.shadowRadius = 16.0
        shortTriangleLayer.shadowOpacity = 0.6
        gradientContainerView.layer?.insertSublayer(shortTriangleLayer, at: 2)
    }

    fileprivate func themeView() {
		backgroundColor = NSColor.loginViewBackground
        colorView.backgroundColor = backgroundColor
        
        loginTitleLabel.textColor = NSColor.loginViewText
        loginTitleLabel.stringValue = NSLocalizedString("Login", comment: "Login title")
		loginViewTextColor = NSColor.loginViewText

        // Set username text field colors
        usernameTextField.setColor(loginViewTextColor)
        userNameUnderlineView.backgroundColor  = loginViewTextColor

        // Set password text field colors
        passwordTextField.setColor(loginViewTextColor)
        passwordUnderlineView.backgroundColor  = loginViewTextColor

        // Set username text field strings
        usernameTextField.placeholderString = "Username"
        usernameTextField.setAccessibilityIdentifier("Username Field")

        // Set password text field strings
        passwordTextField.placeholderString = "Password"
        passwordTextField.setAccessibilityIdentifier("Password Field")

        forgotUserNameTextField.textColor = NSColor.forgotPasswordButtonText

        let loginButtonColor    : NSColor = NSColor.loginButton

        // Style the Login Button
        loginButton.textColor       = NSColor.loginButtonText
        loginButton.backgroundColor = loginButtonColor
        loginButton.borderColor     = loginButtonColor
        loginButton.setAccessibilityIdentifier("Login Button")

        loginButtonStartingWidth = loginButton.frame.size.width

        if Theme.signupURL.count == 0 {
            signupButton.isHidden = true
        } else {
            //Style the Signup Button
            signupButton.textColor       = NSColor.forgotPasswordButtonText
            signupButton.setAccessibilityIdentifier("Signup Button")
        }
        

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
        
        if let window = view.window {
            alert.beginSheetModal(for: window, completionHandler: nil)
        }
        
    }
    
    //MARK: - Signup/Login Click Handlers
    
    /// Begins the account signup logic.
    ///
    /// - Parameter sender: The CustomButton
    @IBAction func signupActionHandler(_ sender: Any) {
        signup()
    }
    
    /// Begins the accoung login logic
    ///
    /// - Parameter sender: The CustomButton
    @IBAction func loginActionHandler(_ sender: Any) {
        login()
    }
   
    /// Routes the user to the account signup URL in the web browser.
    fileprivate func signup() {
        NSWorkspace.shared.open(URL(string: Theme.signupURL)!)
    }
    
    /// Validates the user credentials and attempts to login if the credentials
    /// are valid.
    fileprivate func login() {
        
        let userName = usernameTextField.stringValue
        let password = passwordTextField.stringValue
        
        if userName.isEmpty || password.isEmpty {
            displayAlert(informativeText: NSLocalizedString("InvalidCredentials", comment: "InvalidCredentials"), messageText: NSLocalizedString("InvalidCredentialsTitle", comment: "InvalidCredentialsTitle"))
            
        } else {
            apiManager.login(withUsername: userName, password: password)
        }
    }
    
    /// Animates the width constraint of the login button to increase the width
    /// of the button to stretch accross the view and hide the signup button.
    ///
    /// - Parameters:
    ///   - animationDuration: The amount of time for the animation to be performed in.
    ///   - shouldHideSignupButton: Flag indicating if the signup button should be hidden or not.
    ///   - loginButtonWidth: The desired width for the login button.
    ///   - loginButtonText: The text to display in the login button.
    fileprivate func performLoginButtonTransitionAnimation(animationDuration : CGFloat, shouldHideSignupButton : Bool, loginButtonWidth : CGFloat, loginButtonText : String) {

        if Theme.signupURL.count > 0 {
            signupButton.isHidden = shouldHideSignupButton
        }

        NSAnimationContext.runAnimationGroup({ (animationContext) in
            animationContext.duration = TimeInterval(animationDuration)
            animationContext.allowsImplicitAnimation = true
            loginButton.buttonText = loginButtonText
            view.layoutSubtreeIfNeeded()
        }){}
    }
	@IBAction func forgotUsernameClicked(_ sender: Any) {
		NSWorkspace.shared.open(NSURL(string: Theme.forgotPasswordURL)! as URL)
	}
}

//MARK: - VPN Account Status Reporting

extension LoginViewController : VPNAccountStatusReporting {
    
    /// Displays an alert dialog informing the user the the login failed. Also
    /// enables the login button so the user can try again.
    ///
    /// - parameter notification: The vpn notification.
    func statusLoginFailed(_ notification: Notification) {
        displayAlert(informativeText: NSLocalizedString("LoginFailedGeneral", comment: "LoginFailedGeneral"), messageText: NSLocalizedString("LoginFailedTitle", comment: "LoginFailedTitle"))
        loginButton.isClickable = true
        signupButton.isClickable = true
        
        performLoginButtonTransitionAnimation(animationDuration: 0.3, shouldHideSignupButton: false, loginButtonWidth: loginButtonStartingWidth, loginButtonText: NSLocalizedString("LoginGeneral", comment: "Starting login state"))
    }
    
    /// Disables the login and signup buttons.
    func statusLoginWillBegin() {
        loginButton.isClickable = false
        signupButton.isClickable = false
        
        let expandedWidth : CGFloat = 355
        performLoginButtonTransitionAnimation(animationDuration: 0.3, shouldHideSignupButton: true, loginButtonWidth: expandedWidth, loginButtonText: NSLocalizedString("LoggingIn", comment: "Indicates active login."))
    }
    
    /// Clears the user name and password text fields so there are
    /// no previous credentials saved in the fields.
    ///
    /// - parameter notification: The vpn notification.
    func statusLoginSucceeded(_ notification: Notification) {
        usernameTextField.stringValue = ""
        passwordTextField.stringValue = ""
        loginButton.isClickable = true
        signupButton.isClickable = true
    }
}
