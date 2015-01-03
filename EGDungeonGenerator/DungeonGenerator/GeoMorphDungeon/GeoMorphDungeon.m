//
//  GeoMorphDungeon.m
//  DungeonGenerator
//
//  Created by Charles Cliff on 12/27/14.
//  Copyright (c) 2014 EETech. All rights reserved.
//

#import "GeoMorphDungeon.h"

#pragma mark - SectorGrid
typedef NS_ENUM(NSInteger, SectorType)
{
    kSectorInactive = -1,
    kSectorUnBlocked=  0,
    kSectorNorth    =  1,
    kSectorEast     =  2,
    kSectorSouth    =  3,
    kSectorWest     =  4,
};

typedef NS_ENUM(NSInteger, kSectorSize)
{
    kSectorSmall   =  9,
    kSectorMedium  =  11,
    kSectorLarge   =  13
};

@interface SectorGrid : NSObject

@property (nonatomic) NSInteger *tiles;
@property (nonatomic, readonly) CGSize gridSize;

- (instancetype) initWithGridSize:(CGSize)size;
- (instancetype) initWithSectorSize:(kSectorSize)size;

- (BOOL) isEdgeAt:(CGPoint)tileCoordinate;
- (BOOL) isValidSector:(CGPoint)tileCoordinate;

@end

@implementation SectorGrid

- (instancetype) initWithGridSize:(CGSize)size
{
    if (( self = [super init] ))
    {
        _gridSize = size;
        self.tiles = calloc((NSUInteger) size.width * size.height, sizeof(NSInteger));
        NSAssert(self.tiles, @"Could not allocate memory for tiles");
    }
    return self;
}

- (instancetype) initWithSectorSize:(kSectorSize)size
{
    if (( self = [super init] ))
    {
        _gridSize = CGSizeMake(size, size);
        self.tiles = calloc((NSUInteger) self.gridSize.width * self.gridSize.height, sizeof(NSInteger));
        NSAssert(self.tiles, @"Could not allocate memory for tiles");
    }
    return self;
}

- (BOOL) isValidSector:(CGPoint)tileCoordinate
{
    return !( tileCoordinate.x < 0 ||
             tileCoordinate.x >= self.gridSize.width ||
             tileCoordinate.y < 0 ||
             tileCoordinate.y >= self.gridSize.height );
}

- (NSInteger) tileIndexAt:(CGPoint)tileCoordinate
{
    if ( ![self isValidSector:tileCoordinate] )
        return kSectorInactive;
    
    return ((NSInteger)tileCoordinate.y * (NSInteger)self.gridSize.width + (NSInteger)tileCoordinate.x);
}

- (NSInteger) sectorTypeAt:(CGPoint)tileCoordinate
{
    NSInteger tileArrayIndex = [self tileIndexAt:tileCoordinate];
    if ( tileArrayIndex == -1 )
        return kSectorInactive;
    
    return self.tiles[tileArrayIndex];
}

- (void) setSectorType:(NSInteger)type at:(CGPoint)tileCoordinate
{
    NSInteger tileArrayIndex = [self tileIndexAt:tileCoordinate];
    if ( tileArrayIndex == -1 )
        return;
    
    self.tiles[tileArrayIndex] = type;
}

- (BOOL) isEdgeAt:(CGPoint)tileCoordinate
{
    return ((NSInteger)tileCoordinate.x == 0 ||
            (NSInteger)tileCoordinate.x == (NSInteger)self.gridSize.width - 1 ||
            (NSInteger)tileCoordinate.y == 0 ||
            (NSInteger)tileCoordinate.y == (NSInteger)self.gridSize.height - 1);
}

- (NSString *) description
{
    NSMutableString *tileMapDescription = [NSMutableString stringWithFormat:@"<%@ = %p | \n",
                                           [self class], self];
    for ( NSInteger y = 0; y < (NSInteger)self.gridSize.height; y++ ) {
        [tileMapDescription appendString:[NSString stringWithFormat:@"[%3li]", (long)(y)]];
        for ( NSInteger x = 0; x < (NSInteger)self.gridSize.width; x++ ) {
            [tileMapDescription appendString:[NSString stringWithFormat:@"%li", (long)[self sectorTypeAt:CGPointMake(x, y)]]];
        }
        [tileMapDescription appendString:@"\n"];
    }
    return [tileMapDescription stringByAppendingString:@">"];
}

@end

//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
#pragma mark - GeoMorphDungeon

@interface GeoMorphDungeon()

@property(nonatomic) CGSize sectorGridSize;
@property(nonatomic) kSectorSize sectorSize;

@end

@implementation GeoMorphDungeon
{
    NSUInteger inactiveSectorProbability;
    NSUInteger inactiveSectorMaximum;
    
    NSMutableArray *rooms;
    
    SectorGrid *sectorGrid;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Generate

+ (MapTileGrid*) generateDungeon
{
    GeoMorphDungeon *geomorph = [[GeoMorphDungeon alloc] init];
    [geomorph setUp];
    return nil;
//    return geomorph;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Init

- (id) init
{
    self = [super init];
    if (self != nil)
    {
        rooms = [[NSMutableArray alloc] init];
        
        // Default Values
        self.sectorGridSize = CGSizeMake(6, 6);
        self.sectorSize = kSectorLarge;
        
        inactiveSectorProbability = 0.3;
        inactiveSectorMaximum = 3;
    }
    return self;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Super Methods

- (BOOL) isWalkableTileCoordinateAt:(CGPoint)coordinate
{
    if ( [self.dungeonLayer getTileTypeAt:coordinate] == kDungeonTileWall ) {
        return NO;
    }
    return YES;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Set-Up

- (void) setUp
{
    // 1. Set up the Dungoen Floor Map
    dungeonLayer = [[MapTileGrid alloc] initWithGridSize:CGSizeMake(self.sectorSize * self.sectorGridSize.width,
                                                                  self.sectorSize * self.sectorGridSize.height)];
    // 2. Set Up the Secotr Grid
    [self generateSectors];

    // 3. Generate Rooms
    [self generateRooms];
    
    // 3. Generate Corridors
    [self generateCorridors];
    
    NSLog(@"%@", [dungeonLayer description]);
}

//----------------------------------------------------------------------------------------------
#pragma mark - Sector Set-Up

- (void) generateSectors
{
    // 1. Instantiate a Sector Grid
    sectorGrid = [[SectorGrid alloc] initWithGridSize:self.sectorGridSize];
    
    // 2. Determine Active Sectors
    [self generateInactiveSectors];
    
    // 3. Determine Blocked Sector Sides
    [self generateBlockedSectors];
}

- (void) generateInactiveSectors
{
    NSInteger inactiveSectorCount = 0;
    
    while ( inactiveSectorCount <= inactiveSectorMaximum )
    {
        for ( NSInteger y = 0; y < sectorGrid.gridSize.height; y++ ) {
            for ( NSInteger x = 0; x < sectorGrid.gridSize.width; x++ ) {
                
                if ( (arc4random()%100) <= inactiveSectorProbability ) {
                    inactiveSectorCount = inactiveSectorCount + 1;
                    [sectorGrid setSectorType:kSectorInactive at:CGPointMake(x, y)];
                    
                    if (inactiveSectorCount > inactiveSectorMaximum)
                        return;
                }
            }
        }
    }
}

- (void) generateBlockedSectors
{
    for ( NSInteger y = 0; y < sectorGrid.gridSize.height; y++ ) {
        for ( NSInteger x = 0; x < sectorGrid.gridSize.width; x++ ) {
            
            if ( [sectorGrid sectorTypeAt:CGPointMake(x, y)] != kSectorInactive)
            {
                NSInteger i = arc4random() % 4;
                [sectorGrid setSectorType:i at:CGPointMake(x, y)];
            }
        }
    }
}

//----------------------------------------------------------------------------------------------
#pragma mark - Room Generation

- (void) generateRooms
{
        for ( NSInteger y = 0; y < sectorGrid.gridSize.height; y++ ) {
            for ( NSInteger x = 0; x < sectorGrid.gridSize.width; x++ ) {
    
                // 1. Don't add rooms to inactive sectors
                if ([sectorGrid sectorTypeAt:CGPointMake(x, y)] != kSectorInactive)
                {
                    //
                    DungeonRoom *newRoom = [self generateRoomOfRandomSize];
                    
                    // Randomize the ROOM POSITION
                    newRoom.position = arc4random() % 5;
                    
                    // 2. Determine if the room is blocked in it's cardinal directions
                    if ( ([sectorGrid sectorTypeAt:CGPointMake(x, y-1)] != kSectorInactive) &&
                         ([sectorGrid sectorTypeAt:CGPointMake(x, y)] != kSectorSouth))
                        newRoom.isBlockedSouth  = NO;
                    if ( ([sectorGrid sectorTypeAt:CGPointMake(x, y+1)] != kSectorInactive) &&
                         ([sectorGrid sectorTypeAt:CGPointMake(x, y)] != kSectorNorth))
                        newRoom.isBlockedNorth  = NO;
                    if ( ([sectorGrid sectorTypeAt:CGPointMake(x+1, y)] != kSectorInactive) &&
                         ([sectorGrid sectorTypeAt:CGPointMake(x, y)] != kSectorEast))
                        newRoom.isBlockedEast   = NO;
                    if ( ([sectorGrid sectorTypeAt:CGPointMake(x-1, y)] != kSectorInactive) &&
                         ([sectorGrid sectorTypeAt:CGPointMake(x, y)] != kSectorWest))
                        newRoom.isBlockedWest   = NO;

                    // 4. Generate a Random Room
                    [newRoom generateRandomRoom];
                    
                    // 5. Add the New Room to our Room Array
                    [rooms addObject:newRoom];
    
                    [self insertRoom:newRoom InSector:CGPointMake(x, y)];
                    
                } else {
                    // We cannot add nil objects, but we need *something* to take the place so that we have the correct size of the array
                    // Maybe a Dicitonary instead? And the Keys are the Sector Indeces?
                    /// ... Go fuck yourself Objective C
                    [rooms addObject:[NSNumber numberWithInt:-1]];
                }
            }
        }
    
    // 6. Generate the Walls around each room
    [self generateWalls];
}

- (DungeonRoom*) generateRoomOfRandomSize
{
    DungeonRoom *room = nil;
    
    switch (self.sectorSize) {
        case kSectorSmall:
            room = [[DungeonRoom alloc] initRoomOfSize:kRoomSmall];
            break;
        case kSectorMedium:
            switch (arc4random()%2) {
                case 0:
                    room = [[DungeonRoom alloc] initRoomOfSize:kRoomSmall];
                    break;
                case 1:
                    room = [[DungeonRoom alloc] initRoomOfSize:kRoomMedium];
                    break;
                default:
                    break;
            }
            break;
        case kSectorLarge:
            switch (arc4random()%3) {
                case 0:
                    room = [[DungeonRoom alloc] initRoomOfSize:kRoomSmall];
                    break;
                case 1:
                    room = [[DungeonRoom alloc] initRoomOfSize:kRoomMedium];
                    break;
                case 2:
                    room = [[DungeonRoom alloc] initRoomOfSize:kRoomLarge];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return room;
}

#pragma mark Position a Room in a Sector

- (void) insertRoom:(DungeonRoom*)room InSector:(CGPoint)sectorCoordinate
{
    CGFloat sectorTopLeftX;
    CGFloat sectorTopLeftY;
    
    // 1. Control the position of the Room based on it's POSITION setting
    switch (room.position)
    {
        // 2. Determine the Origin (Bottom Left) of the selected Sector
        case kRoomPositionCenter:
            sectorTopLeftX = (NSInteger) (sectorCoordinate.x * self.sectorSize + self.sectorSize / 2 + 1 - room.gridSize.width / 2);
            sectorTopLeftY = (NSInteger) (sectorCoordinate.y * self.sectorSize + self.sectorSize / 2 + 1 - room.gridSize.height/ 2);
            break;
        case kRoomPositionBottomLeft:
            sectorTopLeftX = (NSInteger) (sectorCoordinate.x * self.sectorSize) + 1;
            sectorTopLeftY = (NSInteger) (sectorCoordinate.y * self.sectorSize) + 1;
            break;
        case kRoomPositionBottomRight:
            sectorTopLeftX = (NSInteger) ((sectorCoordinate.x + 1) * self.sectorSize - room.gridSize.width - 1);
            sectorTopLeftY = (NSInteger) ((sectorCoordinate.y * self.sectorSize) + 1);
            break;
        case kRoomPositionTopLeft:
            sectorTopLeftX = (NSInteger) (sectorCoordinate.x * self.sectorSize) + 1;
            sectorTopLeftY = (NSInteger) ((sectorCoordinate.y + 1) * self.sectorSize - room.gridSize.height - 1);
            break;
        case kRoomPositionTopRight:
            sectorTopLeftX = (NSInteger) ((sectorCoordinate.x + 1) * self.sectorSize - room.gridSize.width - 1);
            sectorTopLeftY = (NSInteger) ((sectorCoordinate.y + 1) * self.sectorSize - room.gridSize.height - 1);
            break;
        default:
            break;
    }
    
    // 3. Insert the INPUT ROOM and
    [dungeonLayer copyMapTileGrid:room AtCoordinate:CGPointMake(sectorTopLeftX, sectorTopLeftY)];
    
    // 4. Set the Coordinate of the INPUT ROOM
    room.coordinate = CGPointMake(sectorTopLeftX, sectorTopLeftY);
}
//----------------------------------------------------------------------------------------------
#pragma mark - Corridor Generation

- (void) generateCorridors
{
    // 1. Generate the Horizontal Corridors
    [self generateHorizontalCorridors];
    
    // 2. Generate the Horizontal Corridors
    [self generateVerticalCorridors];
    
    // 3. Generate the Walls around each corridor
    [self generateWalls];
}


- (void) generateHorizontalCorridors
{
    for ( NSInteger y = 0; y < sectorGrid.gridSize.height; y++ ) {
        for ( NSInteger x = 0; x < sectorGrid.gridSize.width; x++ ) {
            
            // 1. Determine if the Sector is Inactive
            if ( kSectorInactive != [sectorGrid sectorTypeAt:CGPointMake(x, y)])
            {
                DungeonRoom *room = [self roomInSector:CGPointMake(x, y)];
                if ( room != nil) {
                    // 2. Determine if the Sector is Block to the North
                    if (!room.isBlockedEast) {
                        
                        // 3. Determine the Coordinate of the Eastern Door of the selected Room
                        CGPoint eastDoorPoint = CGPointMake(room.coordinateEastDoor.x +
                                                            room.coordinate.x,
                                                            room.coordinateEastDoor.y +
                                                            room.coordinate.y);
                        
                        // 4. Determine the Coordinate of the Western Door on the adjacent Room
                        DungeonRoom *westRoom = [self roomInSector:CGPointMake(x+1, y)];
                        CGPoint westDoorPoint = CGPointMake(westRoom.coordinateWestDoor.x +
                                                            westRoom.coordinate.x,
                                                            westRoom.coordinateWestDoor.y +
                                                            westRoom.coordinate.y);

                        // 5. Utilize the A Star Pathing Algorithm to Determine the Corridor Path
                        AStarPath *starPathAlgorithm = [[AStarPath alloc] initWithTileLayer:self];
                        NSMutableArray *path = [starPathAlgorithm moveToTileCoord:eastDoorPoint FromTileCoord:westDoorPoint];
                        
                        // 6. Set every tile in the path to be a DUNGEON FLOOR TILE
                        for (int i = 0; i < ([path count] - 1); i++) {
                            [dungeonLayer setTileType:kDungeonTileFloor At:CGPointMake( ((ShortestPathStep*) [path objectAtIndex:i]).position.x,
                                                                        ((ShortestPathStep*) [path objectAtIndex:i]).position.y)];
                        }
                    }
                }
            }
        }
    }
}

- (void) generateVerticalCorridors
{
    for ( NSInteger y = 0; y < sectorGrid.gridSize.height; y++ ) {
        for ( NSInteger x = 0; x < sectorGrid.gridSize.width; x++ ) {
            
            // 1. Determine if the Sector is Inactive
            if ( kSectorInactive != [sectorGrid sectorTypeAt:CGPointMake(x, y)])
            {
                DungeonRoom *room = [self roomInSector:CGPointMake(x, y)];
                if ( room != nil) {
                    // 2. Determine if the Sector is Block to the North
                    if (!room.isBlockedNorth) {
                        
                        // 3. Determine the Coordinate of the Northern Door of the selected Room
                        CGPoint northDoorPoint = CGPointMake(room.coordinateNorthDoor.x +
                                                             room.coordinate.x,
                                                             room.coordinateNorthDoor.y +
                                                             room.coordinate.y);
                        
                        // 4. Determine the Coordinate of the Southern Door on the adjacent Room
                        DungeonRoom *southRoom = [self roomInSector:CGPointMake(x, y+1)];
                        CGPoint southDoorPoint = CGPointMake(southRoom.coordinateSouthDoor.x +
                                                             southRoom.coordinate.x,
                                                             southRoom.coordinateSouthDoor.y +
                                                             southRoom.coordinate.y);
                        
                        // 5. Utilize the A Star Pathing Algorithm to Determine the Corridor Path
                        AStarPath *starPathAlgorithm = [[AStarPath alloc] initWithTileLayer:self];
                        NSMutableArray *path = [starPathAlgorithm moveToTileCoord:northDoorPoint FromTileCoord:southDoorPoint];
                        
                        // 6. Set every tile in the path to be a DUNGEON FLOOR TILE
                        for (int i = 0; i < ([path count] - 1); i++) {
                            [dungeonLayer setTileType:kDungeonTileFloor
                                                   At:CGPointMake(((ShortestPathStep*) [path objectAtIndex:i]).position.x,
                                                                  ((ShortestPathStep*) [path objectAtIndex:i]).position.y)];
                        }
                    }
                }
            }
        }
    }
}

//----------------------------------------------------------------------------------------------
#pragma mark - Room Management

- (DungeonRoom*) roomInSector:(CGPoint)sector
{
    DungeonRoom *output = nil;
    if ( [sectorGrid isValidSector:sector])
    {
        output = [rooms objectAtIndex:((NSInteger)sector.y * (NSInteger)self.sectorGridSize.width + (NSInteger)sector.x)];
    }
    return output;
}

@end
