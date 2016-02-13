//
//  CVAppDelegate.h
//  Compact Viewer
//
//  Created by Roi Docampo on 5/1/14.
//  Copyright (c) 2014 Roi Docampo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class CVDocument;

@interface CVAppDelegate : NSObject <NSApplicationDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource>
{
    NSString *initialDocument;
    NSMutableArray *documents;
    BOOL awake;
    NSUInteger draggedDocIndex;
    NSUInteger selectedDocIndex;
    CVDocument *currentPdf;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet PDFView *pdfView;
@property (weak) IBOutlet NSOutlineView *sidebarOutlineView;
@property (weak) IBOutlet NSTextField *pageCounter;
@property (weak) IBOutlet NSTextField *totalPagesLabel;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSScrollView *scrollView;

- (IBAction)duplicateView:(id)sender;
- (IBAction)openInPreview:(id)sender;
- (IBAction)takePageFromForm:(id)sender;
- (IBAction)pageCounterFocus:(id)sender;
- (IBAction)findNext:(id)sender;
- (IBAction)findPrevious:(id)sender;
- (IBAction)findFocus:(id)sender;
- (IBAction)copy:(id)sender;



- (NSUInteger)indexOfDocument:(CVDocument *)document;
- (NSUInteger)indexOfSelectedDocument;
- (void)selectDocumentByIndex:(NSUInteger)index;
- (void)selectDocument:(CVDocument *)document;
- (void)addDocument:(CVDocument *)document atIndex:(NSUInteger)index andSelect:(BOOL)select;
- (CVDocument *)removeDocumentAtIndex:(NSUInteger)index;
- (void)updatePdfView;
- (void)updatePageCounter;

+ (CVAppDelegate *)master;

@end
