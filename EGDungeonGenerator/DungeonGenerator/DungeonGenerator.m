//
//  DungeonGenerator.m
//  EGTileMap
//
//  Created by Charles Cliff on 12/29/14.
//  Copyright (c) 2014 EETech. All rights reserved.
//

#import "DungeonGenerator.h"

@implementation DungeonGenerator

//----------------------------------------------------------------------------------------------
#pragma mark - Getters

- (MapTileGrid*) dungeonLayer
{
    return dungeonLayer;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Generators

- (void) generateWalls
{
    for ( NSInteger y = 0; y < dungeonLayer.gridSize.height; y++ ) {
        for ( NSInteger x = 0; x < dungeonLayer.gridSize.width; x++ ) {
            CGPoint tileCoordinate = CGPointMake(x, y);
            if ( [dungeonLayer getTileTypeAt:tileCoordinate] == kDungeonTileFloor )
            {
                // Iterate through Every Nieghboring Tile
                for ( NSInteger neighbourY = -1; neighbourY < 2; neighbourY++ ) {
                    for ( NSInteger neighbourX = -1; neighbourX < 2; neighbourX++ ) {
                        if ( !(neighbourX == 0 && neighbourY == 0) ) {
                            CGPoint coordinate = CGPointMake(x + neighbourX, y + neighbourY);
                            
                            // If there is no Tile there, then populate the tile with a Wall Tile
                            if ( [dungeonLayer getTileTypeAt:coordinate] == kDungeonTileNone )
                                [dungeonLayer setTileType:kDungeonTileWall At:coordinate];
                        }
                    }
                }
            }
        }
    }
}

@end
