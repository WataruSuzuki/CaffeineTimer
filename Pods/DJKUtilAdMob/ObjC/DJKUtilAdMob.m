//
//  DJKUtilAdMob.m
//  DataUsageCat
//
//  Created by 鈴木 航 on 2015/02/21.
//  Copyright (c) 2015年 鈴木 航. All rights reserved.
//

#import "DJKUtilAdMob.h"
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>

@implementation DJKUtilAdMob

-(GADRewardBasedVideoAd *)createAndLoadAdMobReward:(NSString *)unitId
                                      withSender:(id)sender
{
    GADRewardBasedVideoAd *rewardedVideo = [GADRewardBasedVideoAd sharedInstance];
    rewardedVideo.delegate = sender;
#if DEBUG
    [rewardedVideo loadRequest:[self createGADRequest] withAdUnitID:@"ca-app-pub-3940256099942544/1712485313"];
#else
    [rewardedVideo loadRequest:[self createGADRequest] withAdUnitID:unitId];
#endif

    return rewardedVideo;
}

-(GADInterstitial *)createAndLoadAdMobInterstitial:(NSString *)unitId
                                        withSender:(id)sender
{
    GADInterstitial* interstitial = [[GADInterstitial alloc] initWithAdUnitID:unitId];
    interstitial.delegate = sender;
    
    [interstitial loadRequest:[self createGADRequest]];
    
    return interstitial;
}

-(GADBannerView *)createAdMobBannerView:(NSString *)unitId
                     withViewController:(UIViewController *)rootVC
                             withSender:(id)sender
{
    GADBannerView* admobBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    admobBannerView.translatesAutoresizingMaskIntoConstraints = NO;
    admobBannerView.adUnitID = unitId;
    admobBannerView.delegate = sender;
    admobBannerView.rootViewController = rootVC;
    admobBannerView.hidden = YES;
    
    return admobBannerView;
}

-(GADRequest *)createGADRequest
{
    GADRequest* admobReq = [GADRequest request];
    // Request test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made.
#if DEBUG
    admobReq.testDevices = @[kGADSimulatorID, [DJKUtilAdMob md5WithString]];
#endif
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = self.additionalParameters;
    [admobReq registerAdNetworkExtras:extras];
    
    return admobReq;
}

+(NSString *)md5WithString
{
    NSString *deviceId = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    const char *cStr = [deviceId UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}
@end
