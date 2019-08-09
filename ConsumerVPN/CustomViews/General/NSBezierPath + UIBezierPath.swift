//
//  NSBezierPath + UIBezierPath.swift
//  Consumer VPN
//
//  Created by Jonathan Fuentes on 3/21/19.
//  Copyright © 2019 WLVPN. All rights reserved.
//

import Foundation

extension NSBezierPath {
    
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            }
        }
        
        return path
    }
    
    func addArcWithCenter(center: NSPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        let startAngleRadian = ((startAngle) * (180.0 / .pi))
        let endAngleRadian = ((endAngle) * (180.0 / .pi))
        appendArc(withCenter: center, radius: radius, startAngle: startAngleRadian, endAngle: endAngleRadian)
    }
}
