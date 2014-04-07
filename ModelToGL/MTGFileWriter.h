//
//  MTGFileWriter.h
//  ModelToGL
//
//  Created by Harshad on 04/04/2014.
//  Copyright (c) 2014 Laughing Buddha Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTGWavefrontParser.h"

@interface MTGFileWriter : NSObject

- (instancetype)initForWritingToFileAtURL:(NSURL *)outputURL fileName:(NSString *)fileName;
- (void)writeTriangles:(MTGSceneTriangle *)triangles totalTriangles:(int)totalTriangles;

@end
