//
//  AboutWindowController.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 10/19/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import AppKit

class AboutWindowController : BaseWindowController {
    
    //MARK: - Properties
    
    @IBOutlet var termsOfService: NSTextView!
    @IBOutlet weak var versionInformation: NSTextField!
    @IBOutlet weak var contentView: ColorView!
    
    //MARK: - Window Management
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        prepareViewProperties()
        displayVersionInformation()
    }
    
    /// Styles the UI appropriately per brand.
    fileprivate func prepareViewProperties() {
        
        contentView.wantsLayer = true
        
		contentView.backgroundColor = NSColor.aboutViewBackground
  
        window?.title = "About \(Theme.brandName)"

        let termsOfServicePath = Bundle.main.url(forResource: "tos", withExtension: "html")

        guard let termsOfServiceText = NSAttributedString(url: termsOfServicePath!) else {
            return
        }

        termsOfService.textStorage?.append(termsOfServiceText)
    }
    
    /// Displays the version and build number in the text field.
    fileprivate func displayVersionInformation() {
        
        let versionNumber  = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber   = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        
        versionInformation.stringValue = "Version: \(versionNumber) (\(buildNumber))"
    }
}

extension NSAttributedString {
    internal convenience init?(url: URL) {
        guard let html = try? String(contentsOf: url) else {
            return nil
        }

        guard let data = html.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
            return nil
        }

        guard let attributedString = try?  NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) else {
            return nil
        }

        self.init(attributedString: attributedString)
    }
}
