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
    @IBOutlet fileprivate weak var btHrmStartSearchButton: UIButton!

    @IBOutlet fileprivate weak var batteryLevelLabel: UILabel!
    @IBOutlet fileprivate weak var batteryLevelStackView: UIStackView!

    @IBOutlet fileprivate weak var trainingStackView: UIStackView!
    @IBOutlet fileprivate weak var startButton: StartStopButton!
    @IBOutlet fileprivate weak var stopButton: StartStopButton!
    @IBOutlet fileprivate weak var trainingTimeLabel: UILabel!
    @IBOutlet fileprivate weak var showTrainingDataButton: UIButton!

    @IBOutlet fileprivate weak var heartRateLevelView: HeartRateLevelView!
    @IBOutlet fileprivate weak var minHeartRateLabel: UILabel!
    @IBOutlet fileprivate weak var maxHeartRateLabel: UILabel!
    @IBOutlet fileprivate weak var minFatBurnHeartRateLabel: UILabel!
    @IBOutlet fileprivate weak var maxFatBurnHeartRateLabel: UILabel!

    @IBOutlet fileprivate weak var minFatBurnCenterXConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var maxFatBurnCenterXConstraint: NSLayoutConstraint!

    private let dataSource = HeartRateDataSource()
    private let settingsDataSource = SettingsDataSource.shared

    fileprivate var pulseTimer: Timer?
    fileprivate var minHeartRate: UInt32 = 80
    fileprivate var maxHeartRate: UInt32 = 200

    private var trainingTimer: Timer?
    private var saveDataTimer: Timer?
    private var startTrainingTime: Date?
    private var trainingDuration: TimeInterval = 0
    private var currentTraining: Training?


    // MARK: View Controller methods

    override func viewDidLoad() {
        super.viewDidLoad()

        showStartSearchButton(true)

        batteryLevelLabel.layer.cornerRadius = 18.0
        batteryLevelLabel.clipsToBounds = true
        batteryLevelLabel.text = ""
        batteryLevelStackView.isHidden = true

        heartRateLevelView.level = 0

        stopButton.isHidden = true
        showTrainingDataButton.isHidden = true

        dataSource.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        minHeartRate = settingsDataSource.restHeartRate
        maxHeartRate = settingsDataSource.maxHeartRate

        minHeartRateLabel.text = String(minHeartRate)
        maxHeartRateLabel.text = String(maxHeartRate)
        minFatBurnHeartRateLabel.text = String(settingsDataSource.minFatBurnHeartRate)
        maxFatBurnHeartRateLabel.text = String(settingsDataSource.maxFatBurnHeartRate)

        let baseWidth = heartRateLevelView.bounds.size.width
        let relativeMin =
            CGFloat(settingsDataSource.minFatBurnHeartRate - minHeartRate) / CGFloat(maxHeartRate - minHeartRate)
        let relativeMax = CGFloat(settingsDataSource.maxFatBurnHeartRate - minHeartRate) / CGFloat(maxHeartRate - minHeartRate)

        minFatBurnCenterXConstraint.constant = relativeMin * baseWidth
        maxFatBurnCenterXConstraint.constant = relativeMax * baseWidth
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let trainingDataVC
            = segue.destination as? TrainingDataViewController else { return }
        trainingDataVC.training = currentTraining
    }

    // MARK: Actions

    @objc fileprivate func doHeartBit() {
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

    @objc fileprivate func updateTrainingTimer() {
        trainingDuration += 1
        trainingTimeLabel.text = timeString(forTimeInterval: trainingDuration)
    }

    @objc fileprivate func saveTrainingData() {
        guard let currentTraining = currentTraining else { return }
        DataStorageManager.shared.trainingsManager?
            .addMeasurement(UInt32(dataSource.heartRate),
                            duration: UInt32(trainingDuration),
                            to: currentTraining)
    }

    @IBAction fileprivate func startButtonPressed(_ sender: Any) {
        let trainingOngoing = trainingTimer?.isValid ?? false
        trainingTimer?.invalidate()
        saveDataTimer?.invalidate()

        if trainingOngoing {
            startButton.setTitle("Resume", for: .normal)
        } else {
            startButton.setTitle("Pause", for: .normal)
            if startTrainingTime == nil {
                startTrainingTime = Date()
                trainingTimeLabel.text = timeString(forTimeInterval: 0)
                stopButton.isHidden = false
                stopButton.setNeedsDisplay()
                
                currentTraining =
                    DataStorageManager.shared.trainingsManager?.createTraining()
                showTrainingDataButton.isHidden = false
            }

            trainingTimer =
                Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(HeartRateViewController.updateTrainingTimer),
                                     userInfo: nil,
                                     repeats: true)

            saveDataTimer =
                Timer.scheduledTimer(timeInterval: 30.0,
                                     target: self,
                                     selector: #selector(HeartRateViewController.saveTrainingData),
                                     userInfo: nil,
                                     repeats: true)
        }
    }


    @IBAction fileprivate func stopButtonPressed(_ sender: Any) {
        trainingTimer?.invalidate()
        trainingTimer = nil
        startTrainingTime = nil
        trainingDuration = 0
        startButton.setTitle("Start", for: .normal)
        stopButton.isHidden = true

        dataSource.stopBluetooth()

        showStartSearchButton(true)
        performSegue(withIdentifier: "showTrainingResults", sender: sender)
    }

    @IBAction fileprivate func btHrmStartSearchButtonPressed(_ sender: Any) {
        dataSource.loadBluetooth()
        showStartSearchButton(false)
    }

    // MARK: Helpers

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
        case 0..<0.1:
            return UIColor.red
        case 0.1..<0.5:
            return UIColor.yellow
        case 0.5...1:
            return UIColor.green
        default:
            return UIColor.black
        }
    }

    fileprivate func timeString(forTimeInterval interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds - hours * 3600) / 60
        let seconds = totalSeconds - hours * 3600 - minutes * 60
        return "\(timeString(forTimeUnit: hours)):\(timeString(forTimeUnit: minutes)):\(timeString(forTimeUnit: seconds))"
    }

    fileprivate func timeString(forTimeUnit unit: Int) -> String {
        return "\(unit < 10 ? "0" : "")\(unit)"
    }

    fileprivate func showStartSearchButton(_ show: Bool) {
        btHrmStatusLabel.isHidden = show
        if show {
            btHrmSearchActivityIndicator.stopAnimating()
        } else {
            btHrmSearchActivityIndicator.startAnimating()
        }

        btHrmStartSearchButton.isHidden = !show
        trainingStackView.isHidden = show
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

        heartRateLevelView.level = UInt32(heartRate) < minHeartRate
            ? 0
            : CGFloat(UInt32(heartRate) - minHeartRate) / CGFloat(maxHeartRate - minHeartRate)
    }

    func updated(batteryLevel: UInt8) {
        batteryLevelLabel.backgroundColor = color(forBatteryLevel: Float(batteryLevel) / 100.0)
        batteryLevelLabel.text = "\(batteryLevel)%"

        batteryLevelStackView.isHidden = batteryLevel > 50
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

