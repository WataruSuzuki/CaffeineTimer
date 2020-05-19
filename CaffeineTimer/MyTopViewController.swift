//
//  MyTopViewController.swift
//  CaffeineTimer
//
//  Created by WataruSuzuki on 2016/01/18.
//  Copyright © 2016年 WataruSuzuki. All rights reserved.
//

import UIKit
import HealthKit
import UserNotifications
import CaffeineTimerEmbedded
import LMGaugeView
import MaterialComponents.MaterialFeatureHighlight
import DJKPurchaseService

class MyTopViewController: HelpingMonetizeViewController,
    GaugeTimerUtilDelegate,
    LMGaugeViewDelegate
{
    @IBOutlet weak var caffeineGaugeView: LMGaugeView!
    @IBOutlet weak var buttonAddCaffeine: MDButton!
    @IBOutlet weak var segmentedControlForGauge: UISegmentedControl!
    @IBOutlet weak var labelTimeLeft: UILabel!
    
    let myGaugeTimerUtilities = GaugeTimerUtilities.sharedInstance
    //let myHealthKitUtils = HealthKitUtils.sharedInstance
    private var shownTutorial = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure gauge view
        updateGaugeTimerUtilDelegate()
        initGaugeView()

        updateTimerCaffeineGauge()
        myGaugeTimerUtilities.startCountTimerCaffeineGauge()
        myGaugeTimerUtilities.loadRemainGauge()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyTopViewController.appWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyTopViewController.appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupTutorialPopLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshAllAd()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //executeShortcutFuelGauge()
    }
    
    func executeShortcutFuelGauge() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if #available(iOS 9.0, *) {
                if AppDelegate.ShortcutIdentifier.First.type == delegate.launchedShortcutItem?.type {
                    delegate.launchedShortcutItem = nil
                    myGaugeTimerUtilities.fuelCaffeineGaugeTimer(self, senderSelector: #selector(MyTopViewController.fuelGaugeTimer))
                }
            }
        }
    }

    // MARK: - LMGaugeViewDelegate
    func gaugeView(_ gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        if let limit = caffeineGaugeView.limitValues.first as? CGFloat, limit < value {
            return getMyRedColor()
        }
        return getMyGreenColor()
    }
    
    func getMyRedColor()->UIColor {
        return UIColor(red: 255.0/255, green: 59.0/255, blue: 48.0/255, alpha: 1.0)
    }
    
    func getMyGreenColor()->UIColor {
        return UIColor(red: 11.0/255, green: 150.0/255, blue: 246.0/255, alpha: 1.0)
    }
    
    func setupTutorialPopLabel() {
        let highlightController = MDCFeatureHighlightViewController(highlightedView: buttonAddCaffeine) { (result) in
            
        }
        highlightController.bodyText = NSLocalizedString("tutorial_msg", comment: "")
        highlightController.bodyColor = UIColor.white
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.shownTutorial {
                self.present(highlightController, animated: true, completion: nil)
                self.shownTutorial = true
            }
        }
    }
    
    func initGaugeView() {
        self.caffeineGaugeView.minValue = CGFloat(CaffeineValue.MIN_CAFFEINE_DAY)
        self.caffeineGaugeView.maxValue = CGFloat(CaffeineValue.MAX_CAFFEINE_DAY)
        self.caffeineGaugeView.limitValues = [CGFloat(CaffeineValue.CAFFEINE_PER_DRINK * 2)]
        
        let bounds = UIScreen.main.bounds
        if 480 >= bounds.size.height {
            labelTimeLeft.font = UIFont.systemFont(ofSize: 60.0)
        }
        
        labelTimeLeft.isHidden = true
        caffeineGaugeView.valueTextColor = UIColor.black
        segmentedControlForGauge.setTitle(GaugeTimerUtilities.GaugeDispType.caffeine.getGaugeDispTypeTitle(), forSegmentAt: GaugeTimerUtilities.GaugeDispType.caffeine.rawValue)
        segmentedControlForGauge.setTitle(GaugeTimerUtilities.GaugeDispType.time.getGaugeDispTypeTitle(), forSegmentAt: GaugeTimerUtilities.GaugeDispType.time.rawValue)
        self.caffeineGaugeView.unitOfMeasurement = GaugeTimerUtilities.GaugeDispType.time.getGaugeDispTypeUnit()
        
        updateGaugeDispType()
    }
    
    func updateGaugeDispType() {
        guard let selectedIndex = UserDefaults(suiteName: "group.jp.co.JchanKchan.CaffeineTimer")!.object(forKey: "GaugeType") as? Int else{
            return
        }
        segmentedControlForGauge.selectedSegmentIndex = selectedIndex
        if GaugeTimerUtilities.GaugeDispType.time.rawValue == selectedIndex {
            labelTimeLeft.isHidden = false
            caffeineGaugeView.valueTextColor = caffeineGaugeView.backgroundColor
        } else {
            labelTimeLeft.isHidden = true
            caffeineGaugeView.valueTextColor = UIColor.black
        }
        let selectedType = GaugeTimerUtilities.GaugeDispType(rawValue: segmentedControlForGauge.selectedSegmentIndex)
        self.caffeineGaugeView.unitOfMeasurement = selectedType!.getGaugeDispTypeUnit()
    }
    
    // MARK: - GaugeTimerUtilDelegate
    func updateTimerRemain() {
        updateTimerCaffeineGauge()
    }
    
    func updateTimerCaffeineGauge() {
        //myGaugeTimerUtilities.calculateRemainValues(Float(self.caffeineGaugeView.minValue))
        
        // Set value for gauge view
        self.caffeineGaugeView.value = CGFloat(myGaugeTimerUtilities.velocity)
        self.labelTimeLeft.text = myGaugeTimerUtilities.getTimeLeftsValue()
    }
    
    func updateGaugeTimerUtilDelegate() {
        if nil == myGaugeTimerUtilities.delegateVC {
            myGaugeTimerUtilities.delegateVC = self
        }
    }
    
    @objc func fuelGaugeTimer() {
        // Calculate velocity
        myGaugeTimerUtilities.velocity += Float(CaffeineValue.CAFFEINE_PER_DRINK) / 60
        self.labelTimeLeft.isHidden = true
        caffeineGaugeView.valueTextColor = UIColor.black
        self.caffeineGaugeView.unitOfMeasurement = GaugeTimerUtilities.GaugeDispType.caffeine.getGaugeDispTypeUnit()
        
        if myGaugeTimerUtilities.isFueledToNextValue() {
            
            removeOldFuelNotification()
            updateGaugeTimerUtilDelegate()
            myGaugeTimerUtilities.startCountTimerCaffeineGauge()
            myGaugeTimerUtilities.saveNextFillTime()
            setLocalNotification(NSLocalizedString("digestion_caffeine", comment: ""), notification_id: 1)
            HealthKitUtils.saveCaffeine()
            updateGaugeDispType()
            
            showAdMobInterstitial(rootViewController: self)
            return
        }
        
        // Set value for gauge view
        self.caffeineGaugeView.value = CGFloat(myGaugeTimerUtilities.velocity)
    }
    
    func removeOldFuelNotification() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        } else {
            for notification in UIApplication.shared.scheduledLocalNotifications! {
                UIApplication.shared.cancelLocalNotification(notification)
            }
        }
    }
    
    func setLocalNotification(_ alertBody: String, notification_id: Int) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Caffeine Timer"
            content.body = alertBody
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(myGaugeTimerUtilities.nextFillTime), repeats: false)
            let requestIdentifier = "digestion_caffeine"
            
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) {
                (error_) in
                if let error = error_ {
                    print(error.localizedDescription)
                }
            }
        } else {
            let notification:UILocalNotification = UILocalNotification()
            //notification.alertTitle = "タイトル"
            notification.alertBody = alertBody
            notification.fireDate = Date(timeIntervalSinceNow: TimeInterval(myGaugeTimerUtilities.nextFillTime))
            notification.userInfo = ["notification_id": notification_id]
            
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    @objc func appWillEnterForeground(_ notification: Notification) {
        myGaugeTimerUtilities.loadRemainGauge()
        refreshAllAd()
        updateTimerCaffeineGauge()
    }
    
    @objc func appDidBecomeActive(_ notification: Notification) {
        executeShortcutFuelGauge()
    }
    
    private func refreshAllAd() {
        loadAdMobInterstitial(unitId: "ca-app-pub-3940256099942544/4411468910")
        addAdMobBannerView(unitId: "ca-app-pub-3940256099942544/2934735716", edge: .bottom)
    }
    
    // MARK: - Action
    @IBAction func tapCoffeeButton(_ sender: AnyObject) {
        shownTutorial = true
        myGaugeTimerUtilities.fuelCaffeineGaugeTimer(self, senderSelector: #selector(MyTopViewController.fuelGaugeTimer))
    }
    
    @IBAction func changeSegmentGauge(_ sender: AnyObject) {
        if let segmentedControl:UISegmentedControl = sender as? UISegmentedControl {
            UserDefaults(suiteName: "group.jp.co.JchanKchan.CaffeineTimer")!.set(segmentedControl.selectedSegmentIndex, forKey: "GaugeType")
            updateGaugeDispType()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //tutorialPopLabel.dismiss()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

