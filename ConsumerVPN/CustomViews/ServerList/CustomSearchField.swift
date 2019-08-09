//
//  CustomSearchBar.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/28/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation

protocol CustomSearchFieldDelegate {
    func didEnterSearchText(searchText text : String)
    func didPressReturnKey(searchText text : String)
    func didPressBackSpaceKey()
    func didClearSearchField()
}

@IBDesignable class CustomSearchField : ColorView {

    //MARK: - Properties
    
    fileprivate var searchTextField : NSTextField!
    fileprivate var isSetup = false
    fileprivate let kMinimiumRequiredSearchText = 2
    
    var delegate : CustomSearchFieldDelegate?
    
    //MARK: - Init 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    //MARK: - Interface Builder Management
    
    override func prepareForInterfaceBuilder() {
       configure()
    }
    
    //MARK: - Configuration
    
    /// Configures all of the UI controls.
    ///
    /// - parameter customizationManager: Optionally provided customization manager
    /// for brand specific styling if necessary.
    internal func configure() {
        if isSetup == false {
            isSetup = true
            backgroundColor = NSColor.controlBackgroundColor
            wantsLayer = true
            layer?.cornerRadius = 6
            layer?.masksToBounds = true
            configureSearchField()
        }
    }

    /// Configures the search text field with appropriate settings and applies
    /// auto layout.
    fileprivate func configureSearchField() {
        
        //Apply the configurations
        
        searchTextField = NSTextField()
        searchTextField.drawsBackground = true
        searchTextField.focusRingType = NSFocusRingType.none
        searchTextField.cell?.wraps = false
        searchTextField.delegate = self
        searchTextField.cell?.isScrollable = false
        searchTextField.textColor = NSColor.black
        searchTextField.isBezeled = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholderString = NSLocalizedString("Search", comment: "Search")

        addSubview(searchTextField)
        
        //Apply the auto layout. 
        
        let searchTextFieldMetrics = [
            "rightPadding" : NSNumber(integerLiteral: 5),
            "leftPadding" : NSNumber(integerLiteral: 5),
            "topPadding" : NSNumber(integerLiteral: 5),
            "bottomPadding" : NSNumber(integerLiteral: 5)
        ]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftPadding-[searchTextField]-rightPadding-|", options: [], metrics: searchTextFieldMetrics, views:["searchTextField" : searchTextField]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-topPadding-[searchTextField]-bottomPadding-|", options: [], metrics: searchTextFieldMetrics, views:["searchTextField" : searchTextField]))
    }
    
    /// Clears the search field text and informs the delegate of these changes.
    internal func clearSearchField() {
        searchTextField.stringValue = ""
        delegate?.didClearSearchField()
    }
}

//MARK: - Textfield Delegate Functionality

extension CustomSearchField : NSTextFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        
        if commandSelector == #selector(deleteBackward(_:)) {
            delegate?.didPressBackSpaceKey()
        }
        
        return false
    }
    
    func controlTextDidChange(_ obj: Notification) {
        
        guard let textField = obj.object as? NSTextField else {
            return
        }
        
        if textField.stringValue.count > kMinimiumRequiredSearchText {
            delegate?.didEnterSearchText(searchText: textField.stringValue)
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        //Evaluates the selected keyboard action as the 'Return' key. If not this action
        //bail out.
        guard let selectedAction = obj.userInfo?["NSTextMovement"] as? Int , selectedAction == NSReturnTextMovement else {
            return
        }
        
 
        guard let textField = obj.object as? NSTextField, textField.stringValue.count > 0 else {
            return
        }

        delegate?.didPressReturnKey(searchText: textField.stringValue)
    }
}

