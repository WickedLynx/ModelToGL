//
//  MTGWavefrontParser.m
//  ModelToGL
//
//  Created by Harshad on 04/04/2014.
//  Copyright (c) 2014 Laughing Buddha Software. All rights reserved.
//

#import "MTGWavefrontParser.h"
#import "MTGFileWriter.h"

// Convenience functions to create MTGSceneVertex and MTGSceneTriangle
static MTGSceneVertex MTGSceneVertexMake(GLKVector3 positionCoordinates, GLKVector2 textureCoordinates, GLKVector3 normalCoordinates);
static MTGSceneTriangle MTGSceneTriangleMake(MTGSceneVertex vertexA, MTGSceneVertex vertexB, MTGSceneVertex vertexC);

@implementation MTGWavefrontParser {
    
    NSURL *_fileURL;
    
    MTGFileWriter *_headerWriter;
    MTGFileWriter *_implementationWriter;
    
    NSMutableArray *_vertexRepresentation;
    NSMutableArray *_textureRepresentation;
    NSMutableArray *_normalRepresentation;
    NSMutableArray *_faceRepresentation;
    
}

- (instancetype)initWithFileAtURL:(NSURL *)fileURL {
    
    self = [super init];
    if (self != nil) {
        _fileURL = [fileURL copy];
    }
    
    return self;
}


#pragma mark - Public methods

- (BOOL)parseFile:(NSError *__autoreleasing *)error {
    BOOL success = NO;
    NSError *parseError = nil;
    
    NSData *fileData = [NSData dataWithContentsOfURL:_fileURL];
    NSString *fileRepresentation = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    
    if (fileRepresentation.length > 0) {
        
        // Step 1: Create an array holding each line as a string
        NSArray *allLines = [fileRepresentation componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        _vertexRepresentation = [[NSMutableArray alloc] initWithCapacity:20];
        _textureRepresentation = [[NSMutableArray alloc] initWithCapacity:20];
        _normalRepresentation = [[NSMutableArray alloc] initWithCapacity:20];
        _faceRepresentation = [[NSMutableArray alloc] initWithCapacity:20];
        
        // Step 2: Store strings representing vertices, texture coordinates, normal coordinates in their respective arrays
        for (NSString *aLine in allLines) {
            
            if ([aLine hasPrefix:@"v "]) {
                [_vertexRepresentation addObject:[aLine substringFromIndex:2]];
                
            } else if ([aLine hasPrefix:@"vt "]) {
                [_textureRepresentation addObject:[aLine substringFromIndex:3]];
                
            } else if ([aLine hasPrefix:@"vn "]) {
                [_normalRepresentation addObject:[aLine substringFromIndex:3]];
                
            } else if ([aLine hasPrefix:@"f "]) {
                [_faceRepresentation addObject:[aLine substringFromIndex:2]];
            }
        }
        
        int totalVertices = (int)[_vertexRepresentation count];
        int totalTextureCoords = (int)[_textureRepresentation count];
        int totalNormalCoords = (int)[_normalRepresentation count];
        int totalFaces = (int)[_faceRepresentation count];
        
        
        NSLog(@"Total vertices: %d\nTotal tex coords: %d\nTotal normal coords: %d\nTotal faces: %d", totalVertices, totalTextureCoords, totalNormalCoords, totalFaces);
        
        // Step 3: Make a C array for each positon vector
        GLKVector3 positionVectors[totalVertices];
        NSArray *subArray = nil;

        for (int vertexCount = 0; vertexCount != totalVertices; ++vertexCount) {
            
            NSString *aString = _vertexRepresentation[vertexCount];
            subArray = [aString componentsSeparatedByString:@" "];
            
            GLfloat currentVector[3];
            for (int coordinateCount = 0; coordinateCount != 3; ++coordinateCount) {
                currentVector[coordinateCount] = [subArray[coordinateCount] floatValue];
            }
            
            positionVectors[vertexCount] = GLKVector3Make(currentVector[0], currentVector[1], currentVector[2]);
        }
        
        // Step 4: Make a C array for each texture vector
        GLKVector2 textureVectors[totalTextureCoords];
        subArray = nil;
        for (int texCount = 0; texCount != totalTextureCoords; ++texCount) {
            NSString *aString = _textureRepresentation[texCount];
            subArray = [aString componentsSeparatedByString:@" "];
            
            GLfloat currentTex[2];
            for (int texCoordCount = 0; texCoordCount != 2; ++texCoordCount) {
                currentTex[texCoordCount] = [subArray[texCoordCount] floatValue];
            }
            
            textureVectors[texCount] = GLKVector2Make(currentTex[0], currentTex[1]);
        }
        
        // Step 5: Make a C array for each normal
        GLKVector3 normalVectors[totalNormalCoords];
        subArray = nil;
        for (int normalCount = 0; normalCount != totalNormalCoords; ++normalCount) {
            NSString *aString = _normalRepresentation[normalCount];
            subArray = [aString componentsSeparatedByString:@" "];
            
            GLfloat currentNormal[3];
            for (int normalCoordCount = 0; normalCoordCount != 3; ++normalCoordCount) {
                currentNormal[normalCoordCount] = [subArray[normalCoordCount] floatValue];
            }
            
            normalVectors[normalCount] = GLKVector3Make(currentNormal[0], currentNormal[1], currentNormal[2]);
        }
        
        // Step 6: Create vertices, and then faces
        MTGSceneTriangle triangles[totalFaces];
        subArray = nil;
        for (int triangleCount = 0; triangleCount != totalFaces; ++triangleCount) {
            NSString *aString = _faceRepresentation[triangleCount];
            subArray = [aString componentsSeparatedByString:@" "];
            MTGSceneVertex currentTriangle[3];
            for (int vertexCount = 0; vertexCount != 3; ++vertexCount) {
                
                NSString *vertexDescription = subArray[vertexCount];
                NSArray *subSubArray = [vertexDescription componentsSeparatedByString:@"/"];
                
                int positionIndex = [subSubArray[0] intValue] - 1;
                int textureIndex = [subSubArray[1] intValue] - 1;
                int normalIndex = [subSubArray[2] intValue] - 1;
                
                currentTriangle[vertexCount] = MTGSceneVertexMake(positionVectors[positionIndex], textureVectors[textureIndex], normalVectors[normalIndex]);
            }
            
            triangles[triangleCount] = MTGSceneTriangleMake(currentTriangle[0], currentTriangle[1], currentTriangle[2]);
        }

        NSString *basePath = [[_fileURL path] stringByDeletingLastPathComponent];
        NSString *fileName = [[[_fileURL path] lastPathComponent] stringByDeletingPathExtension];
        
        MTGFileWriter *implementationWriter = [[MTGFileWriter alloc] initForWritingToFileAtURL:[NSURL fileURLWithPath:basePath] fileName:fileName];
        [implementationWriter writeTriangles:triangles totalTriangles:totalFaces];
        
    } else {
        parseError = [NSError errorWithDomain:@"com.laughingBuddhaSoftware.wavefrontParser.fileNotFound" code:1001 userInfo:nil];
    }
    
    if (parseError != nil && error != nil) {
        *error = parseError;
    }

    return success;
}

@end

// Convenience functions to create MTGSceneVertex and MTGSceneTriangle
static MTGSceneVertex MTGSceneVertexMake(GLKVector3 positionCoordinates, GLKVector2 textureCoordinates, GLKVector3 normalCoordinates) {
    MTGSceneVertex vertex;
    
    vertex.position = positionCoordinates;
    vertex.texture = textureCoordinates;
    vertex.normal = normalCoordinates;
    
    return vertex;
}

static MTGSceneTriangle MTGSceneTriangleMake(MTGSceneVertex vertexA, MTGSceneVertex vertexB, MTGSceneVertex vertexC) {
    MTGSceneTriangle triangle;
    
    triangle.vertices[0] = vertexA;
    triangle.vertices[1] = vertexB;
    triangle.vertices[2] = vertexC;
    
    return triangle;
}
