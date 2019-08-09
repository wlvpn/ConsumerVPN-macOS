//
// Created by Kevin Hallmark on 4/25/18.
// Copyright (c) 2018 WLVPN. All rights reserved.
//

import Foundation

final class Theme {
    static let brandName = "Consumer VPN"

    static let signupURL = "https://www.wlvpn.com"
    static let forgotPasswordURL = "https://www.wlvpn.com"
    static let contactSupportURL = "https://www.wlvpn.com"

    static let usernameSuffix = "<username suffix>"
    static let apiKey = "<api key>"
    
    static let serverListHeaderFontSize: CGFloat = 12.0
    // header height will scale based on the font size
    static let serverListHeaderHeight: CGFloat = serverListHeaderFontSize + 14.0
}

extension NSColor {
    // MARK: General Theme
    static var primaryText: NSColor {
        return NSColor.white
    }

    static var primaryAccent: NSColor {
        return NSColor(hexColorString: "4A90E2")
    }

    static var secondaryAccent: NSColor {
        return NSColor.white
    }

    static var primaryBackground: NSColor {
        return NSColor(hexColorString: "1E1E1E")
    }

    static var selectedServer: NSColor {
        return NSColor(hexColorString: "2A2A2A")
    }


    // Main Window Colors

    static var mainWindowText: NSColor {
        return primaryText
    }

    static var headerBackground : NSColor {
        return primaryBackground
    }

    // About View

    static var aboutViewBackground: NSColor {
        return primaryBackground
    }

    // MARK: Login View

    // Login View
    static var loginViewBackground: NSColor {
        return primaryBackground
    }

    static var loginViewText : NSColor {
        return mainWindowText
    }

    static var loginButton: NSColor {
        return primaryAccent
    }

    static var loginButtonText: NSColor {
        return primaryText
    }
    
    static var forgotPasswordButtonText: NSColor {
        return NSColor(hexColorString: "FF9B9B9B")
    }
    
    static var signUpButtonText: NSColor {
        return NSColor(hexColorString: "FF9B9B9B")
    }
    
    static var loginViewGradientTop: NSColor {
        return NSColor(hexColorString: "090A0E")
    }
    
    static var loginViewGradientMid: NSColor {
        return NSColor(hexColorString: "4A4E5C")
    }
    
    static var loginViewGradientBottom: NSColor {
        return NSColor(hexColorString: "202534")
    }
    
    static var loginViewTallTriangleBg: NSColor {
        return NSColor(hexColorString: "2F323F")
    }
    
    static var loginViewShortTriangleBg: NSColor {
        return NSColor(hexColorString: "262a37")
    }

    // MARK: Connect View
    static var connectViewBackground: NSColor {
        return primaryBackground
    }

    static var connectViewText : NSColor {
        return primaryText
    }

    // MARK: Encryption View
    static var encryptionBorder: NSColor {
        return secondaryAccent
    }

    static var encryptionFill: NSColor {
        return secondaryAccent
    }

    static var encryptionActiveText: NSColor {
        return primaryBackground
    }

    static var encryptionInactiveText: NSColor {
        return secondaryAccent
    }

    // MARK: Server Select Button
    static var serverSelectBorder: NSColor {
        return secondaryAccent
    }

    static var serverSelectText: NSColor {
        return primaryAccent
    }
    
    // MARK: Server Location Button
    static var serverLocationButton: NSColor {
        return NSColor(hexColorString: "63666F")
    }
    
    // MARK: Connect Button
    static var connectButton: NSColor {
        return NSColor.systemBlue
    }

    static var connectButtonText : NSColor {
        return NSColor.white
    }

    // MARK: Connect View
    static var disconnectViewBackground: NSColor {
        return primaryBackground
    }

    static var disconnectViewText : NSColor {
        return primaryAccent
    }

    // MARK: Disconnect Button
    static var disconnectButton: NSColor {
        return systemBlue
    }

    static var disconnectButtonText : NSColor {
        return NSColor.white
    }
    
    // MARK: Cancel Button
    static var cancelButton: NSColor {
        return systemRed
    }
    
    static var cancelButtonText: NSColor {
        return white
    }

    // MARK: Server Select Screen

    static var serverListBackground : NSColor {
        return primaryBackground
    }

    static var serverListMouseOverBackground : NSColor {
        return selectedServer
    }

    static var serverListExpandedBackground : NSColor {
        return serverListMouseOverBackground
    }

    static var serverListHeader : NSColor {
        return NSColor(hexColorString: "595959")
    }

    static var serverListHeaderText : NSColor {
        return primaryText
    }

    static var serverListRowDivider : NSColor {
        return NSColor.black
    }

    static var serverListText : NSColor {
        return primaryText
    }

    static var serverListSubtext : NSColor {
        return primaryText
    }

    static var serverSelectRow1: NSColor {
        return NSColor(hexColorString: "282828")
    }
    
    static var serverSelectRow2: NSColor {
        return NSColor(hexColorString: "313131")
    }
    
    static var pingText: NSColor {
        return NSColor(hexColorString: "7ED321")
    }
}
