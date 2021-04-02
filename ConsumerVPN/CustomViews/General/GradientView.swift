//
//  ColorView.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/29/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import Cocoa
import QuartzCore

@IBDesignable
class GradientView : NSView {
    
    //MARK: - Properties 
    
	@IBInspectable internal var topColor : NSColor? {
		didSet {
			if bottomColor == nil {
				bottomColor = topColor
			}
			
			setupView()
		}
	}
	
	@IBInspectable internal var bottomColor : NSColor? {
		didSet {
			if topColor == nil {
				topColor = bottomColor
			}
			
			setupView()
		}
	}

    //MARK: - Init 
    
    override func awakeFromNib() {
        super.awakeFromNib()
		
//		setupView()
    }
	
	override func prepareForInterfaceBuilder() {
		setupView()
	}
	
	func setupView() {
		wantsLayer = true
		
		let gradient = CAGradientLayer()
		
		gradient.frame = bounds
		gradient.colors = [
			topColor!.cgColor,
			bottomColor!.cgColor
		]
		
		gradient.startPoint = CGPoint(x:0.0, y: 1.0)
		gradient.endPoint = CGPoint(x:0.0, y:0.3)
		
		layer = gradient
	}

    func viewDidAppear(_ animated: Bool) {

    }
}
