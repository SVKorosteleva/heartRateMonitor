//
//  FirstViewController.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 30.06.17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

class HeartRateViewController: UIViewController {
    @IBOutlet weak var heartRateValueLabel: UILabel!
    @IBOutlet weak var heartRateView: HeartRateView!
    @IBOutlet weak var deviceInfoTextView: UITextView!
    @IBOutlet weak var btHrmSearchActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btHrmStatusLabel: UILabel!
    @IBOutlet weak var btHrmStatusStackView: UIStackView!

    private let dataSource = HeartRateDataSource()

    fileprivate var pulseTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

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

