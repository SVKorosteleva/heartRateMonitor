//
//  SecondViewController.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 30.06.17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet private weak var ageTextField: UITextField!
    @IBOutlet private weak var restingHeartRateTextField: UITextField!
    @IBOutlet private weak var minHeartRateTextField: UITextField!
    @IBOutlet private weak var maxHeartRateTextField: UITextField!
    @IBOutlet private weak var maxHeartRateLabel: UILabel!
    @IBOutlet private weak var heartRateReseveLabel: UILabel!
    @IBOutlet private weak var backgroundView: UIView!

    private var dataSource = SettingsDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.delegate = self
        fillData()

        ageTextField.addTarget(self,
                               action: #selector(SettingsViewController.textFieldDidChange(_:)),
                               for: .editingChanged)
        restingHeartRateTextField
            .addTarget(self,
                       action: #selector(SettingsViewController.textFieldDidChange(_:)),
                       for: .editingChanged)

        let tapGestureRecognizer =
            UITapGestureRecognizer(target: self,
                                   action: #selector(SettingsViewController.backgroundTapGesture))
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
    }

    fileprivate func fillData() {
        ageTextField.text = String(dataSource.age)
        restingHeartRateTextField.text = String(dataSource.restHeartRate)
        minHeartRateTextField.text = String(dataSource.minFatBurnHeartRate)
        maxHeartRateTextField.text = String(dataSource.maxFatBurnHeartRate)

        maxHeartRateLabel.text = String(dataSource.maxHeartRate)
        heartRateReseveLabel.text = String(dataSource.heartRateReserve)
    }

    // MARK: Action handlers

    @IBAction private func plusMinusButtonTap(_ sender: PlusMinusButton) {
        if sender.tag == 1 {
            dataSource.maxFatBurnHeartRate(increment: sender.plus)
        } else {
            dataSource.minFatBurnHeartRate(increment: sender.plus)
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text,
            let newValue = UInt32(text) else { return }

        if textField == ageTextField {
            dataSource.update(age: newValue)
        } else if textField == restingHeartRateTextField {
            dataSource.update(restHeartRate: newValue)
        }

    }

    @objc private func backgroundTapGesture() {
        ageTextField.resignFirstResponder()
        restingHeartRateTextField.resignFirstResponder()
    }

}

extension SettingsViewController: SettingsDataDelegate {

    func heartRatesUpdated() {
        fillData()
    }

}


