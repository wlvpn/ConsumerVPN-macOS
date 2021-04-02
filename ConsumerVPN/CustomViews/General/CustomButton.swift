//
//  CustomButton.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/30/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import AppKit

//MARK: - Custom Button Implementation

@IBDesignable class CustomButton : NSButton {
    
    //MARK: - Properties
    
    @IBInspectable var cornerRadius : Float = 0
    @IBInspectable var fontSize : Int = 13
    @IBInspectable var borderWidth : Float = 1.5
    @IBInspectable var shouldBoldText : Bool = false

    @IBInspectable var textColor : NSColor = NSColor.white {
        didSet {
            styleButtonText(textColor: textColor)
        }
    }

    @IBInspectable var borderColor : NSColor = NSColor.clear {
        didSet {
            layer?.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var backgroundColor : NSColor = NSColor.clear {
        didSet {
            layer?.backgroundColor = backgroundColor.cgColor
        }
    }

    @IBInspectable var buttonText : String  = "" {
        didSet {
            attributedTitle = NSAttributedString(string: buttonText , attributes: textAttributes)
        }
    }

    var isClickable = true {
        didSet {
            if isClickable == true {
                layer?.opacity = 1.0
            } else {
                layer?.opacity = 0.7
            }
        }
    }

    fileprivate var isSetup = false
    fileprivate var isSelected = false
    fileprivate var textAttributes = [NSAttributedString.Key:Any]()
    
    //MARK: - Inteface Builder Managemenet
    
    override func prepareForInterfaceBuilder() {
        configureView()
    }
    
    //MARK: - Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }
    
    //MARK: - View Configuration and Styling
    
    /// Configures the control UI elements and all styling options.
    internal func configureView() {
        if isSetup == false {
            isSetup = true
            styleView()
        }
    }
    
    /// Applies all the user defined runtime attributes. attriutes all have
    /// fallback values in case none were set in interface builder.
    fileprivate func styleView() {
        
        wantsLayer = true
        
        //We will use the attributed title for most things. Title will be 
        //empty.
        title = ""
        
        //Settings would be equivalent to 'Image Button' in interface builder.
        bezelStyle = NSButton.BezelStyle.smallSquare
        isBordered = false
        
        //Layer styling
        layer?.backgroundColor = backgroundColor.cgColor
        layer?.cornerRadius = CGFloat(cornerRadius)
        layer?.masksToBounds = true
        layer?.borderColor = borderColor.cgColor
        layer?.borderWidth = CGFloat(borderWidth)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
    
        textAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
     
        textAttributes[NSAttributedString.Key.foregroundColor] = textColor
        
        if shouldBoldText == true {
           textAttributes[NSAttributedString.Key.font] = NSFont.boldSystemFont(ofSize: CGFloat(fontSize))
        } else {
            textAttributes[NSAttributedString.Key.font] = NSFont.systemFont(ofSize: CGFloat(fontSize))
        }
        
        attributedTitle = NSAttributedString(string: buttonText , attributes: textAttributes)
    }
    
    /// Updates the text color for the button text field. Updates the selected
    /// text color to match the defined color.
    ///
    /// - parameter textColor: The color to change the button textfield text to.
    internal func styleButtonText(textColor : NSColor) {
        textAttributes[NSAttributedString.Key.foregroundColor] = textColor
        attributedTitle = NSAttributedString(string: buttonText , attributes: textAttributes)
    }
    
    //MARK: - Click Management
    
    override func mouseDown(with event: NSEvent) {
        
        if isClickable == true {
            isSelected = true
            layer?.opacity = 0.7
     
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        
        if isClickable == true {
            isSelected = false
            layer?.opacity = 1.0
    
            guard let target = target, let action = action else {
				// Could not process the button click because the target and action are nil.
                return
            }
            
            NSApp.sendAction(action, to: target, from: self)
        }
    }

    //MARK: - Cursor Rect Management
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: NSCursor.pointingHand)
    }
}
