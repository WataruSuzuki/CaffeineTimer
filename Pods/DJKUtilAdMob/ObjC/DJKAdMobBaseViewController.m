//
//  AdBaseViewController.m
//  WallpaperResizer
//
//  Created by 鈴木 航 on 2016/08/23.
//  Copyright © 2016年 鈴木 航. All rights reserved.
//

#import "DJKAdMobBaseViewController.h"

@interface DJKAdMobBaseViewController ()

@property (nonatomic) DJKUtilAdMob *utilAdMob;

@end

@implementation DJKAdMobBaseViewController

NSString * const Key_iPad = @"iPad";
NSString * const Key_iPhone = @"iPhone";

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if DEBUG
    PACConsentInformation.sharedInstance.debugIdentifiers = [DJKUtilAdMob md5WithString];
    
    // Geography appears as in EEA for debug devices.
    PACConsentInformation.sharedInstance.debugGeography = PACDebugGeographyEEA;
    
    // Geography appears as not in EEA for debug devices.
    //PACConsentInformation.sharedInstance.debugGeography = PACDebugGeographyNotEEA;
    
    //Uncommented if you reset consent status
    PACConsentInformation.sharedInstance.consentStatus = PACConsentStatusUnknown;
#endif
    self.currentPersonalizedAdConsentStatus =
    PACConsentInformation.sharedInstance.consentStatus;
    if (!self.checkConfirmPersonalizedAdConsent
        || self.currentPersonalizedAdConsentStatus != PACConsentStatusUnknown) {
        [self allocDJKUtilAdMob];
        return;
    }
    
    [PACConsentInformation.sharedInstance
     requestConsentInfoUpdateForPublisherIdentifiers:self.publisherIdArrays
     completionHandler:^(NSError *_Nullable error) {
         if (error) {
             // Consent info update failed.
         } else {
             // Consent info update succeeded. The shared PACConsentInformation
             // instance has been updated.
             
             if (PACConsentInformation.sharedInstance.requestLocationInEEAOrUnknown) {
                 [self collectPersonalizedAdsConsent];
             } else {
                 [self allocDJKUtilAdMob];
             }
         }
         self.personalizedAdConsentInformationUpdateHandler(error);
     }];
}

- (void)collectPersonalizedAdsConsent
{
    PACConsentForm *form = [[PACConsentForm alloc] initWithApplicationPrivacyPolicyURL:self.privacyURL];
    form.shouldOfferPersonalizedAds = self.shouldOfferPersonalizedAds;
    form.shouldOfferNonPersonalizedAds = self.shouldOfferNonPersonalizedAds;
    form.shouldOfferAdFree = self.shouldOfferAdFree;
    
    [form loadWithCompletionHandler:^(NSError *_Nullable error) {
        NSLog(@"Load complete. Error: %@", error);
        
        if (error) {
            // Handle error.
        } else {
            // Load successful.
            self.currentPersonalizedAdConsentStatus =
            PACConsentInformation.sharedInstance.consentStatus;
            [self allocDJKUtilAdMob];
        }
        [form presentFromViewController:self dismissCompletion:self.personalizedAdConsentFormDismissCompletionHandler];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)allocDJKUtilAdMob
{
    self.utilAdMob = [[DJKUtilAdMob alloc] init];
    if (self.currentPersonalizedAdConsentStatus == PACConsentStatusNonPersonalized) {
        self.utilAdMob.additionalParameters = @{@"npa": @"1"};
    }
}

- (GADRewardBasedVideoAd *)createAndLoadAdMobReward:(NSString *)key
                                             sender:(UIViewController *)sender
{
    return [self.utilAdMob createAndLoadAdMobReward:key withSender:sender];
}

- (GADInterstitial *)createAndLoadAdMobInterstitial:(NSString *)key
                                             sender:(UIViewController *)sender
{
    return [self.utilAdMob createAndLoadAdMobInterstitial:key withSender:sender];
}

- (void)addAdMobBannerView:(NSString *)key
{
    self.admobBannerView = [self.utilAdMob createAdMobBannerView:key withViewController:self withSender:self];
    [self.view addSubview:self.admobBannerView];
    [self.admobBannerView loadRequest:[[[DJKUtilAdMob alloc] init] createGADRequest]];
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    self.admobBannerView.hidden = NO;
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    self.admobBannerView.hidden = YES;
}

@end
