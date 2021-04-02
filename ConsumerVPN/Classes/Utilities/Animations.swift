//
//  Animations.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/30/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation

class Animations {

    //MARK: - Opacity Animations
    
    /// Builds an opacity fade animation that can be used to fade UI elements in
    /// and out over a specified duration.
    ///
    /// - parameter startingAlphaValue: The starting alpha value for the animation.
    /// - parameter endingAlphaValue:   The ending alpha value for the animation.
    /// - parameter animationDuration:  The animation fade time duration
    /// - parameter animationName:      The name of the animation which can be subscribed to in 
    /// CAAnimationDelegate to know when a particular animation has completed.
    ///
    /// - returns: A newly configured opacity fade animation.
    static func opacityFadeAnimation(startingAlphaValue : Float, endingAlphaValue : Float, animationDuration : Float, animationName : String) -> CABasicAnimation {
        
        let opacityFadeAnimation = CABasicAnimation(keyPath: "opacity")
        opacityFadeAnimation.fromValue = startingAlphaValue
        opacityFadeAnimation.toValue = endingAlphaValue
        opacityFadeAnimation.duration = CFTimeInterval(animationDuration)
        opacityFadeAnimation.setValue(animationName, forKey: "animationName")
        
        return opacityFadeAnimation
    }
}