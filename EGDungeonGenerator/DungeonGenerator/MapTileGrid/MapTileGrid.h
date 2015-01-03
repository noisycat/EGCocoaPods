//
//  MapTiles.h
//  ProceduralLevelGeneration
//
//  Created by Charles Cliff on 11/23/14.
//  Copyright (c) 2014 ElysiumEngineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@interface MapTileGrid : NSObject

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) CGSize gridSize;

- (instancetype) initWithGridSize:(CGSize)size;

- (BOOL) isEdgeTileAt:(CGPoint)tileCoordinate;
- (BOOL) isValidTileCoordinateAt:(CGPoint)tileCoordinate;

//- (BOOL) isWalkableTileCoordinateAt:(CGPoint)tileCoord;

- (void) setTileType:(NSInteger)tileType At:(CGPoint)coorindate;
- (NSInteger) getTileTypeAt:(CGPoint)coorindate;

- (void) copyMapTileGrid:(MapTileGrid*)inputTileGrid AtCoordinate:(CGPoint)coordinate;

@end
