//
//  StartStopButton.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 7/10/17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

@IBDesignable
class StartStopButton: UIButton {

    @IBInspectable var start: Bool = true

    private let startFromColor = UIColor(colorLiteralRed: 40.0 / 255.0, green: 255.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
    private let startToColor = UIColor(colorLiteralRed: 169.0 / 255.0, green: 255.0 / 255.0, blue: 205.0 / 255.0, alpha: 1.0)
    private let stopFromColor = UIColor(colorLiteralRed: 255.0 / 255.0, green: 35.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)
    private let stopToColor = UIColor(colorLiteralRed: 255.0 / 255.0, green: 153.0 / 255.0, blue: 156.0 / 255.0, alpha: 1.0)

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {

        let fromColor = start ? startFromColor : stopFromColor
        let toColor = start ? startToColor : stopToColor
        guard let context = UIGraphicsGetCurrentContext(),
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                 colors: [fromColor.cgColor, toColor.cgColor] as CFArray,
                                 locations: [0.0, 1.0])
              else { return }

        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)

        let path = CGPath(ellipseIn: rect, transform: nil)
        context.addPath(path)
        context.clip()

        let delta = 0.2 * rect.size.width
        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: 0, y: rect.size.height),
                                   end: CGPoint(x: rect.size.width - delta, y: delta),
                                   options: .drawsAfterEndLocation)

        let innerWidth = 0.8 * rect.size.width
        let innerPath = UIBezierPath(ovalIn: CGRect(x: (rect.size.width - innerWidth) / 2.0,
                                                    y: (rect.size.width - innerWidth) / 2.0,
                                                    width: innerWidth, height: innerWidth))
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.white.cgColor)
        innerPath.stroke()

    }


}
