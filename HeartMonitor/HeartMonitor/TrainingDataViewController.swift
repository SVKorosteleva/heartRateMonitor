//
//  TrainingDataViewController.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 9/11/17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

class TrainingDataViewController: UIViewController {
    @IBOutlet private weak var trainingGraphView: TrainingGraphView!
    @IBOutlet private weak var trainingDurationLabel: UILabel!
    @IBOutlet private weak var trainingStartDateLabel: UILabel!
    @IBOutlet private weak var maxBPMLabel: UILabel!
    @IBOutlet private weak var minBPMLabel: UILabel!
    @IBOutlet private weak var avgBPMLabel: UILabel!
    @IBOutlet private weak var fatBuriningTimeLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!

    var training: Training!

    private var dataSource: TrainingDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = TrainingDataSource(training: training)

        trainingStartDateLabel.text =
            TrainingDataSource.text(forDate: training.dateTimeStart ?? Date())
        trainingDurationLabel.text = dataSource.durationText
        maxBPMLabel.text = String(dataSource.maxHeartRate)
        minBPMLabel.text = String(dataSource.minHeartRate)
        avgBPMLabel.text = String(dataSource.avgHeartRate)
        fatBuriningTimeLabel.text =
            "\(dataSource.fatBurnZoneTimeText) (\(dataSource.fatBurnZonePercent)%)"

        trainingGraphView.heartRateLevels =
            (rest: dataSource.settingsDataSource.restHeartRate,
             max: dataSource.settingsDataSource.maxHeartRate,
             minFatBurn: dataSource.settingsDataSource.minFatBurnHeartRate,
             maxFatBurn: dataSource.settingsDataSource.maxFatBurnHeartRate)
        trainingGraphView.heartRateValues =
            dataSource.heartRates
                .filter { $0.heartRate > SettingsDataSource.shared.restHeartRate }
        
        title = "Training"
        if navigationController != nil {
            closeButton.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction private func closeButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
