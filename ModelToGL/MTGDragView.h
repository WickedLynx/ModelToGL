//
//  MTGDragView.h
//  ModelToGL
//
//  Created by Harshad on 07/04/14.
//  Copyright (c) 2014 Laughing Buddha Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MTGDragView;

@protocol MTGDragViewDelegate <NSObject>

@required

- (void)dragViewDidAcceptFileAtURL:(NSURL *)url;

@end

@interface MTGDragView : NSView <NSDraggingDestination> {
    NSURL *_draggedFileURL;
}

@property (weak) id <MTGDragViewDelegate> delegate;

@end
