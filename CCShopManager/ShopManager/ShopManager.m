//
//  ShopeManager.m
//  TumbleBall
//
//  Created by Charles Cliff on 11/23/14.
//  Copyright (c) 2014 ElysiumEngineering. All rights reserved.
//

#import "ShopManager.h"
#import "GameManager.h"

@implementation ShopManager

//----------------------------------------------------------------------------------------------
#pragma mark - Singleton

+ (ShopManager*) sharedShopManager
{
//    NSLog(@"sharedShopManager");

    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        sharedInstance = [[self alloc] init];
        sharedInstance = [self loadInstance];
    });
    return sharedInstance;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Init

+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath)
    {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"shopdata"];
    }
    return filePath;
}

+(instancetype)loadInstance
{
//    NSLog(@"loadInstance");

    NSData* decodedData = [NSData dataWithContentsOfFile: [ShopManager filePath]];
    if (decodedData)
    {
        ShopManager* shopData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return shopData;
    }
    
    return [[ShopManager alloc] init];
}

- (ShopManager*) init
{
    if( [super init] )
    {
        [self loadPlist];
    }
    return self;
}

#pragma mark Loading from Plist

- (void) loadPlist
{
    // Load the input PList
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ShopItems" ofType:@"plist"];
    self.itemDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    //    NSLog(@"loadPlist");
    //    NSLog(@"PLIST Dictionary Size: %lu", (unsigned long)[self.itemDictionary count]);
}

//----------------------------------------------------------------------------------------------
#pragma mark - Saving Data

-(void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[ShopManager filePath] atomically:YES];
//    NSLog(@"ShopManager - save");
}

//----------------------------------------------------------------------------------------------
#pragma mark - Get Current Item Data

-(NSString*) getCurrentSpriteImage
{
    NSDictionary *currentItemDictionary = [self.itemDictionary objectForKey:
                                           [NSString stringWithFormat:@"%li", (long)[[GameManager sharedGameManager] getCurrentCharacterIndex]]];
    return [currentItemDictionary objectForKey:kImageKey];
}

//----------------------------------------------------------------------------------------------
#pragma mark - NSCoding

#define kItemStatusDicitonaryKey @"kItemStatusDicitonaryKey"

- (void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.unlockedStatusDictionary
                   forKey:kItemStatusDicitonaryKey];
}

- (id)initWithCoder:(NSCoder *)decoder
{
//    NSLog(@"initWithCoder");

    self = [self init];
    if (self)
    {
        self.unlockedStatusDictionary = [decoder decodeObjectForKey:kItemStatusDicitonaryKey];
      
    }
    return self;
}
@end
