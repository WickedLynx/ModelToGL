//
//  MTGDragView.m
//  ModelToGL
//
//  Created by Harshad on 07/04/14.
//  Copyright (c) 2014 Laughing Buddha Software. All rights reserved.
//

#import "MTGDragView.h"

@implementation MTGDragView

@synthesize delegate = _delegate;


- (void)awakeFromNib {
    [self registerForDraggedTypes:@[(NSString *)kUTTypeURL]];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    _draggedFileURL = nil;
    NSDragOperation dragOperation = NSDragOperationNone;

    NSPasteboard *thePasteboard = [sender draggingPasteboard];
    NSArray *draggedURLs = [thePasteboard readObjectsForClasses:@[[NSURL class]] options:@{NSPasteboardURLReadingFileURLsOnlyKey : @(YES), NSPasteboardURLReadingContentsConformToTypesKey : @[(NSString *)kUTTypeItem]}];

    NSURL *fileURL = [draggedURLs firstObject];
    if ([[[fileURL path] pathExtension] caseInsensitiveCompare:@"obj"] == NSOrderedSame) {
        dragOperation = NSDragOperationLink;
        _draggedFileURL = fileURL;
    }


    return dragOperation;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {

    if (_draggedFileURL != nil) {
        [self.delegate dragViewDidAcceptFileAtURL:_draggedFileURL];
        _draggedFileURL = nil;
        return YES;
    }


    return NO;
}


@end
