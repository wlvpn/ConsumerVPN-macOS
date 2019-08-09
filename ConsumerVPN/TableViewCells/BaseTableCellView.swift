//
//  BaseTableCellView.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/20/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation

internal protocol CellSelectionDelegate {
    func didLongClickCell(selectedCell : NSTableCellView)
    func didDoubleClickCell(selectedCell : NSTableCellView)
    func didSingleClickCell(selectedCell : NSTableCellView)
}

class BaseTableCellView : NSTableCellView {
    
    //MARK: - Propeties
    
    private var clickTimer : Timer?
    internal var delegate : CellSelectionDelegate?
    
    //MARK: - Click Management
    
    override func mouseDown(with event: NSEvent) {
        clickTimer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(BaseTableCellView.longClickCompleted), userInfo: nil, repeats: false)
    }
    
    override func mouseUp(with event: NSEvent) {
        //Mouse down kicks off the long click timer, we invalidate that timer if we 
        //mouse up before the callback interval has been reached.
        clickTimer?.invalidate()
        clickTimer = nil
        
        //Double click always comes included with a single click. Therefore single clicks
        //are executed after the delay of a double click so we can ignore the single click
        //that comes included with the double click.
        perform(#selector(BaseTableCellView.processSingleClick), with: nil, afterDelay: NSEvent.doubleClickInterval)
        
         if event.clickCount == 2 {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(BaseTableCellView.processSingleClick), object: nil)
            delegate?.didDoubleClickCell(selectedCell: self)
        }

    }
    
    //MARK: - Single Click Handler
    
    @objc internal func processSingleClick() {
        delegate?.didSingleClickCell(selectedCell: self)
    }

    //MARK: - Long Click Time Handler
    
    @objc internal func longClickCompleted() {
        delegate?.didLongClickCell(selectedCell: self)
    }
    
    //MARK: - Click Pointer Indicator
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: NSCursor.pointingHand)
    }
}
