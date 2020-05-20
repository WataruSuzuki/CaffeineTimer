//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by WataruSuzuki on 2016/03/17.
//  Copyright © 2016年 WataruSuzuki. All rights reserved.
//

import UIKit
import NotificationCenter
import CaffeineTimerEmbedded

class TodayViewController: UIViewController,
    GaugeTimeHelperDelegate,
    NCWidgetProviding
{
        
    @IBOutlet weak var segmentedControlForGauge: UISegmentedControl!
    @IBOutlet weak var labelRemainValue: UILabel!
    
    private let helper = GaugeTimeHelper.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        updateGaugeTimeHelperDelegate()
        segmentedControlForGauge.setTitle(
            GaugeTimeHelper.GaugeDispType.caffeine.getGaugeDispTypeTitle(),
            forSegmentAt: GaugeTimeHelper.GaugeDispType.caffeine.rawValue)
        segmentedControlForGauge.setTitle(
            GaugeTimeHelper.GaugeDispType.time.getGaugeDispTypeTitle(),
            forSegmentAt: GaugeTimeHelper.GaugeDispType.time.rawValue)
        
        self.labelRemainValue.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateGaugeDispType()
        //updateTimerCaffeineGauge()
        helper.startCountTimerCaffeineGauge()
        helper.loadRemainGauge()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        helper.stopCountTimerCaffeineGauge()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    private func updateTimerCaffeineGauge() {
        //print(#function)
        //myGaugeTimerUtilities.calculateRemainValues(Float(CaffeineValue.MIN_CAFFEINE_DAY))
        
        // Set value for gauge view
        if GaugeTimeHelper.GaugeDispType.caffeine.rawValue != segmentedControlForGauge.selectedSegmentIndex {
            self.labelRemainValue.text = helper.getTimeLeftsValue()
        } else {
            if #available(iOS 10.0, *) {
                let attrUnitText = NSMutableAttributedString(string: " mg")
                attrUnitText.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 27)], range: NSMakeRange(0, attrUnitText.length))

                let valueAttrText = NSMutableAttributedString(string: String(Int(helper.velocity)))
                valueAttrText.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: self.labelRemainValue.font.pointSize)], range: NSMakeRange(0, valueAttrText.length))
                
                valueAttrText.append(attrUnitText)
                self.labelRemainValue.attributedText = valueAttrText
            } else {
                self.labelRemainValue.text = String(Int(helper.velocity)) + " mg"
            }
        }
//        print(self.labelRemainValue.text!)
    }
    
    private func updateGaugeTimeHelperDelegate() {
        guard helper.delegates["TodayWidget"] == nil else {
            return
        }
        helper.delegates["TodayWidget"] = self
    }
    
    private func updateGaugeDispType() {
        guard let ud = UserDefaults(suiteName: "group.jp.co.JchanKchan.CaffeineTimer"),
              let selectedIndex = ud.object(forKey: "GaugeType") as? Int else {
            return
        }
        segmentedControlForGauge.selectedSegmentIndex = selectedIndex
    }
    
    // MARK: - GaugeTimeHelperDelegate
    func updateTimerRemain() {
        updateTimerCaffeineGauge()
    }

    // MARK: - Action
    @IBAction func changeSegmentGauge(_ sender: AnyObject) {
        if let segmentedControl:UISegmentedControl = sender as? UISegmentedControl {
            UserDefaults(suiteName: "group.jp.co.JchanKchan.CaffeineTimer")!.set(segmentedControl.selectedSegmentIndex, forKey: "GaugeType")
            updateGaugeDispType()
        }
    }
}
