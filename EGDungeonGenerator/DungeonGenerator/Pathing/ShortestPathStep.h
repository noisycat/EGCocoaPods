//
//  ShortestStepPath.h
//  EGTileMap
//
//  Created by Charles Cliff on 12/30/14.
//  Copyright (c) 2014 EETech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@interface ShortestPathStep : NSObject  // A class that represents a step of the computed path
{
    CGPoint position;
    int gScore;
    int hScore;
}

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) int gScore;
@property (nonatomic, assign) int hScore;
@property (nonatomic, assign) ShortestPathStep *parent;

- (id)initWithPosition:(CGPoint)pos;
- (int)fScore;

@end
