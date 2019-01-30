//
//  DJKUtilAdMob.h
//  DataUsageCat
//
//  Created by 鈴木 航 on 2015/02/21.
//  Copyright (c) 2015年 鈴木 航. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <PersonalizedAdConsent/PersonalizedAdConsent.h>

@interface DJKUtilAdMob : NSObject <GADInterstitialDelegate>

-(GADRewardBasedVideoAd *)createAndLoadAdMobReward:(NSString *)unitId
                                        withSender:(id)sender;
-(GADInterstitial *)createAndLoadAdMobInterstitial:(NSString *)unitId
                                        withSender:(id)sender;
-(GADBannerView *)createAdMobBannerView:(NSString *)unitId
                     withViewController:(UIViewController *)rootVC
                             withSender:(id)sender;
+(NSString *)md5WithString;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) GADRequest *createGADRequest;
@property(nonatomic, copy) NSDictionary *additionalParameters;

@end
