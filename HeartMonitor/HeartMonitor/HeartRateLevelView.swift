//
//  HeartRateLevelView.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 8/12/17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

@IBDesignable
class HeartRateLevelView: UIView {

    @IBInspectable var level: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }

    private let colors = [UIColor.blue,
                          UIColor.green,
                          UIColor.yellow,
                          UIColor.orange,
                          UIColor.red]

    override func draw(_ rect: CGRect) {
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: colors.map { $0.cgColor } as CFArray,
                                  locations: nil),
            let context = UIGraphicsGetCurrentContext() else { return }

        let cornerRadius = rect.height / 2
        let path = CGPath(roundedRect: rect,
                          cornerWidth: cornerRadius,
                          cornerHeight: cornerRadius,
                          transform: nil)
        context.addPath(path)

        UIColor(white: 0.7, alpha: 1.0).setFill()
        context.fillPath()

        let gradientPath = UIBezierPath()
        let maxX = rect.width * level
        gradientPath.move(to: CGPoint(x: maxX, y: 0))
        gradientPath.addLine(to: CGPoint(x: cornerRadius, y: 0))
        gradientPath.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
                            radius: cornerRadius,
                            startAngle: 0,
                            endAngle: CGFloat.pi / 2,
                            clockwise: false)
        gradientPath.addLine(to: CGPoint(x: maxX, y: rect.height))
        gradientPath.close()
        context.addPath(gradientPath.cgPath)
        context.clip()

        let delta: CGFloat = 30.0
        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: delta, y: rect.height / 2),
                                   end: CGPoint(x: rect.width - delta, y: rect.height / 2),
                                   options: [.drawsBeforeStartLocation,
                                             .drawsAfterEndLocation])
    }

}
