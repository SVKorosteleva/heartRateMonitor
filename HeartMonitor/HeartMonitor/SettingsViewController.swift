//
//  SecondViewController.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 30.06.17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet fileprivate weak var ageTextField: UITextField!
    @IBOutlet fileprivate weak var restingHeartRateTextField: UITextField!
    @IBOutlet private weak var minHeartRateTextField: UITextField!
    @IBOutlet private weak var maxHeartRateTextField: UITextField!
    @IBOutlet private weak var maxHeartRateLabel: UILabel!
    @IBOutlet private weak var heartRateReseveLabel: UILabel!
    @IBOutlet private weak var pickerView: UIPickerView!

    fileprivate var dataSource = SettingsDataSource.shared

    fileprivate let ageData: [UInt32] = Array(1...100)
    fileprivate let heartRateData: [UInt32] = Array(0...220)

    fileprivate var pickerHeartRate = false

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.delegate = self
        fillData()
        pickerView.isHidden = true
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

    @IBAction private func changeButtonTap(_ sender: UIButton) {
        pickerHeartRate = sender.tag == 1

        pickerView.reloadAllComponents()
        let value = pickerHeartRate ? dataSource.restHeartRate : dataSource.age
        if let index = pickerHeartRate
            ? heartRateData.index(of: value)
            : ageData.index(of: value) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        }
        pickerView.isHidden = false
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

extension SettingsViewController: UIPickerViewDataSource {

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return pickerHeartRate ? heartRateData.count : ageData.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

}

extension SettingsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return pickerHeartRate ? String(heartRateData[row]) : String(ageData[row])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let value = pickerHeartRate ? heartRateData[row] : ageData[row]
        let textField = pickerHeartRate ? restingHeartRateTextField : ageTextField

        textField?.text = String(value)

        if pickerHeartRate {
            dataSource.update(restHeartRate: value)
        } else {
            dataSource.update(age: value)
        }

        pickerView.isHidden = true
    }
}


