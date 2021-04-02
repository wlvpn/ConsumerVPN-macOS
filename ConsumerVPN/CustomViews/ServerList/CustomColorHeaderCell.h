//
//  CustomColorHeaderCell.h
//  TableViewTest
//
//  Created by Kevin Hallmark on 12/14/17.
//  Copyright © 2017 Mudhook Marketing. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * This class lets you customize the header of a tableview. It's written in Objective-C due to limitations with Swift.
 */
@interface CustomColorHeaderCell : NSTableHeaderCell

/**
 * The main cell color
 */
@property (strong) NSColor *cellColor;

/**
 * The bottom of the header cell that is 1px high.
 */
@property (strong) NSColor *separatorColor;

/**
 * The color of the sort arrow on the table header view
 */
@property (strong) NSColor *sortArrowColor;

/**
 * The font color for the text of the header view
 */
@property (strong) NSColor *fontColor;

/**
 * The font size for the text of the header view
 */
@property CGFloat fontSize;

/**
 * The font weight for the text of the header view
 */
@property NSFontWeight fontWeight;

@end
