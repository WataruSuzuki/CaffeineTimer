//
//  DJKProcessInfo.m
//  DJKUtilities
//
//  Created by 鈴木 航 on 2015/08/04.
//  Copyright (c) 2015年 鈴木 航. All rights reserved.
//

#import "DJKProcessInfo.h"
#import <UIKit/UIKit.h>

@implementation DJKProcessInfo

- (BOOL)isGreaterThanOrEqual:(int)majorVer minor:(int)minorVer patch:(int)patchVer
{
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (8.0 <= systemVersion) {
        NSOperatingSystemVersion version = {majorVer, minorVer, patchVer};
        return [self isOperatingSystemAtLeastVersion:version];
    } else {
        float targetVersion = [[NSString stringWithFormat:@"%d.%d", majorVer, minorVer] floatValue];
        return (systemVersion >= targetVersion ? YES : NO);
    }
}

@end
