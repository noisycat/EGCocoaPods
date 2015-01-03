//
//  ShopeManager.h
//  TumbleBall
//
//  Created by Charles Cliff on 11/23/14.
//  Copyright (c) 2014 ElysiumEngineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopManager : NSObject <NSCoding>

#define kIDKey                   @"KIDKEY"
#define kNameKey                 @"KNAMEKEY"
#define kImageKey                @"KIMAGEKEY"
#define kUnLockDescriptionKey    @"KUNLOCKDESCRIPTIONKEY"
#define kLockDescriptionKey      @"KLOCKDESCRIPTIONKEY"

@property (nonatomic, strong) NSMutableDictionary *unlockedStatusDictionary;
@property (nonatomic, strong) NSMutableDictionary *itemDictionary;

//----------------------------------------------------------------------------------------------
#pragma mark - Singleton

+(ShopManager*) sharedShopManager;

//----------------------------------------------------------------------------------------------
#pragma mark - Init

+(NSString*)filePath;
+(instancetype)loadInstance;
-(ShopManager*) init;
-(void)save;

- (void) loadPlist;

-(NSString*) getCurrentSpriteImage;

@end
