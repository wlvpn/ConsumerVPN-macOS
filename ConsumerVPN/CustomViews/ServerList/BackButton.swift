//
//  BackButton.swift
//  WhiteLabelVPN
//
//  Created by Zephaniah Cohen on 9/15/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation

class BackButton : CustomButton {

    //MARK: - Init 

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureView()
    }

    //MARK: - View Configuration

    /// Configures the image views and applies the appropriate auto layout.
    override internal func configureView() {

        title = ""
        //Settings would be equivalent to 'Image Button' in interface builder.
        bezelStyle = NSButton.BezelStyle.smallSquare
        isBordered = false

        let backArrowImageView = NSImageView(frame: CGRect(x:0, y:0, width:25, height:bounds.size.height))
        backArrowImageView.image = NSImage(named: "Back Arrow")

        //Need to do a little bit of horizontal and vertical centering here to get
        //this to allign just right.
        let backTextImageView = NSImageView(frame: CGRect(x:0, y:0, width:75, height:bounds.size.height))
        backTextImageView.image = NSImage(named: "Back Text")
        backTextImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backArrowImageView)
        addSubview(backTextImageView)

        //Apply the auto layout.

        let metricsDict = [
            "leftPadding" : NSNumber(integerLiteral: 25),
            "bottomPadding" : NSNumber(integerLiteral: 5)
        ]

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftPadding-[backTextImageView]", options: [], metrics: metricsDict, views:["backTextImageView" : backTextImageView]))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[backTextImageView]-bottomPadding-|", options: [], metrics: metricsDict, views:["backTextImageView" : backTextImageView]))
    }
}
