//
//  ShortestStepPath.m
//  EGTileMap
//
//  Created by Charles Cliff on 12/30/14.
//  Copyright (c) 2014 EETech. All rights reserved.
//

#import "ShortestPathStep.h"

@implementation ShortestPathStep

@synthesize position;
@synthesize gScore;
@synthesize hScore;
@synthesize parent;

- (id)initWithPosition:(CGPoint)pos
{
    if ((self = [super init])) {
        position = pos;
        gScore = 0;
        hScore = 0;
        parent = nil;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@  pos=[%.0f;%.0f]  g=%d  h=%d  f=%d", [super description], self.position.x, self.position.y, self.gScore, self.hScore, [self fScore]];
}

- (BOOL)isEqual:(ShortestPathStep *)other
{
    return CGPointEqualToPoint(self.position, other.position);
}

- (int)fScore
{
    return self.gScore + self.hScore;
}

@end


