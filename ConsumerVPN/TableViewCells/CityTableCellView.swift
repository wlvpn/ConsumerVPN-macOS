//
//  CityTableCellView.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/16/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation

class CityTableCellView : BaseTableCellView {
    
    //MARK: - Properties
    
    @IBOutlet weak var flagImageView: NSImageView!
    @IBOutlet weak var cityName: NSTextField!
    @IBOutlet weak var serverSubtitle: NSTextField!
    @IBOutlet weak var cityPing: NSTextField!
    @IBOutlet weak var serverLoad: NSTextField!
    @IBOutlet weak var dividerView : ColorView!
    
    fileprivate var trackingArea : NSTrackingArea!
    fileprivate var mousedOverColor : NSColor!
    fileprivate var cellBackgroundColor : NSColor!
    fileprivate var rowIsExpanded = false
    fileprivate var cityMatchesVPNConfiguration = false

    //MARK: - Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTrackingArea()
        wantsLayer = true
    }
    
    /// Styles the cell for the appropriate brand and updates the UI for the display
    /// model elements
    ///
    /// - parameter customizationManager: The brand customization manager.
    /// - parameter cellModel:     The display model to bind to the UI.
    /// - parameter vpnConfiguration: Optional VPN configuration used to check if
    /// the cell row should be styled appropriately.
    func styleCell(cellModel : CellDisplayModel, vpnConfiguration : VPNConfiguration?) {
   
        //Configure the colors
        cellBackgroundColor = NSColor.serverListBackground
        layer?.backgroundColor = cellBackgroundColor.cgColor
        mousedOverColor = NSColor.serverListMouseOverBackground
      
        //Configure UI Elements
        serverSubtitle.textColor = NSColor.serverListSubtext
        cityName.textColor = NSColor.serverListText
        serverLoad.textColor = NSColor.serverListText
        cityPing.textColor = NSColor.pingText
        dividerView.backgroundColor =  NSColor.serverListRowDivider
        
        flagImageView.image = cellModel.flagImage
//        cityPing.stringValue = cellModel.city.pingString
        cityName.stringValue = cellModel.cityDisplayName
        serverSubtitle.stringValue = cellModel.serverInformationSubtitle
        serverLoad.stringValue = cellModel.averageServerLoadSubtitle
        
        //Indicate if we are in expanded state or non expanded state.
        rowIsExpanded = cellModel.selected
        
        if rowIsExpanded == true {
            layer?.backgroundColor = mousedOverColor.cgColor
        } else {
            layer?.backgroundColor = cellBackgroundColor.cgColor
        }
        
        if cellModel.city == vpnConfiguration?.city {
            cityMatchesVPNConfiguration = true
            layer?.backgroundColor = mousedOverColor.cgColor
        } else {
            cityMatchesVPNConfiguration = false 
        }
    }
    
    /// Restores the original background color of the cell.
    private func restoreUnselectedState() {
        if rowIsExpanded == false && cityMatchesVPNConfiguration == false {
            layer?.backgroundColor = cellBackgroundColor.cgColor
        }
    }
    
    //MARK: - Mouse Management
    
    override func mouseEntered(with event: NSEvent) {
        if rowIsExpanded == false && cityMatchesVPNConfiguration == false {
            layer?.backgroundColor = mousedOverColor.cgColor
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        restoreUnselectedState()
    }
    
    //MARK: - Tracking Area Management
    
    override func updateTrackingAreas() {
        restoreUnselectedState()
        super.updateTrackingAreas()
    }
  
    /// Configures the tracking area with the appropriate settings and adds
    /// the tracking area to the cell.
    fileprivate func configureTrackingArea() {
        
        trackingArea = NSTrackingArea(rect: visibleRect, options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.mouseMoved, NSTrackingArea.Options.activeInKeyWindow, NSTrackingArea.Options.enabledDuringMouseDrag, NSTrackingArea.Options.activeAlways], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }
}
