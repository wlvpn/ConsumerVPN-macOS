//
//  ClickableTextField.swift
//  StrongVPN Client
//
//  Created by Kevin Hallmark on 2/2/18.
//  Copyright © 2018 WLVPN. All rights reserved.
//

import Cocoa

class ClickableTextField: NSTextField {

	override func mouseDown(with event: NSEvent) {
		self.sendAction(self.action, to: self.target)
	}

    override func resetCursorRects() {
        addCursorRect(self.bounds, cursor: NSCursor.pointingHand)
    }
}
