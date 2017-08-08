//
//  PlusMinusButton.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 8/7/17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

@IBDesignable
class PlusMinusButton: UIButton {

    @IBInspectable var plus: Bool = false
    @IBInspectable var color: UIColor = UIColor.blue

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1.0
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        color.setStroke()
        context.setLineWidth(1.0)

        let width = rect.width
        let heigth = rect.height
        let delta = 0.2 * width

        context.move(to: CGPoint(x: delta, y: heigth / 2))
        context.addLine(to: CGPoint(x: width - delta, y: heigth / 2))

        if plus {
            context.move(to: CGPoint(x: width / 2, y : delta))
            context.addLine(to: CGPoint(x: width / 2, y: heigth - delta))
        }

        context.strokePath()
    }

}
