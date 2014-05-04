//
//  CVDocument.m
//  Compact Viewer
//
//  Created by Roi Docampo on 5/1/14.
//  Copyright (c) 2014 Roi Docampo. All rights reserved.
//

#import "CVDocument.h"
#import "CVAppDelegate.h"

@implementation CVDocument

+ (CVDocument *)fromFile:(NSString *)filename
{
    CVDocument *doc = [[CVDocument alloc] init];
    doc.url = [NSURL fileURLWithPath:filename];
    NSString *extension = doc.url.pathExtension;
    doc.name = [[doc.url lastPathComponent] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    if ([extension isEqualToString: @"pdf"]) {
        doc.isValid = YES;
    } else {
        if ([extension isEqualToString: @"djvu"] ||
            [extension isEqualToString: @"ps"]) {
            NSMutableArray *comps = [NSMutableArray arrayWithArray:[doc.url pathComponents]];
            NSString *convertedFileName = [(NSString *)comps.lastObject copy];
            [comps removeLastObject];
            [comps addObject:@"converted"];
            convertedFileName = [convertedFileName substringToIndex:convertedFileName.length-extension.length];
            convertedFileName = [convertedFileName stringByAppendingString:@"pdf"];
            [comps addObject:convertedFileName];
            NSString *newFilename = [NSString pathWithComponents:comps];
            if ([[NSFileManager defaultManager] fileExistsAtPath:newFilename]) {
                filename = newFilename;
                doc.url = [NSURL fileURLWithPath:filename];
                doc.isValid = YES;
            } else {
                newFilename = [@"/Users/roi/Dropbox/Articles/converted/"
                               stringByAppendingString:convertedFileName];
                if ([[NSFileManager defaultManager] fileExistsAtPath:newFilename]) {
                    filename = newFilename;
                    doc.url = [NSURL fileURLWithPath:filename];
                    doc.isValid = YES;
                } else {
                    doc.isValid = NO;
                    return doc;
                }
            }
        } else {
            doc.isValid = NO;
            return doc;
        }
    }
    doc.pdf = [[PDFDocument alloc] initWithURL:doc.url];
    //[doc.pdf setDelegate:self];
    doc.position = nil;
    doc.zoom = 1.0;
    doc.mode = kPDFDisplaySinglePageContinuous;
    doc.searchQuery = @"";
    doc.searchResults = nil;
    return doc;
}

+ (CVDocument *)duplicate:(CVDocument *)original
{
    CVDocument *doc = [[CVDocument alloc] init];
    doc.url = original.url;
    doc.name = original.name;
    doc.isValid = original.isValid;
    if (!doc.isValid)
        return doc;
    doc.pdf = [[PDFDocument alloc] initWithURL:doc.url];
    //[doc.pdf setDelegate:self];
    if (original.position)
        doc.position = [[PDFDestination alloc] initWithPage:original.position.page atPoint:original.position.point];
    else
        doc.position = nil;
    doc.zoom = original.zoom;
    doc.mode = original.mode;
    doc.searchQuery = @"";
    doc.searchResults = nil;
    return doc;
}

/*
- (void)didMatchString:(PDFSelection *)instance
{
    NSLog(@"match!");
    if (self.searchResults == nil)
        self.searchResults = [NSMutableArray arrayWithCapacity:0];
    [instance setColor:[NSColor yellowColor]];
    [self.searchResults addObject:instance];
    CVAppDelegate *owner = [CVAppDelegate master];
    NSUInteger myIndex = [owner indexOfDocument:self];
    NSUInteger currentIndex = [owner indexOfSelectedDocument];
    if (myIndex == currentIndex)
        [owner.pdfView setHighlightedSelections:self.searchResults];
}

- (void)documentDidBeginDocumentFind:(NSNotification *)notification
{
    NSLog(@"here");
}
*/

@end
