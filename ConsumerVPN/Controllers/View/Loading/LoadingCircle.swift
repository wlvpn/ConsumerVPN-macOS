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
    let label = NSTextField.init()
    var width:CGFloat = 220
    var height:CGFloat = 220
    var message: String = "" {
        didSet {
            label.stringValue = NSLocalizedString(message, comment: "")
        }
    }
    
    override func layout() {
        super.layout()
        
        //Animation
        animation()
    }
    
    func animation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = NSNumber(value: 0)
        rotation.toValue = NSNumber(value: -2 * Double.pi)
        rotation.duration = 1.5
        rotation.repeatCount = Float.infinity
        outerCircleLayer.add(rotation, forKey: "lineRotation")
    }
    
    fileprivate func configureLabelMessage() {
        //Label
        if message.isEmpty {
            label.isHidden = true
            return
        }
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.textColor = NSColor.loadingAnimationLabelColor
        label.font = NSFont.systemFont(ofSize: 22)
        label.stringValue = NSLocalizedString(message, comment: "")
        label.sizeToFit()
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let size = CGSize(width: width, height: height)
        
        let circleColor = NSColor.loadingAnimationCircleColor
        //Inner circle
        drawInnerCircle(with: size, circleColor: circleColor)
        //Outer circle
        configureOuterCircleLayer(size: size, circleColor: circleColor)
        
        configureLabelMessage()
    }
    
    
    private func drawInnerCircle(with size: CGSize, circleColor: NSColor) {
        let innerCircleLength = min(size.width, size.height) - min(size.width, size.height)/4
        let xMargin = (size.width - innerCircleLength) / 2
        let yMargin = (size.height - innerCircleLength) / 2
        let innerCircleRect = NSRect(x: xMargin, y: yMargin, width: innerCircleLength, height: innerCircleLength)
        
        let innerCircle = NSBezierPath(ovalIn: innerCircleRect)
        innerCircle.lineWidth = 2
        circleColor.setStroke()
        innerCircle.stroke()
    }
        
   
    
    
    
    private func configureOuterCircleLayer(size: CGSize,  circleColor: NSColor) {
        var bounds = CGRect(origin: .zero, size: size)
        bounds.origin = .zero
        outerCircleLayer.bounds = bounds
        outerCircleLayer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = (min(size.width, size.height) / 2) * 0.90
        let arcEndAngle = 0.3 * CGFloat.pi
        let outerCirclePath = NSBezierPath()
        outerCirclePath.addArcWithCenter(center: center, radius: radius, startAngle: 0, endAngle: arcEndAngle, clockwise: false)
        
        outerCircleLayer.bounds = bounds
        outerCircleLayer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        outerCircleLayer.path = outerCirclePath.cgPath
        outerCircleLayer.fillColor = NSColor.clear.cgColor
        outerCircleLayer.lineWidth = 5
        outerCircleLayer.strokeColor = circleColor.cgColor
        outerCircleLayer.lineCap = CAShapeLayerLineCap.round
        layer?.addSublayer(outerCircleLayer)
    }
}
