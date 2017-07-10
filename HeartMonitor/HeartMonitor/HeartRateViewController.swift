//
//  FirstViewController.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 30.06.17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

class HeartRateViewController: UIViewController {
    @IBOutlet fileprivate weak var heartRateValueLabel: UILabel!
    @IBOutlet fileprivate weak var heartRateView: HeartRateView!
    @IBOutlet fileprivate weak var deviceInfoTextView: UITextView!
    @IBOutlet fileprivate weak var btHrmSearchActivityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var btHrmStatusLabel: UILabel!
    @IBOutlet fileprivate weak var btHrmStatusStackView: UIStackView!
    @IBOutlet fileprivate weak var batteryLevelLabel: UILabel!

    private let dataSource = HeartRateDataSource()

    fileprivate var pulseTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        batteryLevelLabel.layer.cornerRadius = 18.0
        batteryLevelLabel.clipsToBounds = true
        batteryLevelLabel.text = ""

        dataSource.delegate = self
        dataSource.loadBluetooth()
    }

    func doHeartBit() {
        let layer = heartRateView.layer

        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = NSNumber(value: 1.0)
        pulseAnimation.toValue = NSNumber(value: 1.1)

        pulseAnimation.duration = 30.0 / Double(dataSource.heartRate)
        pulseAnimation.repeatCount = 1
        pulseAnimation.autoreverses = true
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)

        layer.add(pulseAnimation, forKey: "scale")
    }

    fileprivate func text(btStatus: BTStatus) -> String {
        switch btStatus {
        case .off:
            return "BT is turned off"
        case .searching:
            return "Looking for BT heart rate monitor"
        case .ready:
            return ""
        case .switchBT:
            return "Please turn BT off and on again"
        }
    }

    fileprivate func color(forBatteryLevel level: Float) -> UIColor {
        switch level {
        case 0..<0.3:
            return UIColor.red
        case 0.3..<0.7:
            return UIColor.yellow
        case 0.7...1:
            return UIColor.green
        default:
            return UIColor.black
        }
    }

}

extension HeartRateViewController: HeartRateDelegate {

    func updated(deviceInfo: String) {
        deviceInfoTextView.text = deviceInfo
    }

    func updated(heartRate: UInt16) {
        heartRateValueLabel.text = heartRate == 0 ? "--" : "\(heartRate)"
        pulseTimer?.invalidate()

        guard heartRate > 0 else { return }
        pulseTimer = Timer.scheduledTimer(timeInterval:  60.0 / Double(heartRate),
                                          target: self,
                                          selector: #selector(HeartRateViewController.doHeartBit),
                                          userInfo: nil,
                                          repeats: true)
    }

    func updated(batteryLevel: UInt8) {
        batteryLevelLabel.backgroundColor = color(forBatteryLevel: Float(batteryLevel) / 100.0)
        batteryLevelLabel.text = "\(batteryLevel)%"
    }

    func updated(btStatus: BTStatus) {
        btHrmStatusLabel.text = text(btStatus: btStatus)
        btHrmStatusStackView.isHidden = btStatus == .ready
        
        if [BTStatus.searching, BTStatus.switchBT].contains(btStatus) {
            btHrmSearchActivityIndicator.startAnimating()
        } else {
            btHrmSearchActivityIndicator.stopAnimating()
        }
    }

}

