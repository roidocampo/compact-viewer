//
//  CVTextFieldCell.m
//  Compact Viewer
//
//  Created by Roi Docampo on 5/4/14.
//  Copyright (c) 2014 Roi Docampo. All rights reserved.
//

#import "CVTextFieldCell.h"

@implementation CVTextFieldCell

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
