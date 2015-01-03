//
//  MapTiles.m
//  ProceduralLevelGeneration
//
//  Created by Charles Cliff on 11/23/14.
//  Copyright (c) 2014 ElysiumEngineering. All rights reserved.
//

#import "MapTileGrid.h"

@interface MapTileGrid ()
@property (nonatomic) NSInteger *tiles;
@end

@implementation MapTileGrid

//----------------------------------------------------------------------------------------------
#pragma mark - Init

- (instancetype) initWithGridSize:(CGSize)size
{
  if (( self = [super init] ))
  {
    _gridSize = size;
    _count = (NSUInteger) size.width * size.height;
    self.tiles = calloc(self.count, sizeof(NSInteger));
    NSAssert(self.tiles, @"Could not allocate memory for tiles");
  }
  return self;
}

//----------------------------------------------------------------------------------------------
#pragma mark - 

- (BOOL) isValidTileCoordinateAt:(CGPoint)tileCoordinate
{
  return !( tileCoordinate.x < 0 ||
           tileCoordinate.x >= self.gridSize.width ||
           tileCoordinate.y < 0 ||
           tileCoordinate.y >= self.gridSize.height );
}

- (NSInteger) tileIndexAt:(CGPoint)tileCoordinate
{
  if ( ![self isValidTileCoordinateAt:tileCoordinate] ) {
    return -1;
  }
  return ((NSInteger)tileCoordinate.y * (NSInteger)self.gridSize.width + (NSInteger)tileCoordinate.x);
}

- (BOOL) isEdgeTileAt:(CGPoint)tileCoordinate
{
  return ((NSInteger)tileCoordinate.x == 0 ||
          (NSInteger)tileCoordinate.x == (NSInteger)self.gridSize.width - 1 ||
          (NSInteger)tileCoordinate.y == 0 ||
          (NSInteger)tileCoordinate.y == (NSInteger)self.gridSize.height - 1);
}

//----------------------------------------------------------------------------------------------
#pragma mark - Printing the MapTileGrid to the Console

- (NSString *) description
{
  NSMutableString *tileMapDescription = [NSMutableString stringWithFormat:@"<%@ = %p | \n",
                                         [self class], self];
  
  for ( NSInteger y = 0; y < (NSInteger)self.gridSize.height; y++ )
  {
    [tileMapDescription appendString:[NSString stringWithFormat:@"[%3li]", (long)(y)]];
    
    for ( NSInteger x = 0; x < (NSInteger)self.gridSize.width; x++ )
    {
      [tileMapDescription appendString:[NSString stringWithFormat:@"%li", (long)[self getTileTypeAt:CGPointMake(x, y)]]];
    }
    [tileMapDescription appendString:@"\n"];
  }
  return [tileMapDescription stringByAppendingString:@">"];
}

//----------------------------------------------------------------------------------------------
#pragma mark - TileTypes at Coordinates

- (void) setTileType:(NSInteger)type At:(CGPoint)tileCoordinate
{
    NSInteger tileArrayIndex = [self tileIndexAt:tileCoordinate];
    if ( tileArrayIndex == -1 )
    {
        return;
    }
    self.tiles[tileArrayIndex] = type;
}

- (NSInteger) getTileTypeAt:(CGPoint)tileCoordinate
{
    NSInteger tileArrayIndex = [self tileIndexAt:tileCoordinate];
    if ( tileArrayIndex == -1 )
    {
        return -1;
    }
    return self.tiles[tileArrayIndex];
}

//----------------------------------------------------------------------------------------------
#pragma mark - Combining MapTileGrid

- (void) copyMapTileGrid:(MapTileGrid*)inputTileGrid AtCoordinate:(CGPoint)coordinate
{
    // 1. Determine if the INPUT TILE LAYER is larger than SELF
    if ( inputTileGrid.gridSize.width > self.gridSize.width ) {
        return;
    }
    if ( inputTileGrid.gridSize.height > self.gridSize.height ) {
        return;
    }
    
    // 2. Iterate through every Tile in the INPUT MAP
    //      Start Iterating at Coordinate (0,0)
    for ( NSInteger y = 0; y < inputTileGrid.gridSize.height; y++ ) {
        for ( NSInteger x = 0; x < inputTileGrid.gridSize.width; x++ ) {
            // 3. Copy the value of the INPUT MAP to SELF
            [self setTileType:[inputTileGrid getTileTypeAt:CGPointMake(x, y)]
                           At:CGPointMake(coordinate.x + x, coordinate.y + y)];
        }
    }
}
@end
