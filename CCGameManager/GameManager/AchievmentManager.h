//
//  TBAchievmentManager.h
//  TumbleBall
//
//  Created by Charles Cliff on 11/23/14.
//  Copyright (c) 2014 ElysiumEngineering. All rights reserved.
//

#define kKeyAchievementType @"KEY_ACHIEVEMENT_TYPE"

#define kAchievmentTypeReachScore           @"SCORE"
#define kAchievmentTypeReachLevel           @"LEVEL"
#define kAchievmentTypeTime                 @"TIME"

#define kAchievmentTypeRepeatScore          @"REPEAT_SCORE"
#define kAchievmentTypeRepeatLevel          @"REPEAT_LEVEL"
#define kAchievmentTypeRepeatTime           @"REPEAT_TIME"


#define kKeyID                      @"KEY_ID"
#define kKeyAchievementTitle        @"KEY_ACHIEVEMENT_TITLE"
#define kKeyScore                   @"KEY_SCORE"
#define kKeyLevel                   @"KEY_LEVEL"

#define kKeyValue                   @"KEY_VALUE"
#define kKeyRepeated                @"KEY_REPEATED"


#define kTier1  @"TIER_1"
#define kTier2  @"TIER_2"
#define kTier3  @"TIER_3"
#define kTier4  @"TIER_4"

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint32_t, kAchievementTier)
{
    kAchievementTier1 = 1,
    kAchievementTier2 = 2,
    kAchievementTier3 = 3,
    kAchievementTier4 = 4,
};

@protocol AchievementManagerDelegate <NSObject>

@optional

- (void) didUpdateScoreAchievementForTier:(kAchievementTier) inputTier;
- (void) didUpdateLevelAchievementForTier:(kAchievementTier) inputTier;
- (void) didUpdateTimeAchievementForTier:(kAchievementTier) inputTier;

- (void) didUpdateRepeatScoreAchievementForTier:(kAchievementTier) inputTier WithPercentComplete:(float) percentComplete;
- (void) didUpdateRepeatLevelAchievementForTier:(kAchievementTier) inputTier WithPercentComplete:(float) percentComplete;
- (void) didUpdateRepeatTimeAchievementForTier:(kAchievementTier) inputTier WithPercentComplete:(float) percentComplete;

@end

@interface AchievmentManager : NSObject <NSCoding>
{
    id <AchievementManagerDelegate> delegate;
}
@property (retain) id delegate;

@property (nonatomic, assign) NSInteger scoreCounterTier1;
@property (nonatomic, assign) NSInteger scoreCounterTier2;
@property (nonatomic, assign) NSInteger scoreCounterTier3;
@property (nonatomic, assign) NSInteger scoreCounterTier4;

@property (nonatomic, assign) NSInteger levelCounterTier1;
@property (nonatomic, assign) NSInteger levelCounterTier2;
@property (nonatomic, assign) NSInteger levelCounterTier3;
@property (nonatomic, assign) NSInteger levelCounterTier4;

@property (nonatomic, assign) NSInteger timeCounterTier1;
@property (nonatomic, assign) NSInteger timeCounterTier2;
@property (nonatomic, assign) NSInteger timeCounterTier3;
@property (nonatomic, assign) NSInteger timeCounterTier4;

- (void) resolveTimeAchievement;
- (void) resolveLevelAchievement;
- (void) resolveScoreAchievement;

- (void) resolveRepeatedTimeAchievement;
- (void) resolveRepeatedScoreAchievement;
- (void) resolveRepeatedLevelAchievement __deprecated;

-(void) printState;

@end
