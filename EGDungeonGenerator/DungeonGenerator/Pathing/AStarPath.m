//
//  PathAlgorithm.m
//  DungeonGenerator
//
//  Created by Charles Cliff on 12/29/14.
//  Copyright (c) 2014 EETech. All rights reserved.
//

#import "AStarPath.h"

#pragma mark - AStarPath Implementation

@interface AStarPath()

@property(nonatomic, weak) DungeonGenerator *dungeonGenerator;

@property (nonatomic, strong) NSMutableArray *path;
@property (nonatomic, retain) NSMutableArray *spOpenSteps;
@property (nonatomic, retain) NSMutableArray *spClosedSteps;

@end

@implementation AStarPath

//----------------------------------------------------------------------------------------------
#pragma mark - Calculating the Path

- (id) initWithTileLayer:(DungeonGenerator*) inputTileLayer
{
    self = [super init];
    if (self != nil) {
        self.dungeonGenerator = inputTileLayer;
    }
    return self;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Calculating the Path

- (NSMutableArray*) moveToTileCoord:(CGPoint) tileCoord FromTileCoord:(CGPoint) fromCoord
{
    // Get current tile coordinate and desired tile coord
    CGPoint fromTileCoord   = fromCoord;
    CGPoint toTileCoord     = tileCoord;
    
    // Check that there is a path to compute ;-)
    if (CGPointEqualToPoint(fromTileCoord, toTileCoord))
    {
        NSLog(@"You're already there! :P");
        return nil;
    }
    
    // Must check that the desired location is walkable
    // In our case it's really easy, because only wall are unwalkable
    //    if ([_layer isWallAtTileCoord:toTileCoord])
    //    {
    ////        [[SimpleAudioEngine sharedEngine] playEffect:@"hitWall.wav"];
    //        return;
    //    }
    
    self.spOpenSteps    = [[NSMutableArray alloc] init];
    self.spClosedSteps  = [[NSMutableArray alloc] init];
    self.path   = nil;
    
    // Start by adding the from position to the open list
    [self insertInOpenSteps:[[ShortestPathStep alloc] initWithPosition:fromTileCoord] ];
    
    do
    {
        // Get the lowest F cost step
        // Because the list is ordered, the first step is always the one with the lowest F cost
        ShortestPathStep *currentStep = [self.spOpenSteps objectAtIndex:0];
        
        // Add the current step to the closed set
        [self.spClosedSteps addObject:currentStep];
        
        // Remove it from the open list
        // Note that if we wanted to first removing from the open list, care should be taken to the memory
        [self.spOpenSteps removeObjectAtIndex:0];
        
        // If the currentStep is the desired tile coordinate, we are done!
        if (CGPointEqualToPoint(currentStep.position, toTileCoord))
        {
            // When the
            [self constructPath:currentStep];
            self.spOpenSteps    = nil; // Set to nil to release unused memory
            self.spClosedSteps  = nil; // Set to nil to release unused memory
            break;
        }
        
        // Get the adjacent tiles coord of the current step
        NSArray *adjSteps = [self walkableAdjacentTilesCoordForTileCoord:currentStep.position];
        
        for (NSValue *v in adjSteps)
        {
            ShortestPathStep *step = [[ShortestPathStep alloc] initWithPosition:[v CGPointValue]];
            
            // Check if the step isn't already in the closed set
            if ([self.spClosedSteps containsObject:step])
            {
                continue; // Ignore it
            }
            
            // Compute the cost from the current step to that step
            int moveCost = [self costToMoveFromStep:currentStep toAdjacentStep:step];
            
            // Check if the step is already in the open list
            NSUInteger index = [self.spOpenSteps indexOfObject:step];
            
            if (index == NSNotFound) // Not on the open list, so add it
            {
                
                // Set the current step as the parent
                step.parent = currentStep;
                
                // The G score is equal to the parent G score + the cost to move from the parent to it
                step.gScore = currentStep.gScore + moveCost;
                
                // Compute the H score which is the estimated movement cost to move from that step to the desired tile coordinate
                step.hScore = [self computeHScoreFromCoord:step.position toCoord:toTileCoord];
                
                // Adding it with the function which is preserving the list ordered by F score
                [self insertInOpenSteps:step];
            }
            else // Already in the open list
            {
                
                step = [self.spOpenSteps objectAtIndex:index]; // To retrieve the old one (which has its scores already computed ;-)
                
                // Check to see if the G score for that step is lower if we use the current step to get there
                if ((currentStep.gScore + moveCost) < step.gScore)
                {
                    
                    // The G score is equal to the parent G score + the cost to move from the parent to it
                    step.gScore = currentStep.gScore + moveCost;
                    
                    // Because the G Score has changed, the F score may have changed too
                    // So to keep the open list ordered we have to remove the step, and re-insert it with
                    // the insert function which is preserving the list ordered by F score
                    
                    // Now we can removing it from the list without be afraid that it can be released
                    [self.spOpenSteps removeObjectAtIndex:index];
                    
                    // Re-insert it with the function which is preserving the list ordered by F score
                    [self insertInOpenSteps:step];
                }
            }
        }
        
    }
    while ([self.spOpenSteps count] > 0);
    
    return self.path;
}

//----------------------------------------------------------------------------------------------
#pragma mark -

// Insert a path step (ShortestPathStep) in the ordered open steps list (spOpenSteps)
- (void)insertInOpenSteps:(ShortestPathStep *)step
{
    int stepFScore = [step fScore]; // Compute the step's F score
    NSInteger count = [self.spOpenSteps count];
    int i = 0; // This will be the index at which we will insert the step
    for (; i < count; i++) {
        if (stepFScore <= [[self.spOpenSteps objectAtIndex:i] fScore]) { // If the step's F score is lower or equals to the step at index i
            // Then we found the index at which we have to insert the new step
            // Basically we want the list sorted by F score
            break;
        }
    }
    // Insert the new step at the determined index to preserve the F score ordering
    [self.spOpenSteps insertObject:step atIndex:i];
}

// Compute the H score from a position to another (from the current position to the final desired position
- (int)computeHScoreFromCoord:(CGPoint)fromCoord toCoord:(CGPoint)toCoord
{
    // Here we use the Manhattan method, which calculates the total number of step moved horizontally and vertically to reach the
    // final desired step from the current step, ignoring any obstacles that may be in the way
    return abs(toCoord.x - fromCoord.x) + abs(toCoord.y - fromCoord.y);
}

// Compute the cost of moving from a step to an adjacent one
- (int)costToMoveFromStep:(ShortestPathStep *)fromStep toAdjacentStep:(ShortestPathStep *)toStep
{
    // Because we can't move diagonally and because terrain is just walkable or unwalkable the cost is always the same.
    // But it have to be different if we can move diagonally and/or if there is swamps, hills, etc...
    return 1;
}

- (void) constructPath:(ShortestPathStep *)step
{
    self.path = [NSMutableArray array];
    
    do
    {
        if (step.parent != nil) // Don't add the last step which is the start position (remember we go backward, so the last one is the origin position ;-)
        {
            [self.path insertObject:step atIndex:0]; // Always insert at index 0 to reverse the path
        }
        step = step.parent; // Go backward
    }
    while (step != nil); // Until there is no more parents
}

//----------------------------------------------------------------------------------------------
#pragma mark - Tile Properties

- (NSArray *) walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord
{
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:4];
    
    // Top
    CGPoint p = CGPointMake(tileCoord.x, tileCoord.y - 1);
    if ( [self.dungeonGenerator.dungeonLayer isValidTileCoordinateAt:p] && [self.dungeonGenerator isWalkableTileCoordinateAt:p] )
        [tmp addObject:[NSValue valueWithCGPoint:p]];
    
    // Left
    p = CGPointMake(tileCoord.x - 1, tileCoord.y);
    if ( [self.dungeonGenerator.dungeonLayer isValidTileCoordinateAt:p] && [self.dungeonGenerator isWalkableTileCoordinateAt:p] )
        [tmp addObject:[NSValue valueWithCGPoint:p]];
    
    // Bottom
    p = CGPointMake(tileCoord.x, tileCoord.y + 1);
    if ( [self.dungeonGenerator.dungeonLayer isValidTileCoordinateAt:p] && [self.dungeonGenerator isWalkableTileCoordinateAt:p] )
        [tmp addObject:[NSValue valueWithCGPoint:p]];
    
    // Right
    p = CGPointMake(tileCoord.x + 1, tileCoord.y);
    if ( [self.dungeonGenerator.dungeonLayer isValidTileCoordinateAt:p] && [self.dungeonGenerator isWalkableTileCoordinateAt:p] )
        [tmp addObject:[NSValue valueWithCGPoint:p]];
    
    return [NSArray arrayWithArray:tmp];
}

@end
