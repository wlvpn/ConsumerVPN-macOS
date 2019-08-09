//
//  ColorView.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/29/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable class ColorView : NSView {
    
    //MARK: - Properties 
    
    @IBInspectable internal var backgroundColor : NSColor? {
        didSet {
            layer?.backgroundColor = backgroundColor?.cgColor
        }
    }
    
    //MARK: - Init 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wantsLayer = true
    }
}
