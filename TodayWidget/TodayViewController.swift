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
    GaugeTimerUtilDelegate,
    NCWidgetProviding
{
        
    @IBOutlet weak var segmentedControlForGauge: UISegmentedControl!
    @IBOutlet weak var labelRemainValue: UILabel!
    
    let myGaugeTimerUtilities = GaugeTimerUtilities.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        updateGaugeTimerUtilDelegate()
        segmentedControlForGauge.setTitle(GaugeTimerUtilities.GaugeDispType.caffeine.getGaugeDispTypeTitle(), forSegmentAt: GaugeTimerUtilities.GaugeDispType.caffeine.rawValue)
        segmentedControlForGauge.setTitle(GaugeTimerUtilities.GaugeDispType.time.getGaugeDispTypeTitle(), forSegmentAt: GaugeTimerUtilities.GaugeDispType.time.rawValue)
        
        self.labelRemainValue.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateGaugeDispType()
        //updateTimerCaffeineGauge()
        myGaugeTimerUtilities.startCountTimerCaffeineGauge()
        myGaugeTimerUtilities.loadRemainGauge()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        myGaugeTimerUtilities.stopCountTimerCaffeineGauge()
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
    
    func updateTimerCaffeineGauge() {
        //print(#function)
        //myGaugeTimerUtilities.calculateRemainValues(Float(CaffeineValue.MIN_CAFFEINE_DAY))
        
        // Set value for gauge view
        if GaugeTimerUtilities.GaugeDispType.caffeine.rawValue == segmentedControlForGauge.selectedSegmentIndex {
            if #available(iOS 10.0, *) {
                let attrUnitText = NSMutableAttributedString(string: " mg")
                attrUnitText.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 27)], range: NSMakeRange(0, attrUnitText.length))

                let valueAttrText = NSMutableAttributedString(string: String(Int(myGaugeTimerUtilities.velocity)))
                valueAttrText.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: self.labelRemainValue.font.pointSize)], range: NSMakeRange(0, valueAttrText.length))
                
                valueAttrText.append(attrUnitText)
                self.labelRemainValue.attributedText = valueAttrText
            } else {
                self.labelRemainValue.text = String(Int(myGaugeTimerUtilities.velocity)) + " mg"
            }
        } else {
            self.labelRemainValue.text = myGaugeTimerUtilities.getTimeLeftsValue()
        }
//        print(self.labelRemainValue.text!)
    }
    
    func updateGaugeTimerUtilDelegate() {
        if nil == myGaugeTimerUtilities.delegateWidget {
            myGaugeTimerUtilities.delegateWidget = self
        }
    }
    
    func updateGaugeDispType() {
        guard let selectedIndex = UserDefaults(suiteName: "group.jp.co.JchanKchan.CaffeineTimer")!.object(forKey: "GaugeType") as? Int else{
            return
        }
        segmentedControlForGauge.selectedSegmentIndex = selectedIndex
    }
    
    // MARK: - GaugeTimerUtilDelegate
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
