//
//  CCAdViewController.m
//  TEST
//
//  Created by Charles Cliff on 9/26/14.
//  Copyright (c) 2014 Charles Cliff. All rights reserved.
//

#import "CCAdViewController.h"

@interface CCAdViewController ()

- (void)createBanner;
- (void)addBanner;

- (void) sizeBanner;
- (void) positionBanner;

@end

@implementation CCAdViewController

@synthesize adPosition;

@synthesize debugFlag;
@synthesize showInterstitialAds;
@synthesize showBannerAds;

//----------------------------------------------------------------------------------------------
#pragma mark - Loading the View
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the Default Position of the Banner View
    self.adPosition = CCAdPositionTop;
    
    // Set up the Interstitial Ad
    [self cycleInterstitial];
    self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.debugFlag) {
        NSLog(@"ViewDidAppear");
    }

    [self.adView removeFromSuperview];
    self.adView = nil;
    
    if (self.showInterstitialAds) {
        if ([self presentInterlude]) {
            
        } else {
            [self performSelector:@selector(createBanner) withObject:nil afterDelay:2.0];
        }
    } else {
        [self performSelector:@selector(createBanner) withObject:nil afterDelay:2.0];
    }
    
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    if (self.debugFlag)
        NSLog(@"viewDidDisappear");
    
    // Clean Up Any Refernces to the AdBannerView
    [self.adView removeFromSuperview];
    self.adView = nil;
}
//----------------------------------------------------------------------------------------------
#pragma mark - Necessary

- (BOOL) shouldAutorotate
{
    return YES;
}

//----------------------------------------------------------------------------------------------
#pragma mark - Banner
- (void)createBanner
{
    if (self.showBannerAds) {
        // Create the iAd
        if (self.debugFlag) {
            NSLog(@"CC createBanner -- Creating iAd");
        }
        
        // iOS 6 and above uses a new initializer, which Apple say we should use if available
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            self.adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        } else {
            // iOS 5 will need to use the old method
            self.adView = [[ADBannerView alloc] init];
        }
        
        self.adView.delegate = self;
        self.adView.hidden = YES;
        
        // Position the Ad
        [self addBanner];
        
        if (self.debugFlag) {
            NSLog(@"CC createBanner -- Adding iAd to view.");
        }
        
        [self.view insertSubview:self.adView atIndex:0];
        
        if (self.debugFlag) {
            NSLog(@"Final Banner Position X: %f",self.adView.frame.origin.x);
            NSLog(@"Final Banner Position Y: %f",self.adView.frame.origin.y);
            NSLog(@"Final Banner Size X: %f",self.adView.frame.size.width);
            NSLog(@"Final Banner Size Y: %f",self.adView.frame.size.height);
        }
    }
}

- (void)addBanner
{
    // Set the Size and Position of the ADBannerView
    if (self.debugFlag) {
        NSLog(@"CC addBanner -- Setting the Size of the ADBannerView");
    }
    
    // Size the AdBannerView
    [self sizeBanner];
    
    // Position the AdBannerView
    [self positionBanner];
}

- (void)removeBannerPermanently:(BOOL)permanent
{
    // When `permanently` is NO
    // This method simply hides the banner from view - the banner will show again when the next ad request is fired...
    // ... This can be 1-5 minutes for iAd, and 2 minutes for AdMob (this can be changed in your AdMob account)
    
    // When `permanently` is YES
    // This method will set the banner's view to nil and remove the banner completely from the container view
    // A new banner will not be shown unless you call restartAds.
    if (TRUE)
    {
        self.showingIAD = NO;
        CGRect bannerFrame = self.adView.frame;
        if(self.adPosition == CCAdPositionBottom)
        {
            bannerFrame.origin.y = [[UIScreen mainScreen] bounds].size.height;
        }
        else if(self.adPosition == CCAdPositionTop)
        {
            bannerFrame.origin.y = 0 - self.adView.frame.size.height;
        }
        self.adView.frame = bannerFrame;
        self.adView.hidden = YES;
        
        [self.view sendSubviewToBack:self.adView];
        
        if (permanent && self.adView.bannerViewActionInProgress==NO)
        {
            self.adView.delegate = nil;
            [self.adView removeFromSuperview];
            self.adView = nil;
            if (self.debugFlag) {
                NSLog(@"CC removeBannerPermanently -- Permanently removed iAd from view.");
            }
        }
        else
        {
            if (self.debugFlag) {
                NSLog(@"CC removeBannerPermanently -- Temporarily hiding iAd off screen.");
            }
        }
    }
}

- (void) sizeBanner
{
    if (self.debugFlag) {
        NSLog(@"CC sizeBanner -- Banner Size Width: %f",self.adView.frame.size.width);
        NSLog(@"CC sizeBanner -- Banner Size Height: %f",self.adView.frame.size.height);
    }
    
    CGRect bannerFrame = self.adView.frame;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    // If configured to support iOS 5, then we need to set the currentContentSizeIdentifier in order to resize the banner properly.
    self.adView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
    
    
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation]);
    
    if (isPortrait){
        self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    }
    else{
        self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
#else
    // If configured to support iOS >= 6.0 only, then we want to avoid currentContentSizeIdentifier as it is deprecated.
    // Fortunately all we need to do is ask the banner for a size that fits into the layout area we are using.
    // At this point in this method contentFrame=self.view.bounds, so we'll use that size for the layout.
    bannerFrame.size = [self.adView sizeThatFits:self.view.bounds.size];
#endif
    
//    self.adView.frame = bannerFrame;
    [self.adView setFrame:bannerFrame];
    if (self.debugFlag) {
        NSLog(@"CC sizeBanner -- Banner Size Width: %f",self.adView.frame.size.width);
        NSLog(@"CC sizeBanner -- Banner Size Height: %f",self.adView.frame.size.height);
    }
}

- (void) positionBanner
{
    if (self.debugFlag) {
        NSLog(@"CC positionBanner");
    }
    
    CGRect bannerFrame = CGRectMake(self.adView.frame.origin.x, self.adView.frame.origin.y, self.adView.frame.size.width, self.adView.frame.size.width);
    
    if( self.adPosition == CCAdPositionBottom ){
        
        bannerFrame.origin.y = CGRectGetMaxY(self.view.bounds) - self.adView.frame.size.height;
        
        // We will have to compensate for the Navigation Bar is Present
        bannerFrame.origin.y = bannerFrame.origin.y - self.tabBarController.tabBar.frame.size.height;
    }
    else if( self.adPosition == CCAdPositionTop ){
        
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        CGRect statusBarWindowRect = [self.view.window convertRect:statusBarFrame fromWindow: nil];
        CGRect statusBarViewRect = [self.view convertRect:statusBarWindowRect fromView: nil];
        bannerFrame.origin.y = statusBarViewRect.size.height;
        
        // We will have to compensate for the Navigation Bar is Present
        if(!self.navigationController.navigationBarHidden)
            bannerFrame.origin.y = bannerFrame.origin.y + self.navigationController.navigationBar.frame.size.height;
    }
    self.adView.frame = bannerFrame;
    
    if (self.debugFlag) {
        NSLog(@"CC positionBanner -- Banner Position X: %f",self.adView.frame.origin.x);
        NSLog(@"CC positionBanner -- Banner Position Y: %f",self.adView.frame.origin.y);
    }
}
//----------------------------------------------------------------------------------------------
#pragma mark - Orientation Methods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.debugFlag) {
        NSLog(@"Orient the Ad");
    }
//    // Resize the Banner
    [self sizeBanner];
    [self positionBanner];
}
//----------------------------------------------------------------------------------------------
#pragma mark - iAd Delegate Methods

- (void)bannerViewWillLoadAd:(ADBannerView *)banner
{
    // We don't need to execute any code before an iAd is about to be displayed
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (self.debugFlag) {
        NSLog(@"CC bannerViewDidLoadAd -- New iAd received.");
    }
    
    [self addBanner];
    
    self.showingIAD = YES;
    self.adView.hidden = NO;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self layoutAds];
                     }
                     completion:^(BOOL finished){
                         // Ensure view isn't behind the container and untappable
                         if (finished) [self.view bringSubviewToFront:self.adView];
                     }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.debugFlag) {
        NSLog(@"CC bannerView:didFailToReceiveAdWithError: -- Failed to receive iAd. %@", error.localizedDescription);
    }
    
    // Ensure view is hidden off screen
    if (self.adView.frame.origin.y >= 0 && self.adView.frame.origin.y < self.view.frame.size.height)
    {
        [self removeBannerPermanently:NO];
    }
    self.showingIAD = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutAds];
    }];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    if (self.debugFlag) {
        NSLog(@"CC bannerViewActionShouldBegin -- Tapped on an iAd.");
    }
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    if (self.debugFlag) {
        NSLog(@"CC bannerViewActionDidFinish -- Finished viewing iAd.");
    }
    // Nothing to do here
}


- (void)layoutAds
{
    if (self.debugFlag) {
        NSLog(@"CC layoutAds");
    }
    [self.view setNeedsLayout];
}
//----------------------------------------------------------------------------------------------
#pragma mark - ADInterstitialAd Management
- (void)cycleInterstitial
{
    if (self.debugFlag) {
        NSLog(@"cycleInterstitial");
    }
    // Clean up the old interstitial...
//    interstitial.delegate = nil;
    interstitial = nil;
    
    // and create a new interstitial. We set the delegate so that we can be notified of when
    interstitial = [[ADInterstitialAd alloc] init];
    interstitial.delegate = self;
}

- (BOOL)presentInterlude
{

    
    // If the interstitial managed to load, then we'll present it now.
    
    BOOL output = NO;
    
    if (interstitial.loaded) {
        
        if (self.debugFlag)
            NSLog(@"presentInterlude -- Ad Loaded");

        output = [self requestInterstitialAdPresentation];
        
        if (output) {
            [self.adView removeFromSuperview];
            self.adView = nil;
        }
    } else {
        if (self.debugFlag)
            NSLog(@"presentInterlude -- Ad Failed to Load");
    }
    [self cycleInterstitial];
    return output;
}

- (void) presentInterludeWithCompletionHandler:(void(^)(void))completion
{
    // If the interstitial managed to load, then we'll present it now.
    if (interstitial.loaded)
    {
        if (self.debugFlag) {
            NSLog(@"presentInterludeWithCompletionHandler -- Ad Loaded");
        }
        if (![self requestInterstitialAdPresentation]) {
            if (self.debugFlag)
                NSLog(@"Failed to Get Interstitial Presentation");
        }
    } else
    {
        if (self.debugFlag) {
            NSLog(@"presentInterludeWithCompletionHandler -- Ad Failed to Load");
        }
    }
    [self cycleInterstitial];
    
    // Call the Completion Block Handler
    completion();
}
//----------------------------------------------------------------------------------------------
#pragma mark - ADInterstitialViewDelegate methods

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    [self cycleInterstitial];
    [self performSelector:@selector(createBanner) withObject:nil afterDelay:2.0];
}

// This method will be invoked when an error has occurred attempting to get advertisement content.
// The ADError enum lists the possible error codes.
- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    if (self.debugFlag)
        NSLog(@"Interstitial Ad Did Fail");
    [self cycleInterstitial];
}


- (BOOL) requestInterstitialAdPresentation
{
    if (self.debugFlag)
        NSLog(@"requestInterstitialAdPresentation");
    return [super requestInterstitialAdPresentation];
}

@end
