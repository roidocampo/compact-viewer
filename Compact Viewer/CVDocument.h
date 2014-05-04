//
//  CVDocument.h
//  Compact Viewer
//
//  Created by Roi Docampo on 5/1/14.
//  Copyright (c) 2014 Roi Docampo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface CVDocument : NSObject

@property BOOL isValid;
@property (strong) NSURL *url;
@property (strong) NSString *name;
@property (strong) PDFDocument *pdf;
@property (strong) PDFDestination *position;
@property float zoom;
@property PDFDisplayMode mode;
@property (strong) NSString *searchQuery;
@property (strong) NSMutableArray *searchResults;

+ (CVDocument *)fromFile:(NSString *)file;
+ (CVDocument *)duplicate:(CVDocument *)original;
//- (void)didMatchString:(PDFSelection *)instance;

@end
