//
//  PathAlgorithm.h
//  DungeonGenerator
//
//  Created by Charles Cliff on 12/29/14.
//  Copyright (c) 2014 EETech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import <CoreGraphics/CGGeometry.h>
#import "DungeonGenerator.h"
#import "ShortestPathStep.h"

@interface AStarPath : NSObject

- (id) initWithTileLayer:(DungeonGenerator*) inputTileLayer;

- (NSMutableArray*) moveToTileCoord:(CGPoint) tileCoord FromTileCoord:(CGPoint) fromCoord;

@end
