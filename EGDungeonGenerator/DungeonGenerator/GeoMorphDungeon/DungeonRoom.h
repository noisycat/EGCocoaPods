//
//  DungeonRoom.h
//  DungeonGenerator
//
//  Created by Charles Cliff on 12/28/14.
//  Copyright (c) 2014 EETech. All rights reserved.
//

#define kSmallRoomWidth  7
#define kMediumRoomWidth 9
#define kLargeRoomWidth  11

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import "MapTileGrid.h"

typedef NS_ENUM(NSInteger, kRoomTileType)
{
    kRoomTileEntrance  =  1,
};

typedef NS_ENUM(NSInteger, kDungeonRoomSize)
{
    kRoomSmall     =  7,
    kRoomMedium    =  9,
    kRoomLarge     =  11,
};

typedef NS_ENUM(NSInteger, kDungeonRoomPosition)
{
    kRoomPositionCenter     =  0,
    kRoomPositionBottomLeft =  1,
    kRoomPositionBottomRight=  2,
    kRoomPositionTopLeft    =  3,
    kRoomPositionTopRight   =  4,
};

@interface DungeonRoom : MapTileGrid
{
    kDungeonRoomSize roomSize;
}

@property(nonatomic) BOOL isBlockedNorth;
@property(nonatomic) BOOL isBlockedEast;
@property(nonatomic) BOOL isBlockedSouth;
@property(nonatomic) BOOL isBlockedWest;

@property(nonatomic) CGPoint coordinateEastDoor;
@property(nonatomic) CGPoint coordinateNorthDoor;
@property(nonatomic) CGPoint coordinateSouthDoor;
@property(nonatomic) CGPoint coordinateWestDoor;

@property(nonatomic) CGPoint coordinate;

@property(nonatomic) kDungeonRoomPosition position;

//----------------------------------------------------------------------------------------------
#pragma mark - Class Methods

- (id) initRoomOfSize:(kDungeonRoomSize)inputSize;

- (void) generateRandomRoom;
- (void) generateRandomDoors;

- (NSUInteger) roomSize;

@end
