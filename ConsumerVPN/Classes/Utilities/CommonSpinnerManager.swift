//
//  CommonSpinner.swift
//  ConsumerVPN
//
//  Created by Jyoti Gawali Katkar on 18/04/24.
//  Copyright © 2024 WLVPN. All rights reserved.
//

import Cocoa

class CommonSpinnerManager {
    static let shared = CommonSpinnerManager()
    
    private let overlayView: CustomBlurView
    private var spinnerSuperview: NSView?
    
    private init() {
        overlayView = CustomBlurView()
        
    }
    
    func showSpinner(on view: NSView?, message:String = "Loading...") {
        guard let spinnerSuperview = view else { return }
        overlayView.loadingCircle.message = message
        spinnerSuperview.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: spinnerSuperview.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: spinnerSuperview.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: spinnerSuperview.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: spinnerSuperview.bottomAnchor)
        ])
    }
    
    func hideSpinner() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.overlayView.removeFromSuperview()
            self.spinnerSuperview = nil
        }
    }
    
    
}

class CustomBlurView: NSView {
    var loadingCircle: LoadingCircle!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.8).cgColor
        // Add progress indicator as a subview
        loadingCircle = LoadingCircle()
        loadingCircle.translatesAutoresizingMaskIntoConstraints = false // Add this line
        loadingCircle.message = "Loading..."
        self.addSubview(loadingCircle)
        
        // Center the progress indicator within the view using constraints
        NSLayoutConstraint.activate([
            loadingCircle.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingCircle.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingCircle.widthAnchor.constraint(equalToConstant: 220),
            loadingCircle.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return self
    }
    
    // Override mouse events to prevent passing them to underlying views
    override func mouseDown(with event: NSEvent) {
        // Do nothing
    }
    
    override func mouseUp(with event: NSEvent) {
        // Do nothing
    }
    
    override func mouseDragged(with event: NSEvent) {
        // Do nothing
    }
    
    override func rightMouseDown(with event: NSEvent) {
        // Do nothing
    }
    
    override func otherMouseDown(with event: NSEvent) {
        // Do nothing
    }
    
}

