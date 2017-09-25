//
//  TrainingsListViewController.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 9/22/17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

class TrainingsListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private var trainings: [Training] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Trainings"

        trainings = DataStorageManager.shared.trainingsManager?.trainings() ?? []
        trainings = trainings.filter { $0.duration > 0 }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let trainingDataVC = segue.destination as? TrainingDataViewController else {
                return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        trainingDataVC.training = trainings[indexPath.row]
    }

}

extension TrainingsListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "TrainingCell", for: indexPath)
        cell.textLabel?.textColor = UIColor(red: 107.0 / 255.0,
                                            green: 160.0 / 255.0,
                                            blue: 232.0 / 255.0,
                                            alpha: 1.0)

        let training = trainings[indexPath.row]

        cell.textLabel?.text =
            "\(TrainingDataSource.text(forDate: training.dateTimeStart ?? Date())), " +
            "\(TrainingDataSource.text(forTimeInSeconds: UInt32(training.duration)))"
        return cell
    }

}

extension TrainingsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
