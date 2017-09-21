//
//  TrainingGraphView.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 9/11/17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

typealias HeartRateLevels = (rest: UInt32, max: UInt32, minFatBurn: UInt32, maxFatBurn: UInt32)

@IBDesignable
class TrainingGraphView: UIView {
    override var bounds: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }

    var heartRateLevels: HeartRateLevels = (rest: 80, max: 200, minFatBurn: 140, maxFatBurn: 170) {
        didSet {
            setNeedsDisplay()
            updateHeartRateAxisLabels()
            updateLabelsPositioning()
        }
    }

    var heartRateValues: [HRMeasurement] =
        [HRMeasurement(heartRate: 100, seconds: 0),
         HRMeasurement(heartRate: 130, seconds: 30),
         HRMeasurement(heartRate: 140, seconds: 60),
         HRMeasurement(heartRate: 135, seconds: 90),
         HRMeasurement(heartRate: 138, seconds: 120),
         HRMeasurement(heartRate: 143, seconds: 150),
         HRMeasurement(heartRate: 152, seconds: 180),
         HRMeasurement(heartRate: 160, seconds: 200),
         HRMeasurement(heartRate: 168, seconds: 220),
         HRMeasurement(heartRate: 175, seconds: 250),
         HRMeasurement(heartRate: 169, seconds: 280),
         HRMeasurement(heartRate: 163, seconds: 300)] {
        didSet {
            setNeedsDisplay()
            updateTimeAxisLabels()
        }
    }

    @IBInspectable var mainAreaColor: UIColor = UIColor.red
    @IBInspectable var lineColor: UIColor = UIColor.white

    @IBOutlet private weak var maxHeartRateLabel: UILabel!
    @IBOutlet private weak var minHeartRateLabel: UILabel!
    @IBOutlet private weak var maxFatBurnLabel: UILabel!
    @IBOutlet private weak var minFatBurnLabel: UILabel!
    @IBOutlet private weak var timeAxisValue0Label:UILabel!
    @IBOutlet private weak var timeAxisValue1Label:UILabel!
    @IBOutlet private weak var timeAxisValue2Label:UILabel!
    @IBOutlet private weak var timeAxisValue3Label:UILabel!
    @IBOutlet private weak var timeAxisValue4Label:UILabel!
    @IBOutlet private weak var maxHeartRateTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var maxHeartRateTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var maxFatBurnTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var minFatBurnBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var minHeartRateBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var timeAxisTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var timeAxisLeadingConstraint: NSLayoutConstraint!

    private let topMargin: CGFloat = 40
    private let leftMargin: CGFloat = 30
    private let labelToLineMargin: CGFloat = 3
    private let cornerRadius: CGFloat = 20
    private let lineWidth: CGFloat = 1
    private let graphLineWidth: CGFloat = 2

    private var maxFatBurnY: CGFloat {
        let heartRateRange = heartRateLevels.max - heartRateLevels.rest
        let maxFatBurn =
            CGFloat(heartRateLevels.maxFatBurn - heartRateLevels.rest) / CGFloat(heartRateRange)
        return topMargin + (1.0 - maxFatBurn) * CGFloat(heartRateRange)
    }

    private var minFatBurnY: CGFloat {
        let heartRateRange = heartRateLevels.max - heartRateLevels.rest
        let minFatBurn =
            CGFloat(heartRateLevels.minFatBurn - heartRateLevels.rest) / CGFloat(heartRateRange)
        return topMargin + (1.0 - minFatBurn) * CGFloat(heartRateRange)
    }

    private var numberOfMinutes: Int {
        let maxSeconds =
            heartRateValues.sorted(by: { $0.seconds > $1.seconds}).first?.seconds ?? 0
        return Int(ceil(Double(maxSeconds) / 60.0))
    }

    private var maxTimeValue: Int {
        var result = numberOfMinutes
            + ((numberOfMinutes % 4 > 0) ? (4 - numberOfMinutes % 4) : 0)
        if result == 0 {
            result = 4
        }
        return result
    }

    override func draw(_ rect: CGRect) {

        let outerPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        mainAreaColor.setFill()
        outerPath.fill()

        strokeLine(at: rect.height - topMargin, width: rect.width, dashed: false)
        strokeLine(at: topMargin, width: rect.width, dashed: false)

        strokeLine(at: maxFatBurnY, width: rect.width, dashed: true)
        strokeLine(at: minFatBurnY, width: rect.width, dashed: true)

        guard heartRateValues.count > 0 else { return }

        let graphPath = UIBezierPath()

        let heartRateY = { [unowned self] (i: Int) -> CGFloat in
            let heartRateRange =
                CGFloat(self.heartRateLevels.max - self.heartRateLevels.rest)
            let heartRateLevel =
                CGFloat(self.heartRateValues[i].heartRate - self.heartRateLevels.rest) / heartRateRange
            return self.topMargin + (1.0 - heartRateLevel) * heartRateRange
        }

        let x0 = leftMargin
        let heartRateX = { [unowned self] (i: Int) -> CGFloat in
            let totalWidth = rect.width - 2 * self.leftMargin
            let xi =
                totalWidth * CGFloat(self.heartRateValues[i].seconds)
                    / (CGFloat(self.maxTimeValue) * 60.0)
            return x0 + xi
        }

        graphPath.move(to: CGPoint(x: x0, y: heartRateY(0)))
        for i in 1..<heartRateValues.count {
            graphPath.addLine(to: CGPoint(x: heartRateX(i), y: heartRateY(i)))
        }

        graphPath.lineWidth = graphLineWidth
        graphPath.stroke()

    }

    private func strokeLine(at y: CGFloat, width: CGFloat, dashed: Bool) {
        lineColor.setStroke()

        let line = UIBezierPath()
        line.move(to: CGPoint(x: leftMargin, y: y))
        line.addLine(to: CGPoint(x: width - leftMargin, y: y))
        if dashed {
            line.setLineDash([2.0, 2.0], count: 2, phase: 4.0)
        }
        line.lineWidth = lineWidth
        line.stroke()
    }

    private func updateHeartRateAxisLabels() {
        maxHeartRateLabel.text = String(heartRateLevels.max)
        minHeartRateLabel.text = String(heartRateLevels.rest)
        maxFatBurnLabel.text = String(heartRateLevels.maxFatBurn)
        minFatBurnLabel.text = String(heartRateLevels.minFatBurn)
    }

    private func updateTimeAxisLabels() {
        let timeDelta = maxTimeValue / 4

        timeAxisValue0Label.text = "0 min"
        timeAxisValue1Label.text = String(timeDelta)
        timeAxisValue2Label.text = String(2 * timeDelta)
        timeAxisValue3Label.text = String(3 * timeDelta)
        timeAxisValue4Label.text = String(maxTimeValue)

    }

    private func updateLabelsPositioning() {
        maxHeartRateTopConstraint.constant = topMargin + labelToLineMargin
        maxHeartRateTrailingConstraint.constant = leftMargin
        minHeartRateBottomConstraint.constant = topMargin + labelToLineMargin
        maxFatBurnTopConstraint.constant = maxFatBurnY + labelToLineMargin
        minFatBurnBottomConstraint.constant = minFatBurnY - labelToLineMargin
        timeAxisTopConstraint.constant = topMargin - labelToLineMargin
        timeAxisLeadingConstraint.constant = leftMargin
    }

}
