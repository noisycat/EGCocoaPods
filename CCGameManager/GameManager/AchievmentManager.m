//
//  TBAchievmentManager.m
//  TumbleBall
//
//  Created by Charles Cliff on 11/23/14.
//  Copyright (c) 2014 ElysiumEngineering. All rights reserved.
//

#import "AchievmentManager.h"
#import "GameManager.h"
#import "GKHelper.h"

@implementation AchievmentManager
{
    BOOL debugFlag;
}

@synthesize delegate;

@synthesize scoreCounterTier1;
@synthesize scoreCounterTier2;
@synthesize scoreCounterTier3;
@synthesize scoreCounterTier4;

@synthesize levelCounterTier1;
@synthesize levelCounterTier2;
@synthesize levelCounterTier3;
@synthesize levelCounterTier4;

@synthesize timeCounterTier1;
@synthesize timeCounterTier2;
@synthesize timeCounterTier3;
@synthesize timeCounterTier4;

//----------------------------------------------------------------------------------------------
#pragma mark - Init

-(AchievmentManager*) init
{
    self = [super init];
    if( self != nil)
    {
        self.scoreCounterTier1 = 0;
        self.scoreCounterTier2 = 0;
        self.scoreCounterTier3 = 0;
        self.scoreCounterTier4 = 0;
        
        self.levelCounterTier1 = 0;
        self.levelCounterTier2 = 0;
        self.levelCounterTier3 = 0;
        self.levelCounterTier4 = 0;
        
        self.timeCounterTier1 = 0;
        self.timeCounterTier2 = 0;
        self.timeCounterTier3 = 0;
        self.timeCounterTier4 = 0;
    }
    return self;
}

-(void) initDebugState
{
    // Load the input P-List
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TBAchievements" ofType:@"plist"];
    NSDictionary *achievementDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    debugFlag = [[achievementDictionary objectForKey:@"DEBUG"] boolValue];
}

-(void) printState __deprecated{
    NSLog(@"TBAchievmentManager -- printState");
}

//----------------------------------------------------------------------------------------------
#pragma mark - Achievments

- (void) resolveLevelAchievement
{
    if (debugFlag) {
        NSLog(@"TBAchievementManager -- resolveLevelAchievement");
    }
    
    // 1. Load the input P-List
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TBAchievements" ofType:@"plist"];
    NSDictionary *achievementDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *levelDictionary = achievementDictionary[ kAchievmentTypeReachLevel ];
    
    // 2. Current Level
    NSUInteger currentLevel = [[GameManager sharedGameManager] currentLevel];
    
    // 3. Check the current game score for each Tier
    // A. Handle Tier 4
    NSInteger levelAchievementTier4 = [[levelDictionary[ kTier4 ] objectForKey:kKeyLevel] intValue];
    if ( currentLevel > levelAchievementTier4)
    {
        [self.delegate didUpdateLevelAchievementForTier:kAchievementTier4];

//        NSString *Tier4_ID = (NSString *) [levelDictionary[ kTier4 ] objectForKey:kKeyID];
//
//        [[GKHelper sharedGameKitHelper] reportAchievementWithID:Tier4_ID
//                                                percentComplete:100];
    }else{
        // B. Handle Tier 3
        NSInteger levelAchievementTier3 = [[levelDictionary[ kTier3 ] objectForKey:kKeyLevel] intValue];
        if ( currentLevel >= levelAchievementTier3)
        {
            [self.delegate didUpdateLevelAchievementForTier:kAchievementTier3];
            
//            NSString *Tier3_ID = (NSString *) [levelDictionary[ kTier3 ] objectForKey:kKeyID];
//            
//            [[GKHelper sharedGameKitHelper] reportAchievementWithID:Tier3_ID
//                                                    percentComplete:100];
        }else{
            // C. Handle Tier 2
            NSInteger levelAchievementTier2 = [[levelDictionary[ kTier2 ] objectForKey:kKeyLevel] intValue];
            if ( currentLevel >= levelAchievementTier2)
            {
                [self.delegate didUpdateLevelAchievementForTier:kAchievementTier2];

//                NSString *Tier2_ID = (NSString *) [levelDictionary[ kTier2 ] objectForKey:kKeyID];
//
//                [[GKHelper sharedGameKitHelper] reportAchievementWithID:Tier2_ID
//                                                        percentComplete:100];
            }else{
                // D. Handle Tier 1
                NSInteger levelAchievementTier1 = [[levelDictionary[ kTier1 ] objectForKey:kKeyLevel] intValue];
                if ( currentLevel >= levelAchievementTier1)
                {
                    [self.delegate didUpdateLevelAchievementForTier:kAchievementTier1];

//                    NSString *Tier1_ID = (NSString *) [levelDictionary[ kTier1 ] objectForKey:kKeyID];
//
//                    [[GKHelper sharedGameKitHelper] reportAchievementWithID:Tier1_ID
//                                                            percentComplete:100];
                }
            }
        }
    }
}

- (void) resolveScoreAchievement
{
    if (debugFlag) {
        NSLog(@"TBAchievementManager -- resolveScoreAchievement");
    }

    // 1. Load the input P-List
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TBAchievements" ofType:@"plist"];
    NSDictionary *achievementDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *reachScoreDictionary = achievementDictionary[ kAchievmentTypeReachScore ];
    
    // Load Achievement Tiers from the P-List
    
    NSInteger AchievementTier1 = [[reachScoreDictionary[ kTier1 ] objectForKey:kKeyScore] intValue];
    NSInteger AchievementTier2 = [[reachScoreDictionary[ kTier2 ] objectForKey:kKeyScore] intValue];
    NSInteger AchievementTier3 = [[reachScoreDictionary[ kTier3 ] objectForKey:kKeyScore] intValue];
    NSInteger AchievementTier4 = [[reachScoreDictionary[ kTier4 ] objectForKey:kKeyScore] intValue];
    
    // 2. Current Score
    NSUInteger currentScore = [[GameManager sharedGameManager] currentScore];
    
    // 3. Check the current game score for each Tier
    if ( currentScore > AchievementTier4) {
        // Handle Tier 4
        [self.delegate didUpdateScoreAchievementForTier:kAchievementTier4];
        
//        NSString *Tier4_ID = (NSString *) [reachScoreDictionary[ kTier4 ] objectForKey:kKeyID];
//        
//        [[GKHelper sharedGameKitHelper] reportAchievementWithID:Tier4_ID
//                                                percentComplete:100];
        if (debugFlag) NSLog(@"Score Tier 4");
        
    }else{
        if ( currentScore >= AchievementTier3) {
            // Handle Tier 3
            [self.delegate didUpdateScoreAchievementForTier:kAchievementTier3];

//            NSString *Tier3_ID = (NSString *) [reachScoreDictionary[ kTier3 ] objectForKey:kKeyID];
//
//            [[GKHelper sharedGameKitHelper] reportAchievementWithID:Tier3_ID
//                                                    percentComplete:100];
            if (debugFlag) NSLog(@"Score Tier 3");

        }else{
            if ( currentScore >= AchievementTier2) {
                // Handle Tier 2
                [self.delegate didUpdateScoreAchievementForTier:kAchievementTier2];

//                NSString *Tier2_ID = (NSString *) [reachScoreDictionary[ kTier2 ] objectForKey:kKeyID];
//                
//                [[GKHelper sharedGameKitHelper] reportAchievementWithID:Tier2_ID
//                                                        percentComplete:100];
                if (debugFlag) NSLog(@"Score Tier 2");

            }else{
                if ( currentScore >= AchievementTier1) {
                    // Handle Tier 1
                    [self.delegate didUpdateScoreAchievementForTier:kAchievementTier1];

//                    NSString *Tier1_ID = (NSString *) [reachScoreDictionary[ kTier1 ] objectForKey:kKeyID];
//                    
//                    [[GKHelper sharedGameKitHelper] reportAchievementWithID:Tier1_ID
//                                                            percentComplete:100];
                    if (debugFlag) NSLog(@"Score Tier 1");
                }
            }
        }
    }
}

- (void) resolveTimeAchievement
{
    if (debugFlag)
        NSLog(@"TBAchievementManager -- resolveScoreAchievement");
    
    // 1. Load the input P-List
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TBAchievements" ofType:@"plist"];
    NSDictionary *achievementDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *timeDictionary = achievementDictionary[ kAchievmentTypeTime ];
    
    // 2. Retrieve the Current Score from the GAME MANAGER
    float currentScore = [[GameManager sharedGameManager] currentScore];

    
    // 3. Check the current game score for each Tier
    // A. Handle Tier 4
    float AchievementTier4 = [[timeDictionary[ kTier4 ] objectForKey:kKeyValue] floatValue];
    if ( currentScore > AchievementTier4)
    {
        [self.delegate didUpdateTimeAchievementForTier:kAchievementTier4];
        
//        NSString *Tier4_ID = (NSString *) [timeDictionary[ kTier4 ] objectForKey:kKeyID];
//        
//        [[GKHelper sharedGameKitHelper] reportAchievementWithID:Tier4_ID
//                                                percentComplete:100];
        if (debugFlag) NSLog(@"Score Tier 4");
        
    }else{
        // B. Handle Tier 3
        float AchievementTier3 = [[timeDictionary[ kTier3 ] objectForKey:kKeyValue] floatValue];
        if ( currentScore >= AchievementTier3)
        {
            [self.delegate didUpdateTimeAchievementForTier:kAchievementTier3];

//            NSString *Tier3_ID = (NSString *) [timeDictionary[ kTier3 ] objectForKey:kKeyID];
//            
//            [[GKHelper sharedGameKitHelper] reportAchievementWithID:Tier3_ID
//                                                    percentComplete:100];
            if (debugFlag) NSLog(@"Score Tier 3");
            
        }else{
            // C. Handle Tier 2
            float AchievementTier2 = [[timeDictionary[ kTier2 ] objectForKey:kKeyValue] floatValue];
            if ( currentScore >= AchievementTier2)
            {
                [self.delegate didUpdateTimeAchievementForTier:kAchievementTier2];

//                NSString *Tier2_ID = (NSString *) [timeDictionary[ kTier2 ] objectForKey:kKeyID];
//                
//                [[GKHelper sharedGameKitHelper] reportAchievementWithID:Tier2_ID
//                                                        percentComplete:100];
                if (debugFlag) NSLog(@"Score Tier 2");
                
            }else{
                // D. Handle Tier 1
                float AchievementTier1 = [[timeDictionary[ kTier1 ] objectForKey:kKeyValue] floatValue];
                if ( currentScore >= AchievementTier1)
                {
                    [self.delegate didUpdateTimeAchievementForTier:kAchievementTier1];

//                    NSString *Tier1_ID = (NSString *) [timeDictionary[ kTier1 ] objectForKey:kKeyID];
//                    
//                    [[GKHelper sharedGameKitHelper] reportAchievementWithID:Tier1_ID
//                                                            percentComplete:100];
                    if (debugFlag) NSLog(@"Score Tier 1");
                }
            }
        }
    }
    
}

//----------------------------------------------------------------------------------------------
#pragma mark - Repetition Achievments

- (void) resolveRepeatedScoreAchievement
{
    if (debugFlag) {
        NSLog(@"TBAchievementManager -- resolveRepeatedScoreAchievement");
    }

    // 1. Load the input P-List
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TBAchievements" ofType:@"plist"];
    NSDictionary *achievementDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *repeatScoreDictionary = achievementDictionary[ kAchievmentTypeRepeatScore ];
    
    // 2. Current Score
    NSUInteger currentScore = [[GameManager sharedGameManager] currentScore];
    
    // 3. Check the current game score for each Tier
    // A. Handle Tier 4
    NSInteger AchievementTier4 = [[repeatScoreDictionary[ kTier4 ] objectForKey:kKeyScore] intValue];
    if ( currentScore > AchievementTier4) {
        scoreCounterTier4++;
        NSInteger MinRepTier4 = [[repeatScoreDictionary[ kTier4 ] objectForKey:kKeyRepeated] intValue];
        
        [self.delegate didUpdateRepeatScoreAchievementForTier:kAchievementTier4
                                          WithPercentComplete:MAX(100, 100*(scoreCounterTier4/MinRepTier4 ))];
        if (debugFlag) {
            NSLog(@"minimumScoreCounterTier4: %ld", (long)scoreCounterTier4);
        }
    }else{
        // B. Handle Tier 3
        NSInteger AchievementTier3 = [[repeatScoreDictionary[ kTier3 ] objectForKey:kKeyScore] intValue];
        if ( currentScore >= AchievementTier3)
        {
            scoreCounterTier3++;
            NSInteger MinRepTier3 = [[repeatScoreDictionary[ kTier3 ] objectForKey:kKeyRepeated] intValue];
            
            [self.delegate didUpdateRepeatScoreAchievementForTier:kAchievementTier3
                                              WithPercentComplete:MAX(100, 100*(scoreCounterTier3/MinRepTier3 ))];
            if (debugFlag) {
                NSLog(@"minimumScoreCounterTier3: %ld", (long)scoreCounterTier3);
            }
        }else{
            // C. Handle Tier 2
            NSInteger AchievementTier2 = [[repeatScoreDictionary[ kTier2 ] objectForKey:kKeyScore] intValue];
            if ( currentScore >= AchievementTier2)
            {
                scoreCounterTier2++;
                NSInteger MinRepTier2 = [[repeatScoreDictionary[ kTier2 ] objectForKey:kKeyRepeated] intValue];

                [self.delegate didUpdateRepeatScoreAchievementForTier:kAchievementTier2
                                                  WithPercentComplete:MAX(100, 100*(scoreCounterTier2/MinRepTier2 ))];
                if (debugFlag) {
                    NSLog(@"minimumScoreCounterTier2: %ld", (long)scoreCounterTier2);
                }
            }else{
                // D. Handle Tier 1
                NSInteger AchievementTier1 = [[repeatScoreDictionary[ kTier1 ] objectForKey:kKeyScore] intValue];
                if ( currentScore >= AchievementTier1) {
                    scoreCounterTier1++;
                    NSInteger MinRepTier1 = [[repeatScoreDictionary[ kTier1 ] objectForKey:kKeyRepeated] intValue];
                    
                    [self.delegate didUpdateRepeatScoreAchievementForTier:kAchievementTier1
                                                      WithPercentComplete:MAX(100, 100*(scoreCounterTier3/MinRepTier1 ))];
                    if (debugFlag) {
                        NSLog(@"minimumScoreCounterTier1: %ld", (long)scoreCounterTier1);
                    }
                }
            }
        }
    }
}

- (void) resolveRepeatedLevelAchievement
{
    if (debugFlag)
        NSLog(@"TBAchievementManager -- resolveRepeatedScoreAchievement");
    
    // 1. Load the input P-List
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TBAchievements" ofType:@"plist"];
    NSDictionary *achievementDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *repeatLevelDictionary = achievementDictionary[ kAchievmentTypeRepeatLevel ];
    
    // 2. Current Score
    NSUInteger currentLevel = [[GameManager sharedGameManager] currentLevel];
    
    // 3. Check the current game score for each Tier
    // A. Handle Tier 4
    NSInteger AchievementTier4 = [[repeatLevelDictionary[ kTier4 ] objectForKey:kKeyLevel] intValue];
    if ( currentLevel > AchievementTier4) {
        levelCounterTier4++;
        NSInteger MinRepTier4 = [[repeatLevelDictionary[ kTier4 ] objectForKey:kKeyRepeated] intValue];
        
        [self.delegate didUpdateRepeatLevelAchievementForTier:kAchievementTier4
                                          WithPercentComplete:MAX(100, 100 * ( levelCounterTier4 /MinRepTier4 ))];
        
        if (debugFlag)
            NSLog(@"minimumLevelCounterTier4: %ld", (long)levelCounterTier4);
        
    }else{
        // B. Handle Tier 3
        NSInteger AchievementTier3 = [[repeatLevelDictionary[ kTier3 ] objectForKey:kKeyLevel] intValue];
        if ( currentLevel >= AchievementTier3) {
            levelCounterTier3++;
            NSInteger MinRepTier3 = [[repeatLevelDictionary[ kTier3 ] objectForKey:kKeyRepeated] intValue];

            [self.delegate didUpdateRepeatLevelAchievementForTier:kAchievementTier3
                                              WithPercentComplete:MAX(100, 100 * ( levelCounterTier3 /MinRepTier3 ))];
            
            if (debugFlag)
                NSLog(@"minimumLevelCounterTier3: %ld", (long)levelCounterTier3);
            
        }else{
            // C. Handle Tier 2
            NSInteger AchievementTier2 = [[repeatLevelDictionary[ kTier2 ] objectForKey:kKeyLevel] intValue];
            if ( currentLevel >= AchievementTier2) {
                levelCounterTier2++;
                NSInteger MinRepTier2 = [[repeatLevelDictionary[ kTier2 ] objectForKey:kKeyRepeated] intValue];
                
                [self.delegate didUpdateRepeatLevelAchievementForTier:kAchievementTier2
                                                  WithPercentComplete:MAX(100, 100 * ( levelCounterTier2 /MinRepTier2 ))];
                
                if (debugFlag)
                    NSLog(@"minimumLevelCounterTier2: %ld", (long)levelCounterTier2);
                    
            }else{
                // D. Handle Tier 1
                NSInteger AchievementTier1 = [[repeatLevelDictionary[ kTier1 ] objectForKey:kKeyLevel] intValue];
                if ( currentLevel >= AchievementTier1) {
                    levelCounterTier1++;
                    NSInteger MinRepTier1 = [[repeatLevelDictionary[ kTier1 ] objectForKey:kKeyRepeated] intValue];
                    
                    [self.delegate didUpdateRepeatLevelAchievementForTier:kAchievementTier1
                                                      WithPercentComplete:MAX(100, 100 * ( levelCounterTier1 /MinRepTier1 ))];
                    
                    if (debugFlag)
                        NSLog(@"minimumLevelCounterTier1: %ld", (long)levelCounterTier1);
                    
                }
            }
        }
    }
}

- (void) resolveRepeatedTimeAchievement
{
    if (debugFlag)
        NSLog(@"TBAchievementManager -- resolveRepeatedTimeAchievement");
    
    // 1. Load the input P-List
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TBAchievements" ofType:@"plist"];
    NSDictionary *achievementDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *repeatTimeDictionary = achievementDictionary[ kAchievmentTypeRepeatTime ];
    
    // 2. Current Score
    NSUInteger currentLevel = [[GameManager sharedGameManager] currentLevel];
    
    // 3. Check the current game score for each Tier
    // A. Handle Tier 4
    NSInteger AchievementTier4 = [[repeatTimeDictionary[ kTier4 ] objectForKey:kKeyValue] intValue];
    if ( currentLevel > AchievementTier4) {
        timeCounterTier4++;
        NSInteger MinRepTier4 = [[repeatTimeDictionary[ kTier4 ] objectForKey:kKeyRepeated] intValue];
        
        [self.delegate didUpdateRepeatTimeAchievementForTier:kAchievementTier4
                                         WithPercentComplete:MAX(100, 100 * ( timeCounterTier4 /MinRepTier4 ))];
        if (debugFlag)
            NSLog(@"minimumLevelCounterTier4: %ld", (long)levelCounterTier4);
        
    }else{
        // B. Handle Tier 3
        NSInteger AchievementTier3 = [[repeatTimeDictionary[ kTier3 ] objectForKey:kKeyValue] intValue];
        if ( currentLevel >= AchievementTier3) {
            timeCounterTier3++;
            NSInteger MinRepTier3 = [[repeatTimeDictionary[ kTier3 ] objectForKey:kKeyRepeated] intValue];
            
            [self.delegate didUpdateRepeatTimeAchievementForTier:kAchievementTier3
                                             WithPercentComplete:MAX(100, 100 * ( timeCounterTier3 /MinRepTier3 ))];
            
            if (debugFlag)
                NSLog(@"minimumLevelCounterTier3: %ld", (long)levelCounterTier3);
            
        }else{
            // C. Handle Tier 2
            NSInteger AchievementTier2 = [[repeatTimeDictionary[ kTier2 ] objectForKey:kKeyValue] intValue];
            if ( currentLevel >= AchievementTier2) {
                timeCounterTier2++;
                NSInteger MinRepTier2 = [[repeatTimeDictionary[ kTier2 ] objectForKey:kKeyRepeated] intValue];
                
                [self.delegate didUpdateRepeatTimeAchievementForTier:kAchievementTier2
                                                 WithPercentComplete:MAX(100, 100 * ( timeCounterTier2 /MinRepTier2 ))];
                
                if (debugFlag)
                    NSLog(@"minimumLevelCounterTier2: %ld", (long)levelCounterTier2);
                
            }else{
                // D. Handle Tier 1
                NSInteger AchievementTier1 = [[repeatTimeDictionary[ kTier1 ] objectForKey:kKeyLevel] intValue];
                if ( currentLevel >= AchievementTier1) {
                    timeCounterTier1++;
                    NSInteger MinRepTier1 = [[repeatTimeDictionary[ kTier1 ] objectForKey:kKeyRepeated] intValue];
                    
                    [self.delegate didUpdateRepeatTimeAchievementForTier:kAchievementTier1
                                                     WithPercentComplete:MAX(100, 100 * ( timeCounterTier1 /MinRepTier1 ))];
                    
                    if (debugFlag)
                        NSLog(@"minimumLevelCounterTier1: %ld", (long)levelCounterTier1);
                    
                }
            }
        }
    }
}
//----------------------------------------------------------------------------------------------
#pragma mark - NSCoding

#define kMinimumScoreCounter1          @"SCORE_COUNTER_1"
#define kMinimumScoreCounter2          @"SCORE_COUNTER_2"
#define kMinimumScoreCounter3          @"SCORE_COUNTER_3"
#define kMinimumScoreCounter4          @"SCORE_COUNTER_4"

#define kMinimumLevelCounter1          @"LEVEL_COUNTER_1"
#define kMinimumLevelCounter2          @"LEVEL_COUNTER_2"
#define kMinimumLevelCounter3          @"LEVEL_COUNTER_3"
#define kMinimumLevelCounter4          @"LEVEL_COUNTER_4"

#define kMinimumTimeCounter1          @"TIME_COUNTER_1"
#define kMinimumTimeCounter2          @"TIME_COUNTER_2"
#define kMinimumTimeCounter3          @"TIME_COUNTER_3"
#define kMinimumTimeCounter4          @"TIME_COUNTER_4"

- (void) encodeWithCoder:(NSCoder *)encoder
{
    if (debugFlag) {
        NSLog(@"TBAchievementManager -- encodeWithCoder");
    }
    
    // Score based achievements
    [encoder encodeInteger:self.scoreCounterTier1 forKey:kMinimumScoreCounter1];
    [encoder encodeInteger:self.scoreCounterTier2 forKey:kMinimumScoreCounter2];
    [encoder encodeInteger:self.scoreCounterTier3 forKey:kMinimumScoreCounter3];
    [encoder encodeInteger:self.scoreCounterTier4 forKey:kMinimumScoreCounter4];
    
    // Level based achievements
    [encoder encodeInteger:self.levelCounterTier1 forKey:kMinimumLevelCounter1];
    [encoder encodeInteger:self.levelCounterTier2 forKey:kMinimumLevelCounter2];
    [encoder encodeInteger:self.levelCounterTier3 forKey:kMinimumLevelCounter3];
    [encoder encodeInteger:self.levelCounterTier4 forKey:kMinimumLevelCounter4];
    
    // Time based achievements
    [encoder encodeInteger:self.timeCounterTier1 forKey:kMinimumTimeCounter1];
    [encoder encodeInteger:self.timeCounterTier2 forKey:kMinimumTimeCounter2];
    [encoder encodeInteger:self.timeCounterTier3 forKey:kMinimumTimeCounter3];
    [encoder encodeInteger:self.timeCounterTier4 forKey:kMinimumTimeCounter4];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        [self initDebugState];
        
        // Score based achievements
        self.scoreCounterTier1 = [decoder decodeIntegerForKey:kMinimumScoreCounter1];
        self.scoreCounterTier2 = [decoder decodeIntegerForKey:kMinimumScoreCounter2];
        self.scoreCounterTier3 = [decoder decodeIntegerForKey:kMinimumScoreCounter3];
        self.scoreCounterTier4 = [decoder decodeIntegerForKey:kMinimumScoreCounter4];

        // Level based achievements
        self.levelCounterTier1 = [decoder decodeIntegerForKey:kMinimumLevelCounter1];
        self.levelCounterTier2 = [decoder decodeIntegerForKey:kMinimumLevelCounter2];
        self.levelCounterTier3 = [decoder decodeIntegerForKey:kMinimumLevelCounter3];
        self.levelCounterTier4 = [decoder decodeIntegerForKey:kMinimumLevelCounter4];
        
        // Time based achievements
        self.timeCounterTier1 = [decoder decodeIntegerForKey:kMinimumTimeCounter1];
        self.timeCounterTier2 = [decoder decodeIntegerForKey:kMinimumTimeCounter2];
        self.timeCounterTier3 = [decoder decodeIntegerForKey:kMinimumTimeCounter3];
        self.timeCounterTier4 = [decoder decodeIntegerForKey:kMinimumTimeCounter4];
        
        if (debugFlag) {
            NSLog(@"AchievementManager -- initWithCoder");
            NSLog(@"ScoreCounterTier1 -- %ld", (long)scoreCounterTier1);
            NSLog(@"LevelCounterTier1 -- %ld", (long)levelCounterTier1);
            NSLog(@"TimeCounterTier1 -- %ld", (long)timeCounterTier1);
        }
        
    }
    return self;
}

@end
