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
    @IBOutlet private weak var maxBPMLabel: UILabel!
    @IBOutlet private weak var minBPMLabel: UILabel!
    @IBOutlet private weak var avgBPMLabel: UILabel!
    @IBOutlet private weak var fatBuriningTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction private func closeButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
