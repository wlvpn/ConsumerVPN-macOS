//
//  WLCustomTextField.h
//  WhiteLabelVPN
//
//  Created by Kevin Hallmark on 1/21/16.
//  @copyright 2016 WLVPN All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface WLCustomTextField : NSTextField

@property IBInspectable NSColor *insertionPointColor;
@property IBInspectable NSColor *placeholderTextColor;

/**
 * Sets the insertionPointColor, placeholderTextColor and textColor
 *
 * @param color The color to set for all the properties
 */
- (void)setColor:(NSColor *)color;

@end
