//
//  GaugeTimerUtilities.swift
//  CaffeineTimer
//
//  Created by WataruSuzuki on 2016/03/14.
//  Copyright © 2016年 WataruSuzuki. All rights reserved.
//

import UIKit

public protocol GaugeTimeHelperDelegate: class {
    func updateTimerRemain()
}

public class GaugeTimeHelper: NSObject {
    
    public static var sharedInstance: GaugeTimeHelper = {
        return GaugeTimeHelper()
    }()
    private override init() {}
    
    let TIME_DELAY_1SECOND = 1.0
    let timeDelta: Double = 1.0
    let fuelTimeDelta = Double(1.0/48)
    var updateTimer: Timer!
    var fuelTimer: Timer?
    var nextValue: Float = 0.0

    public var velocity: Float = 0.0
    public var timeLefts: Int = 0
    public var nextFillTime: Int = 0
    
    public var delegates = [String: GaugeTimeHelperDelegate]()
    
    public func loadRemainGauge() {
        if let timeUpDate: Date = UserDefaults(suiteName: "group.jp.co.JchanKchan.CaffeineTimer")!.object(forKey: "TimeUp") as? Date {
            nextFillTime = Int(timeUpDate.timeIntervalSince(Date()))
            if 0 > nextFillTime {
                nextFillTime = 0
            }
            timeLefts = nextFillTime
            velocity = Float(CaffeineValue.CAFFEINE_PER_DRINK) / Float(CaffeineValue.HOUR_CAFFEINE_PER_DRINK) * Float(nextFillTime)
        }
    }
    
    public func saveNextFillTime() {
        nextFillTime += Int(CaffeineValue.HOUR_CAFFEINE_PER_DRINK)
        timeLefts = nextFillTime
        UserDefaults(suiteName: "group.jp.co.JchanKchan.CaffeineTimer")!.set(Date(timeIntervalSinceNow: TimeInterval(nextFillTime)), forKey: "TimeUp")
    }
    
    //public func startCountTimerCaffeineGauge(sender: AnyObject, senderSelector:Selector) {
    public func startCountTimerCaffeineGauge() {
        if nil == self.updateTimer {
            let delay = TIME_DELAY_1SECOND * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.updateTimer = Timer.scheduledTimer(timeInterval: self.timeDelta, target: self, selector: #selector(GaugeTimeHelper.calculateRemainValues), userInfo: nil, repeats: true)
            })
        }
    }
    
    public func stopCountTimerCaffeineGauge() {
        if self.updateTimer != nil && self.updateTimer!.isValid {
            self.updateTimer.invalidate()
            self.updateTimer = nil
        }
        delegates.removeAll()
    }
    
    public func fuelCaffeineGaugeTimer(_ sender: AnyObject, senderSelector:Selector) {
        if self.fuelTimer != nil && self.fuelTimer!.isValid {
            let controller = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("processing_caffeine", comment: ""), preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            sender.present(controller, animated: true, completion: nil)
        } else {
            nextValue = velocity + Float(CaffeineValue.CAFFEINE_PER_DRINK)
            if nextValue > Float(CaffeineValue.MAX_CAFFEINE_DAY) {
                nextValue = Float(CaffeineValue.MAX_CAFFEINE_DAY)
            }
            
            stopCountTimerCaffeineGauge()
            self.fuelTimer = Timer.scheduledTimer(timeInterval: fuelTimeDelta, target: sender, selector: senderSelector, userInfo: nil, repeats: true)
        }
    }
    
    public func isFueledToNextValue() ->Bool {
        if velocity > nextValue {
            velocity = nextValue
            nextValue = 0.0
            self.fuelTimer!.invalidate()
            return true
        }
        return false
    }
    
    public func getTimeLeftsValue() ->String {
        let hours = timeLefts / 3600
        let minutes = timeLefts % 3600 / 60
        let seconds = timeLefts % 3600 % 60
        
        return String(format: "%02d:%02d:%02d", arguments: [hours, minutes, seconds])
    }
    
    //public func calculateRemainValues(minValue: Float) {
    @objc public func calculateRemainValues() {
        let minValue = Float(CaffeineValue.MIN_CAFFEINE_DAY)
        timeLefts -= 1
        if 0 > timeLefts {
            timeLefts = 0
        }
        
        // Calculate velocity
        velocity -= Float(CaffeineValue.CAFFEINE_PER_DRINK) / Float(CaffeineValue.HOUR_CAFFEINE_PER_DRINK)
        if velocity < minValue {
            velocity = minValue
        }
        
        //print("velocity = \(velocity)")
        //print("timeLefts = \(timeLefts)")
        delegates.forEach({ $0.value.updateTimerRemain() })
    }
    
    public enum GaugeDispType : Int {
        case caffeine = 0,
        time,
        max
        
        public func getGaugeDispTypeTitle() -> String {
            switch self {
            case GaugeDispType.caffeine:
                return NSLocalizedString("your_caffeine", comment: "")
            case GaugeDispType.time:
                return NSLocalizedString("time_left", comment: "")
            default:
                return ""
            }
        }
        public func getGaugeDispTypeUnit() -> String {
            switch self {
            case GaugeDispType.caffeine:
                return NSLocalizedString("caffeine_unit_mg", comment: "")
            case GaugeDispType.time:
                return NSLocalizedString("time_left", comment: "")
            default:
                return ""
            }
        }
    }
}
