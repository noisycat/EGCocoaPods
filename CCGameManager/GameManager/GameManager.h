//
//  GameManager.h
//  ProceduralLevelGeneration
//
//  Created by Charles Cliff on 11/23/14.
//  Copyright (c) 2014 ElysiumEngineering. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AchievmentManager.h"


@protocol GameManagerDelegate <NSObject>

@optional
- (void) gameManagerTimerDidEnd;
- (void) gameManagerTimerDidReachPercent:(float) percentComplete;
- (void) gameManagerLevelDidEnd;
- (void) gameManagerGameDidEnd;

@end

@interface GameManager : NSObject <NSCoding>
{
    NSString *_docPath;
    NSInteger currentCharacterIndex;
    
    float currentCountdown;
    
    id <GameManagerDelegate> delegate;
}

@property (retain) id delegate;

@property(nonatomic, readonly) NSUInteger currentLevel;
@property(nonatomic, readonly) NSUInteger currentScore;

@property(nonatomic, readonly) NSUInteger bestLevel;
@property(nonatomic, readonly) NSUInteger bestScore;

@property(nonatomic) float levelCountDownTime;
@property(nonatomic) float levelCountDownRate;

@property (nonatomic, strong) AchievmentManager *achievementManager; // Achievement Manager

#pragma mark Singleton
+ (GameManager*) sharedGameManager;

#pragma mark Updating
- (void) update:(CFTimeInterval)currentTime;

#pragma mark Scores
- (void) addPointsToScore:(NSInteger) newPoints;

#pragma mark Time
- (void) addSecondsToTimer:(NSInteger) newSeconds;
- (float) getSecondsInTimer;

#pragma mark Game
- (void) startGame;
- (void) stopGame;

#pragma mark Level
- (void) startLevel;
- (void) stopLevel;

#pragma mark Saving Data
-(void)save;

@end
