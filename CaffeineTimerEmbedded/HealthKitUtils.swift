//
//  HealthKitUtils.swift
//  CaffeineTimer
//
//  Created by WataruSuzuki on 2016/03/16.
//  Copyright © 2016年 WataruSuzuki. All rights reserved.
//

import UIKit
import HealthKit

public class HealthKitUtils: NSObject {

    public static var sharedInstance: HealthKitUtils = {
        return HealthKitUtils()
    }()
    private override init() {}
    
    private class func saveHealthStore(_ healthStore: HKHealthStore, sample: HKQuantitySample) {
        healthStore.save(sample, withCompletion: { (success, error_) -> Void in
            if let error = error_ {
                print(error.localizedDescription)
            } else {
                print("success health store");
            }
        })
    }
    
    private class func saveHealthValueWithUnit(_ unit: HKUnit! , type: HKQuantityType!, valueStr: String, completion: ((_ success: Bool, _ error: Error?) -> Void)) {
        let healthStore = HKHealthStore()
        let quantity = HKQuantity(unit: unit, doubleValue: Double(valueStr)!)
        
        let nowDate = Date()
        let sample = HKQuantitySample(type: type, quantity: quantity, start: nowDate, end: nowDate)
        
        let shareTypes: Set<HKSampleType> = [
            HKSampleType.quantityType(forIdentifier: .dietaryCaffeine)!
        ]
        let readTypes: Set<HKObjectType> = [
            type
        ]
        let authStatus = healthStore.authorizationStatus(for: type)
        
        if authStatus != .sharingAuthorized {
            healthStore.requestAuthorization(toShare: shareTypes, read: readTypes, completion: { (success, error_) -> Void in
                if let error = error_ {
                    print(error.localizedDescription)
                } else {
                    HealthKitUtils.saveHealthStore(healthStore, sample: sample)
                }
            })
            return
        }
        
        HealthKitUtils.saveHealthStore(healthStore, sample: sample)
    }
    
    public class func saveCaffeine() {
        let valueStr = String(CaffeineValue.CAFFEINE_PER_DRINK)
        let healthUnit = HKUnit.gramUnit(with: HKMetricPrefix.milli)
        let healthObjType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine)
        
        saveHealthValueWithUnit(healthUnit, type: healthObjType, valueStr: valueStr, completion: {
            success, error_ in
            
            if let error = error_ {
                print(error.localizedDescription)
            } else {
                print("success saveHealthValueWithUnit")
            }
        })
    }
    
}
