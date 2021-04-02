//
//  ShieldView.swift
//  ConsumerVPN
//
//  Created by Francisco Cantu on 12/06/20.
//  Copyright © 2020 WLVPN. All rights reserved.
//

import Cocoa

class ShieldView: NSView {
	@IBInspectable
	var isDisconnected : Bool = false
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		drawShield()
    }
	
	private func drawShield() {
		
		if Theme.drawCustomShield {
			if isDisconnected {
				drawCustomDisconnected()
			} else {
				drawCustom()
			}
			
			return
		}
		
		//// Color Declarations
		let gradientColor = NSColor.shieldGradientBottom
		let gradientColor2 = NSColor.shieldGradientTop
		let fillColor = NSColor.shieldCheckmark

		//// Gradient Declarations
		let linearGradient1 = NSGradient(colors: [gradientColor, gradientColor2], atLocations: [0.0, 1.0], colorSpace: NSColorSpace.sRGB)!

		//// Page-1
		//// CONNECTED
		//// connected-shield-
		//// Group- 6
		//// Fill-1 Drawing
		let fill1Path = NSBezierPath()
		fill1Path.move(to: NSPoint(x: 82.29, y: 58.45))
		fill1Path.curve(to: NSPoint(x: 48.06, y: 7.16), controlPoint1: NSPoint(x: 82.29, y: 36.04), controlPoint2: NSPoint(x: 68.8, y: 15.83))
		fill1Path.line(to: NSPoint(x: 48.04, y: 7.15))
		fill1Path.line(to: NSPoint(x: 42.52, y: 4.78))
		fill1Path.line(to: NSPoint(x: 37.72, y: 6.86))
		fill1Path.curve(to: NSPoint(x: 4.18, y: 57.87), controlPoint1: NSPoint(x: 17.37, y: 15.73), controlPoint2: NSPoint(x: 4.2, y: 35.75))
		fill1Path.line(to: NSPoint(x: 4.18, y: 85.57))
		fill1Path.line(to: NSPoint(x: 42.67, y: 106.58))
		fill1Path.line(to: NSPoint(x: 82.29, y: 85.55))
		fill1Path.line(to: NSPoint(x: 82.29, y: 58.45))
		fill1Path.close()
		fill1Path.move(to: NSPoint(x: 43.64, y: 110.76))
		fill1Path.curve(to: NSPoint(x: 41.66, y: 110.75), controlPoint1: NSPoint(x: 43.02, y: 111.09), controlPoint2: NSPoint(x: 42.28, y: 111.08))
		fill1Path.line(to: NSPoint(x: 1.11, y: 88.61))
		fill1Path.curve(to: NSPoint(x: 0.03, y: 86.79), controlPoint1: NSPoint(x: 0.44, y: 88.24), controlPoint2: NSPoint(x: 0.03, y: 87.55))
		fill1Path.line(to: NSPoint(x: 0.03, y: 57.87))
		fill1Path.curve(to: NSPoint(x: 36.06, y: 3.07), controlPoint1: NSPoint(x: 0.05, y: 34.1), controlPoint2: NSPoint(x: 14.19, y: 12.6))
		fill1Path.line(to: NSPoint(x: 41.69, y: 0.63))
		fill1Path.curve(to: NSPoint(x: 43.34, y: 0.63), controlPoint1: NSPoint(x: 42.21, y: 0.4), controlPoint2: NSPoint(x: 42.81, y: 0.4))
		fill1Path.line(to: NSPoint(x: 49.68, y: 3.35))
		fill1Path.curve(to: NSPoint(x: 86.45, y: 58.45), controlPoint1: NSPoint(x: 71.96, y: 12.67), controlPoint2: NSPoint(x: 86.45, y: 34.39))
		fill1Path.line(to: NSPoint(x: 86.45, y: 86.79))
		fill1Path.curve(to: NSPoint(x: 85.35, y: 88.62), controlPoint1: NSPoint(x: 86.45, y: 87.56), controlPoint2: NSPoint(x: 86.03, y: 88.26))
		fill1Path.line(to: NSPoint(x: 43.64, y: 110.76))
		fill1Path.close()
		fill1Path.windingRule = .evenOdd
		NSGraphicsContext.saveGraphicsState()
		fill1Path.addClip()
		linearGradient1.draw(from: NSPoint(x: 43.24, y: 55.73),
			to: NSPoint(x: 43.24, y: 108.17),
			options: [.drawsBeforeStartingLocation, .drawsAfterEndingLocation])
		NSGraphicsContext.restoreGraphicsState()

		//// Fill-4 Drawing
		let fill4Path = NSBezierPath()
		fill4Path.move(to: NSPoint(x: 27.13, y: 58.88))
		fill4Path.curve(to: NSPoint(x: 24.22, y: 59.1), controlPoint1: NSPoint(x: 26.39, y: 59.74), controlPoint2: NSPoint(x: 25.09, y: 59.84))
		fill4Path.curve(to: NSPoint(x: 23.99, y: 56.21), controlPoint1: NSPoint(x: 23.35, y: 58.37), controlPoint2: NSPoint(x: 23.25, y: 57.07))
		fill4Path.line(to: NSPoint(x: 34.88, y: 43.5))
		fill4Path.curve(to: NSPoint(x: 37.75, y: 43.23), controlPoint1: NSPoint(x: 35.61, y: 42.65), controlPoint2: NSPoint(x: 36.89, y: 42.53))
		fill4Path.line(to: NSPoint(x: 63.12, y: 63.8))
		fill4Path.curve(to: NSPoint(x: 63.42, y: 66.69), controlPoint1: NSPoint(x: 64.01, y: 64.52), controlPoint2: NSPoint(x: 64.14, y: 65.81))
		fill4Path.curve(to: NSPoint(x: 60.52, y: 66.99), controlPoint1: NSPoint(x: 62.7, y: 67.57), controlPoint2: NSPoint(x: 61.4, y: 67.71))
		fill4Path.line(to: NSPoint(x: 36.71, y: 47.69))
		fill4Path.line(to: NSPoint(x: 27.13, y: 58.88))
		fill4Path.close()
		fill4Path.windingRule = .evenOdd
		fillColor.setFill()
		fill4Path.fill()

	}
    
}
