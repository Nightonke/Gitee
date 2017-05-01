//
//  Extensions.swift
//  VHGithubNotifier
//
//  Created by Apollo Zhu on 4/30/17.
//  Copyright © 2017 黄伟平. All rights reserved.
//

extension Description {

    fileprivate var fontSize: CGFloat {
        get {
            return font.pointSize
        }
        set {
            font = NSUIFont(name: font.fontName, size: newValue) ?? font
        }
    }

    fileprivate var width: CGFloat {
        return text!.size(attributes: [NSFontAttributeName:font]).width
    }

}

@objc class VHPieChartView: PieChartView {

    override func draw(_ rect: CGRect) {
        if chartDescription?.textAlign == .center {
            let max = bounds.width - chartDescription!.xOffset * 2
            let cur = chartDescription!.width
            if cur > max {
                chartDescription!.fontSize *= max / cur
            }

            chartDescription!.position =
                CGPoint(x: bounds.midX,
                        y: bounds.maxY
                            - legend.yOffset
                            - legend.neededHeight
                            - chartDescription!.yOffset
                            - chartDescription!.font.lineHeight
                            - 20)
        } else {
            chartDescription?.position = nil
        }

        super.draw(rect)
    }
    
}

