/*
 * NSColor+HexColor.m
 * WhiteLabelVPN
 * 
 * @copyright 2018 WLVPN. All rights reserved.
*/

#import "NSColor+HexColor.h"


@implementation NSColor (HexColor)

+ (NSColor *)colorWithHexColorString:(NSString *)inColorString {
	// Strip the hex
	if ([inColorString hasPrefix:@"#"]) {
		inColorString = [inColorString substringWithRange:NSMakeRange(1, [inColorString length] - 1)];
	}

	NSColor* result = nil;
	unsigned colorCode = 0;
	unsigned char redByte, greenByte, blueByte;

	if (nil != inColorString) {
		NSScanner* scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode]; // ignore error
	}

	redByte = (unsigned char)(colorCode >> 16);
	greenByte = (unsigned char)(colorCode >> 8);
	blueByte = (unsigned char)(colorCode); // masks off high bits

	result = [NSColor colorWithDeviceRed:(CGFloat)redByte / 0xff
								   green:(CGFloat)greenByte / 0xff
									blue:(CGFloat)blueByte / 0xff
								   alpha:1.0
	];

	return result;
}

@end