//
//  DJKUtilLocale.h
//  DJKUtilities
//
//  Created by 鈴木 航 on 2014/11/09.
//  Copyright (c) 2014年 鈴木 航. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJKUtilLocale : NSObject

extern NSString * const DATE_FORMAT_FOR_CSV;
extern NSString * const DATETIME_FORMAT_FOR_CSV;

+(BOOL)isLocaleJapanese;
+(NSString *)getFormatedDateStrByStyle:(NSDateFormatterStyle)style
                           withDateStr:(NSString *)dateStr;

@end
