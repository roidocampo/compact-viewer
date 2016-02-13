//
//  CVSearchFieldCell.m
//  Compact Viewer
//
//  Created by Roi Docampo on 5/4/14.
//  Copyright (c) 2014 Roi Docampo. All rights reserved.
//

#import "CVSearchFieldCell.h"

@implementation CVSearchFieldCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (self.innerBackgroundColor != nil)
    {
        [self.innerBackgroundColor setFill];
        NSRect frame = cellFrame;
        double radius = 0;//MIN(NSWidth(frame), NSHeight(frame)) / 2.0;
        [[NSBezierPath bezierPathWithRoundedRect:frame
                                         xRadius:radius yRadius:radius] fill];
    }
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (NSText *)setUpFieldEditorAttributes:(NSText *)textObj
{
    [textObj setBackgroundColor:self.innerBackgroundColor];
    
    NSColor *txtColor =
    [NSColor colorWithSRGBRed: 167./255.
                        green: 167./255.
                         blue: 168./255.
                        alpha: 1.];
    
    NSColor *bkgColor =
    [NSColor colorWithSRGBRed: 44./255.
                        green: 88./255.
                         blue: 126./255.
                        alpha: 1.];
    
    [(NSTextView *)textObj setInsertionPointColor: txtColor];
    
    [(NSTextView *)textObj setSelectedTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      bkgColor, NSBackgroundColorAttributeName,
      txtColor, NSForegroundColorAttributeName,
      nil]];
    
    return textObj;
}

@end
