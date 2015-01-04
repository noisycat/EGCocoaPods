//
//  GameManager.m
//  ProceduralLevelGeneration
//
//  Created by Charles Cliff on 11/23/14.
//  Copyright (c) 2014 ElysiumEngineering. All rights reserved.
//

#import "GameManager.h"
#import "GKHelper.h"

@interface GameManager()
{
//    float currentTime;
    float previousTime;
    
    BOOL gameIsRunning;
    
    // These need to be set befor ethe Game Manager Begins  Level
    float maxCountdown;
    float countdownRate;
}

- (void) updateLevelTimer:(CFTimeInterval)currentTime;

@end

@implementation GameManager

@synthesize delegate;
@synthesize levelCountDownTime;
@synthesize levelCountDownRate;
@synthesize achievementManager;

//----------------------------------------------------------------------------------------------
#pragma mark - Singleton

+ (GameManager*) sharedGameManager
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

+(instancetype)loadInstance
{
    NSData* decodedData = [NSData dataWithContentsOfFile: [GameManager filePath]];
    if (decodedData)
    {
        GameManager* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        //        [gameData.achievementManager printState];
        
        return gameData;
    }
    
    return [[GameManager alloc] init];
}

//----------------------------------------------------------------------------------------------
#pragma mark File Path

+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"gamedata"];
    }
    return filePath;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Updating the Level

- (void) update:(CFTimeInterval)currentTime;
{    
    // 1. Determine if the Game is Running
    if ( gameIsRunning )
    {
        // Update the Level's Countdown Timer
        [self updateLevelTimer:currentTime];
        
        // Determine if the Level has Run Out of Time
        if (currentCountdown <= 0.0)
            [self stopGame];
    }
}

- (void) updateLevelTimer:(CFTimeInterval)currentTime
{
    // 1. Update Countdown Timer
    currentCountdown = MAX( MIN( (currentCountdown - self.levelCountDownRate * (currentTime - previousTime)), maxCountdown + 5 ), 0.0);

    // 2. Set the PREVIOUS TIME
    previousTime = currentTime;
    
    // 3. Send a Message to the Delegate
    [self.delegate gameManagerTimerDidReachPercent:[self getSecondsInTimer]];
}

//----------------------------------------------------------------------------------------------
#pragma mark - Score Management

- (void) addPointsToScore:(NSInteger) newPoints
{
    _currentScore = self.currentScore + newPoints;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Time Management

- (void) addSecondsToTimer:(NSInteger) newSeconds
{
    currentCountdown = currentCountdown + newSeconds;
}

- (float) getSecondsInTimer
{
    return (currentCountdown /  maxCountdown);
}

//----------------------------------------------------------------------------------------------
#pragma mark - Level Management

- (void) startLevel
{
    // 1. Setting the Time Counter
    maxCountdown = self.levelCountDownTime;
    currentCountdown = self.levelCountDownTime + 3;        // Why Am I Adding 3? ...\Why did I do this?
    
    // 2. Set the PREVIOUS TIME
    previousTime = CACurrentMediaTime();
    
    // 3. Iterate the Level Counter
    _currentLevel++;
    
//    NSLog(@"startLevel");
}

- (void) stopLevel
{
//    NSLog(@"GameManager -- stopLevel");
}

//----------------------------------------------------------------------------------------------
#pragma mark - Game Management

- (void) startGame
{
    // 1. Reset the Entire Game
    [self reset];
    
    // 2. Set the GameIsRunning Flag
    gameIsRunning = YES;
}

- (void) stopGame
{
//    NSLog(@"GameManager -- stopLevel");

    // 1. Set the GameIsRunning Flag
    gameIsRunning = NO;
    
    // 2. Check for a new Maximum Score
    if (self.currentScore > self.bestScore){
        _bestScore = self.currentScore;
        [[GKHelper sharedGameKitHelper] submitHighScore:self.bestScore WithLeaderboardID:@"TB_LB01"];
    }
    
    // 3. Check for a new Maximum Score
    if (self.currentScore > self.bestLevel){
        _bestLevel = self.currentLevel;
    }
    
//     Resolve each Achievement
//    [self.achievementManager resolveScoreAchievement];
//    [self.achievementManager resolveLevelAchievement];
//    [self.achievementManager resolveRepeatedScoreAchievement];
//    [self.achievementManager resolveRepeatedLevelAchievement];
    
    // Provide the End Game Notificaiton
    NSNotification *note = [NSNotification notificationWithName:@"GAMEOVER" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

- (void) reset
{
    // 1. Reset the New Score
    _currentScore = 0;
    
    // 2. Reset the Current Level Counter to Zero
    _currentLevel = 0;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Saving Data

-(void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[GameManager filePath] atomically:YES];
//    NSLog(@"save");
}

//----------------------------------------------------------------------------------------------
#pragma mark - NSCoding

#define kBestScoreKey           @"BEST_SCORE"
#define kBestLevelKey           @"BEST_LEVEL"
#define kAchivementManager      @"ACHIEVEMENT_MANAGER"

- (void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:self.bestScore forKey:kBestScoreKey];
    [encoder encodeInteger:self.bestLevel forKey:kBestLevelKey];
    [encoder encodeObject:self.achievementManager forKey:kAchivementManager];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    NSLog(@"GameManager - initWithCoder");
    
    self = [super init];
    
    if (self) {
        _bestScore = [decoder decodeIntegerForKey:kBestScoreKey];
        _bestLevel = [decoder decodeIntegerForKey:kBestLevelKey];
        self.achievementManager = [decoder decodeObjectForKey:kAchivementManager];
    }
    return self;
}

@end
