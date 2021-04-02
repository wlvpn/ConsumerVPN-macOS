//
//  NSImageView.swift
//  VIPRE VPN
//
//  Created by Javier Hernández on 8/14/19.
//  Copyright © 2019 WLVPN. All rights reserved.
//

extension NSImageView {
    func tinted(withTintColor tintColor: NSColor) {
        if #available(OSX 10.14, *) {
            contentTintColor = tintColor
        } else {
            if let image = self.image {
                // Probably Will Be Needed To Differentiate The Target Of The Tinting Process
                // guard image.isTemplate else { return }
                let copiedImage = image.copy() as! NSImage
                copiedImage.lockFocus()
                tintColor.set()
                let imageBounds = NSMakeRect(0, 0, copiedImage.size.width, copiedImage.size.height)
                imageBounds.fill(using: .sourceAtop)
                copiedImage.unlockFocus()
                copiedImage.isTemplate = false
                self.image = copiedImage
            }
        }
    }
    
    func themed() {
        tinted(withTintColor: .primaryAccent)
    }
}
