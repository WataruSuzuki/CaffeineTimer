//
//  AdBaseViewController.h
//  WallpaperResizer
//
//  Created by 鈴木 航 on 2016/08/23.
//  Copyright © 2016年 鈴木 航. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJKUtilAdMob.h"

extern NSString * const Key_iPad;
extern NSString * const Key_iPhone;

@interface DJKAdMobBaseViewController : UIViewController <
    GADRewardBasedVideoAdDelegate,
    GADInterstitialDelegate,
    GADBannerViewDelegate
>

@property (nonatomic) GADBannerView* admobBannerView;
@property (nonatomic) GADInterstitial* admobInterstitial;
@property (nonatomic) GADRewardBasedVideoAd* admobRewardedVideo;
@property (nonatomic) NSArray* publisherIdArrays;
@property (nonatomic) PACDismissCompletion personalizedAdConsentFormDismissCompletionHandler;
@property (nonatomic) PACConsentInformationUpdateHandler personalizedAdConsentInformationUpdateHandler;
@property (nonatomic) BOOL shouldOfferPersonalizedAds;
@property (nonatomic) BOOL shouldOfferNonPersonalizedAds;
@property (nonatomic) BOOL shouldOfferAdFree;
@property (nonatomic) NSURL *privacyURL;
@property (nonatomic) PACConsentStatus currentPersonalizedAdConsentStatus;
@property (nonatomic) BOOL checkConfirmPersonalizedAdConsent;

- (GADRewardBasedVideoAd *)createAndLoadAdMobReward:(NSString *)key
                                             sender:(UIViewController *)sender;
- (GADInterstitial *)createAndLoadAdMobInterstitial:(NSString *)key
                                             sender:(UIViewController *)sender;
//- (void)addAdMobBannerView:(NSDictionary *)keys;
- (void)addAdMobBannerView:(NSString *)key;

@end
