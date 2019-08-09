/*
 * NSColor+HexColor.h
 * WhiteLabelVPN
 * 
 * @copyright 2018 WLVPN. All rights reserved.
*/

#import <Foundation/Foundation.h>
@import AppKit;

@interface NSColor (HexColor)

+ (NSColor *)colorWithHexColorString:(NSString *)inColorString;

@end
