//
//  LoadingView.swift
//  Consumer VPN
//
//  Created by Jonathan Fuentes on 8/15/19.
//  Copyright © 2019 WLVPN. All rights reserved.
//

import Cocoa

protocol LoadingViewDelegate: AnyObject {
    func didSelectCancelConnect()
}

class LoadingView: ColorView {
    
    @IBOutlet weak var cancelButton: CustomButton!
    @IBOutlet weak var loadingCircle: LoadingCircle!
    
    weak var delegate: LoadingViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        cancelButton.isHidden = true
        loadingCircle.message = "Connecting..."
    }
    class func newInstance() -> LoadingView {
        var loadingView:LoadingView?
        var topLevelObjects : NSArray?
        if Bundle.main.loadNibNamed("LoadingView", owner: self, topLevelObjects: &topLevelObjects) {
            loadingView = topLevelObjects!.first(where: { $0 is LoadingView }) as? LoadingView
        }
        
        return loadingView!
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
		themeView()
    }
    
    fileprivate func themeView() {
        cancelButton.backgroundColor    = NSColor.cancelButton
        cancelButton.borderColor        = NSColor.cancelButton
        cancelButton.textColor          = NSColor.cancelButtonText
        cancelButton.buttonText         = NSLocalizedString("Cancel", comment: "Cancel")
        cancelButton.setAccessibilityIdentifier("Cancel Button")
    }
    
    @IBAction func cancelConnect(_ sender: Any) {
        loadingCircle.label.stringValue = NSLocalizedString("Cancelling...", comment: "")
        loadingCircle.label.lineBreakMode = .byCharWrapping
        
        delegate?.didSelectCancelConnect()
    }
}
