//
//  CVTableCellView.h
//  Compact Viewer
//
//  Created by Roi Docampo on 5/2/14.
//  Copyright (c) 2014 Roi Docampo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CVDocument;

@interface CVTableCellView : NSTableCellView

@property (weak) IBOutlet NSBox *box;
@property (weak) IBOutlet NSBox *line;

@property (weak) CVDocument *doc;

+ (CVTableCellView *)newWithDocument:(CVDocument *)document;

@end
