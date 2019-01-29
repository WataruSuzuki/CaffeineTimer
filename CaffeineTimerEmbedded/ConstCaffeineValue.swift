//
//  ConstCaffeineValue.swift
//  CaffeineTimer
//
//  Created by WataruSuzuki on 2016/01/18.
//  Copyright © 2016年 WataruSuzuki. All rights reserved.
//

import Foundation

public struct CaffeineValue {
    public static let MIN_CAFFEINE_DAY : Int = 0
    public static let MAX_CAFFEINE_DAY : Int = 400
    #if DEBUG_SWIFT
    public static let HOUR_CAFFEINE_PER_DRINK: TimeInterval = 60//1 minutes
    #else
    public static let HOUR_CAFFEINE_PER_DRINK: TimeInterval = 14400//4 hours(4 * 60 * 60)
    #endif
    public static let CAFFEINE_PER_DRINK: Int = 130
}
