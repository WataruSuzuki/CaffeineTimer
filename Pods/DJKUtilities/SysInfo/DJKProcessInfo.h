//
//  DJKProcessInfo.h
//  DJKUtilities
//
//  Created by 鈴木 航 on 2015/08/04.
//  Copyright (c) 2015年 鈴木 航. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJKProcessInfo : NSProcessInfo

- (BOOL)isGreaterThanOrEqual:(int)majorVer minor:(int)minorVer patch:(int)patchVer;

@end
