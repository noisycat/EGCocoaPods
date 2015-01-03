//
//  DungeonGenerator.h
//  DungeonGenerator
//
//  Created by Charles Cliff on 12/29/14.
//  Copyright (c) 2014 EETech. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "TileLayer.h"
#import "MapTileGrid.h"

typedef NS_ENUM(NSInteger, kDungeonTileType)
{
    kDungeonTileNone  =  0,
    kDungeonTileFloor  =  1,
    kDungeonTileWall   =  2,
    kDungeonTileDoor   =  3,
};

@interface DungeonGenerator : NSObject
{
    MapTileGrid *dungeonLayer;
}

#pragma mark - Getters
- (MapTileGrid*) dungeonLayer;

#pragma mark - Generators
+ (MapTileGrid*) generateDungeon;
- (void) generateWalls;

#pragma mark - Over Write Methods
- (BOOL) isWalkableTileCoordinateAt:(CGPoint)coordinate;

@end
