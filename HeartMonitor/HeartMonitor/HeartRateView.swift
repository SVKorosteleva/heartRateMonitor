//
//  HeartRateView.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 30.06.17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

@IBDesignable
class HeartRateView: UIView {
    @IBInspectable var fromColor: UIColor = UIColor(red: 92.0 / 255.0,
                                           green: 255.0 / 255.0,
                                           blue: 217.0 / 255.0,
                                           alpha: 1.0)
    @IBInspectable var toColor: UIColor = UIColor(red: 202.0 / 255.0,
                                         green: 252.0 / 255.0,
                                         blue: 248.0 / 255.0,
                                         alpha: 1.0)

    override func draw(_ rect: CGRect) {
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: [fromColor.cgColor, toColor.cgColor] as CFArray,
                                  locations: [0.0, 1.0]),
            let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        let path = CGPath(ellipseIn: rect, transform: nil)
        context.addPath(path)
        context.clip()

        let delta = 0.2 * rect.size.width
        context.drawLinearGradient(gradient,
                                    start: CGPoint(x: 0.0, y: rect.size.height),
                                    end: CGPoint(x: rect.size.width - delta, y: delta),
                                    options: .drawsAfterEndLocation)

    }

}
