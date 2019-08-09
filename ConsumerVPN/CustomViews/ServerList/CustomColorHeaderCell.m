//
//  CustomColorHeaderCell.m
//  TableViewTest
//
//  Created by Kevin Hallmark on 12/14/17.
//  Copyright © 2017 Mudhook Marketing. All rights reserved.
//

#import "CustomColorHeaderCell.h"

@implementation CustomColorHeaderCell

- (instancetype)initTextCell:(NSString *)string {
	self = [super initTextCell:string];

	if (self) {
		_cellColor      = [NSColor blackColor];
		_separatorColor = [NSColor greenColor];
		_sortArrowColor = [NSColor whiteColor];
		_fontColor      = [NSColor whiteColor];
        _fontSize       = 15.0;
        _fontWeight     = NSFontWeightBold;
	}

	return self;
}
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[self.cellColor set];
	NSRectFillUsingOperation(cellFrame, NSCompositeSourceOver);

	[self drawInteriorWithFrame:cellFrame inView:controlView];

	NSBezierPath *path = [NSBezierPath bezierPath];

	CGFloat startX = NSMinX(cellFrame);
	CGFloat endX   = NSMaxX(cellFrame);
	CGFloat maxY   = NSMaxY(cellFrame);

	[path moveToPoint:NSMakePoint(startX, maxY)];
	[path lineToPoint:NSMakePoint(endX, maxY)];

	[path closePath];

	[self.separatorColor set];
	[path stroke];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {

	NSDictionary *attributes = @{
		NSFontAttributeName: [NSFont systemFontOfSize:self.fontSize weight:self.fontWeight],
		NSForegroundColorAttributeName: self.fontColor,
	};

	self.attributedStringValue = [[NSAttributedString alloc]
		initWithString:self.stringValue
			attributes: attributes
	];

    NSRect offsetRect = NSOffsetRect(cellFrame, 2.0, 4.0);

    [super drawInteriorWithFrame:offsetRect inView:controlView];
}

- (void)drawSortIndicatorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView ascending:(BOOL)ascending priority:(NSInteger)priority {

	CGFloat startX = NSMaxX(cellFrame) - 28;
	CGFloat midX = NSMaxX(cellFrame) - 24;
	CGFloat endX = NSMaxX(cellFrame) - 20;

    CGFloat startY  = (cellFrame.size.height / 2) - 3;
    CGFloat endY    = (cellFrame.size.height / 2) + 3;

	NSBezierPath *path = [NSBezierPath bezierPath];

	if (ascending) {
		[path moveToPoint:NSMakePoint(startX, endY)];
		[path lineToPoint:NSMakePoint(midX, startY)];
		[path lineToPoint:NSMakePoint(endX, endY)];
	} else {
		[path moveToPoint:NSMakePoint(startX, startY)];
		[path lineToPoint:NSMakePoint(endX, startY)];
		[path lineToPoint:NSMakePoint(midX, endY)];
	}

	[path closePath];
	[self.sortArrowColor set];
	[path fill];
}

@end
