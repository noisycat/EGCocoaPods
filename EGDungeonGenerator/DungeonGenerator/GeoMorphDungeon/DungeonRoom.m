//
//  DungeonRoom.m
//  DungeonGenerator
//
//  Created by Charles Cliff on 12/28/14.
//  Copyright (c) 2014 EETech. All rights reserved.
//

#import "DungeonRoom.h"
#import "DungeonGenerator.h"

@interface DungeonRoom()

//@property(nonatomic,strong) TileLayer* roomMap;

- (void) generateRandomRoomMap;
- (void) generateRandomDoors;

@end

@implementation DungeonRoom

//----------------------------------------------------------------------------------------------
#pragma mark - Class Methods

+ (DungeonRoom*) dungeonRoomOfSize:(kDungeonRoomSize)inputSize
{
    DungeonRoom* room = [[DungeonRoom alloc] initRoomOfSize:inputSize];
    
    // 2. Generate the Room Map
    [room generateRandomRoomMap];
    
    // 3. Generate the Doors
    [room generateRandomDoors];
    
    return room;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Init

- (id) initRoomOfSize:(kDungeonRoomSize)inputSize
{
    self = [super initWithGridSize:CGSizeMake(inputSize, inputSize)];
    if (self != nil)
    {
        roomSize = inputSize;
        
        // 1. Set the Blocked Flags
        self.isBlockedNorth = YES;
        self.isBlockedEast  = YES;
        self.isBlockedSouth = YES;
        self.isBlockedWest  = YES;
        
        // 2. Set the Tiles to be Floor Tiles
        for ( NSInteger y = 1; y < self.gridSize.height-1; y++ ) {
            for ( NSInteger x = 1; x < self.gridSize.width-1; x++ ) {
                [self setTileType:kDungeonTileFloor At:CGPointMake(x, y)];
            }
        }
    }
    return self;
}

- (NSUInteger) roomSize
{
    return roomSize;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Random Room

- (void) generateRandomRoom
{
    // Generate the Room Map
//    [self generateRandomRoomMap];
    
    // Generate the Doors
    [self generateRandomDoors];
}

//----------------------------------------------------------------------------------------------
#pragma mark - Doors

- (void) generateRandomDoors
{
    if ( !self.isBlockedNorth ) {
        CGPoint doorCooridnate = CGPointMake([self randomNumberBetweenMin:2 andMax:(roomSize-1)], self.gridSize.height - 1);
        self.coordinateNorthDoor = doorCooridnate;
        [self setTileType:kDungeonTileDoor At:doorCooridnate];
    }
    if ( !self.isBlockedSouth ) {
        CGPoint doorCooridnate = CGPointMake([self randomNumberBetweenMin:2 andMax:(roomSize-1)], 0);
        self.coordinateSouthDoor = doorCooridnate;
        [self setTileType:kDungeonTileDoor At:doorCooridnate];
    }
    if ( !self.isBlockedEast ) {
        CGPoint doorCooridnate = CGPointMake(self.gridSize.width - 1, [self randomNumberBetweenMin:2 andMax:(roomSize-1)]);
        self.coordinateEastDoor = doorCooridnate;
        [self setTileType:kDungeonTileDoor At:doorCooridnate];
    }
    if ( !self.isBlockedWest ) {
        CGPoint doorCooridnate = CGPointMake(0, [self randomNumberBetweenMin:2 andMax:(roomSize-1)]);
        self.coordinateWestDoor = doorCooridnate;
        [self setTileType:kDungeonTileDoor At:doorCooridnate];
    }
}

//----------------------------------------------------------------------------------------------
#pragma mark - Utilities
// TO DO: Move this to a set of utilities...
- (NSInteger) randomNumberBetweenMin:(NSInteger)min andMax:(NSInteger)max
{
    return min + arc4random() % (max - min);
}

@end
