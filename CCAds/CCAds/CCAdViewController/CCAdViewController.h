//
//  CCAdViewController.h
//  TEST
//
//  Created by Charles Cliff on 9/26/14.
//  Copyright (c) 2014 Charles Cliff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

typedef NS_ENUM(NSInteger, CCAdPosition) {
    CCAdPositionBottom = 1,
    CCAdPositionTop = 2
};

@interface CCAdViewController : UIViewController <ADBannerViewDelegate, ADInterstitialAdDelegate>
{
    ADInterstitialAd *interstitial;
}

@property (nonatomic, strong) ADBannerView *adView;

@property (nonatomic, assign) CCAdPosition adPosition;

@property (nonatomic, assign) BOOL showingIAD;

@property (nonatomic, assign) BOOL debugFlag;
@property (nonatomic, assign) BOOL showInterstitialAds;
@property (nonatomic, assign) BOOL showBannerAds;

- (BOOL) presentInterlude;


@end