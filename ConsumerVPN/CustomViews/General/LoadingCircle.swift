//
//  LoadingCircle.swift
//  Consumer VPN
//
//  Created by Jonathan Fuentes on 3/21/19.
//  Copyright © 2019 WLVPN. All rights reserved.
//

import Cocoa

class LoadingCircle: NSView {
    
    let outerCircleLayer = CAShapeLayer()
    
    override func layout() {
        super.layout()
        
        //Animation
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.byValue = NSNumber(value: 2 * Double.pi)
        rotation.duration = 1.5
        rotation.repeatCount = Float.infinity
        outerCircleLayer.add(rotation, forKey: "lineRotation")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let circleColor = NSColor.primaryAccent
        
        //Inner circle
        let innerCircleLenght = dirtyRect.width - 60
        let xMargin = (dirtyRect.width - innerCircleLenght) / 2
        let yMargin = (dirtyRect.height - innerCircleLenght) / 2
        let innerCircleRect = NSRect(x: xMargin, y: yMargin, width: innerCircleLenght, height: innerCircleLenght)
        
        let innerCircle = NSBezierPath(ovalIn: innerCircleRect)
        innerCircle.lineWidth = 2
        circleColor.setStroke()
        innerCircle.stroke()
        
        //Outer circle
        let center = CGPoint(x: dirtyRect.width / 2.0, y: dirtyRect.height / 2.0)
        let radius = (dirtyRect.width / 2.0) * 0.90
        let arcEndAngle = 0.3 * CGFloat.pi
        let outerCirclePath = NSBezierPath()
        outerCirclePath.addArcWithCenter(center: center, radius: radius, startAngle: 0, endAngle: arcEndAngle, clockwise: false)
        
        layer?.addSublayer(outerCircleLayer)

        var bounds = CGRect(x: 300, y: 300, width: dirtyRect.width, height: dirtyRect.height)
        bounds.origin = CGPoint.zero
        outerCircleLayer.bounds = bounds
        outerCircleLayer.position = CGPoint(x: dirtyRect.width / 2, y: dirtyRect.height / 2)
        outerCircleLayer.path = outerCirclePath.cgPath
        outerCircleLayer.fillColor = NSColor.clear.cgColor
        outerCircleLayer.lineWidth = 5
        outerCircleLayer.strokeColor = circleColor.cgColor
        outerCircleLayer.lineCap = CAShapeLayerLineCap.round
        
        //Label
        let label = NSTextField.init()
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.textColor = circleColor
        label.font = NSFont.systemFont(ofSize: 22)
        label.stringValue = NSLocalizedString("Connecting...", comment: "")
        label.sizeToFit()
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: NSWidth(label.frame)).isActive = true
        label.heightAnchor.constraint(equalToConstant: NSHeight(label.frame)).isActive = true
    }
}
