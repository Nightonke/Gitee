//
//  VHVisualEffectView.swift
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/7.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

import Cocoa

@objc class VHVisualEffectView: NSVisualEffectView {

    override init(frame frameRect: NSRect) {
        tintColor = .clear
        super.init(frame:frameRect)
    }

    required init?(coder: NSCoder) {
        tintColor = .clear
        super.init(coder: coder)
    }

    var tintColor: NSColor {
        didSet {
            layer?.sublayers?.first(where: { $0.name == "ClearCopyLayer" })?.backgroundColor = tintColor.cgColor
        }
    }

}
