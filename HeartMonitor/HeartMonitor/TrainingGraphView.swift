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

    var heartRateValues: [UInt32] =
        [100, 130, 140, 135, 138, 143, 152, 160, 168, 175, 169, 163] {
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
        return Int(ceil(Double(heartRateValues.count + 1) / 2.0))
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
                CGFloat(self.heartRateValues[i] - self.heartRateLevels.rest) / heartRateRange
            return self.topMargin + (1.0 - heartRateLevel) * heartRateRange
        }

        let x0 = leftMargin
        let dx = (rect.width - 2 * leftMargin) / CGFloat(2 * maxTimeValue)

        graphPath.move(to: CGPoint(x: x0, y: heartRateY(0)))
        for i in 1..<heartRateValues.count {
            graphPath.addLine(to: CGPoint(x: x0 + CGFloat(i) * dx, y: heartRateY(i)))
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
