//
//  WLCustomTextField.m
//  WhiteLabelVPN
//
//  Created by Kevin Hallmark on 1/21/16.
//  @copyright 2016 WLVPN All rights reserved.
//

#import "WLCustomTextField.h"

@implementation WLCustomTextField

/**
 * Sets the insertionPointColor, placeholderTextColor and textColor
 *
 * @param color The color to set for all the properties
 */
- (void)setColor:(NSColor *)color {
    self.textColor = color;
    self.insertionPointColor = color;
    self.placeholderTextColor = color;
}

- (void)setPlaceholderString:(NSString *)placeholderString {
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(placeholderString, @"Field Text")];

    NSRange range = NSMakeRange( 0, [placeholder length] );

    NSFont *textFont = self.font;

    if (textFont) {
        [placeholder addAttribute:NSFontAttributeName value:textFont range:range];
    }

    [placeholder addAttribute:NSForegroundColorAttributeName value:self.placeholderTextColor range:range];
    [placeholder fixAttributesInRange:range];

    [self setPlaceholderAttributedString:placeholder];
}

- (BOOL)becomeFirstResponder {
    BOOL success = [super becomeFirstResponder];
    if (success) {
        // Strictly spoken, NSText (which currentEditor returns) doesn't
        // implement setInsertionPointColor:, but it's an NSTextView in practice.
        // But let's be paranoid, better show an invisible black-on-black cursor
        // than crash.
        NSTextView *textField = (NSTextView *) [self currentEditor];
        if ([textField respondsToSelector:@selector(setInsertionPointColor:)]) {
            [textField setInsertionPointColor:self.insertionPointColor];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:WLLoginFieldSelectionNotification object:self userInfo:@{@"type":@"User"}];
    }

    return success;
}

@end
