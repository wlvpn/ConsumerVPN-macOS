//
//  ServerTableCellView.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/20/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation

class ServerTableCellView : BaseTableCellView {

    fileprivate var mousedOverColor : NSColor!

    //MARK: - Properties
 
    @IBOutlet weak var serverName : NSTextField!
    @IBOutlet weak var serverLoad : NSTextField!
    @IBOutlet weak var serverPing : NSTextField!
    
    fileprivate var cellBackgroundColor : NSColor!
    
    //MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        wantsLayer = true
    }
    
    /// Styles the cell for the appropriate brand and updates the UI for the display
    /// model elements
    ///
    /// - parameter customizationManager: The brand customization manager.
    /// - parameter server:               The server model to bind to the UI.
    internal func styleCell(server : Server) {

        cellBackgroundColor = NSColor.serverListExpandedBackground
        layer?.backgroundColor = cellBackgroundColor.cgColor

        mousedOverColor = NSColor.serverListBackground
    }
}
