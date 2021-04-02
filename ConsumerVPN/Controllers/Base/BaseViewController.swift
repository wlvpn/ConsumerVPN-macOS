//
//  BaseViewController.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/14/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import AppKit

class BaseViewController : NSViewController {
    
    //MARK: - Properties
    
    @objc internal var apiManager : VPNAPIManager!
    @objc internal var vpnConfiguration : VPNConfiguration?
    
    internal var backgroundColor : NSColor!
    internal var colorView : ColorView {
        get {
            return super.view as! ColorView
        }
    }
    
    var customBarItems: [Any] = []
    
    //MARK: - Init
    init?(nibName nibNameOrNil: String?, apiManager : VPNAPIManager) {
        self.apiManager = apiManager
        self.vpnConfiguration = apiManager.vpnConfiguration

        super.init(nibName: nibNameOrNil.map { $0 }, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

//MARK: - NSViewController Enhancements

extension NSViewController {
    
    /// Hides a view completely by altering the isHidden property and the
    /// opacity of the layer.
    ///
    /// - Parameter view: The view to hide.
    func hideView(view : NSView) {
        view.layer?.opacity = 0
        view.isHidden = true
    }
    
    /// Will apply a fade animation to a supplied view.
    ///
    /// - Parameters:
    ///   - view: The view to animate
    ///   - endingOpacity: The ending opacity 1.0 for visible 0.0 for hidden.
    ///   - fadeAnimation: The fade animation to use
    ///   - animationName: The name of the animation useful for KVO.
    func applyFadeAnimationTo(view : NSView, endingOpacity : Float, fadeAnimation : CABasicAnimation, animationName : String) {
        
        view.layer?.add(fadeAnimation, forKey: animationName)
        view.layer?.opacity = endingOpacity
        
        if endingOpacity == 1 {
            view.isHidden = false
        } else {
            view.isHidden = true
        }
    }
}

extension BaseViewController: TouchBarComponents {
    func getCustomBarItems() -> [Any] {
        return customBarItems
    }
}
