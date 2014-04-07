//
//  MTGRootController.m
//  ModelToGL
//
//  Created by Harshad on 07/04/14.
//  Copyright (c) 2014 Laughing Buddha Software. All rights reserved.
//

#import "MTGRootController.h"

#import "MTGDragView.h"

#import "MTGWavefrontParser.h"

@interface MTGRootController () <MTGDragViewDelegate>

@property (strong) IBOutlet MTGDragView *dragView;

@end

@implementation MTGRootController

- (void)awakeFromNib {
    [self.dragView setDelegate:self];
}

- (void)dragViewDidAcceptFileAtURL:(NSURL *)url {
    MTGWavefrontParser *parser = [[MTGWavefrontParser alloc] initWithFileAtURL:url];
    [parser parseFile:nil];
}

@end
