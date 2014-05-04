//
//  CVAppDelegate.m
//  Compact Viewer
//
//  Created by Roi Docampo on 5/1/14.
//  Copyright (c) 2014 Roi Docampo. All rights reserved.
//

#import "CVAppDelegate.h"
#import "CVDocument.h"
#import "CVTableCellView.h"

#define LOCAL_REORDER_PASTEBOARD_TYPE @"cv.local.reorder.pasteboard.type"

static CVAppDelegate *_master;

@implementation CVAppDelegate

//////////////////////////////////////////////////////////////////////////////
//
//  Basic initialization
//
//////////////////////////////////////////////////////////////////////////////

+ (CVAppDelegate *)master;
{
    return _master;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    initialDocument = nil;
    awake = NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _master = self;
    draggedDocIndex = NSNotFound;
    currentPdf = nil;
    documents = [[NSMutableArray alloc] init];
    awake = YES;
    [self.sidebarOutlineView reloadData];
    
    if (initialDocument) {
        [self application:nil openFile:initialDocument];
    }
    
    /*
    [self application:nil openFile:
     @"/Users/roi/Dropbox/Articles/White_1990_Implementation_of_the_straightening_algorithm_of_classical_invariant_theory.pdf"];
    [self application:nil openFile:
     @"/Users/roi/Dropbox/Articles/Thuillier_2007_Géométrie_toroïdale_et_géométrie_analytique_non_archimédienne_Application_au.pdf"];
    [self application:nil openFile:
     @"/Users/roi/Dropbox/Articles/Timashev_2006_Homogeneous_spaces_and_equivariant_embeddings.pdf"];
    [self application:nil openFile:
     @"/Users/roi/Dropbox/Articles/Vasconcelos_2005_Integral_closure.pdf"];
    [self application:nil openFile:
     @"/Users/roi/Dropbox/Articles/Wassermann_2010_Kac-Moody_and_Virasoro_algebras.pdf"];
    */
    
    [NSTimer scheduledTimerWithTimeInterval: 0.5
                                     target: self
                                   selector: @selector(updatePageCounter)
                                   userInfo: nil
                                    repeats: YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

//////////////////////////////////////////////////////////////////////////////
//
//  Opening Files
//
//////////////////////////////////////////////////////////////////////////////

- (BOOL)application:(NSApplication *)sender
           openFile:(NSString *)filename
{
    if (!awake) {
        initialDocument = filename;
        return YES;
    }
    CVDocument *newDoc = [CVDocument fromFile:filename];
    if (!newDoc.isValid) {
        if ([[newDoc.url pathExtension] isEqualToString:@"djvu"])
            [[NSWorkspace sharedWorkspace] openFile:filename withApplication:@"DjView"];
        else if ([[newDoc.url pathExtension] isEqualToString:@"ps"])
            [[NSWorkspace sharedWorkspace] openFile:filename withApplication:@"Preview"];
        return NO;
    }
    [self.window makeKeyWindow];
    [self addDocument:newDoc atIndex:NSNotFound andSelect:YES];
    return YES;
}

- (void)addDocument:(CVDocument *)document
            atIndex:(NSUInteger)index
          andSelect:(BOOL)select
{
    if (index > [documents count])
        index=[documents count];
    [documents insertObject:document atIndex:index];
    if (select)
        [self selectDocumentByIndex:index];
    else {
        if (index <= selectedDocIndex)
            selectedDocIndex++;
        [self selectDocumentByIndex:selectedDocIndex];
    }
}

- (IBAction)openDocument:(id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    
    openPanel.title = @"Choose a PDF file";
    openPanel.showsResizeIndicator = YES;
    openPanel.showsHiddenFiles = NO;
    openPanel.canChooseDirectories = NO;
    openPanel.canCreateDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.allowedFileTypes = @[@"pdf"];
    
    [openPanel beginSheetModalForWindow:self.window
                      completionHandler:^(NSInteger result) {
                          if (result==NSOKButton) {
                              NSURL *selection = openPanel.URLs[0];
                              NSString* path = [selection.path stringByResolvingSymlinksInPath];
                              [self application:nil openFile:path];
                          }
                      }];
}

- (IBAction)openInPreview:(id)sender
{
    [[NSWorkspace sharedWorkspace] openFile:[currentPdf.url path] withApplication:@"Preview"];
}

//////////////////////////////////////////////////////////////////////////////
//
//  Closing Files
//
//////////////////////////////////////////////////////////////////////////////

- (BOOL)windowShouldClose:(id)sender
{
    // if ([documents count] == 0) return YES;
    [self removeDocumentAtIndex:selectedDocIndex];
    return NO;
}

- (CVDocument *)removeDocumentAtIndex:(NSUInteger)index
{
    if (index >= [documents count]) return nil;
    CVDocument *doc = [documents objectAtIndex:index];
    [documents removeObjectAtIndex:index];
    [self selectDocumentByIndex:selectedDocIndex];
    return doc;
}

//////////////////////////////////////////////////////////////////////////////
//
//  Document controller
//
//////////////////////////////////////////////////////////////////////////////

- (NSUInteger)indexOfDocument:(CVDocument *)document
{
    return [documents indexOfObject:document];
}

- (NSUInteger)indexOfSelectedDocument
{
    return selectedDocIndex;
}

//////////////////////////////////////////////////////////////////////////////
//
//  Selection
//
//////////////////////////////////////////////////////////////////////////////

- (void)selectDocumentByIndex:(NSUInteger)index
{
    [self selectDocumentByIndex:index withReload:YES];
}

- (void)selectDocumentByIndex:(NSUInteger)index
                   withReload:(BOOL)needsReload
{
    if ([documents count] == 0)
        selectedDocIndex = NSNotFound;
    else {
        if (index >= [documents count])
            index = [documents count]-1;
        selectedDocIndex = index;
    }
    if (needsReload)
        [self.sidebarOutlineView reloadData];
    [self updatePdfView];
    if (needsReload) {
        [self.sidebarOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        NSPoint scrollPoint;
        scrollPoint.x=5;
        scrollPoint.y=60*(index+1);
        NSRect bnds = self.scrollView.contentView.bounds;
        if (!NSPointInRect(scrollPoint, bnds)) {
            scrollPoint.y = MAX(0,60 * (index - ((int)bnds.size.height) / 60) + ((int)bnds.size.height) % 60);
            [self.sidebarOutlineView scrollPoint:scrollPoint];
        }
    }
    [self.sidebarOutlineView setNeedsDisplay:YES];
}

- (void)selectDocument:(CVDocument *)document
{
    [self selectDocumentByIndex:[self indexOfDocument:document]];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger i = [self.sidebarOutlineView selectedRow];
    if (i != -1)
        selectedDocIndex = (NSUInteger)i;
    [self selectDocumentByIndex:selectedDocIndex withReload:NO];
}

//////////////////////////////////////////////////////////////////////////////
//
//  Pdf View
//
//////////////////////////////////////////////////////////////////////////////

- (void)updatePdfView
{
    if ([documents count] == 0) {
        currentPdf = nil;
        [self.pdfView setDocument:nil];
        [self.pdfView setNeedsDisplay:YES];
        [self.totalPagesLabel setStringValue:@"of 0"];
        [self.pageCounter setIntegerValue:0];
    } else {
        CVDocument *selDoc = [documents objectAtIndex:selectedDocIndex];
        if (selDoc != currentPdf) {
            [self savePdfViewState];
            currentPdf = selDoc;
            [self.pdfView setDocument:currentPdf.pdf];
            if (currentPdf.position) {
                [self.pdfView setDisplayMode:currentPdf.mode];
                [self.pdfView setScaleFactor:currentPdf.zoom];
                [self.pdfView goToDestination:currentPdf.position];
            }
            [self.pdfView setNeedsDisplay:YES];
            [self.totalPagesLabel setStringValue:
             [NSString stringWithFormat:@"of %lu",
              (unsigned long)currentPdf.pdf.pageCount]];
            [self updatePageCounter];
            [self.pdfView setHighlightedSelections:currentPdf.searchResults];
        }
    }
}

- (void)savePdfViewState
{
    currentPdf.position = [self.pdfView currentDestination];
    currentPdf.zoom = [self.pdfView scaleFactor];
    currentPdf.mode = [self.pdfView displayMode];
}

- (IBAction)duplicateView:(id)sender
{
    [self savePdfViewState];
    CVDocument *newDoc = [CVDocument duplicate:currentPdf];
    [self addDocument:newDoc atIndex:selectedDocIndex+1 andSelect:YES];
}


//////////////////////////////////////////////////////////////////////////////
//
//  Sidebar -- NSOutlineView Data Source
//
//////////////////////////////////////////////////////////////////////////////

- (NSInteger) outlineView:(NSOutlineView *)outlineView
   numberOfChildrenOfItem:(id)item
{
    if (!awake)
        return 0;
    else if (item == nil)
        return [documents count];
    else
        return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)item
{
    if (!awake)
        return nil;
    else if (item == nil)
        return [documents objectAtIndex:index];
    else
        return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
    return NO;
}

- (NSView *) outlineView:(NSOutlineView *)outlineView
      viewForTableColumn:(NSTableColumn *)tableColumn
                    item:(id)item
{
    if (!awake)
        return nil;
    else if ([documents containsObject:item])
        return [CVTableCellView newWithDocument:(CVDocument *)item];
    else
        return nil;
}

//////////////////////////////////////////////////////////////////////////////
//
//  Drag and drop
//
//////////////////////////////////////////////////////////////////////////////

- (void)awakeFromNib {
    [self.sidebarOutlineView registerForDraggedTypes:[NSArray arrayWithObject:LOCAL_REORDER_PASTEBOARD_TYPE]];
}

- (id <NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView
                pasteboardWriterForItem:(id)item
{
    NSUInteger index = [self indexOfDocument:(CVDocument *)item];
    NSNumber *nIndex = [NSNumber numberWithUnsignedInteger:index];
    NSString *stringRepr = [nIndex stringValue];
    NSPasteboardItem *pboardItem = [[NSPasteboardItem alloc] init];
    [pboardItem setString:stringRepr forType: LOCAL_REORDER_PASTEBOARD_TYPE];
    return pboardItem;
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov
                  validateDrop:(id <NSDraggingInfo>)info
                  proposedItem:(id)item
            proposedChildIndex:(NSInteger)childIndex
{
    if (item == nil && 0<=childIndex && childIndex<=[documents count])
        return NSDragOperationMove;
    else
        return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
         acceptDrop:(id < NSDraggingInfo >)info
               item:(id)item
         childIndex:(NSInteger)index
{
    NSPasteboardItem *pboarditem = (NSPasteboardItem *)[[[info draggingPasteboard] pasteboardItems] firstObject];
    NSString *stringRepr = [pboarditem stringForType:LOCAL_REORDER_PASTEBOARD_TYPE];
    NSInteger prevIndex = [stringRepr integerValue];
    if (prevIndex < 0) return NO;
    [self moveDocumentFrom:prevIndex to:index];
    return YES;
}

- (void)moveDocumentFrom:(NSUInteger)from to:(NSUInteger)to
{
    if (from == to) return;
    if (from < to) to--;
    [self addDocument:[self removeDocumentAtIndex:from] atIndex:to andSelect:YES];
}

//////////////////////////////////////////////////////////////////////////////
//
//  Page counter
//
//////////////////////////////////////////////////////////////////////////////

- (void)updatePageCounter
{
    if (currentPdf == nil)
        return;
    
    BOOL counterFocused = NO;
    
    counterFocused = ([self.window.firstResponder isKindOfClass:[NSTextView class]]
                      &&
                      [self.window fieldEditor:NO forObject:nil]!=nil
                      &&
                      [self.pageCounter isEqualTo:
                       (id)[(NSTextView *)[self.window firstResponder]delegate]]);
	
    if (!counterFocused) {
        PDFPage *currentPage = [self.pdfView currentPage];
        NSInteger currentPageNumber = [currentPdf.pdf indexForPage:currentPage];
        [self.pageCounter setIntegerValue:(currentPageNumber+1)];
    }
}

- (IBAction)takePageFromForm:(id)sender
{
    NSInteger value = [sender integerValue]-1;
    if (0 <= value && value <= currentPdf.pdf.pageCount) {
        PDFPage *targetPage = [currentPdf.pdf pageAtIndex:value];
        [self.pdfView goToPage:targetPage];
    }
    [self updatePageCounter];
}

- (IBAction)pageCounterFocus:(id)sender
{
    [self.pageCounter becomeFirstResponder];
}

//////////////////////////////////////////////////////////////////////////////
//
//  Find
//
//////////////////////////////////////////////////////////////////////////////

- (void)findWithOptions:(int)options
{
    NSString *newQuery = self.searchField.stringValue;
    
    if (![currentPdf.searchQuery isEqualToString:newQuery]) {
        currentPdf.searchQuery = newQuery;
        currentPdf.searchResults = [NSMutableArray arrayWithCapacity:0];
        [self.pdfView setHighlightedSelections:nil];
    }

    if (![newQuery isEqualToString:@""] ) {
        PDFSelection *previousSel;
        if ([currentPdf.searchResults count] == 0) {
            PDFPage *currentPage = self.pdfView.currentPage;
            NSPoint currentPoint = self.pdfView.currentDestination.point;
            previousSel = [currentPdf.pdf selectionFromPage:currentPage
                                                    atPoint:currentPoint
                                                     toPage:currentPage
                                                    atPoint:currentPoint];
        } else {
            previousSel = currentPdf.searchResults.lastObject;
            [previousSel setColor:[NSColor yellowColor]];
        }
        PDFSelection *nextSel = [currentPdf.pdf findString:newQuery fromSelection:previousSel withOptions:options];
        if (nextSel) {
            [nextSel setColor:[NSColor greenColor]];
            [currentPdf.searchResults addObject:nextSel];
            PDFSelection *newPos = [nextSel copy];
            for (PDFPage *newPage in nextSel.pages) {
                NSRect newRect = [nextSel boundsForPage:newPage];
                NSPoint newPoint = newRect.origin;
                NSSize newSize = newRect.size;
                NSPoint newPoint2;
                newPoint2.x = newPoint.x + newSize.width;
                newPoint2.y = newPoint.y + newSize.height;
                newPoint.y += 50;
                [newPos addSelection:[currentPdf.pdf selectionFromPage: newPage
                                                               atPoint: newPoint
                                                                toPage: newPage
                                                               atPoint: newPoint2]];
            }
            [self.pdfView goToSelection:newPos];
            [self.pdfView setHighlightedSelections:currentPdf.searchResults];
        }
    }
}

- (IBAction)findNext:(id)sender
{
    [self findWithOptions:NSCaseInsensitiveSearch];
}

- (IBAction)findPrevious:(id)sender
{
    [self findWithOptions: (NSBackwardsSearch | NSCaseInsensitiveSearch)];
}

- (IBAction)findFocus:(id)sender
{
    [self.searchField becomeFirstResponder];
}

//////////////////////////////////////////////////////////////////////////////
//
//  End
//
//////////////////////////////////////////////////////////////////////////////

@end


























