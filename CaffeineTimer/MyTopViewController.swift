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
    GaugeTimeHelperDelegate,
    LMGaugeViewDelegate
{
    @IBOutlet weak var caffeineGaugeView: LMGaugeView!
    @IBOutlet weak var buttonAddCaffeine: MDButton!
    @IBOutlet weak var segmentedControlForGauge: UISegmentedControl!
    @IBOutlet weak var labelTimeLeft: UILabel!
    
    private let helper = GaugeTimeHelper.sharedInstance
    //let myHealthKitUtils = HealthKitUtils.sharedInstance
    private var shownTutorial = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure gauge view
        addHelperDelegate()
        initGaugeView()

        updateTimerCaffeineGauge()
        helper.startCountTimerCaffeineGauge()
        helper.loadRemainGauge()
        
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
        
        PurchaseService.shared.confirmConsent(
            publisherIds: [ServiceKeys.ADMOB_PUB_ID],
            //productId: ServiceKeys.UNLOCK_AD,
            privacyPolicyUrl: AppDelegate.privacyPolicyUrl, completion: { (confirmed) in
                if confirmed {
                    self.refreshAllAd()
                }
            }
        )
    }
    
    private func executeShortcutFuelGauge() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if #available(iOS 9.0, *) {
                if AppDelegate.ShortcutIdentifier.First.type == delegate.launchedShortcutItem?.type {
                    delegate.launchedShortcutItem = nil
                    helper.fuelCaffeineGaugeTimer(self, senderSelector: #selector(MyTopViewController.fuelGaugeTimer))
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
    
    private func getMyRedColor() -> UIColor {
        return UIColor(red: 255.0/255, green: 59.0/255, blue: 48.0/255, alpha: 1.0)
    }
    
    private func getMyGreenColor() -> UIColor {
        return UIColor(red: 11.0/255, green: 150.0/255, blue: 246.0/255, alpha: 1.0)
    }
    
    private func setupTutorialPopLabel() {
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
    
    private func initGaugeView() {
        self.caffeineGaugeView.minValue = CGFloat(CaffeineValue.MIN_CAFFEINE_DAY)
        self.caffeineGaugeView.maxValue = CGFloat(CaffeineValue.MAX_CAFFEINE_DAY)
        self.caffeineGaugeView.limitValues = [CGFloat(CaffeineValue.CAFFEINE_PER_DRINK * 2)]
        
        let bounds = UIScreen.main.bounds
        if 480 >= bounds.size.height {
            labelTimeLeft.font = UIFont.systemFont(ofSize: 60.0)
        }
        
        labelTimeLeft.isHidden = true
        caffeineGaugeView.valueTextColor = valueTextColor()
        segmentedControlForGauge.setTitle(GaugeTimeHelper.GaugeDispType.caffeine.getGaugeDispTypeTitle(), forSegmentAt: GaugeTimeHelper.GaugeDispType.caffeine.rawValue)
        segmentedControlForGauge.setTitle(GaugeTimeHelper.GaugeDispType.time.getGaugeDispTypeTitle(), forSegmentAt: GaugeTimeHelper.GaugeDispType.time.rawValue)
        self.caffeineGaugeView.unitOfMeasurement = GaugeTimeHelper.GaugeDispType.time.getGaugeDispTypeUnit()
        
        updateGaugeDispType()
    }
    
    private func valueTextColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
    
    private func updateGaugeDispType() {
        guard let ud = UserDefaults(suiteName: "group.jp.co.JchanKchan.CaffeineTimer"),
              let selectedIndex = ud.object(forKey: "GaugeType") as? Int else {
            return
        }
        segmentedControlForGauge.selectedSegmentIndex = selectedIndex
        if GaugeTimeHelper.GaugeDispType.time.rawValue == selectedIndex {
            labelTimeLeft.isHidden = false
            caffeineGaugeView.valueTextColor = caffeineGaugeView.backgroundColor
        } else {
            labelTimeLeft.isHidden = true
            caffeineGaugeView.valueTextColor = valueTextColor()
        }
        let selectedType = GaugeTimeHelper.GaugeDispType(rawValue: segmentedControlForGauge.selectedSegmentIndex)
        self.caffeineGaugeView.unitOfMeasurement = selectedType!.getGaugeDispTypeUnit()
    }
    
    // MARK: - GaugeTimeHelperDelegate
    func updateTimerRemain() {
        updateTimerCaffeineGauge()
    }
    
    private func updateTimerCaffeineGauge() {
        // Set value for gauge view
        self.caffeineGaugeView.value = CGFloat(helper.velocity)
        self.labelTimeLeft.text = helper.getTimeLeftsValue()
    }
    
    private func addHelperDelegate() {
        guard helper.delegates["MyTopView"] == nil else {
            return
        }
        helper.delegates["MyTopView"] = self
    }
    
    @objc func fuelGaugeTimer() {
        // Calculate velocity
        helper.velocity += Float(CaffeineValue.CAFFEINE_PER_DRINK) / 60
        self.labelTimeLeft.isHidden = true
        caffeineGaugeView.valueTextColor = valueTextColor()
        self.caffeineGaugeView.unitOfMeasurement = GaugeTimeHelper.GaugeDispType.caffeine.getGaugeDispTypeUnit()
        
        if helper.isFueledToNextValue() {
            
            removeOldFuelNotification()
            addHelperDelegate()
            helper.startCountTimerCaffeineGauge()
            helper.saveNextFillTime()
            setLocalNotification(NSLocalizedString("digestion_caffeine", comment: ""), notification_id: 1)
            HealthKitUtils.saveCaffeine()
            updateGaugeDispType()
            
            showAdMobInterstitial(rootViewController: self)
            return
        }
        
        // Set value for gauge view
        self.caffeineGaugeView.value = CGFloat(helper.velocity)
    }
    
    private func removeOldFuelNotification() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        } else {
            for notification in UIApplication.shared.scheduledLocalNotifications! {
                UIApplication.shared.cancelLocalNotification(notification)
            }
        }
    }
    
    private func setLocalNotification(_ alertBody: String, notification_id: Int) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Caffeine Timer"
            content.body = alertBody
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(helper.nextFillTime), repeats: false)
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
            notification.fireDate = Date(timeIntervalSinceNow: TimeInterval(helper.nextFillTime))
            notification.userInfo = ["notification_id": notification_id]
            
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    @objc func appWillEnterForeground(_ notification: Notification) {
        helper.loadRemainGauge()
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
        helper.fuelCaffeineGaugeTimer(self, senderSelector: #selector(MyTopViewController.fuelGaugeTimer))
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

