//
//  CVTableCellView.m
//  Compact Viewer
//
//  Created by Roi Docampo on 5/2/14.
//  Copyright (c) 2014 Roi Docampo. All rights reserved.
//

#import "CVTableCellView.h"
#import "CVDocument.h"
#import "CVAppDelegate.h"

@interface NSImage (Tint)

- (NSImage *)tintedImageWithColor:(NSColor *)tint;

@end

@implementation NSImage (Tint)

- (NSImage *)tintedImageWithColor:(NSColor *)tint
{
    NSSize size = [self size];
    NSRect imageBounds = NSMakeRect(0, 0, size.width, size.height);
    
    NSImage *copiedImage = [self copy];
    
    [copiedImage lockFocus];
    
    [tint set];
    NSRectFillUsingOperation(imageBounds, NSCompositeSourceAtop);
    
    [copiedImage unlockFocus];
    
    return copiedImage;
}

@end

@implementation CVTableCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

+ (CVTableCellView *)newWithDocument:(CVDocument *)document
{
    CVAppDelegate *owner = [CVAppDelegate master];
    CVTableCellView *new = (CVTableCellView *)[owner.sidebarOutlineView makeViewWithIdentifier:@"DataCell" owner:owner];
    new.doc = document;
    [new.textField setStringValue:new.doc.name];
    NSImage *darkTriange = [NSImage imageNamed:NSImageNameGoRightTemplate];
    NSImage *clearTriangle = [darkTriange tintedImageWithColor:[NSColor redColor]];
    [new.imageView setImage:clearTriangle];
    return new;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CVAppDelegate *owner = [CVAppDelegate master];
    NSUInteger index = [owner indexOfDocument:self.doc];
    NSUInteger selectedIndex = [owner indexOfSelectedDocument];
    
    if (index == 0)
        [self.line setHidden:YES];
    else
        [self.line setHidden:NO];
    if (index == selectedIndex)
        [self.imageView setHidden:NO];
    else
        [self.imageView setHidden:YES];
    /*
    if (index == selectedIndex) {
        [self.box setFillColor:
         [NSColor colorWithSRGBRed: 203./255.
                             green: 222./255.
                              blue: 240./255.
                             alpha: 1.0]];
        [self.box setBorderType:NSLineBorder];
        [self.box setBorderColor:
         [NSColor colorWithSRGBRed: 34./255.
                             green: 81./255.
                              blue: 182./255.
                             alpha: 1.0]];
        [self.line setHidden:YES];
    } else if (index+1 == selectedIndex) {
        [self.box setFillColor: [NSColor clearColor]];
        [self.box setBorderType:NSNoBorder];
        [self.line setHidden:YES];
    } else {
        [self.box setFillColor: [NSColor clearColor]];
        [self.box setBorderType:NSNoBorder];
        [self.line setHidden:NO];
        [self.line setBorderWidth:20];
        [self.line setBorderType:NSLineBorder];
        [self.line setBorderColor:
         [NSColor colorWithSRGBRed: 200./255.
                             green: 81./255.
                              blue: 182./255.
                             alpha: 1.0]];
    }
    */
    [super drawRect:dirtyRect];
}

@end
