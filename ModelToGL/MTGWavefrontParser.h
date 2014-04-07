//
//  MTGWavefrontParser.h
//  ModelToGL
//
//  Created by Harshad on 04/04/2014.
//  Copyright (c) 2014 Laughing Buddha Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 position;
    GLKVector2 texture;
    GLKVector3 normal;
} MTGSceneVertex;

typedef struct {
    MTGSceneVertex vertices[3];
} MTGSceneTriangle;

@interface MTGWavefrontParser : NSObject

- (instancetype)initWithFileAtURL:(NSURL *)fileURL;

- (BOOL)parseFile:(NSError *__autoreleasing *)error;

@end
